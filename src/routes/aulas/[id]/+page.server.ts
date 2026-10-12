import { error, fail } from '@sveltejs/kit';
import { isEstado, requiresPhoto } from '#lib/estados.ts';
import type { Actions, PageServerLoad } from './$types';

const MAX_NOTE_LENGTH = 500;
const MAX_PHOTO_BYTES = 10 * 1024 * 1024;
const RECENT_REPORTS = 10;

const EXTENSION_BY_TYPE: Record<string, string> = {
	'image/jpeg': 'jpg',
	'image/png': 'png',
	'image/webp': 'webp',
	'image/heic': 'heic',
	'image/heif': 'heif'
};

function parseAulaId(raw: string) {
	const id = Number(raw);
	if (!Number.isInteger(id) || id <= 0) error(404, 'Aula no encontrada.');
	return id;
}

export const load: PageServerLoad = async ({ params, locals }) => {
	const aulaId = parseAulaId(params.id);

	const [aulaResult, reportesResult] = await Promise.all([
		locals.supabase
			.from('aulas')
			.select('id, nombre, estado_actual, actualizado_en')
			.eq('id', aulaId)
			.maybeSingle(),
		locals.supabase
			.from('reportes')
			.select('id, estado, nota, foto_path, creado_en, usuario_id')
			.eq('aula_id', aulaId)
			.order('creado_en', { ascending: false })
			.limit(RECENT_REPORTS)
	]);

	if (aulaResult.error || reportesResult.error) error(500, 'No se pudo cargar el aula.');
	if (!aulaResult.data) error(404, 'Aula no encontrada.');

	return {
		aula: aulaResult.data,
		reportes: reportesResult.data,
		userId: locals.user?.id ?? null
	};
};

export const actions: Actions = {
	default: async ({ params, request, locals }) => {
		const aulaId = parseAulaId(params.id);
		const form = await request.formData();

		const estado = form.get('estado');
		const nota = String(form.get('nota') ?? '').trim();
		const foto = form.get('foto');
		const hasPhoto = foto instanceof File && foto.size > 0;

		if (!isEstado(estado)) {
			return fail(400, { nota, message: 'Selecciona el estado del aula.' });
		}
		if (nota.length > MAX_NOTE_LENGTH) {
			return fail(400, {
				nota,
				message: `La nota no puede superar ${MAX_NOTE_LENGTH} caracteres.`
			});
		}
		if (hasPhoto && !EXTENSION_BY_TYPE[foto.type]) {
			return fail(400, { nota, message: 'La foto debe ser JPG, PNG, WEBP o HEIC.' });
		}
		if (hasPhoto && foto.size > MAX_PHOTO_BYTES) {
			return fail(400, { nota, message: 'La foto no puede superar 10 MB.' });
		}

		// Early, friendly check. The DB trigger enforces the same rule authoritatively.
		const { data: aula } = await locals.supabase
			.from('aulas')
			.select('estado_actual')
			.eq('id', aulaId)
			.maybeSingle();
		if (!aula) error(404, 'Aula no encontrada.');
		if (requiresPhoto(aula.estado_actual, estado) && !hasPhoto) {
			return fail(400, {
				nota,
				message: 'El aula estaba sucia: adjunta una foto como evidencia de la limpieza.'
			});
		}

		let fotoPath: string | null = null;
		if (hasPhoto) {
			fotoPath = `${aulaId}/${crypto.randomUUID()}.${EXTENSION_BY_TYPE[foto.type]}`;
			const { error: uploadError } = await locals.supabase.storage
				.from('evidencias')
				.upload(fotoPath, foto, { contentType: foto.type, upsert: false });
			if (uploadError) {
				return fail(500, { nota, message: 'No se pudo subir la foto. Intenta nuevamente.' });
			}
		}

		const { error: insertError } = await locals.supabase.from('reportes').insert({
			aula_id: aulaId,
			estado,
			nota: nota || null,
			foto_path: fotoPath
		});

		if (insertError) {
			// 23514 = check_violation raised by our trigger with a user-facing Spanish message.
			// An uploaded photo stays orphaned in Storage; only admins may delete objects.
			const message =
				insertError.code === '23514'
					? insertError.message
					: 'No se pudo guardar el reporte. Intenta nuevamente.';
			return fail(400, { nota, message });
		}

		return { success: true };
	}
};
