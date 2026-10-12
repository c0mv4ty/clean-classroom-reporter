import { defineEnvVars } from '@sveltejs/kit/env';

/**
 * Environment variables used by the app.
 * Public values are exposed via `$app/env/public`; private ones via `$app/env/private` (server only).
 */
export const variables = defineEnvVars({
	PUBLIC_SUPABASE_URL: {
		public: true,
		static: true,
		description: 'Supabase project URL'
	},
	PUBLIC_SUPABASE_ANON_KEY: {
		public: true,
		static: true,
		description: 'Supabase anon (publishable) key'
	},
	SUPABASE_SERVICE_ROLE_KEY: {
		description: 'Supabase service role key. Server only; used exclusively for admin user creation.'
	}
});
