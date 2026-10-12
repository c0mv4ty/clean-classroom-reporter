<script lang="ts">
	import { enhance } from '$app/forms';
	import EstadoBadge from '#lib/components/EstadoBadge.svelte';
	import { ESTADO_LABEL, ESTADOS, requiresPhoto } from '#lib/estados.ts';
	import { formatDateTime } from '#lib/format.ts';
	import type { EstadoAula } from '#lib/types/database.ts';
	import type { PageProps } from './$types';

	let { data, form }: PageProps = $props();

	let estado = $state<EstadoAula | null>(null);
	let submitting = $state(false);

	const fotoRequerida = $derived(requiresPhoto(data.aula.estado_actual, estado));
</script>

<svelte:head>
	<title>{data.aula.nombre} · Aulas limpias</title>
</svelte:head>

<p><a href="/">← Volver a las aulas</a></p>

<header class="head">
	<h1>{data.aula.nombre}</h1>
	<EstadoBadge estado={data.aula.estado_actual} />
</header>
<p class="muted">Última actualización: {formatDateTime(data.aula.actualizado_en)}</p>

<section class="card">
	<h2>Nuevo reporte</h2>

	<form
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
		<fieldset>
			<legend>Estado</legend>
			<div class="estados">
				{#each ESTADOS as opcion (opcion)}
					<label class="estado {opcion}">
						<input type="radio" name="estado" value={opcion} bind:group={estado} required />
						{ESTADO_LABEL[opcion]}
					</label>
				{/each}
			</div>
		</fieldset>

		<label>
			Nota (opcional)
			<textarea
				name="nota"
				rows="3"
				maxlength="500"
				placeholder="Ej.: basurero lleno"
				value={form?.nota ?? ''}></textarea>
		</label>

		<label>
			Foto {fotoRequerida ? '(obligatoria)' : '(opcional)'}
			<input
				type="file"
				name="foto"
				accept="image/*"
				capture="environment"
				required={fotoRequerida}
			/>
		</label>

		{#if data.aula.estado_actual === 'sucio'}
			<p class="alert warning">
				Esta aula está marcada como sucia. Para reportarla como limpia o medio limpia debes adjuntar
				una foto como evidencia.
			</p>
		{/if}

		{#if form?.message}
			<p class="alert error" role="alert">{form.message}</p>
		{:else if form?.success}
			<p class="alert success" role="status">Reporte guardado.</p>
		{/if}

		<button type="submit" class="primary" disabled={submitting}>
			{submitting ? 'Enviando…' : 'Enviar reporte'}
		</button>
	</form>
</section>

<h2>Últimos reportes</h2>
{#if data.reportes.length === 0}
	<p class="muted">Aún no hay reportes para esta aula.</p>
{:else}
	<ul class="reportes">
		{#each data.reportes as r (r.id)}
			<li class="card">
				<div class="row">
					<EstadoBadge estado={r.estado} />
					<small class="muted">{formatDateTime(r.creado_en)}</small>
				</div>
				{#if r.nota}<p>{r.nota}</p>{/if}
				<small class="muted">
					{r.usuario_id === data.userId ? 'Reportado por ti' : 'Reportado por otro presidente'}
					{#if r.foto_path}· con foto{/if}
				</small>
			</li>
		{/each}
	</ul>
{/if}

<style>
	.head {
		display: flex;
		align-items: center;
		gap: 0.75rem;
	}

	.head h1 {
		margin: 0;
	}

	fieldset {
		border: none;
		padding: 0;
		margin: 0;
	}

	legend {
		font-weight: 500;
		margin-bottom: 0.35rem;
	}

	.estados {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(7rem, 1fr));
		gap: 0.5rem;
	}

	.estado {
		display: flex;
		align-items: center;
		gap: 0.4rem;
		padding: 0.7rem;
		border: 2px solid var(--border);
		border-radius: 8px;
		cursor: pointer;
	}

	.estado.limpio:has(input:checked) {
		border-color: var(--limpio);
		background: var(--limpio-bg);
	}

	.estado.medio_limpio:has(input:checked) {
		border-color: var(--medio);
		background: var(--medio-bg);
	}

	.estado.sucio:has(input:checked) {
		border-color: var(--sucio);
		background: var(--sucio-bg);
	}

	.reportes {
		list-style: none;
		padding: 0;
		margin: 0;
		display: grid;
		gap: 0.5rem;
	}

	.reportes p {
		margin: 0.4rem 0;
	}

	.row {
		display: flex;
		justify-content: space-between;
		align-items: center;
		gap: 0.5rem;
	}
</style>
