import { error } from '@sveltejs/kit';
import { m } from '#lib/paraglide/messages.js';
import type { PageServerLoad } from './$types';

const RECENT_REPORTS = 10;

export const load: PageServerLoad = async ({ locals }) => {
	if (locals.profile?.rol === 'admin') {
		const { data: aulas, error: dbError } = await locals.supabase
			.from('aulas')
			.select('id, nombre, estado_actual, actualizado_en')
			.order('id');

		if (dbError) error(500, m.home_load_error());
		return { kind: 'admin' as const, aulas };
	}

	// Presidentes reach a classroom through its QR code, so the home never lists classrooms.
	// RLS (reportes_select_authenticated) allows reading reports; the filter keeps it to their own.
	const userId = locals.user?.id;
	if (!userId) return { kind: 'presidente' as const, reportes: [] };

	const { data: reportes, error: dbError } = await locals.supabase
		.from('reportes')
		.select('id, estado, creado_en, aula:aulas(nombre)')
		.eq('usuario_id', userId)
		.order('creado_en', { ascending: false })
		.limit(RECENT_REPORTS);

	if (dbError) error(500, m.home_mine_load_error());
	return { kind: 'presidente' as const, reportes };
};
