<script lang="ts">
	import { House, LayoutGrid, QrCode, RotateCcwClock, Users } from '@lucide/svelte';
	import { m } from '#lib/paraglide/messages.js';
	import LanguageSwitch from './LanguageSwitch.svelte';
	import NavLinks, { type NavLink } from './NavLinks.svelte';
	import ThemeToggle from './ThemeToggle.svelte';
	import UserMenu from './UserMenu.svelte';

	type Props = {
		nombre: string;
		isAdmin: boolean;
		pathname: string;
	};

	let { nombre, isAdmin, pathname }: Props = $props();

	const links = $derived<NavLink[]>([
		{
			href: '/',
			// Presidentes have no classroom list: their `/` is a home with the QR instructions.
			label: isAdmin ? m.nav_classrooms() : m.nav_home(),
			icon: isAdmin ? LayoutGrid : House,
			current: pathname === '/' || pathname.startsWith('/aulas')
		},
		...(isAdmin
			? [
					{
						href: '/admin',
						label: m.nav_history(),
						icon: RotateCcwClock,
						current: pathname === '/admin'
					},
					{
						href: '/admin/usuarios',
						label: m.nav_users(),
						icon: Users,
						current: pathname.startsWith('/admin/usuarios')
					},
					{
						href: '/admin/qr',
						label: m.nav_qr(),
						icon: QrCode,
						current: pathname.startsWith('/admin/qr')
					}
				]
			: [])
	]);
</script>

<header class="app-header">
	<div class="container bar">
		<a href="/" class="wordmark" aria-label={m.nav_home_aria()}>
			<span class="mark">ESPOCH</span>
			<span class="sub">{m.app_name()}</span>
		</a>

		<div class="inline-nav">
			<NavLinks {links} variant="bar" />
		</div>

		<div class="actions">
			<div class="inline-only"><LanguageSwitch variant="bar" /></div>
			<div class="inline-only"><ThemeToggle /></div>
			<UserMenu
				{nombre}
				rolLabel={isAdmin ? m.nav_role_admin() : m.nav_role_presidente()}
				{links}
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
