-- Manual scenario script for the evidence rule, state sync and RLS.
-- Run after stub_supabase.sql, the migrations and seed.sql on a throwaway database:
--   psql -d <db> -f supabase/tests/rules_scenarios.sql
-- Lines marked 'must FAIL' are expected to raise errors. The final query prints
-- PASS/FAIL for the rules that matter (every row must be PASS).
--
-- Rules under test (two states, photo only when reporting sucio):
--   * estado_aula = ('limpio', 'sucio'); medio_limpio no longer exists.
--   * A 'sucio' report requires a photo (hint 'evidencia_requerida').
--   * A 'limpio' report never requires a photo; if one is sent it must be valid.
\set ON_ERROR_STOP 0
insert into auth.users (id, email, raw_user_meta_data, raw_app_meta_data) values
 ('00000000-0000-0000-0000-000000000001','pres@x.cl','{"nombre":"Pres Uno","rol":"admin"}','{}'),
 ('00000000-0000-0000-0000-000000000002','admin@x.cl','{"nombre":"Admin"}','{"rol":"admin"}');
select nombre, rol from public.profiles order by nombre;
insert into storage.objects (bucket_id,name) values
 ('evidencias','1/a.jpg'),('evidencias','1/c.jpg'),('evidencias','2/b.jpg');
set role authenticated; select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000001',false);
\echo '-- presidente sees profiles:'
select count(*) from public.profiles;
\echo '-- sucio without photo (must FAIL, hint evidencia_requerida)'
insert into public.reportes (aula_id, estado, nota) values (1,'sucio','basurero lleno');
select estado_actual from public.aulas where id=1;
\echo '-- sucio with nonexistent photo (must FAIL)'
insert into public.reportes (aula_id, estado, foto_path) values (1,'sucio','1/x.jpg');
\echo '-- sucio with photo on wrong aula path (must FAIL)'
insert into public.reportes (aula_id, estado, foto_path) values (1,'sucio','2/b.jpg');
\echo '-- sucio with photo (ok)'
insert into public.reportes (aula_id, estado, nota, foto_path) values (1,'sucio','basurero lleno','1/a.jpg');
select estado_actual, actualizado_en is not null from public.aulas where id=1;
\echo '-- limpio without photo (ok, photo not required)'
insert into public.reportes (aula_id, estado) values (1,'limpio');
select estado_actual from public.aulas where id=1;
\echo '-- limpio with nonexistent photo (must FAIL)'
insert into public.reportes (aula_id, estado, foto_path) values (1,'limpio','1/x.jpg');
\echo '-- limpio with photo on wrong aula path (must FAIL)'
insert into public.reportes (aula_id, estado, foto_path) values (1,'limpio','2/b.jpg');
\echo '-- limpio with optional valid photo (ok)'
insert into public.reportes (aula_id, estado, foto_path) values (1,'limpio','1/c.jpg');
\echo '-- medio_limpio no longer valid (must FAIL)'
insert into public.reportes (aula_id, estado) values (2,'medio_limpio');
\echo '-- impersonate other user (must FAIL)'
insert into public.reportes (aula_id, estado, usuario_id) values (2,'limpio','00000000-0000-0000-0000-000000000002');
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
\echo '-- summary (every row must be PASS)'
select 'enum is exactly (limpio, sucio)' as check,
       case when enum_range(null::public.estado_aula)::text = '{limpio,sucio}' then 'PASS' else 'FAIL' end as result
union all
select 'no sucio report without photo stored',
       case when not exists (select 1 from public.reportes where estado::text = 'sucio' and foto_path is null) then 'PASS' else 'FAIL' end
union all
select 'limpio report without photo stored',
       case when exists (select 1 from public.reportes where estado::text = 'limpio' and foto_path is null) then 'PASS' else 'FAIL' end
union all
select 'no medio_limpio report stored',
       case when not exists (select 1 from public.reportes where estado::text = 'medio_limpio') then 'PASS' else 'FAIL' end
union all
select 'exactly 3 reports stored (sucio+photo, limpio, limpio+photo)',
       case when (select count(*) from public.reportes) = 3 then 'PASS' else 'FAIL' end
union all
select 'aula 1 ends limpio and synced',
       case when (select estado_actual::text from public.aulas where id = 1) = 'limpio' then 'PASS' else 'FAIL' end
union all
select 'aula 2 untouched (limpio)',
       case when (select estado_actual::text from public.aulas where id = 2) = 'limpio' then 'PASS' else 'FAIL' end;
