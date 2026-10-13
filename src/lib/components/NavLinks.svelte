<script lang="ts" module>
	import type { Component } from 'svelte';

	export type NavLink = {
		href: string;
		label: string;
		icon: Component<{ size?: number; 'aria-hidden'?: 'true' }>;
		current: boolean;
	};
</script>

<script lang="ts">
	import { ICON_SIZE } from './icon-size.ts';

	let {
		links,
		variant,
		label = 'Principal'
	}: { links: NavLink[]; variant: 'bar' | 'menu'; label?: string } = $props();
</script>

<nav class="nav {variant}" aria-label={label}>
	<ul>
		{#each links as link (link.href)}
			<li>
				<a href={link.href} aria-current={link.current ? 'page' : undefined}>
					<link.icon size={ICON_SIZE.sm} aria-hidden="true" />
					{link.label}
				</a>
			</li>
		{/each}
	</ul>
</nav>

<style>
	ul {
		list-style: none;
		margin: 0;
		padding: 0;
		display: flex;
	}

	a {
		display: flex;
		align-items: center;
		gap: var(--space-2);
		min-height: var(--touch);
		font-size: var(--text-sm);
		font-weight: 600;
		text-decoration: none;
		transition:
			color var(--duration-fast) var(--ease-out),
			background-color var(--duration-fast) var(--ease-out),
			border-color var(--duration-fast) var(--ease-out);
	}

	/* Inline links on the red bar */
	.bar,
	.bar ul,
	.bar li {
		height: 100%;
	}

	.bar ul {
		gap: var(--space-1);
	}

	.bar a {
		height: 100%;
		padding-inline: var(--space-3);
		color: var(--color-brand-contrast-muted);
		border-bottom: 3px solid transparent;
	}

	.bar a:hover {
		color: var(--color-brand-contrast);
	}

	.bar a[aria-current='page'] {
		color: var(--color-brand-contrast);
		border-bottom-color: var(--color-brand-contrast);
	}

	.bar a:focus-visible {
		outline-color: var(--color-brand-contrast);
		outline-offset: -2px;
	}

	/* Stacked links inside the menu panel */
	.menu ul {
		flex-direction: column;
		gap: var(--space-1);
	}

	.menu a {
		padding-inline: var(--space-3);
		border-radius: var(--radius-sm);
		color: var(--color-text);
	}

	.menu a:hover {
		background: var(--color-surface-alt);
		color: var(--color-text);
	}

	.menu a[aria-current='page'] {
		background: var(--color-brand-tint);
		color: var(--color-brand-tint-fg);
	}
</style>
