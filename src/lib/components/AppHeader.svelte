<script lang="ts">
	import { LayoutGrid, RotateCcwClock, Users } from '@lucide/svelte';
	import type { Snippet } from 'svelte';
	import NavLinks, { type NavLink } from './NavLinks.svelte';
	import ThemeToggle from './ThemeToggle.svelte';
	import UserMenu from './UserMenu.svelte';

	type Props = {
		nombre: string;
		isAdmin: boolean;
		pathname: string;
		/** Reserved for the future ES/EN switch (Paraglide i18n follow-up). Not rendered when absent. */
		languageSwitch?: Snippet;
	};

	let { nombre, isAdmin, pathname, languageSwitch }: Props = $props();

	const links = $derived<NavLink[]>([
		{
			href: '/',
			label: 'Aulas',
			icon: LayoutGrid,
			current: pathname === '/' || pathname.startsWith('/aulas')
		},
		...(isAdmin
			? [
					{
						href: '/admin',
						label: 'Historial',
						icon: RotateCcwClock,
						current: pathname === '/admin'
					},
					{
						href: '/admin/usuarios',
						label: 'Usuarios',
						icon: Users,
						current: pathname.startsWith('/admin/usuarios')
					}
				]
			: [])
	]);
</script>

<header class="app-header">
	<div class="container bar">
		<a href="/" class="wordmark" aria-label="ESPOCH, Aulas limpias: inicio">
			<span class="mark">ESPOCH</span>
			<span class="sub">Aulas limpias</span>
		</a>

		<div class="inline-nav">
			<NavLinks {links} variant="bar" />
		</div>

		<div class="actions">
			{#if languageSwitch}
				<!-- Reserved: ES/EN language switch (Paraglide i18n follow-up). -->
				<div class="inline-only">{@render languageSwitch()}</div>
			{/if}
			<div class="inline-only"><ThemeToggle /></div>
			<UserMenu
				{nombre}
				rolLabel={isAdmin ? 'Administración' : 'Presidente de curso'}
				{links}
				{languageSwitch}
			/>
		</div>
	</div>
</header>

<style>
	.app-header {
		position: sticky;
		top: 0;
		z-index: var(--z-header);
		background: var(--color-header);
		color: var(--color-brand-contrast);
		border-bottom: 3px solid var(--color-accent);
	}

	.bar {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: var(--space-3);
		min-height: calc(var(--touch) + var(--space-4));
	}

	.wordmark {
		display: flex;
		align-items: baseline;
		gap: var(--space-2);
		min-width: 0;
		color: var(--color-brand-contrast);
		text-decoration: none;
	}

	.wordmark:hover {
		color: var(--color-brand-contrast);
	}

	.wordmark:focus-visible {
		outline-color: var(--color-brand-contrast);
	}

	.mark {
		font-family: var(--font-heading);
		font-weight: 700;
		font-size: var(--text-xl);
		letter-spacing: 0.02em;
		line-height: 1;
	}

	.sub {
		font-size: var(--text-sm);
		font-weight: 500;
		color: var(--color-brand-contrast-muted);
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
		padding-left: var(--space-2);
		border-left: var(--border-width) solid var(--color-brand-contrast-muted);
	}

	.inline-nav,
	.inline-only {
		display: none;
	}

	.actions {
		display: flex;
		align-items: center;
		gap: var(--space-2);
		flex: none;
	}

	@media (min-width: 640px) {
		.bar {
			min-height: calc(var(--touch) * 1.5);
			gap: var(--space-5);
		}

		.inline-nav {
			display: block;
			flex: 1;
			align-self: stretch;
			min-width: 0;
		}

		.inline-only {
			display: flex;
		}
	}
</style>
