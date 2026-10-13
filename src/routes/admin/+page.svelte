<script lang="ts">
	import EstadoBadge from '#lib/components/EstadoBadge.svelte';
	import { ICON_SIZE } from '#lib/components/icon-size.ts';
	import { ChevronLeft, ChevronRight, ExternalLink } from '@lucide/svelte';
	import PageHeader from '#lib/components/PageHeader.svelte';
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
	<title>Historial · ESPOCH Aulas limpias</title>
</svelte:head>

<PageHeader
	title="Historial de reportes"
	description="{data.total} {data.total === 1 ? 'reporte registrado' : 'reportes registrados'}"
>
	{#snippet aside()}
		<form method="GET" class="filtro">
			<label class="field">
				<span class="field-label">Filtrar por aula</span>
				<select
					class="input"
					name="aula"
					value={data.aulaId ?? ''}
					onchange={(e) => e.currentTarget.form?.requestSubmit()}
				>
					<option value="">Todas las aulas</option>
					{#each data.aulas as aula (aula.id)}
						<option value={aula.id}>{aula.nombre}</option>
					{/each}
				</select>
			</label>
			<noscript><button type="submit" class="btn">Filtrar</button></noscript>
		</form>
	{/snippet}
</PageHeader>

{#if data.reportes.length === 0}
	<p class="empty muted">
		{data.aulaId
			? 'Esta aula aún no tiene reportes.'
			: 'Todavía no se ha registrado ningún reporte.'}
	</p>
{:else}
	<div class="table-card">
		<table class="rtable">
			<thead>
				<tr>
					<th scope="col">Fecha</th>
					<th scope="col">Aula</th>
					<th scope="col">Estado</th>
					<th scope="col">Nota</th>
					<th scope="col">Presidente</th>
					<th scope="col">Evidencia</th>
				</tr>
			</thead>
			<tbody>
				{#each data.reportes as r (r.id)}
					<tr>
						<td data-label="Fecha" class="nowrap">{formatDateTime(r.creado_en)}</td>
						<td data-label="Aula"><strong>{r.aula?.nombre ?? '—'}</strong></td>
						<td data-label="Estado"><span><EstadoBadge estado={r.estado} /></span></td>
						<td data-label="Nota">{r.nota ?? '—'}</td>
						<td data-label="Presidente">{r.usuario?.nombre ?? '—'}</td>
						<td data-label="Evidencia">
							{#if r.fotoUrl}
								<a class="foto" href={r.fotoUrl} target="_blank" rel="noopener noreferrer">
									Ver foto <ExternalLink size={ICON_SIZE.sm} aria-hidden="true" />
									<span class="visually-hidden">(se abre en otra pestaña)</span>
								</a>
							{:else if r.foto_path}
								<span class="muted">No disponible</span>
							{:else}
								<span class="muted">Sin foto</span>
							{/if}
						</td>
					</tr>
				{/each}
			</tbody>
		</table>
	</div>

	{#if data.totalPages > 1}
		<nav class="paginacion" aria-label="Paginación">
			{#if data.page > 1}
				<a class="btn" href={pageHref(data.page - 1)}
					><ChevronLeft size={ICON_SIZE.sm} aria-hidden="true" /> Anterior</a
				>
			{/if}
			<span class="muted">Página {data.page} de {data.totalPages}</span>
			{#if data.page < data.totalPages}
				<a class="btn" href={pageHref(data.page + 1)}
					>Siguiente <ChevronRight size={ICON_SIZE.sm} aria-hidden="true" /></a
				>
			{/if}
		</nav>
	{/if}
{/if}

<style>
	.filtro {
		width: 100%;
		min-width: min(100%, 16rem);
	}

	.nowrap {
		white-space: nowrap;
	}

	.foto {
		display: inline-flex;
		align-items: center;
		gap: var(--space-1);
		font-weight: 600;
	}

	.empty {
		padding: var(--space-5);
		text-align: center;
		background: var(--color-surface);
		border: var(--border-width) dashed var(--color-border-strong);
		border-radius: var(--radius-md);
	}

	.paginacion {
		display: flex;
		flex-wrap: wrap;
		gap: var(--space-3);
		align-items: center;
		justify-content: center;
		font-size: var(--text-sm);
	}
</style>
