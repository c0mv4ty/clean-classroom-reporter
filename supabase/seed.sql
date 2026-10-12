-- 28 classrooms: "Aula 1" .. "Aula 28".
insert into public.aulas (nombre)
select 'Aula ' || g
from generate_series(1, 28) as g
on conflict (nombre) do nothing;
