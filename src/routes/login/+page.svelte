<script lang="ts">
	import { enhance } from '$app/forms';
	import type { PageProps } from './$types';

	let { form }: PageProps = $props();
	let submitting = $state(false);
</script>

<svelte:head>
	<title>Ingresar · Aulas limpias</title>
</svelte:head>

<section class="card login">
	<h1>Ingresar</h1>
	<p class="muted">Acceso para presidentes de curso y administración.</p>

	<form
		method="POST"
		use:enhance={() => {
			submitting = true;
			return async ({ update }) => {
				await update();
				submitting = false;
			};
		}}
	>
		<label>
			Correo
			<input name="email" type="email" autocomplete="email" required value={form?.email ?? ''} />
		</label>
		<label>
			Contraseña
			<input name="password" type="password" autocomplete="current-password" required />
		</label>

		{#if form?.message}
			<p class="alert error" role="alert">{form.message}</p>
		{/if}

		<button type="submit" class="primary" disabled={submitting}>
			{submitting ? 'Ingresando…' : 'Ingresar'}
		</button>
	</form>
</section>

<style>
	.login {
		max-width: 24rem;
		margin: 2rem auto;
	}
</style>
