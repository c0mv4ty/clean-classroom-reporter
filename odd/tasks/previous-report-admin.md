# Feature: previous-report-admin

## Objective
Let the admin see, for every dirty (`sucio`) report, who reported that classroom just before and in what state, plus a summary of how often each user's report was the last one before a dirty report.

## Problem / Why
The admin wants to spot who tends to leave classrooms dirty. The data only knows who REPORTED, not who occupied the room: a previous `limpio` report means the room was clean when that person left. The feature therefore shows the previous report as context, never as an accusation, and the copy says so.

## Scope
- Admin only (user decision: "Solo el admin"). Presidentes never see other users' names; no change to `profiles` RLS.
- `/admin` history: for each `sucio` row, a "Previous report" line with author, state and time (or "No previous report").
- A summary block on `/admin`: users ranked by number of times their report was the last one before a dirty report, with the latest occurrence. Respects the existing `?aula=` filter.
- Neutral es/en copy that states a previous report is context, not proof of who left the room dirty.

## Constraints
- New migration only (never edit applied migrations); admin-only enforced at the DB level as well as in the page load (`assertAdmin`).
- Test-first with `supabase/tests/rules_scenarios.sql` against a throwaway DB inside the local Docker Postgres (never `supabase db reset`).
- Follow DESIGN.md/PRODUCT.md (existing `.rtable`/Card vocabulary, tokens only, state never color alone); es/en via Paraglide; English artifacts.
- Migration must be run manually in the production Supabase SQL editor before the app deploy.

## Tasks
- [x] T1 DB: scenarios first (RED), new migration exposing previous-report data and the summary admin-only. Route: delegated writer.
- [x] T2 App: `/admin` loader + page UI + es/en messages (+ docs/DESIGN.md if a new component pattern appears). Route: delegated writer.

## Delivery
Strategy: ask-on-risk; one work-unit commit per task on `feat/previous-report-admin`; user asked for direct merge to main without PRs. Production order: migration first, then deploy.

## Progress
- Branch `feat/previous-report-admin` created from `main` (two-state-reports already merged and pushed; the user confirmed the production migration for it was applied).
- Engram mirror `odd/previous-report-admin/tasks` pending (mem_save keeps failing: host session registration not confirmed).

- T1 implemented by the writer (uncommitted): `supabase/migrations/20261022000000_previous_report_admin.sql` adds two admin-only SECURITY DEFINER functions (`admin_reportes_previos(uuid[])`, `admin_resumen_reporte_previo(integer)`); each raises `insufficient_privilege` unless `public.is_admin()`; execute revoked from public/anon and granted to authenticated; `profiles` RLS untouched. `supabase/tests/rules_scenarios.sql` extended with a second section (own PASS/FAIL summary). RED: 12 of 12 new checks FAIL without the migration; GREEN: 12 of 12 PASS and the original 7 still PASS. Applied to the local DB with `npx supabase migration up`; as the real presidente identity both functions refuse (own profile visible 1, other profiles 0).
- T2 implemented by the writer (uncommitted): `/admin` loader calls both functions (previous report only for sucio rows, summary honours `?aula=`), new `PreviousReport.svelte` and `ReporterSummary.svelte`, new "Previous report" column, es/en messages with the visible "context, not proof" sentence, hand-written DB types, README note. Verified in the browser (local DB): sequence on aula 7 with presidente and admin, previous report line with author/state/time, "No previous report" for first dirty reports, summary counts, aula filter, empty state, es and en, 390px and 1280px without horizontal overflow; a mobile label overlap in the summary was found and fixed (nowrap moved from the cell to an inner span). `/admin` redirects a presidente to `/`.
- Production: run `20261022000000_previous_report_admin.sql` in the Supabase SQL editor as `postgres` BEFORE deploying; without it `/admin` fails to load.

## Next step
Parent verifies and commits T1 (`feat(db): add admin-only previous report functions`) and T2 (`feat(admin): show previous report and reporter summary`), then merge to main and push (user asked for direct merge, no PR).

## Verification summary (parent)
- Parent spot check: `npm run check` 0 errors; prettier clean on `src`, `messages`, `README.md` and the migration; both `admin_reportes_previos` and `admin_resumen_reporte_previo` exist in the local DB. Writer results: RED 12 of 12 new scenario checks failed without the migration, GREEN 12 of 12 plus the 7 original pass with it; a presidente is refused by both functions and `anon` gets "permission denied"; `/admin` verified in es/en at 390px and 1280px with a real report sequence.
- Route: one delegated writer for T1 and T2. Commits: `feat(db): add admin-only previous report functions` and `feat(admin): show previous report and reporter summary`.
- Production: run `20261022000000_previous_report_admin.sql` in the Supabase SQL editor as `postgres`. Until it is applied, `/admin` fails to load. The user asked for the merge and push to main directly.
