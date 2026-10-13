<script lang="ts">
	import AulaCard from '#lib/components/AulaCard.svelte';
	import PageHeader from '#lib/components/PageHeader.svelte';
	import StateSummary from '#lib/components/StateSummary.svelte';
	import { formatDateTime } from '#lib/format.ts';
	import type { PageProps } from './$types';

	let { data }: PageProps = $props();

	const ultimaActualizacion = $derived(
		data.aulas
			.map((a) => a.actualizado_en)
			.filter((d): d is string => Boolean(d))
			.sort()
			.at(-1)
	);
</script>

<svelte:head>
	<title>Aulas · ESPOCH Aulas limpias</title>
</svelte:head>

<PageHeader
	title="Estado de las aulas"
	description={ultimaActualizacion
		? `Última actualización: ${formatDateTime(ultimaActualizacion)}. Elige un aula para reportar su estado.`
		: 'Elige un aula para reportar su estado.'}
/>

<StateSummary estados={data.aulas.map((a) => a.estado_actual)} />

{#if data.aulas.length === 0}
	<p class="empty muted">
		No hay aulas registradas todavía. La administración debe cargarlas primero.
	</p>
{:else}
	<ul class="grid" aria-label="Aulas">
		{#each data.aulas as aula (aula.id)}
			<li><AulaCard {aula} /></li>
		{/each}
	</ul>
{/if}

<style>
	.grid {
		list-style: none;
		padding: 0;
		margin: 0;
		display: grid;
		grid-template-columns: repeat(2, minmax(0, 1fr));
		gap: var(--space-3);
	}

	.grid li {
		min-width: 0;
	}

	.empty {
		padding: var(--space-5);
		text-align: center;
		background: var(--color-surface);
		border: var(--border-width) dashed var(--color-border-strong);
		border-radius: var(--radius-md);
	}

	@media (min-width: 640px) {
		.grid {
			grid-template-columns: repeat(3, minmax(0, 1fr));
			gap: var(--space-4);
		}
	}

	@media (min-width: 1024px) {
		.grid {
			grid-template-columns: repeat(4, minmax(0, 1fr));
		}
	}
</style>
