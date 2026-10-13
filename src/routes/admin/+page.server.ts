import { error } from '@sveltejs/kit';
import { m } from '#lib/paraglide/messages.js';
import { assertAdmin } from '#lib/server/guards.ts';
import type { PageServerLoad } from './$types';

const PAGE_SIZE = 50;
const SIGNED_URL_TTL_SECONDS = 60 * 60;

export const load: PageServerLoad = async ({ locals, url }) => {
	assertAdmin(locals);

	const aulaParam = Number(url.searchParams.get('aula'));
	const aulaId = Number.isInteger(aulaParam) && aulaParam > 0 ? aulaParam : null;
	const pageParam = Number(url.searchParams.get('page'));
	const page = Number.isInteger(pageParam) && pageParam > 0 ? pageParam : 1;
	const from = (page - 1) * PAGE_SIZE;

	let query = locals.supabase
		.from('reportes')
		.select(
			'id, estado, nota, foto_path, creado_en, aula:aulas(id, nombre), usuario:profiles(nombre)',
			{ count: 'exact' }
		)
		.order('creado_en', { ascending: false })
		.range(from, from + PAGE_SIZE - 1);
	if (aulaId) query = query.eq('aula_id', aulaId);

	const [reportesResult, aulasResult] = await Promise.all([
		query,
		locals.supabase.from('aulas').select('id, nombre').order('id')
	]);

	if (reportesResult.error || aulasResult.error) error(500, m.admin_load_error());

	const reportes = reportesResult.data;
	const paths = reportes.map((r) => r.foto_path).filter((p): p is string => !!p);

	const signedUrls = new Map<string, string>();
	if (paths.length > 0) {
		const { data: signed } = await locals.supabase.storage
			.from('evidencias')
			.createSignedUrls(paths, SIGNED_URL_TTL_SECONDS);
		for (const s of signed ?? []) {
			if (s.path && s.signedUrl) signedUrls.set(s.path, s.signedUrl);
		}
	}

	const total = reportesResult.count ?? 0;

	return {
		aulas: aulasResult.data,
		aulaId,
		page,
		totalPages: Math.max(1, Math.ceil(total / PAGE_SIZE)),
		total,
		reportes: reportes.map((r) => ({
			...r,
			fotoUrl: r.foto_path ? (signedUrls.get(r.foto_path) ?? null) : null
		}))
	};
};
