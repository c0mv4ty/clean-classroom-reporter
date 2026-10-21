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
--   * Admin-only previous-report functions (admin_reportes_previos, admin_resumen_reporte_previo);
--     see the last section. That section prints its own PASS/FAIL summary.
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

-- ---------------------------------------------------------------------------
-- Previous-report scenarios (admin-only data). Uses aulas 5 and 6 and the
-- notes r1..r9 as markers, so it does not disturb the checks above.
--   aula 5: r1 Ana limpio, r2 Beto sucio, r3 Ana limpio, r4 Beto sucio, r5 Beto sucio
--   aula 6: r6 Ana sucio (first report), r7 Beto limpio, r8 Ana sucio, r9 Beto sucio
-- Expected previous report of each: r1 none, r2 r1, r4 r3, r5 r4, r6 none, r8 r7, r9 r8.
-- Expected summary (last report before a sucio report): Ana 3 (r2, r4, r9), Beto 2 (r5, r8).
-- ---------------------------------------------------------------------------
\echo
\echo '=== previous-report scenarios ==='
insert into auth.users (id, email, raw_user_meta_data, raw_app_meta_data) values
 ('00000000-0000-0000-0000-000000000003','ana@x.cl','{"nombre":"Ana"}','{}'),
 ('00000000-0000-0000-0000-000000000004','beto@x.cl','{"nombre":"Beto"}','{}');
insert into storage.objects (bucket_id,name) values
 ('evidencias','5/s1.jpg'),('evidencias','5/s2.jpg'),('evidencias','5/s3.jpg'),
 ('evidencias','6/s1.jpg'),('evidencias','6/s2.jpg'),('evidencias','6/s3.jpg');
set role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000003',false);
insert into public.reportes (aula_id, estado, nota) values (5,'limpio','r1');
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000004',false);
insert into public.reportes (aula_id, estado, nota, foto_path) values (5,'sucio','r2','5/s1.jpg');
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000003',false);
insert into public.reportes (aula_id, estado, nota) values (5,'limpio','r3');
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000004',false);
insert into public.reportes (aula_id, estado, nota, foto_path) values (5,'sucio','r4','5/s2.jpg');
insert into public.reportes (aula_id, estado, nota, foto_path) values (5,'sucio','r5','5/s3.jpg');
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000003',false);
insert into public.reportes (aula_id, estado, nota, foto_path) values (6,'sucio','r6','6/s1.jpg');
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000004',false);
insert into public.reportes (aula_id, estado, nota) values (6,'limpio','r7');
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000003',false);
insert into public.reportes (aula_id, estado, nota, foto_path) values (6,'sucio','r8','6/s2.jpg');
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000004',false);
insert into public.reportes (aula_id, estado, nota, foto_path) values (6,'sucio','r9','6/s3.jpg');
\echo '-- presidente calls admin_resumen_reporte_previo (must FAIL, insufficient_privilege)'
select * from public.admin_resumen_reporte_previo();
\echo '-- presidente calls admin_reportes_previos (must FAIL, insufficient_privilege)'
select * from public.admin_reportes_previos(array[gen_random_uuid()]);
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000002',false);
\echo '-- admin summary (Ana 3, Beto 2):'
select * from public.admin_resumen_reporte_previo();
\echo '-- admin summary, aula 5 (Ana 2, Beto 1):'
select * from public.admin_resumen_reporte_previo(5);
reset role;

create temp table prev_checks (check_name text, ok boolean);
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000002',false);

-- Previous report of every marked report, compared against the expected map.
insert into prev_checks
select 'previous report is the immediately preceding report of the same aula',
       coalesce((
         select count(*) = 7 and bool_and(
                  e.prev_nota is not distinct from pr.nota
              and e.prev_nombre is not distinct from p.anterior_nombre
              and e.prev_estado is not distinct from p.anterior_estado::text)
         from (values
           ('r1', null, null, null), ('r2','r1','Ana','limpio'), ('r4','r3','Ana','limpio'),
           ('r5','r4','Beto','sucio'), ('r6', null, null, null), ('r8','r7','Beto','limpio'),
           ('r9','r8','Ana','sucio')
         ) as e (nota, prev_nota, prev_nombre, prev_estado)
         join public.reportes r on r.nota = e.nota
         left join public.admin_reportes_previos(
           (select array_agg(id) from public.reportes where nota ~ '^r[0-9]$')) p on p.reporte_id = r.id
         left join public.reportes pr on pr.id = p.anterior_id
       ), false);

