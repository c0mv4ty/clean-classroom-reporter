import { error, fail } from '@sveltejs/kit';
import { MIN_PASSWORD_LENGTH } from '#lib/constants.ts';
import { m } from '#lib/paraglide/messages.js';
import { assertAdmin } from '#lib/server/guards.ts';
import { createAdminClient } from '#lib/server/supabase-admin.ts';
import type { Rol } from '#lib/types/database.ts';
import type { Actions, PageServerLoad } from './$types';

function isRol(value: unknown): value is Rol {
	return value === 'presidente' || value === 'admin';
}

export const load: PageServerLoad = async ({ locals }) => {
	assertAdmin(locals);

	const admin = createAdminClient();
	const [profilesResult, usersResult] = await Promise.all([
		locals.supabase.from('profiles').select('id, nombre, rol, creado_en').order('nombre'),
		admin.auth.admin.listUsers({ page: 1, perPage: 1000 })
	]);

	if (profilesResult.error) error(500, m.admin_users_load_error());

	const emailById = new Map(
		(usersResult.data?.users ?? []).map((u) => [u.id, u.email ?? ''] as const)
	);

	return {
		usuarios: profilesResult.data.map((p) => ({ ...p, email: emailById.get(p.id) ?? '' }))
	};
};

export const actions: Actions = {
	create: async ({ request, locals }) => {
		assertAdmin(locals);

		const form = await request.formData();
		const email = String(form.get('email') ?? '')
			.trim()
			.toLowerCase();
		const nombre = String(form.get('nombre') ?? '').trim();
		const password = String(form.get('password') ?? '');
		const rol = form.get('rol');
		const values = { email, nombre, rol: isRol(rol) ? rol : 'presidente' };

		if (!email || !nombre) {
			return fail(400, { ...values, message: m.admin_users_error_required() });
		}
		if (password.length < MIN_PASSWORD_LENGTH) {
			return fail(400, {
				...values,
				message: m.admin_users_error_password_short({ min: MIN_PASSWORD_LENGTH })
			});
		}
		if (!isRol(rol)) {
			return fail(400, { ...values, message: m.admin_users_error_role() });
		}

		const { error: createError } = await createAdminClient().auth.admin.createUser({
			email,
			password,
			email_confirm: true,
			user_metadata: { nombre },
			// app_metadata is not user-editable; the DB trigger reads `rol` from here.
			app_metadata: { rol }
		});

		if (createError) {
			const message =
				createError.status === 422 || /already/i.test(createError.message)
					? m.admin_users_error_duplicate()
					: m.admin_users_error_create();
			return fail(400, { ...values, message });
		}

		return { created: email };
	}
};
