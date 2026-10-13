<script lang="ts">
	import EstadoIcon from './EstadoIcon.svelte';
	import { m } from '#lib/paraglide/messages.js';
	import { estadoLabel, ESTADOS } from '#lib/estados.ts';
	import type { EstadoAula } from '#lib/types/database.ts';

	let { estados }: { estados: EstadoAula[] } = $props();

	const resumen = $derived(
		ESTADOS.map((estado) => ({
			estado,
			total: estados.filter((e) => e === estado).length
		}))
	);
</script>

<ul class="summary" aria-label={m.estado_summary_aria()}>
	{#each resumen as r (r.estado)}
		<li class="chip {r.estado}">
			<span class="dot"><EstadoIcon estado={r.estado} size="md" /></span>
			<span class="label">{estadoLabel(r.estado)}</span>
			<strong class="count">{r.total}</strong>
		</li>
	{/each}
</ul>

<style>
	.summary {
		list-style: none;
		margin: 0;
		padding: 0;
		display: grid;
		grid-template-columns: repeat(3, minmax(0, 1fr));
		gap: var(--space-2);
	}

	.chip {
		display: grid;
		grid-template-columns: auto minmax(0, 1fr);
		grid-template-areas:
			'dot count'
			'label label';
		align-items: center;
		gap: var(--space-1) var(--space-2);
		padding: var(--space-3);
		border: var(--border-width) solid;
		border-radius: var(--radius-md);
		min-width: 0;
	}

	.dot {
		grid-area: dot;
		display: inline-grid;
		place-items: center;
	}

	.count {
		grid-area: count;
		font-family: var(--font-heading);
		font-size: var(--text-xl);
		line-height: 1;
		justify-self: end;
	}

	.label {
		grid-area: label;
		font-size: var(--text-xs);
		font-weight: 600;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	.limpio {
		background: var(--color-limpio-bg);
		border-color: var(--color-limpio-border);
		color: var(--color-limpio-fg);
	}

	.medio_limpio {
		background: var(--color-medio-bg);
		border-color: var(--color-medio-border);
		color: var(--color-medio-fg);
	}

	.sucio {
		background: var(--color-sucio-bg);
		border-color: var(--color-sucio-border);
		color: var(--color-sucio-fg);
	}

	@media (min-width: 640px) {
		.summary {
			display: flex;
			flex-wrap: wrap;
		}

		.chip {
			grid-template-columns: auto auto auto;
			grid-template-areas: 'dot label count';
			gap: var(--space-2);
			padding: var(--space-2) var(--space-4) var(--space-2) var(--space-2);
			border-radius: var(--radius-pill);
		}

		.label {
			font-size: var(--text-sm);
		}

		.count {
			font-size: var(--text-lg);
		}
	}
</style>
