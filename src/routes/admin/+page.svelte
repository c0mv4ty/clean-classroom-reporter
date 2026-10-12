<script lang="ts">
	import EstadoBadge from '#lib/components/EstadoBadge.svelte';
	import { formatDateTime } from '#lib/format.ts';
	import type { PageProps } from './$types';

	let { data }: PageProps = $props();

	function pageHref(page: number) {
		const params = new URLSearchParams();
		if (data.aulaId) params.set('aula', String(data.aulaId));
		if (page > 1) params.set('page', String(page));
		const qs = params.toString();
		return qs ? `/admin?${qs}` : '/admin';
	}
</script>

<svelte:head>
	<title>Historial · Aulas limpias</title>
</svelte:head>

<h1>Historial de reportes</h1>

<form method="GET" class="filtro">
	<label>
		Aula
		<select
			name="aula"
			value={data.aulaId ?? ''}
			onchange={(e) => e.currentTarget.form?.requestSubmit()}
		>
			<option value="">Todas</option>
			{#each data.aulas as aula (aula.id)}
				<option value={aula.id}>{aula.nombre}</option>
			{/each}
		</select>
	</label>
	<noscript><button type="submit">Filtrar</button></noscript>
</form>

<p class="muted">{data.total} reporte(s)</p>

{#if data.reportes.length === 0}
	<p class="muted">No hay reportes.</p>
{:else}
	<div class="table-wrap">
		<table>
			<thead>
				<tr>
					<th>Fecha</th>
					<th>Aula</th>
					<th>Estado</th>
					<th>Nota</th>
					<th>Presidente</th>
					<th>Evidencia</th>
				</tr>
			</thead>
			<tbody>
				{#each data.reportes as r (r.id)}
					<tr>
						<td>{formatDateTime(r.creado_en)}</td>
						<td>{r.aula?.nombre ?? '—'}</td>
						<td><EstadoBadge estado={r.estado} /></td>
						<td>{r.nota ?? ''}</td>
						<td>{r.usuario?.nombre ?? '—'}</td>
						<td>
							{#if r.fotoUrl}
								<a href={r.fotoUrl} target="_blank" rel="noopener noreferrer">Ver foto</a>
							{:else if r.foto_path}
								<span class="muted">No disponible</span>
							{:else}
								<span class="muted">—</span>
							{/if}
						</td>
					</tr>
				{/each}
			</tbody>
		</table>
	</div>

	{#if data.totalPages > 1}
		<nav class="paginacion" aria-label="Paginación">
			{#if data.page > 1}<a href={pageHref(data.page - 1)}>← Anterior</a>{/if}
			<span class="muted">Página {data.page} de {data.totalPages}</span>
			{#if data.page < data.totalPages}<a href={pageHref(data.page + 1)}>Siguiente →</a>{/if}
		</nav>
	{/if}
{/if}

<style>
	.filtro {
		max-width: 18rem;
		margin-bottom: 0.5rem;
	}

	.paginacion {
		display: flex;
		gap: 1rem;
		align-items: center;
		justify-content: center;
		margin-top: 1rem;
	}
</style>
