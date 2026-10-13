<script lang="ts">
	import '../app.css';
	import favicon from '#lib/assets/favicon.svg';
	import AppHeader from '#lib/components/AppHeader.svelte';
	import { page } from '$app/state';
	import type { LayoutProps } from './$types';

	let { data, children }: LayoutProps = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
</svelte:head>

{#if data.profile}
	<AppHeader
		nombre={data.profile.nombre}
		isAdmin={data.profile.rol === 'admin'}
		pathname={page.url.pathname}
	/>
	<main class="container app-main">
		{@render children()}
	</main>
{:else}
	<main>
		{@render children()}
	</main>
{/if}

<style>
	.app-main {
		display: grid;
		gap: var(--space-5);
		padding-block: var(--space-5) var(--space-7);
	}
</style>
