<script lang="ts">
	import { enhance } from '$app/forms';
	import { formatDateTime } from '#lib/format.ts';
	import type { PageProps } from './$types';

	let { data, form }: PageProps = $props();
	let submitting = $state(false);

	const presidentes = $derived(data.usuarios.filter((u) => u.rol === 'presidente').length);
</script>

<svelte:head>
	<title>Usuarios · Aulas limpias</title>
</svelte:head>

<h1>Usuarios</h1>

<section class="card">
	<h2>Crear usuario</h2>
	<form
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
			<label>
				Nombre
				<input name="nombre" required value={form?.nombre ?? ''} />
			</label>
			<label>
				Correo
				<input name="email" type="email" required autocomplete="off" value={form?.email ?? ''} />
			</label>
			<label>
				Contraseña inicial
				<input name="password" type="password" minlength="8" required autocomplete="new-password" />
			</label>
			<label>
				Rol
				<select name="rol" value={form?.rol ?? 'presidente'}>
					<option value="presidente">Presidente</option>
					<option value="admin">Admin</option>
				</select>
			</label>
		</div>

		{#if form?.message}
			<p class="alert error" role="alert">{form.message}</p>
		{:else if form?.created}
			<p class="alert success" role="status">Usuario {form.created} creado.</p>
		{/if}

		<button type="submit" class="primary" disabled={submitting}>
			{submitting ? 'Creando…' : 'Crear usuario'}
		</button>
	</form>
</section>

<h2>Listado ({data.usuarios.length} usuarios, {presidentes} presidentes)</h2>
<div class="table-wrap">
	<table>
		<thead>
			<tr>
				<th>Nombre</th>
				<th>Correo</th>
				<th>Rol</th>
				<th>Creado</th>
			</tr>
		</thead>
		<tbody>
			{#each data.usuarios as u (u.id)}
				<tr>
					<td>{u.nombre}</td>
					<td>{u.email}</td>
					<td>{u.rol === 'admin' ? 'Admin' : 'Presidente'}</td>
					<td>{formatDateTime(u.creado_en)}</td>
				</tr>
			{/each}
		</tbody>
	</table>
</div>

<style>
	.fields {
		display: grid;
		gap: 0.85rem;
		grid-template-columns: repeat(auto-fit, minmax(13rem, 1fr));
	}
</style>
