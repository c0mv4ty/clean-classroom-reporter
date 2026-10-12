-- Manual scenario script for the evidence rule, state sync and RLS.
-- Run after stub_supabase.sql, the migration and seed.sql on a throwaway database:
--   psql -d <db> -f supabase/tests/rules_scenarios.sql
-- Lines marked 'must FAIL' are expected to raise errors.
\set ON_ERROR_STOP 0
insert into auth.users (id, email, raw_user_meta_data, raw_app_meta_data) values
 ('00000000-0000-0000-0000-000000000001','pres@x.cl','{"nombre":"Pres Uno","rol":"admin"}','{}'),
 ('00000000-0000-0000-0000-000000000002','admin@x.cl','{"nombre":"Admin"}','{"rol":"admin"}');
select nombre, rol from public.profiles order by nombre;
set role authenticated; select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000001',false);
\echo '-- presidente sees profiles:'
select count(*) from public.profiles;
\echo '-- report sucio on aula 1 (ok)'
insert into public.reportes (aula_id, estado, nota) values (1,'sucio','basurero lleno');
select estado_actual from public.aulas where id=1;
\echo '-- limpio without photo (must FAIL)'
insert into public.reportes (aula_id, estado) values (1,'limpio');
\echo '-- limpio with nonexistent photo (must FAIL)'
insert into public.reportes (aula_id, estado, foto_path) values (1,'limpio','1/x.jpg');
\echo '-- photo on wrong aula path (must FAIL)'
insert into storage.objects (bucket_id,name) values ('evidencias','2/a.jpg'),('evidencias','1/b.jpg');
insert into public.reportes (aula_id, estado, foto_path) values (1,'limpio','2/a.jpg');
\echo '-- limpio with photo (ok)'
insert into public.reportes (aula_id, estado, foto_path) values (1,'limpio','1/b.jpg');
select estado_actual, actualizado_en is not null from public.aulas where id=1;
\echo '-- impersonate other user (must FAIL)'
insert into public.reportes (aula_id, estado, usuario_id) values (2,'sucio','00000000-0000-0000-0000-000000000002');
\echo '-- update/delete (must FAIL)'
update public.reportes set estado='sucio';
delete from public.reportes;
\echo '-- update aula as presidente (0 rows)'
update public.aulas set estado_actual='sucio' where id=3;
\echo '-- delete storage as presidente (0 rows)'
delete from storage.objects;
select is_admin();
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000002',false);
\echo '-- admin:'
select is_admin(), (select count(*) from public.profiles);
reset role;
\echo '-- promote user 1 via app_metadata'
update auth.users set raw_app_meta_data='{"rol":"admin"}' where email='pres@x.cl';
select nombre, rol from public.profiles order by nombre;
select count(*) from public.reportes;
