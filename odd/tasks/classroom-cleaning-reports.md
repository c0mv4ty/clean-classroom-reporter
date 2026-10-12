# Feature: classroom-cleaning-reports

## Objective
Micro app where class presidents report the cleaning state of classrooms, with photo evidence when a dirty classroom becomes clean.

## Problem / Why
There is no traceable record of classroom cleanliness. Presidents move between classrooms by schedule and need a quick way to report state and observations (e.g. full trash bin).

## Scope
- 47 users with role `presidente`, 1 user with role `admin`.
- 28 classrooms (`aulas`).
- States: `limpio`, `medio_limpio`, `sucio`.
- Report = state + optional note + photo (required when previous state was `sucio` and new state is not `sucio`).
- Any presidente can report any classroom.
- Public signup disabled; admin creates users.

## Stack / Constraints
- SvelteKit (TypeScript) + `@sveltejs/adapter-cloudflare` (Cloudflare Pages).
- Supabase: Auth, Postgres (RLS), Storage (private bucket `evidencias`).
- `@supabase/ssr` with cookie sessions (no localStorage in SSR).
- Evidence rule enforced in DB trigger, not only in UI.
- Reports are append-only (no update/delete) for auditability.

## Tasks
- [ ] T1 Scaffold SvelteKit + adapter-cloudflare + `@supabase/ssr` (hooks, typed locals, env)
- [ ] T2 Supabase migrations: enums, tables, trigger (evidence rule + `estado_actual` sync), RLS, storage bucket + policies, seed 28 aulas
- [ ] T3 Auth: login, logout, route guards by role
- [ ] T4 Presidente UI: classroom list with current state, report form (state, note, photo upload)
- [ ] T5 Admin UI: report history with evidence, user creation (service role, server-only)
- [ ] T6 Deploy: wrangler config, env vars docs, README

## Acceptance criteria
- Unauthenticated users cannot access any page except `/login`.
- Inserting a non-`sucio` report for a `sucio` classroom without `foto_path` fails at DB level.
- `aulas.estado_actual` always equals the latest report state.
- Presidentes cannot update/delete reports; only admin can create users.
- `npm run check` and `npm run build` pass.

## Checks
- `npm run check`, `npm run build`
- SQL migration reviewed (no local Supabase CLI available: supabase/wrangler not installed).

## Delivery
- Strategy: ask-on-risk. Forecast: ~900 authored lines (exceeds 400 → chain strategy to be asked before PRs).

## Progress
| Task | Route | Commit | Notes |
|------|-------|--------|-------|

## Next step
T1–T6 delegated to one bounded writer (writer trigger: 2+ non-trivial files).
