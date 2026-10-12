import { error } from '@sveltejs/kit';

/**
 * Defense in depth: hooks already redirect non-admins away from /admin,
 * but every admin load/action re-checks before touching privileged data.
 */
export function assertAdmin(locals: App.Locals) {
	if (locals.profile?.rol !== 'admin') error(403, 'Acceso restringido a administración.');
}
