# Despliegue en Cloudflare Pages

Guía paso a paso para desplegar **Aulas limpias** (SvelteKit 3 + `@sveltejs/adapter-cloudflare`) en
Cloudflare Pages, usando un proyecto de Supabase ya existente.

El despliegue se hace con **integración con Git**: Cloudflare compila y despliega automáticamente
en cada push a `main` (y crea un preview por cada otra rama o PR).

## 0. Prerrequisitos

- Una cuenta de Cloudflare (el plan gratuito alcanza).
- Node.js 22+ y `npm install` ya ejecutado.
- El proyecto de Supabase configurado (migración, seed y primer admin). Ver la sección 1 del `README.md`.
- Tres valores de Supabase (Project Settings → API):

| Variable                    | Tipo               | Cuándo se lee                              |
| --------------------------- | ------------------ | ------------------------------------------ |
| `PUBLIC_SUPABASE_URL`       | variable en texto  | **Al compilar** (se incrusta en el bundle) |
| `PUBLIC_SUPABASE_ANON_KEY`  | variable en texto  | **Al compilar** (se incrusta en el bundle) |
| `SUPABASE_SERVICE_ROLE_KEY` | **secret** cifrado | En ejecución, solo en el servidor          |

> Las dos variables `PUBLIC_*` son `static`, por lo que deben existir **cuando corre
> `npm run build`**. Si se agregan o cambian después de compilar, hay que volver a compilar. Nunca
> poner la service role key como variable en texto plano y nunca commitearla.

## 1. Verificar el build en local

```sh
cp .env.example .env      # completar los tres valores
npm run check
npm run build
npm run preview           # http://localhost:4173
```

Iniciar sesión en `/login` y comprobar que la app funciona antes de tocar Cloudflare.

## 2. Conectar el repositorio en Cloudflare

1. Dashboard de Cloudflare → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**.
2. Autorizar GitHub y seleccionar `thealeeeh/MA_Aulas`. Rama de producción: `main`.
3. Configuración de build:
   - Framework preset: **SvelteKit** (o None)
   - Build command: `npm run build`
   - Build output directory: `.svelte-kit/cloudflare`
4. Variables de entorno (agregarlas en **Production** y **Preview**):
   - `PUBLIC_SUPABASE_URL` → texto plano
   - `PUBLIC_SUPABASE_ANON_KEY` → texto plano
   - `SUPABASE_SERVICE_ROLE_KEY` → **Encrypt**
   - `NODE_VERSION` → `22` (texto plano, fija la versión de Node del build)
5. **Save and Deploy**. El primer build tarda un par de minutos.
6. Abrir la URL `https://<proyecto>.pages.dev` y continuar con la sección 3.

## 3. Apuntar Supabase a la URL desplegada

Supabase → Authentication → **URL Configuration**:

- **Site URL:** `https://<proyecto>.pages.dev` (o el dominio propio)
- **Redirect URLs:** agregar la misma URL.

## 4. Prueba de humo (checklist para quien revisa)

- [ ] `/login` carga, los estilos e iconos se ven y el cambio de idioma (ES/EN) funciona.
- [ ] El login con el usuario admin funciona y redirige a la lista de aulas.
- [ ] Se puede reportar un aula; pasar de sucio a limpio exige una foto.
- [ ] `/admin/usuarios` permite crear un presidente (usa `SUPABASE_SERVICE_ROLE_KEY`; si falla con
      error de servidor, falta el secret).
- [ ] Abrir el sitio en ancho de celular (diseño mobile-first, navbar responsive).

## Solución de problemas

| Síntoma                                                | Causa probable / solución                                                              |
| ------------------------------------------------------ | -------------------------------------------------------------------------------------- |
| El build falla en `wrangler types`                     | Revisar la versión de Node (`NODE_VERSION=22`) y que `npm install` use el lockfile     |
| La app carga pero fallan todas las llamadas a Supabase | Faltaban las variables `PUBLIC_*` al compilar. Definirlas y lanzar un nuevo despliegue |
| Error 500 solo al crear usuarios                       | `SUPABASE_SERVICE_ROLE_KEY` no está como secret en ese entorno (Production vs Preview) |
| El login funciona en local pero no en producción       | Site URL / Redirect URLs de Supabase sin actualizar (sección 3)                        |
| Cambié una variable y no pasó nada                     | Las variables se aplican en el **siguiente** build. Reintentar el despliegue           |

## Rollback

Workers & Pages → proyecto → **Deployments** → elegir un despliegue anterior exitoso →
**Rollback to this deployment**.
