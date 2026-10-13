# Deploying to Cloudflare Pages

Step-by-step guide to deploy **Aulas limpias** (SvelteKit 3 + `@sveltejs/adapter-cloudflare`) to
Cloudflare Pages, backed by an existing Supabase project.

Two ways to deploy. Pick one:

- **2A. Git integration (recommended):** Cloudflare builds and deploys on every push.
- **2B. Direct upload (CLI):** you build locally and upload with `wrangler`.

## 0. Prerequisites

- A Cloudflare account (free plan is enough).
- Node.js 22+ and `npm install` already run.
- The Supabase project is set up (migration, seed, first admin). See `README.md` section 1.
- Three values from Supabase (Project Settings → API):

| Variable                    | Type                 | When it is read                        |
| --------------------------- | -------------------- | -------------------------------------- |
| `PUBLIC_SUPABASE_URL`       | plain variable       | **Build time** (inlined in the bundle) |
| `PUBLIC_SUPABASE_ANON_KEY`  | plain variable       | **Build time** (inlined in the bundle) |
| `SUPABASE_SERVICE_ROLE_KEY` | encrypted **secret** | Runtime, server only                   |

> The two `PUBLIC_*` variables are `static`, so they must exist **when `npm run build` runs**. If
> you add or change them after a build, you must rebuild. Never put the service role key in a
> plain variable and never commit it.

## 1. Verify the build locally

```sh
cp .env.example .env      # fill in the three values
npm run check
npm run build
npm run preview           # http://localhost:4173
```

Log in at `/login` and make sure the app works before touching Cloudflare.

## 2A. Git integration (dashboard)

1. Cloudflare dashboard → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**.
2. Authorize GitHub and select `thealeeeh/MA_Aulas`. Production branch: `main`.
3. Build settings:
   - Framework preset: **SvelteKit** (or None)
   - Build command: `npm run build`
   - Build output directory: `.svelte-kit/cloudflare`
4. Environment variables (add them for **Production** and **Preview**):
   - `PUBLIC_SUPABASE_URL` → plain text
   - `PUBLIC_SUPABASE_ANON_KEY` → plain text
   - `SUPABASE_SERVICE_ROLE_KEY` → **Encrypt**
   - `NODE_VERSION` → `22` (plain text, pins the build image)
5. **Save and Deploy**. The first build takes a couple of minutes.
6. Open the `https://<project>.pages.dev` URL and go to section 3 below.

## 2B. Direct upload (CLI)

`wrangler` is a dev dependency, so use `npx`.

```sh
npx wrangler login
npx wrangler pages project create aulas-limpias --production-branch main
npm run build                       # needs the PUBLIC_* values in .env
npx wrangler pages secret put SUPABASE_SERVICE_ROLE_KEY --project-name aulas-limpias
npx wrangler pages deploy --project-name aulas-limpias
```

`wrangler.toml` already sets `pages_build_output_dir` and `nodejs_compat`, so no output path is
needed. Repeat `npm run build` + `pages deploy` for each new release.

## 3. Point Supabase at the deployed URL

Supabase → Authentication → **URL Configuration**:

- **Site URL:** `https://<project>.pages.dev` (or your custom domain)
- **Redirect URLs:** add the same URL.

## 4. Smoke test (checklist for the reviewer)

- [ ] `/login` loads, styles and icons render, language switch works (ES/EN).
- [ ] Login with the admin user succeeds and redirects to the classroom list.
- [ ] A classroom can be reported; a dirty → clean report requires a photo.
- [ ] `/admin/usuarios` can create a presidente (this uses `SUPABASE_SERVICE_ROLE_KEY`; if it
      fails with a server error, the secret is missing).
- [ ] Open the site on a phone width (mobile-first layout, responsive navbar).

## Troubleshooting

| Symptom                                   | Likely cause / fix                                                                           |
| ----------------------------------------- | -------------------------------------------------------------------------------------------- |
| Build fails on `wrangler types`           | Check Node version (`NODE_VERSION=22`) and that `npm install` ran from the lockfile          |
| App loads but every Supabase call fails   | `PUBLIC_*` vars were missing at build time. Set them and trigger a new deploy                |
| 500 only when creating users              | `SUPABASE_SERVICE_ROLE_KEY` not set as a secret for that environment (Production vs Preview) |
| Login works locally but not in production | Supabase Site URL / Redirect URLs not updated (section 3)                                    |
| Changed a variable but nothing changed    | Variables apply to the **next** build. Retry the deployment                                  |

## Rollback

Workers & Pages → project → **Deployments** → pick a previous successful deployment →
**Rollback to this deployment**.
