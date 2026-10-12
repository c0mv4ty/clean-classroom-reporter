import { fail, redirect } from '@sveltejs/kit';
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
			return fail(400, { email, message: 'Ingresa tu correo y contraseña.' });
		}

		const { error } = await locals.supabase.auth.signInWithPassword({ email, password });
		if (error) {
			return fail(400, { email, message: 'Correo o contraseña incorrectos.' });
		}

		redirect(303, safeRedirect(url.searchParams.get('redirectTo')));
	}
};
