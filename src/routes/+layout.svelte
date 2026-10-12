<script lang="ts">
	import '../app.css';
	import favicon from '#lib/assets/favicon.svg';
	import { page } from '$app/state';
	import type { LayoutProps } from './$types';

	let { data, children }: LayoutProps = $props();
	const isAdmin = $derived(data.profile?.rol === 'admin');
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
</svelte:head>

{#if data.profile}
	<header class="topbar">
		<a href="/" class="brand">Aulas limpias</a>
		<nav>
			<a href="/" aria-current={page.url.pathname === '/' ? 'page' : undefined}>Aulas</a>
			{#if isAdmin}
				<a href="/admin" aria-current={page.url.pathname === '/admin' ? 'page' : undefined}>
					Historial
				</a>
				<a
					href="/admin/usuarios"
					aria-current={page.url.pathname.startsWith('/admin/usuarios') ? 'page' : undefined}
				>
					Usuarios
				</a>
			{/if}
		</nav>
		<form method="POST" action="/logout" class="logout">
			<span class="muted user">{data.profile.nombre}</span>
			<button type="submit" class="link">Salir</button>
		</form>
	</header>
{/if}

<main>
	{@render children()}
</main>