insert into prev_checks
select 'first report of an aula has no previous (r1, r6)',
       coalesce((
         select count(*) = 0
         from public.admin_reportes_previos(
           (select array_agg(id) from public.reportes where nota in ('r1','r6')))
       ), false);

insert into prev_checks
select 'summary counts: Ana 3, Beto 2 (ranked)',
       coalesce((select string_agg(anterior_nombre || '=' || veces, ',' order by veces desc, anterior_nombre)
                 from public.admin_resumen_reporte_previo()) = 'Ana=3,Beto=2', false);

insert into prev_checks
select 'summary filtered by aula 5: Ana 2, Beto 1',
       coalesce((select string_agg(anterior_nombre || '=' || veces, ',' order by veces desc, anterior_nombre)
                 from public.admin_resumen_reporte_previo(5)) = 'Ana=2,Beto=1', false);

insert into prev_checks
select 'summary filtered by aula 6: Ana first (latest), 1 each',
       coalesce((select string_agg(anterior_nombre || '=' || veces, ',')
                 from public.admin_resumen_reporte_previo(6)) = 'Ana=1,Beto=1', false);

insert into prev_checks
select 'summary latest occurrence is the time of the dirty report (Ana r9, Beto r8)',
       coalesce((select bool_and(
                   s.ultima_vez = (select creado_en from public.reportes where nota = case s.anterior_nombre when 'Ana' then 'r9' else 'r8' end))
                 from public.admin_resumen_reporte_previo() s), false);

insert into prev_checks
select 'summary for an aula without dirty reports is empty',
       coalesce((select count(*) = 0 from public.admin_resumen_reporte_previo(3)), false);

-- Non-admin and anonymous callers are refused with insufficient_privilege.
do $$
declare
  v_sub text;
  v_ok boolean;
begin
  foreach v_sub in array array['00000000-0000-0000-0000-000000000003', '']
  loop
    perform set_config('request.jwt.claim.sub', v_sub, false);
    v_ok := false;
    begin
      perform * from public.admin_resumen_reporte_previo();
    exception when insufficient_privilege then v_ok := true;
    end;
    insert into prev_checks values ('summary refused for ' || case v_sub when '' then 'no session' else 'a presidente' end, v_ok);
    v_ok := false;
    begin
      perform * from public.admin_reportes_previos(array[gen_random_uuid()]);
    exception when insufficient_privilege then v_ok := true;
    end;
    insert into prev_checks values ('previous reports refused for ' || case v_sub when '' then 'no session' else 'a presidente' end, v_ok);
  end loop;
  perform set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000002', false);
end $$;

-- Execute grants: authenticated only (anon and PUBLIC cannot call the functions).
insert into prev_checks
select 'execute on admin functions: authenticated yes, anon no',
       coalesce(
         has_function_privilege('authenticated', 'public.admin_reportes_previos(uuid[])', 'execute')
         and has_function_privilege('authenticated', 'public.admin_resumen_reporte_previo(integer)', 'execute')
         and not has_function_privilege('anon', 'public.admin_reportes_previos(uuid[])', 'execute')
         and not has_function_privilege('anon', 'public.admin_resumen_reporte_previo(integer)', 'execute'),
         false);

\echo '-- previous-report summary (every row must be PASS)'
select e.check_name as check,
       case when coalesce(bool_or(c.ok), false) then 'PASS' else 'FAIL' end as result
from (values
  ('previous report is the immediately preceding report of the same aula'),
  ('first report of an aula has no previous (r1, r6)'),
  ('summary counts: Ana 3, Beto 2 (ranked)'),
  ('summary filtered by aula 5: Ana 2, Beto 1'),
  ('summary filtered by aula 6: Ana first (latest), 1 each'),
  ('summary latest occurrence is the time of the dirty report (Ana r9, Beto r8)'),
  ('summary for an aula without dirty reports is empty'),
  ('summary refused for a presidente'),
  ('previous reports refused for a presidente'),
  ('summary refused for no session'),
  ('previous reports refused for no session'),
  ('execute on admin functions: authenticated yes, anon no')
) as e (check_name)
left join prev_checks c on c.check_name = e.check_name
group by e.check_name
order by min(case e.check_name when 'previous report is the immediately preceding report of the same aula' then 0 else 1 end), e.check_name;
