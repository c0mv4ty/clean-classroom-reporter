<script lang="ts">
	import EstadoBadge from '#lib/components/EstadoBadge.svelte';
	import { ICON_SIZE } from '#lib/components/icon-size.ts';
	import { ChevronLeft, ChevronRight, ExternalLink } from '@lucide/svelte';
	import PageHeader from '#lib/components/PageHeader.svelte';
	import PreviousReport from '#lib/components/PreviousReport.svelte';
	import ReporterSummary from '#lib/components/ReporterSummary.svelte';
	import { m } from '#lib/paraglide/messages.js';
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
	<title>{m.meta_title({ page: m.nav_history() })}</title>
</svelte:head>

<PageHeader
	title={m.admin_history_title()}
	description={m.admin_history_count({ count: data.total })}
>
	{#snippet aside()}
		<form method="GET" class="filtro">
			<label class="field">
				<span class="field-label">{m.admin_filter_label()}</span>
				<select
					class="input"
					name="aula"
					value={data.aulaId ?? ''}
					onchange={(e) => e.currentTarget.form?.requestSubmit()}
				>
					<option value="">{m.admin_filter_all()}</option>
					{#each data.aulas as aula (aula.id)}
						<option value={aula.id}>{aula.nombre}</option>
					{/each}
				</select>
			</label>
			<noscript><button type="submit" class="btn">{m.admin_filter_submit()}</button></noscript>
		</form>
	{/snippet}
</PageHeader>

<ReporterSummary items={data.resumen} aulaNombre={data.aulaNombre} />

{#if data.reportes.length === 0}
	<p class="empty muted">{data.aulaId ? m.admin_empty_filtered() : m.admin_empty()}</p>
{:else}
	<div class="table-card">
		<table class="rtable">
			<thead>
				<tr>
					<th scope="col">{m.admin_col_date()}</th>
					<th scope="col">{m.admin_col_classroom()}</th>
					<th scope="col">{m.admin_col_status()}</th>
					<th scope="col">{m.admin_col_previous()}</th>
					<th scope="col">{m.admin_col_note()}</th>
					<th scope="col">{m.admin_col_president()}</th>
					<th scope="col">{m.admin_col_evidence()}</th>
				</tr>
			</thead>
			<tbody>
				{#each data.reportes as r (r.id)}
					<tr>
						<td data-label={m.admin_col_date()} class="nowrap">{formatDateTime(r.creado_en)}</td>
						<td data-label={m.admin_col_classroom()}><strong>{r.aula?.nombre ?? '—'}</strong></td>
						<td data-label={m.admin_col_status()}><span><EstadoBadge estado={r.estado} /></span></td
						>
						{#if r.anterior !== undefined}
							<td data-label={m.admin_col_previous()}>
								<PreviousReport previous={r.anterior} />
							</td>
						{:else}
							<td class="na" aria-hidden="true"></td>
						{/if}
						<td data-label={m.admin_col_note()}>{r.nota ?? '—'}</td>
						<td data-label={m.admin_col_president()}>{r.usuario?.nombre ?? '—'}</td>
						<td data-label={m.admin_col_evidence()}>
							{#if r.fotoUrl}
								<a class="foto" href={r.fotoUrl} target="_blank" rel="noopener noreferrer">
									{m.admin_photo_view()}
									<ExternalLink size={ICON_SIZE.sm} aria-hidden="true" />
									<span class="visually-hidden">{m.admin_new_tab()}</span>
								</a>
							{:else if r.foto_path}
								<span class="muted">{m.admin_photo_unavailable()}</span>
							{:else}
								<span class="muted">{m.admin_photo_none()}</span>
							{/if}
						</td>
					</tr>
				{/each}
			</tbody>
		</table>
	</div>

	{#if data.totalPages > 1}
		<nav class="paginacion" aria-label={m.admin_pagination_aria()}>
			{#if data.page > 1}
				<a class="btn" href={pageHref(data.page - 1)}
					><ChevronLeft size={ICON_SIZE.sm} aria-hidden="true" /> {m.admin_prev()}</a
				>
			{/if}
			<span class="muted">{m.admin_page_of({ page: data.page, total: data.totalPages })}</span>
			{#if data.page < data.totalPages}
				<a class="btn" href={pageHref(data.page + 1)}
					>{m.admin_next()} <ChevronRight size={ICON_SIZE.sm} aria-hidden="true" /></a
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

	/* Previous-report cell only applies to dirty reports: hide the empty cell when rows are stacked. */
	td.na {
		display: none;
	}

	@media (min-width: 640px) {
		td.na {
			display: table-cell;
		}
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
