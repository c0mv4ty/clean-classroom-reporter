-- Admin-only previous-report data.
--
-- A previous report is context, not proof of who left a classroom dirty: the
-- system only knows who REPORTED the aula, not who occupied it.
--
-- Names live behind profiles RLS (a presidente only reads their own row), so
-- the data is exposed through two SECURITY DEFINER functions that check
-- public.is_admin() themselves. `profiles` RLS is left untouched.
--
-- "Previous report" = the immediately preceding report of the SAME aula,
-- ordered by creado_en and then id (deterministic tie-break).

-- ---------------------------------------------------------------------------
-- Previous report for a set of report ids (the page of the admin history)
-- ---------------------------------------------------------------------------
create or replace function public.admin_reportes_previos(p_ids uuid[])
returns table (
	reporte_id uuid,
	anterior_id uuid,
	anterior_usuario_id uuid,
	anterior_nombre text,
	anterior_estado public.estado_aula,
	anterior_creado_en timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
	if not public.is_admin() then
		raise exception 'Solo un administrador puede consultar los reportes anteriores.'
			using errcode = 'insufficient_privilege';
	end if;

	return query
	select r.id, p.id, p.usuario_id, pf.nombre, p.estado, p.creado_en
	from public.reportes r
	cross join lateral (
		select x.id, x.usuario_id, x.estado, x.creado_en
		from public.reportes x
		where x.aula_id = r.aula_id
			and (x.creado_en, x.id) < (r.creado_en, r.id)
		order by x.creado_en desc, x.id desc
		limit 1
	) p
	join public.profiles pf on pf.id = p.usuario_id
	where r.id = any (p_ids);
end;
$$;

-- ---------------------------------------------------------------------------
-- Summary: how many times each user's report was the last one before a sucio
-- report, with the time of the latest such sucio report. Optional aula filter.
-- ---------------------------------------------------------------------------
create or replace function public.admin_resumen_reporte_previo(p_aula_id integer default null)
returns table (
	anterior_usuario_id uuid,
	anterior_nombre text,
	veces bigint,
	ultima_vez timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
	if not public.is_admin() then
		raise exception 'Solo un administrador puede consultar el resumen de reportes anteriores.'
			using errcode = 'insufficient_privilege';
	end if;

	return query
	select p.usuario_id, pf.nombre, count(*)::bigint, max(r.creado_en)
	from public.reportes r
	cross join lateral (
		select x.usuario_id
		from public.reportes x
		where x.aula_id = r.aula_id
			and (x.creado_en, x.id) < (r.creado_en, r.id)
		order by x.creado_en desc, x.id desc
		limit 1
	) p
	join public.profiles pf on pf.id = p.usuario_id
	where r.estado = 'sucio'
		and (p_aula_id is null or r.aula_id = p_aula_id)
	group by p.usuario_id, pf.nombre
	order by count(*) desc, max(r.creado_en) desc, pf.nombre;
end;
$$;

-- Callable by signed-in users only; the functions refuse non-admins themselves.
revoke all on function public.admin_reportes_previos(uuid[]) from public, anon;
revoke all on function public.admin_resumen_reporte_previo(integer) from public, anon;
grant execute on function public.admin_reportes_previos(uuid[]) to authenticated;
grant execute on function public.admin_resumen_reporte_previo(integer) to authenticated;
