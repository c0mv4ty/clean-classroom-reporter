import { error } from '@sveltejs/kit';
import { renderSVG } from 'uqr';
import { m } from '#lib/paraglide/messages.js';
import { assertAdmin } from '#lib/server/guards.ts';
import type { PageServerLoad } from './$types';

/** Standard quiet zone is 4 modules; error correction M survives a smudged sticker. */
const QR_OPTIONS = { border: 4, ecc: 'M' } as const;

const LOCAL_HOSTS = new Set(['localhost', '127.0.0.1', '[::1]', '0.0.0.0']);

export const load: PageServerLoad = async ({ locals, url }) => {
	assertAdmin(locals);

	const { data, error: loadError } = await locals.supabase
		.from('aulas')
		.select('id, nombre')
		.order('id');
	if (loadError) error(500, m.admin_load_error());

	return {
		origin: url.origin,
		isLocalOrigin: LOCAL_HOSTS.has(url.hostname),
		aulas: data.map((aula) => ({
			id: aula.id,
			nombre: aula.nombre,
			svg: renderSVG(`${url.origin}/aulas/${aula.id}`, QR_OPTIONS)
		}))
	};
};
