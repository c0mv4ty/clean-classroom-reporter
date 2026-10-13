<script lang="ts">
	import { enhance } from '$app/forms';
	import Button from '#lib/components/Button.svelte';
	import Card from '#lib/components/Card.svelte';
	import { ICON_SIZE } from '#lib/components/icon-size.ts';
	import { Check, TriangleAlert } from '@lucide/svelte';
	import PageHeader from '#lib/components/PageHeader.svelte';
	import { formatDateTime } from '#lib/format.ts';
	import type { PageProps } from './$types';

	let { data, form }: PageProps = $props();
	let submitting = $state(false);

	const presidentes = $derived(data.usuarios.filter((u) => u.rol === 'presidente').length);
</script>

<svelte:head>
	<title>Usuarios · ESPOCH Aulas limpias</title>
</svelte:head>

<PageHeader
	title="Usuarios"
	description="{data.usuarios.length} usuarios, {presidentes} presidentes de curso"
/>

<Card title="Crear usuario">
	<form
		class="create"
		method="POST"
		action="?/create"
		use:enhance={() => {
			submitting = true;
			return async ({ result, update }) => {
				await update({ reset: result.type === 'success' });
				submitting = false;
			};
		}}
	>
		<div class="fields">
			<label class="field">
				<span class="field-label">Nombre</span>
				<input class="input" name="nombre" required value={form?.nombre ?? ''} />
			</label>
			<label class="field">
				<span class="field-label">Correo</span>
				<input
					class="input"
					name="email"
					type="email"
					required
					autocomplete="off"
					value={form?.email ?? ''}
				/>
			</label>
			<label class="field">
				<span class="field-label">Contraseña inicial</span>
				<input
					class="input"
					name="password"
					type="password"
					minlength="8"
					required
					autocomplete="new-password"
				/>
				<span class="field-hint">Mínimo 8 caracteres.</span>
			</label>
			<label class="field">
				<span class="field-label">Rol</span>
				<select class="input" name="rol" value={form?.rol ?? 'presidente'}>
					<option value="presidente">Presidente</option>
					<option value="admin">Admin</option>
				</select>
			</label>
		</div>

		{#if form?.message}
			<p class="alert error" role="alert">
				<TriangleAlert size={ICON_SIZE.sm} aria-hidden="true" />
				{form.message}
			</p>
		{:else if form?.created}
			<p class="alert success" role="status">
				<Check size={ICON_SIZE.sm} aria-hidden="true" /> Usuario {form.created} creado.
			</p>
		{/if}

		<div class="actions">
			<Button type="submit" variant="primary" disabled={submitting}>
				{submitting ? 'Creando…' : 'Crear usuario'}
			</Button>
		</div>
	</form>
</Card>

<section class="listado" aria-labelledby="listado-titulo">
	<h2 id="listado-titulo">Listado</h2>
	<div class="table-card">
		<table class="rtable">
			<thead>
				<tr>
					<th scope="col">Nombre</th>
					<th scope="col">Correo</th>
					<th scope="col">Rol</th>
					<th scope="col">Creado</th>
				</tr>
			</thead>
			<tbody>
				{#each data.usuarios as u (u.id)}
					<tr>
						<td data-label="Nombre"><strong>{u.nombre}</strong></td>
						<td data-label="Correo" class="email">{u.email}</td>
						<td data-label="Rol">
							<span class="rol" class:admin={u.rol === 'admin'}>
								{u.rol === 'admin' ? 'Admin' : 'Presidente'}
							</span>
						</td>
						<td data-label="Creado" class="nowrap">{formatDateTime(u.creado_en)}</td>
					</tr>
				{/each}
			</tbody>
		</table>
	</div>
</section>

<style>
	.create {
		display: grid;
		gap: var(--space-4);
	}

	.fields {
		display: grid;
		gap: var(--space-4);
		align-items: start;
	}

	.actions {
		display: grid;
	}

	.listado {
		display: grid;
		gap: var(--space-3);
		min-width: 0;
	}

	.listado h2 {
		font-size: var(--text-lg);
	}

	.email {
		overflow-wrap: anywhere;
	}

	.nowrap {
		white-space: nowrap;
	}

	.rol {
		justify-self: start;
		display: inline-block;
		padding: var(--space-1) var(--space-2);
		border-radius: var(--radius-pill);
		background: var(--color-surface-alt);
		font-size: var(--text-xs);
		font-weight: 600;
		color: var(--color-heading);
	}

	.rol.admin {
		background: var(--color-brand-tint);
		color: var(--color-brand-deep);
	}

	@media (min-width: 640px) {
		.fields {
			grid-template-columns: repeat(2, minmax(0, 1fr));
		}

		.actions {
			justify-content: start;
		}
	}

	@media (min-width: 1024px) {
		.fields {
			grid-template-columns: repeat(4, minmax(0, 1fr));
		}
	}
</style>
