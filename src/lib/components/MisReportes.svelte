<script lang="ts">
	import Card from './Card.svelte';
	import EstadoBadge from './EstadoBadge.svelte';
	import { m } from '#lib/paraglide/messages.js';
	import { formatDateTime } from '#lib/format.ts';
	import type { EstadoAula } from '#lib/types/database.ts';

	type Reporte = {
		id: string;
		estado: EstadoAula;
		creado_en: string;
		aula: { nombre: string } | null;
	};

	let { reportes }: { reportes: Reporte[] } = $props();
</script>

<Card title={m.home_mine_title()}>
	{#if reportes.length === 0}
		<p class="muted">{m.home_mine_empty()}</p>
	{:else}
		<ul class="list">
			{#each reportes as reporte (reporte.id)}
				<li class="row">
					<strong class="name">{reporte.aula?.nombre ?? '-'}</strong>
					<EstadoBadge estado={reporte.estado} />
					<time class="when" datetime={reporte.creado_en}>
						{formatDateTime(reporte.creado_en)}
					</time>
				</li>
			{/each}
		</ul>
	{/if}
</Card>

<style>
	.list {
		list-style: none;
		margin: 0;
		padding: 0;
	}

	.row {
		display: flex;
		flex-wrap: wrap;
		align-items: center;
		gap: var(--space-1) var(--space-3);
		padding-block: var(--space-3);
		border-bottom: var(--border-width) solid var(--color-border);
	}

	.row:first-child {
		padding-top: 0;
	}

	.row:last-child {
		padding-bottom: 0;
		border-bottom: none;
	}

	.name {
		font-family: var(--font-heading);
		font-weight: 700;
		color: var(--color-heading);
		min-width: 0;
	}

	.when {
		flex-basis: 100%;
		font-size: var(--text-xs);
		color: var(--color-text-muted);
	}

	@media (min-width: 640px) {
		.name {
			flex: 1;
		}

		.when {
			flex-basis: auto;
			font-size: var(--text-sm);
		}
	}
</style>
