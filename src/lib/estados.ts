import type { EstadoAula } from '#lib/types/database.ts';

export const ESTADOS: readonly EstadoAula[] = ['limpio', 'medio_limpio', 'sucio'];

export const ESTADO_LABEL: Record<EstadoAula, string> = {
	limpio: 'Limpio',
	medio_limpio: 'Medio limpio',
	sucio: 'Sucio'
};

export function isEstado(value: unknown): value is EstadoAula {
	return typeof value === 'string' && (ESTADOS as readonly string[]).includes(value);
}

/** Mirrors the DB trigger: leaving the `sucio` state requires photo evidence. */
export function requiresPhoto(estadoActual: EstadoAula, nuevoEstado: EstadoAula | null) {
	return estadoActual === 'sucio' && nuevoEstado !== null && nuevoEstado !== 'sucio';
}
