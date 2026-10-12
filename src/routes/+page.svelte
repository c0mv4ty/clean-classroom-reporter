<script lang="ts">
	import EstadoBadge from '#lib/components/EstadoBadge.svelte';
	import { ESTADO_LABEL, ESTADOS } from '#lib/estados.ts';
	import { formatDateTime } from '#lib/format.ts';
	import type { PageProps } from './$types';

	let { data }: PageProps = $props();

	const resumen = $derived(
		ESTADOS.map((estado) => ({
			estado,
			total: data.aulas.filter((a) => a.estado_actual === estado).length
		}))
	);
</script>

<svelte:head>
	<title>Aulas · Aulas limpias</title>
</svelte:head>

<h1>Estado de las aulas</h1>

<p class="resumen">
	{#each resumen as r (r.estado)}
		<span class="badge {r.estado}">{ESTADO_LABEL[r.estado]}: {r.total}</span>
	{/each}
</p>

<ul class="grid">
	{#each data.aulas as aula (aula.id)}
		<li>
			<a class="card aula {aula.estado_actual}" href="/aulas/{aula.id}">
				<strong>{aula.nombre}</strong>
				<EstadoBadge estado={aula.estado_actual} />
				<small class="muted">Actualizado: {formatDateTime(aula.actualizado_en)}</small>
			</a>
		</li>
	{/each}
</ul>

<style>
	.resumen {
		display: flex;
		flex-wrap: wrap;
		gap: 0.5rem;
		margin: 0 0 1rem;
	}

	.grid {
		list-style: none;
		padding: 0;
		margin: 0;
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(9.5rem, 1fr));
		gap: 0.75rem;
	}

	.aula {
		display: grid;
		gap: 0.4rem;
		justify-items: start;
		text-decoration: none;
		color: inherit;
		border-left: 5px solid var(--border);
		height: 100%;
	}

	.aula.limpio {
		border-left-color: var(--limpio);
	}

	.aula.medio_limpio {
		border-left-color: var(--medio);
	}

	.aula.sucio {
		border-left-color: var(--sucio);
	}

	.aula:hover,
	.aula:focus-visible {
		box-shadow: 0 2px 8px rgb(0 0 0 / 8%);
	}
</style>
