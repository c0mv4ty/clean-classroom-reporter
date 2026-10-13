<script lang="ts">
	import EstadoBadge from './EstadoBadge.svelte';
	import { ChevronRight } from '@lucide/svelte';
	import { ICON_SIZE } from './icon-size.ts';
	import { formatDateTime } from '#lib/format.ts';
	import type { EstadoAula } from '#lib/types/database.ts';

	type Aula = {
		id: number;
		nombre: string;
		estado_actual: EstadoAula;
		actualizado_en: string | null;
	};

	let { aula }: { aula: Aula } = $props();
</script>

<a class="aula {aula.estado_actual}" href="/aulas/{aula.id}">
	<span class="top">
		<strong class="name">{aula.nombre}</strong>
		<span class="go"><ChevronRight size={ICON_SIZE.md} aria-hidden="true" /></span>
	</span>
	<EstadoBadge estado={aula.estado_actual} />
	<small class="updated">
		{aula.actualizado_en
			? `Actualizado ${formatDateTime(aula.actualizado_en)}`
			: 'Sin reportes aún'}
	</small>
</a>

<style>
	.aula {
		display: grid;
		gap: var(--space-2);
		justify-items: start;
		align-content: start;
		height: 100%;
		min-height: calc(var(--touch) * 2.5);
		padding: var(--space-3);
		background: var(--color-surface);
		border: var(--border-width) solid var(--color-border);
		border-radius: var(--radius-md);
		box-shadow: var(--shadow-sm);
		color: inherit;
		text-decoration: none;
		transition:
			border-color var(--duration-fast) var(--ease-out),
			box-shadow var(--duration-fast) var(--ease-out),
			transform var(--duration-fast) var(--ease-out);
	}

	.aula.sucio {
		border-color: var(--color-sucio-border);
	}

	.aula:hover {
		color: inherit;
		border-color: var(--color-border-strong);
		box-shadow: var(--shadow-md);
		transform: translateY(-1px);
	}

	.top {
		display: flex;
		align-items: flex-start;
		justify-content: space-between;
		gap: var(--space-2);
		width: 100%;
		min-width: 0;
	}

	.name {
		font-family: var(--font-heading);
		font-size: var(--text-base);
		font-weight: 700;
		line-height: var(--leading-tight);
		color: var(--color-heading);
		min-width: 0;
	}

	.go {
		color: var(--color-text-subtle);
		transition: color var(--duration-fast) var(--ease-out);
	}

	.aula:hover .go {
		color: var(--color-link);
	}

	.updated {
		font-size: var(--text-xs);
		color: var(--color-text-muted);
	}

	@media (min-width: 640px) {
		.aula {
			padding: var(--space-4);
		}

		.name {
			font-size: var(--text-lg);
		}
	}
</style>
