import { m } from '#lib/paraglide/messages.js';
import type { EstadoAula } from '#lib/types/database.ts';

export const ESTADOS: readonly EstadoAula[] = ['limpio', 'sucio'];

const ESTADO_LABEL: Record<EstadoAula, () => string> = {
	limpio: m.estado_limpio,
	sucio: m.estado_sucio
};

/** Localized display label; the DB enum value itself is never translated. */
export function estadoLabel(estado: EstadoAula) {
	return ESTADO_LABEL[estado]();
}

export function isEstado(value: unknown): value is EstadoAula {
	return typeof value === 'string' && (ESTADOS as readonly string[]).includes(value);
}

/** Mirrors the DB trigger: reporting `sucio` requires photo evidence; `limpio` needs none. */
export function requiresPhoto(estado: EstadoAula | null) {
	return estado === 'sucio';
}
