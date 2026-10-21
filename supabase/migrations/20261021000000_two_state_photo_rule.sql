-- Two cleaning states and a new evidence rule.
--
--   * `medio_limpio` is removed: estado_aula becomes ('limpio', 'sucio').
--     Existing medio_limpio rows (reportes.estado and aulas.estado_actual) become 'limpio'.
--   * Evidence rule inverted: a photo is required when a report is 'sucio' and is
--     optional for 'limpio'. A photo that is sent is still validated (aula folder, exists).
--
-- Postgres cannot drop a value from an enum, so the type is recreated and both columns
-- are converted in place. ALTER ... TYPE rewrites the two tables under an ACCESS EXCLUSIVE
-- lock; with 28 aulas and a small report history this is instantaneous. The conversion
-- happens during the table rewrite (no UPDATE statements), so the append-only guarantees
-- (revoked UPDATE/DELETE, no update policies) are unaffected and no insert trigger fires.
-- Run once as the table owner (postgres); the type block is skipped if already applied.

do $$
begin
	if exists (
		select 1
		from pg_enum e
		join pg_type t on t.oid = e.enumtypid
		join pg_namespace n on n.oid = t.typnamespace
		where n.nspname = 'public' and t.typname = 'estado_aula' and e.enumlabel = 'medio_limpio'
	) then
		alter type public.estado_aula rename to estado_aula_old;
		create type public.estado_aula as enum ('limpio', 'sucio');

		alter table public.aulas alter column estado_actual drop default;
		alter table public.aulas
			alter column estado_actual type public.estado_aula
			using (case estado_actual::text when 'medio_limpio' then 'limpio' else estado_actual::text end)::public.estado_aula;
		alter table public.aulas alter column estado_actual set default 'limpio';

		alter table public.reportes
			alter column estado type public.estado_aula
			using (case estado::text when 'medio_limpio' then 'limpio' else estado::text end)::public.estado_aula;

		drop type public.estado_aula_old;
	end if;
end
$$;

-- Evidence rule: photo required iff the report is 'sucio'. Everything else is unchanged
-- (aula lock, photo path normalization and ownership, storage existence, server timestamp).
create or replace function public.reportes_before_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
	-- Lock the aula row so concurrent reports for the same aula are serialized.
	perform 1
	from public.aulas a
	where a.id = new.aula_id
	for update;

	if not found then
		raise exception 'El aula % no existe.', new.aula_id
			using errcode = 'foreign_key_violation';
	end if;

	new.foto_path := nullif(btrim(new.foto_path), '');

	if new.estado = 'sucio' and new.foto_path is null then
		raise exception 'Se requiere una foto como evidencia al reportar el aula como sucia.'
			using errcode = 'check_violation', hint = 'evidencia_requerida';
	end if;

	if new.foto_path is not null then
		-- Evidence must live under the aula's folder and must actually exist.
		if new.foto_path not like new.aula_id::text || '/%' then
			raise exception 'La ruta de la foto no corresponde al aula.'
				using errcode = 'check_violation';
		end if;

		if not exists (
			select 1 from storage.objects o
			where o.bucket_id = 'evidencias' and o.name = new.foto_path
		) then
			raise exception 'La foto de evidencia no existe en el almacenamiento.'
				using errcode = 'check_violation';
		end if;
	end if;

	-- Server-side timestamp; clients cannot backdate reports.
	new.creado_en := now();
	return new;
end;
$$;

-- CREATE OR REPLACE keeps the function ACL; restate it so this file is self-describing.
revoke execute on function public.reportes_before_insert() from public, anon, authenticated;
