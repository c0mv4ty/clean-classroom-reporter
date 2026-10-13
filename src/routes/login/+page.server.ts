import { fail, redirect } from '@sveltejs/kit';
import { m } from '#lib/paraglide/messages.js';
import type { Actions } from './$types';

/** Only allow same-origin relative redirects to avoid open redirects. */
function safeRedirect(target: string | null) {
	if (!target || !target.startsWith('/') || target.startsWith('//')) return '/';
	return target;
}

export const actions: Actions = {
	default: async ({ request, url, locals }) => {
		const form = await request.formData();
		const email = String(form.get('email') ?? '').trim();
		const password = String(form.get('password') ?? '');

		if (!email || !password) {
			return fail(400, { email, message: m.login_error_missing() });
		}

		const { error } = await locals.supabase.auth.signInWithPassword({ email, password });
		if (error) {
			return fail(400, { email, message: m.login_error_invalid() });
		}

		redirect(303, safeRedirect(url.searchParams.get('redirectTo')));
	}
};
