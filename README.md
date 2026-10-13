# Aulas limpias

Micro app where class presidents report the cleaning state of classrooms (`aulas`), with photo
evidence required when a dirty (`sucio`) classroom is reported as clean again.

- **Stack:** SvelteKit 3 (Svelte 5 runes, TypeScript) on Cloudflare Pages, Supabase (Auth,
  Postgres with RLS, private Storage bucket `evidencias`).
- **Roles:** `presidente` (reports any classroom) and `admin` (creates users, sees the full
  history with evidence photos). Public signup is disabled.
- **Rules enforced in the database:** the evidence rule and `aulas.estado_actual` sync live in a
  trigger (`supabase/migrations/20261012000000_init.sql`); reports are append-only.

## 1. Supabase setup

1. Create a Supabase project.
2. Run the migration, then the seed, in the SQL editor (or with the Supabase CLI):
   - `supabase/migrations/20261012000000_init.sql` (schema, triggers, RLS, `evidencias` bucket)
   - `supabase/seed.sql` (28 classrooms, "Aula 1" .. "Aula 28")
3. **Disable public signup:** Authentication → Sign In / Providers → turn off "Allow new users
   to sign up". Users are created only by the admin from `/admin/usuarios`.
4. **Create the first admin.** Create a user in Authentication → Users → "Add user" (tick
   auto-confirm), then promote it in the SQL editor:

   ```sql
   update auth.users
   set raw_app_meta_data = raw_app_meta_data || '{"rol": "admin"}'
   where email = 'admin@example.com';
   ```

   A trigger copies `rol` from `app_metadata` into `public.profiles`. The role is never read
   from `user_metadata`, because users can edit that themselves. Optionally set a display name:

   ```sql
   update public.profiles set nombre = 'Administración'
   where id = (select id from auth.users where email = 'admin@example.com');
   ```

5. From then on, the admin creates the presidentes at `/admin/usuarios`.

## 2. Environment variables

Copy `.env.example` to `.env` and fill in the values from the Supabase dashboard (Connect →
App Frameworks → SvelteKit, or Project Settings → API):

| Variable                    | Where it is used            | Notes                                              |
| --------------------------- | --------------------------- | -------------------------------------------------- |
| `PUBLIC_SUPABASE_URL`       | browser + server            | Inlined at **build time**                          |
| `PUBLIC_SUPABASE_ANON_KEY`  | browser + server            | Anon or publishable key; inlined at build time     |
| `SUPABASE_SERVICE_ROLE_KEY` | server only (`#lib/server`) | Secret. Used only to create users. Read at runtime |

Variables are declared in `src/env.ts` (SvelteKit 3 `defineEnvVars`) and imported from
`$app/env/public` / `$app/env/private`.

## 3. Local development

```sh
npm install
cp .env.example .env   # then edit
npm run dev
```

Checks:

```sh
npm run check   # wrangler types + svelte-check
npm run build   # production build for Cloudflare Pages
```

`supabase/tests/` holds a plain-Postgres stub of the `auth`/`storage` schemas plus a scenario
script that exercises the evidence rule, state sync and RLS without the Supabase CLI.

## Internationalization

The UI is available in Spanish (default) and English using [Paraglide JS](https://inlang.com/m/gerre34r/library-inlang-paraglideJs). The locale is stored in the `PARAGLIDE_LOCALE` cookie (falling back to the browser's preferred language, then Spanish), so URLs stay unprefixed.

- Messages live in `messages/{locale}.json`. Keys are grouped by area (`nav_*`, `login_*`, `aula_*`, `admin_*`, `estado_*`). Use them with `import { m } from '#lib/paraglide/messages.js'` and `m.some_key({ param })`.
- To add a message: add the same key to every `messages/*.json` file, then use it. The compiler runs with `npm run dev`, `npm run build` and `npm run check`; generated code goes to `src/lib/paraglide` (git-ignored).
- To add a locale: add its code to `locales` in `project.inlang/settings.json`, create `messages/<code>.json`, and add it to the `NAME` map in `src/lib/components/LanguageSwitch.svelte` (plus a `language_<code>` message).
- Server actions and loads call `m.*` directly; the request locale is applied by `paraglideMiddleware` in `src/hooks.server.ts`.
- Dates use the active locale and the `America/Lima` time zone (`src/lib/format.ts`).

## 4. Deploy to Cloudflare Pages

`wrangler.toml` sets `pages_build_output_dir = ".svelte-kit/cloudflare"` and the
`nodejs_compat` flag.

**Git integration (dashboard):**

1. Workers & Pages → Create → Pages → connect the repository.
2. Build command `npm run build`, output directory `.svelte-kit/cloudflare`.
3. Settings → Variables and Secrets (Production and Preview):
   - `PUBLIC_SUPABASE_URL`, `PUBLIC_SUPABASE_ANON_KEY` as plain variables (needed at build time).
   - `SUPABASE_SERVICE_ROLE_KEY` as an **encrypted secret**.
4. Deploy.

**Direct upload (CLI, uses the local `wrangler` dev dependency):**

```sh
npm run build
npx wrangler pages deploy
npx wrangler pages secret put SUPABASE_SERVICE_ROLE_KEY
```

In Supabase, add the deployed URL under Authentication → URL Configuration → Site URL.
