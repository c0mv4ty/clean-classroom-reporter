import { error, fail } from '@sveltejs/kit';
import { assertAdmin } from '#lib/server/guards.ts';
import { createAdminClient } from '#lib/server/supabase-admin.ts';
import type { Rol } from '#lib/types/database.ts';
import type { Actions, PageServerLoad } from './$types';

const MIN_PASSWORD_LENGTH = 8;

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

	if (profilesResult.error) error(500, 'No se pudieron cargar los usuarios.');

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
			return fail(400, { ...values, message: 'Correo y nombre son obligatorios.' });
		}
		if (password.length < MIN_PASSWORD_LENGTH) {
			return fail(400, {
				...values,
				message: `La contraseña debe tener al menos ${MIN_PASSWORD_LENGTH} caracteres.`
			});
		}
		if (!isRol(rol)) {
			return fail(400, { ...values, message: 'Rol inválido.' });
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
					? 'Ya existe un usuario con ese correo.'
					: 'No se pudo crear el usuario.';
			return fail(400, { ...values, message });
		}

		return { created: email };
	}
};
