-- Classroom cleaning reports: initial schema.
-- Evidence rule and current-state sync are enforced here, not only in the UI.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type public.rol_usuario as enum ('presidente', 'admin');
create type public.estado_aula as enum ('limpio', 'medio_limpio', 'sucio');

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------
create table public.profiles (
	id uuid primary key references auth.users (id) on delete cascade,
	nombre text not null,
	rol public.rol_usuario not null default 'presidente',
	creado_en timestamptz not null default now()
);

create table public.aulas (
	id integer generated always as identity primary key,
	nombre text not null unique,
	estado_actual public.estado_aula not null default 'limpio',
	actualizado_en timestamptz
);

create table public.reportes (
	id uuid primary key default gen_random_uuid(),
	aula_id integer not null references public.aulas (id) on delete restrict,
	usuario_id uuid not null default auth.uid() references public.profiles (id) on delete restrict,
	estado public.estado_aula not null,
	nota text check (nota is null or char_length(nota) <= 500),
	foto_path text,
	creado_en timestamptz not null default now()
);

create index reportes_aula_id_creado_en_idx on public.reportes (aula_id, creado_en desc);
create index reportes_creado_en_idx on public.reportes (creado_en desc);

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
-- SECURITY DEFINER so it can read profiles without recursing into profiles RLS.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
	select exists (
		select 1 from public.profiles p
		where p.id = auth.uid() and p.rol = 'admin'
	);
$$;

-- ---------------------------------------------------------------------------
-- Report triggers: evidence rule + aula state sync
-- ---------------------------------------------------------------------------
create or replace function public.reportes_before_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
	v_estado_actual public.estado_aula;
begin
	-- Lock the aula row so concurrent reports are serialized and the
	-- "previous state" check cannot race with another insert.
	select a.estado_actual into v_estado_actual
	from public.aulas a
	where a.id = new.aula_id
	for update;

	if not found then
		raise exception 'El aula % no existe.', new.aula_id
			using errcode = 'foreign_key_violation';
	end if;

	new.foto_path := nullif(btrim(new.foto_path), '');

	if v_estado_actual = 'sucio' and new.estado <> 'sucio' and new.foto_path is null then
		raise exception 'Se requiere una foto como evidencia: el aula estaba sucia y el nuevo estado no es sucio.'
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

create or replace function public.reportes_after_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
	update public.aulas
	set estado_actual = new.estado,
		actualizado_en = new.creado_en
	where id = new.aula_id;
	return null;
end;
$$;

create trigger reportes_before_insert
	before insert on public.reportes
	for each row execute function public.reportes_before_insert();

create trigger reportes_after_insert
	after insert on public.reportes
	for each row execute function public.reportes_after_insert();

-- ---------------------------------------------------------------------------
-- Profile sync from auth.users
-- Role comes from raw_app_meta_data (only settable with the service role),
-- never from raw_user_meta_data (editable by the user).
-- ---------------------------------------------------------------------------
create or replace function public.rol_from_app_metadata(meta jsonb)
returns public.rol_usuario
language sql
immutable
set search_path = ''
as $$
	select case when meta ->> 'rol' = 'admin' then 'admin'::public.rol_usuario
		else 'presidente'::public.rol_usuario end;
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
	insert into public.profiles (id, nombre, rol)
	values (
		new.id,
		coalesce(nullif(btrim(new.raw_user_meta_data ->> 'nombre'), ''), split_part(new.email, '@', 1)),
		public.rol_from_app_metadata(new.raw_app_meta_data)
	);
	return new;
end;
$$;

create or replace function public.handle_user_app_metadata_update()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
	update public.profiles
	set rol = public.rol_from_app_metadata(new.raw_app_meta_data)
	where id = new.id;
	return new;
end;
$$;

create trigger on_auth_user_created
	after insert on auth.users
	for each row execute function public.handle_new_user();

create trigger on_auth_user_app_metadata_updated
	after update of raw_app_meta_data on auth.users
	for each row
	when (old.raw_app_meta_data is distinct from new.raw_app_meta_data)
	execute function public.handle_user_app_metadata_update();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.aulas enable row level security;
alter table public.reportes enable row level security;

-- profiles: read own row, admin reads all. No client writes (rol is managed via app_metadata).
create policy "profiles_select_own_or_admin" on public.profiles
	for select to authenticated
	using (id = (select auth.uid()) or (select public.is_admin()));

-- aulas: everyone authenticated reads; only admin writes.
create policy "aulas_select_authenticated" on public.aulas
	for select to authenticated
	using (true);

create policy "aulas_insert_admin" on public.aulas
	for insert to authenticated
	with check ((select public.is_admin()));

create policy "aulas_update_admin" on public.aulas
	for update to authenticated
	using ((select public.is_admin()))
	with check ((select public.is_admin()));

create policy "aulas_delete_admin" on public.aulas
	for delete to authenticated
	using ((select public.is_admin()));

-- reportes: append-only. Read for authenticated, insert as self, no update/delete.
create policy "reportes_select_authenticated" on public.reportes
	for select to authenticated
	using (true);

create policy "reportes_insert_self" on public.reportes
	for insert to authenticated
	with check (usuario_id = (select auth.uid()));

-- Defense in depth on top of RLS (no update/delete policies exist).
revoke update, delete, truncate on public.reportes from anon, authenticated;
revoke insert, update, delete, truncate on public.profiles from anon, authenticated;
revoke all on public.reportes, public.profiles, public.aulas from anon;

revoke execute on function public.reportes_before_insert() from public, anon, authenticated;
revoke execute on function public.reportes_after_insert() from public, anon, authenticated;
revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.handle_user_app_metadata_update() from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Storage: private evidence bucket
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
	'evidencias',
	'evidencias',
	false,
	10485760, -- 10 MB
	array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif']
)
on conflict (id) do nothing;

create policy "evidencias_insert_authenticated" on storage.objects
	for insert to authenticated
	with check (bucket_id = 'evidencias');

create policy "evidencias_select_authenticated" on storage.objects
	for select to authenticated
	using (bucket_id = 'evidencias');

create policy "evidencias_delete_admin" on storage.objects
	for delete to authenticated
	using (bucket_id = 'evidencias' and (select public.is_admin()));
