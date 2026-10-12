import { error } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
	const { data: aulas, error: dbError } = await locals.supabase
		.from('aulas')
		.select('id, nombre, estado_actual, actualizado_en')
		.order('id');

	if (dbError) error(500, 'No se pudieron cargar las aulas.');
	return { aulas };
};
