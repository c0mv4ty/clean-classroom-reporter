# Feature: photo-1mb-limit

## Objective
Cap evidence photos at 1 MB and compress them automatically in the browser so presidentes never hit the limit.

## Problem / Why
User decision: the `evidencias` bucket limit goes from 10 MB to 1 MB. Phone photos are typically 2 to 8 MB and the app does not compress, so a bare 1 MB cap would reject most `sucio` reports. User chose "Comprimir en el navegador".

## Scope
- Client: on photo selection, downscale and re-encode to JPEG until the file is under 1 MB; replace the file in the form input; block submit while processing; clear message when it cannot be decoded (e.g. HEIC in browsers that cannot decode it) or cannot reach 1 MB.
- Server: `MAX_PHOTO_BYTES` becomes 1 MB (hard cap, never trust the client).
- DB/Storage: migration setting `storage.buckets.file_size_limit = 1048576` for `evidencias`.
- es/en copy for the processing state and the size errors.

## Constraints
- New migration only; deploy order is app first, then migration (an old app sending up to 10 MB would be rejected by a 1 MB bucket).
- Follow DESIGN.md/PRODUCT.md and the existing PhotoPicker vocabulary; accessible status messages (`aria-live`); es/en via Paraglide.
- No test runner: verification is `npm run check`, prettier on changed files, and browser plus Storage API checks against the local Docker Supabase.

## Tasks
- [x] T1 Photo limit: migration, shared constant, client compression in PhotoPicker (+ `src/lib/image.ts`), server cap, messages, docs. Route: delegated writer.

## Delivery
Strategy: ask-on-risk; one work-unit commit on `feat/photo-1mb-limit`; direct merge to main and push, no PR (user's standing instruction).

## Progress
- Branch `feat/photo-1mb-limit` created from `main` (previous-report-admin merged and pushed).
- Engram mirror `odd/photo-1mb-limit/tasks` pending (mem_save keeps failing: host session registration not confirmed).

## Next step
Delegate T1.

## Writer notes (T1, uncommitted, parent to verify and commit)
- Files: migration `20261023000000_photo_size_limit_1mb.sql`; `MAX_PHOTO_BYTES = 1 MB` in `src/lib/constants.ts` (used by the server action and the compressor); `src/lib/image.ts` (`compressImage`, `PhotoError`); `PhotoPicker.svelte` (compression on select, `busy` bindable, status messages); `aulas/[id]/+page.svelte` (blocks submit while busy); `+page.server.ts` (shared cap); es/en messages (`photo_processing`, `photo_error_unreadable`, `photo_error_too_large`); README and docs/DEPLOY.md (cap, browser compression, deploy order app first then migration).
- Compression settings: decode with `createImageBitmap(..., { imageOrientation: 'from-image' })` (fallback to `<img>`), long edge 1600/1280/1024/800 px, JPEG quality 0.82/0.72/0.62/0.5, target <= 95% of the cap; small JPEG/PNG/WEBP are returned untouched after a successful decode; HEIC that the browser cannot decode is rejected with the "could not be read" message.
- Observed: `npm run check` 0 errors; prettier clean on changed files; local bucket limit 1048576; Storage API: 2 MB upload HTTP 400 `EntityTooLarge`, 500 KB upload HTTP 200 (test object deleted via the API); browser as presidente: 11.2 MB JPEG became 245,440 bytes and the stored object is 245,440 bytes image/jpeg; 4.1 MB became 246,212; 52 KB passed untouched; 6 MB noise JPEG became 842,477; 6.5 MB noise PNG became a 720,557 byte `.jpg`; 54 MB noise JPEG became 690,828 in 752 ms; a text file renamed `.jpg` shows the translated error and clears the input; direct POSTs of 1 MB + 1 byte and 2 MB return 400 "The photo cannot exceed 1 MB."; `too_large` verified at util level only (not through the UI).
- Production order: deploy the app first, then run the migration (or edit the bucket limit in the dashboard).

## Verification summary (parent)
- Parent spot check: `npm run check` 0 errors; prettier clean on `src`, `messages`, `README.md`, `docs` and the migration; local `storage.buckets.file_size_limit` is 1048576; no stale 10 MB references in `src` or `messages`.
- Writer results: Storage API with a presidente JWT returned 400 `EntityTooLarge` for 2 MB and 200 for 500 KB; browser compression measured 11.2 MB -> 245,440 bytes (stored object identical), 6 MB noise -> 842,477 bytes, 54 MB noise -> 690,828 bytes in 752 ms; a small JPEG passed untouched; a non-image renamed .jpg showed the translated error and was cleared; direct POSTs of 1 MB + 1 byte and 2 MB returned 400.
- Not exercised through the UI: the "still too large" message (checked only at util level with a 5 KB cap). English 390px screenshots not taken.
- Route: delegated writer. Commit: `feat(photos): cap evidence at 1 MB with browser compression`.
- Production order: deploy the app first, then run `20261023000000_photo_size_limit_1mb.sql` (or set the limit under Storage > evidencias > Edit bucket).

## Next step
Merge to main and push once the user confirms (a push deploys production).
