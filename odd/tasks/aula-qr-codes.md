# Feature: aula-qr-codes

## Objective
Let an admin generate and print one QR code per classroom so a presidente can scan it, sign in only if needed, and land on that classroom's report form.

## Problem / Why
PRODUCT.md principle 4: "Scan, sign in, report." The deep link already works (`/aulas/<id>`; unauthenticated users go to `/login?redirectTo=...` and return after sign-in), but there is no way to produce the QR codes to stick on the classroom doors.

## Scope
- New admin-only page `/admin/qr` listing all classrooms with a QR each, plus a print layout (labels sized for A4).
- QR encodes `<origin>/aulas/<id>`, origin taken from the request URL so production prints production links.
- Admin nav link and es/en messages (Paraglide).
- No schema change, no change to the presidente flow.

## Constraints
- Follow DESIGN.md / PRODUCT.md (tokens only, 44px touch targets, no color-alone, no nested cards, English artifacts, es/en copy via Paraglide).
- QR rendered server-side as SVG (pure JS lib that runs on Cloudflare Workers), no client JS needed to print.
- Admin check on load via `assertAdmin` (defense in depth, as in other admin routes).
- No test runner in the repo: RED/GREEN not applicable; checks are `npm run check`, `npm run lint`, and browser verification.

## Tasks
- [x] T1 `/admin/qr` page: server load (assertAdmin, aulas list, origin), SVG QR per aula, print stylesheet, admin nav link, es/en messages. Route: delegated writer (3+ non-trivial files).

## Delivery
Strategy: ask-on-risk; forecast well under 400 authored lines; one work-unit commit on `feat/aula-qr`.

## Progress
- Branch `feat/aula-qr` created.
- T1 implemented by the writer (uncommitted, parent to verify and commit): `uqr@0.1.3`, `/admin/qr` load + page, admin nav link, es/en messages.
- Observed by the writer: `npm run check` 0 errors; prettier clean on changed files; 28 QR labels render; QR for Aula 12 decoded with zbarimg to `http://127.0.0.1:5173/aulas/12`; print layout verified under emulated print in dark theme; production build with adapter-cloudflare succeeds.
- Engram mirror `odd/aula-qr-codes/tasks` pending: `mem_save` failed (host session registration not confirmed). Resync when available.

- Parent spot check: `npm run check` 0 errors, prettier clean on `src`, `messages`, `package.json`. Route: delegated writer (3+ non-trivial files). Commit: `feat(admin): add printable QR codes per classroom` on `feat/aula-qr`.
- Open: the writer saw an unexplained redirect to `/` twice during browser checks (not reproduced in 3 attempts); Spanish copy not yet viewed in the browser; non-admin access verified by code reading only.

## Next step
Manual check of `/admin/qr` in Spanish and as a presidente, then push and open a PR (user decision).
