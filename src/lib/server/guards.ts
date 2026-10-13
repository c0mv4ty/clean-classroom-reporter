import { error } from '@sveltejs/kit';
import { m } from '#lib/paraglide/messages.js';

/**
 * Defense in depth: hooks already redirect non-admins away from /admin,
 * but every admin load/action re-checks before touching privileged data.
 */
export function assertAdmin(locals: App.Locals) {
	if (locals.profile?.rol !== 'admin') error(403, m.error_forbidden());
}
