# Feature: two-state-reports

## Objective
Simplify reporting to two states (`limpio`, `sucio`) and require a photo only when reporting `sucio`.

## Problem / Why
User decision: `medio_limpio` is not pertinent, and photo evidence is only needed when a classroom is dirty. The current rule (photo required when a dirty classroom is reported as no longer dirty) is inverted relative to that.

## Scope
- Remove `medio_limpio` everywhere (DB enum, types, UI, i18n, tokens, docs).
- Evidence rule in the DB trigger: photo required iff the new report's state is `sucio`; optional otherwise.
- Existing `medio_limpio` reports/aulas are converted to `limpio` (user decision: "Convertirlos a limpio").
- Consequence accepted: reporting `limpio` no longer needs proof.

## Constraints
- New migration only; never edit `20261012000000_init.sql` (already applied in production).
- Postgres cannot drop enum values: recreate the type and convert columns.
- Rule enforced in the DB trigger, not only in the UI; reports stay append-only.
- Follow DESIGN.md/PRODUCT.md; es/en via Paraglide; English artifacts.
- Test-first where runnable: `supabase/tests/rules_scenarios.sql` against the local Docker DB; app checks are `npm run check`, prettier on changed files, browser verification.

## Tasks
- [x] T1 DB: scenarios first (RED), new migration recreating `estado_aula` as (`limpio`,`sucio`) with data conversion and the inverted evidence rule, seed/test updates. Route: delegated writer.
- [ ] T2 App: types, `estados.ts`, report form action and UI (EstadoPicker, StateSummary, EstadoBadge, EstadoIcon, PhotoPicker), tokens in `app.css`, es/en messages, README/docs, DESIGN.md and sidecar. Route: delegated writer.

## Delivery
Strategy: ask-on-risk; one work-unit commit per task on `feat/two-state-reports`. The migration must be run manually in the production Supabase SQL editor before the app deploy.

## Progress
- Branch `feat/two-state-reports` created from `main`.
- Engram mirror `odd/two-state-reports/tasks` pending (mem_save has been failing: host session registration not confirmed).

- T1 implemented by the writer (uncommitted, parent to verify and commit): `supabase/migrations/20261021000000_two_state_photo_rule.sql` (guarded `do` block recreates `estado_aula` as limpio/sucio and converts both columns with `medio_limpio` mapped to `limpio`; `reportes_before_insert` replaced so a photo is required iff the report is `sucio`, hint `evidencia_requerida` kept; function ACL revokes restated) and `supabase/tests/rules_scenarios.sql` rewritten for the new rules with a final PASS/FAIL summary. `seed.sql` has no `medio_limpio` reference, unchanged.
- T1 test-first: scenarios run on a throwaway database inside the local Docker Postgres (stub + init + seed). RED against the init schema: 6 of 7 summary checks FAIL (only "aula 1 ends limpio" passed by coincidence). GREEN after the new migration: 7 of 7 PASS and `\dT+ public.estado_aula` lists limpio, sucio.
- T1 conversion check: on a scratch DB with legacy rows, before limpio=1, medio_limpio=1, sucio=2 (4 total, aula 2 medio_limpio); after limpio=2, sucio=2 (4 total, aula 2 limpio), old type dropped, `aulas.estado_actual` default kept, second run of the migration is a no-op. On the real local Supabase DB (`npx supabase migration up`): before medio_limpio=1, sucio=2, aula 12 medio_limpio; after limpio=1, sucio=2 (3 total), aula 12 limpio. The planned probe insert on aula 28 was refused because aula 28 was already `sucio` from earlier browser tests (old rule needed a photo), so the existing aula 12 report served as the legacy row.
- Local app is temporarily inconsistent until T2: the UI still offers `medio_limpio`, which the DB now rejects.

- Parent spot check (T1): enum is `limpio,sucio`; report counts limpio=1/sucio=2; evidence rule at migration line 64. Route: delegated writer. Commit: `feat(db): drop medio_limpio and require photo only for sucio`.
- Before production: run `20261021000000_two_state_photo_rule.sql` in the Supabase SQL editor as `postgres` BEFORE deploying the T2 app (brief ACCESS EXCLUSIVE locks, instant at this size; rewrites historical medio_limpio rows to limpio).

## Next step
Delegate T2.
