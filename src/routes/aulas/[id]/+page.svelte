<script lang="ts">
	import { enhance } from '$app/forms';
	import Button from '#lib/components/Button.svelte';
	import Card from '#lib/components/Card.svelte';
	import EstadoBadge from '#lib/components/EstadoBadge.svelte';
	import EstadoPicker from '#lib/components/EstadoPicker.svelte';
	import { ICON_SIZE } from '#lib/components/icon-size.ts';
	import { Camera, Check, ChevronLeft, TriangleAlert } from '@lucide/svelte';
	import PageHeader from '#lib/components/PageHeader.svelte';
	import PhotoPicker from '#lib/components/PhotoPicker.svelte';
	import { requiresPhoto } from '#lib/estados.ts';
	import { formatDateTime } from '#lib/format.ts';
	import { m } from '#lib/paraglide/messages.js';
	import type { EstadoAula } from '#lib/types/database.ts';
	import type { PageProps } from './$types';

	let { data, form }: PageProps = $props();

	let estado = $state<EstadoAula | null>(null);
	let submitting = $state(false);

	const estaSucia = $derived(data.aula.estado_actual === 'sucio');
	// The label reflects the evidence rule as soon as the page loads: a dirty classroom
	// needs a photo unless it is reported dirty again.
	const fotoObligatoria = $derived(estaSucia && estado !== 'sucio');
	const fotoRequerida = $derived(requiresPhoto(data.aula.estado_actual, estado));
</script>

<svelte:head>
	<title>{m.meta_title({ page: data.aula.nombre })}</title>
</svelte:head>

<a class="back" href="/"><ChevronLeft size={ICON_SIZE.md} aria-hidden="true" /> {m.aula_back()}</a>

<PageHeader
	title={data.aula.nombre}
	description={m.aula_updated_at({ date: formatDateTime(data.aula.actualizado_en) })}
>
	{#snippet aside()}
		<EstadoBadge estado={data.aula.estado_actual} />
	{/snippet}
</PageHeader>

<div class="layout">
	<Card title={m.aula_new_report()}>
		<form
			class="report-form"
			method="POST"
			enctype="multipart/form-data"
			use:enhance={() => {
				submitting = true;
				return async ({ result, update }) => {
					await update({ reset: result.type === 'success' });
					if (result.type === 'success') estado = null;
					submitting = false;
				};
			}}
		>
			<EstadoPicker name="estado" bind:value={estado} />

			<label class="field">
				<span class="field-label">{m.aula_note_label()}</span>
				<textarea
					class="input"
					name="nota"
					rows="3"
					maxlength="500"
					placeholder={m.aula_note_placeholder()}
					value={form?.nota ?? ''}></textarea>
			</label>

			<PhotoPicker
				name="foto"
				label={fotoObligatoria ? m.aula_photo_required_label() : m.aula_photo_optional_label()}
				hint={fotoObligatoria ? m.aula_photo_hint_dirty() : undefined}
				required={fotoRequerida}
			/>

			{#if form?.message}
				<p class="alert error" role="alert">
					<TriangleAlert size={ICON_SIZE.sm} aria-hidden="true" />
					{form.message}
				</p>
			{:else if form?.success}
				<p class="alert success" role="status">
					<Check size={ICON_SIZE.sm} aria-hidden="true" />
					{m.aula_saved()}
				</p>
			{/if}

			<Button type="submit" variant="primary" block disabled={submitting}>
				{submitting ? m.aula_submitting() : m.aula_submit()}
			</Button>
		</form>
	</Card>

	<section class="history" aria-labelledby="historial-titulo">
		<h2 id="historial-titulo">{m.aula_history_title()}</h2>
		{#if data.reportes.length === 0}
			<p class="muted">{m.aula_history_empty()}</p>
		{:else}
			<ol class="reportes">
				{#each data.reportes as r (r.id)}
					<li class="reporte">
						<div class="row">
							<EstadoBadge estado={r.estado} />
							<time class="muted" datetime={r.creado_en}>{formatDateTime(r.creado_en)}</time>
						</div>
						{#if r.nota}<p class="nota">{r.nota}</p>{/if}
						<p class="meta">
							{r.usuario_id === data.userId ? m.aula_reported_by_you() : m.aula_reported_by_other()}
							{#if r.foto_path}
								<span class="with-photo"
									><Camera size={ICON_SIZE.sm} aria-hidden="true" /> {m.aula_with_photo()}</span
								>
							{/if}
						</p>
					</li>
				{/each}
			</ol>
		{/if}
	</section>
</div>

<style>
	.back {
		display: inline-flex;
		align-items: center;
		gap: var(--space-2);
		min-height: var(--touch);
		justify-self: start;
		font-size: var(--text-sm);
		font-weight: 600;
		text-decoration: none;
	}

	.back:hover {
		text-decoration: underline;
	}

	.layout {
		display: grid;
		gap: var(--space-6);
		align-items: start;
	}

	.report-form {
		display: grid;
		gap: var(--space-5);
	}

	.history {
		display: grid;
		gap: var(--space-3);
		min-width: 0;
	}

	.history h2 {
		font-size: var(--text-lg);
	}

	.reportes {
		list-style: none;
		padding: 0;
		margin: 0;
		background: var(--color-surface);
		border: var(--border-width) solid var(--color-border);
		border-radius: var(--radius-md);
	}

	.reporte {
		display: grid;
		gap: var(--space-2);
		padding: var(--space-3) var(--space-4);
		border-bottom: var(--border-width) solid var(--color-border);
	}

	.reporte:last-child {
		border-bottom: none;
	}

	.row {
		display: flex;
		flex-wrap: wrap;
		justify-content: space-between;
		align-items: center;
		gap: var(--space-2);
		font-size: var(--text-sm);
	}

	.nota {
		color: var(--color-heading);
	}

	.meta {
		display: flex;
		flex-wrap: wrap;
		gap: var(--space-1) var(--space-3);
		font-size: var(--text-xs);
		color: var(--color-text-muted);
	}

	.with-photo {
		display: inline-flex;
		align-items: center;
		gap: var(--space-1);
	}

	@media (min-width: 1024px) {
		.layout {
			grid-template-columns: minmax(0, 3fr) minmax(0, 2fr);
		}
	}
</style>
