import { createClient } from '@supabase/supabase-js';
import { SUPABASE_SERVICE_ROLE_KEY } from '$app/env/private';
import { PUBLIC_SUPABASE_URL } from '$app/env/public';
import type { Database } from '#lib/types/database.ts';

/**
 * Service-role client. Bypasses RLS — use only from admin-guarded server code
 * (user creation). Never import from client code; `$lib/server` enforces that.
 */
export function createAdminClient() {
	return createClient<Database>(PUBLIC_SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
		auth: { autoRefreshToken: false, persistSession: false }
	});
}
