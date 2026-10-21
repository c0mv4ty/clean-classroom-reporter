import { error, fail } from '@sveltejs/kit';
import { isEstado, requiresPhoto } from '#lib/estados.ts';
import { m } from '#lib/paraglide/messages.js';
import type { Actions, PageServerLoad } from './$types';

const MAX_NOTE_LENGTH = 500;
const MAX_PHOTO_BYTES = 10 * 1024 * 1024;
const RECENT_REPORTS = 10;
const EVIDENCE_REQUIRED_HINT = 'evidencia_requerida';

const EXTENSION_BY_TYPE: Record<string, string> = {
	'image/jpeg': 'jpg',
	'image/png': 'png',
	'image/webp': 'webp',
	'image/heic': 'heic',
	'image/heif': 'heif'
};

function parseAulaId(raw: string) {
	const id = Number(raw);
	if (!Number.isInteger(id) || id <= 0) error(404, m.aula_not_found());
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

	if (aulaResult.error || reportesResult.error) error(500, m.aula_load_error());
	if (!aulaResult.data) error(404, m.aula_not_found());

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
		const fotoField = form.get('foto');

		if (!isEstado(estado)) {
			return fail(400, { nota, message: m.report_error_estado_missing() });
		}
		if (nota.length > MAX_NOTE_LENGTH) {
			return fail(400, {
				nota,
				message: m.report_error_note_too_long({ max: MAX_NOTE_LENGTH })
			});
		}

		// A photo only counts as evidence for a `sucio` report; for `limpio` any file is ignored
		// and never uploaded.
		const foto =
			requiresPhoto(estado) && fotoField instanceof File && fotoField.size > 0 ? fotoField : null;

		// Early, friendly check. The DB trigger enforces the same rule authoritatively.
		if (requiresPhoto(estado) && !foto) {
			return fail(400, { nota, message: m.report_error_evidence_required() });
		}
		if (foto && !EXTENSION_BY_TYPE[foto.type]) {
			return fail(400, { nota, message: m.report_error_photo_type() });
		}
		if (foto && foto.size > MAX_PHOTO_BYTES) {
			return fail(400, {
				nota,
				message: m.report_error_photo_size({ max: MAX_PHOTO_BYTES / (1024 * 1024) })
			});
		}

		let fotoPath: string | null = null;
		if (foto) {
			fotoPath = `${aulaId}/${crypto.randomUUID()}.${EXTENSION_BY_TYPE[foto.type]}`;
			const { error: uploadError } = await locals.supabase.storage
				.from('evidencias')
				.upload(fotoPath, foto, { contentType: foto.type, upsert: false });
			if (uploadError) {
				return fail(500, { nota, message: m.report_error_upload() });
			}
		}

		const { error: insertError } = await locals.supabase.from('reportes').insert({
			aula_id: aulaId,
			estado,
			nota: nota || null,
			foto_path: fotoPath
		});

		if (insertError) {
			// 23514 = check_violation raised by our trigger; its hint identifies the evidence rule,
			// so the user-facing text is localized here instead of echoing the DB's Spanish message.
			// An uploaded photo stays orphaned in Storage; only admins may delete objects.
			const message =
				insertError.code === '23514' && insertError.hint === EVIDENCE_REQUIRED_HINT
					? m.report_error_evidence_required()
					: m.report_error_save();
			return fail(400, { nota, message });
		}

		return { success: true };
	}
};
