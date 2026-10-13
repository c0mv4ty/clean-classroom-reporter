import { error } from '@sveltejs/kit';
import { m } from '#lib/paraglide/messages.js';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
	const { data: aulas, error: dbError } = await locals.supabase
		.from('aulas')
		.select('id, nombre, estado_actual, actualizado_en')
		.order('id');

	if (dbError) error(500, m.home_load_error());
	return { aulas };
};
