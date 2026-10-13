<script lang="ts">
	import { CircleUser, LogOut, Menu, X } from '@lucide/svelte';
	import type { Snippet } from 'svelte';
	import { afterNavigate } from '$app/navigation';
	import { ICON_SIZE } from './icon-size.ts';
	import NavLinks, { type NavLink } from './NavLinks.svelte';
	import ThemeSelect from './ThemeSelect.svelte';

	type Props = {
		nombre: string;
		rolLabel: string;
		links: NavLink[];
		/** Reserved for the future ES/EN switch (Paraglide i18n follow-up). Not rendered when absent. */
		languageSwitch?: Snippet;
	};

	let { nombre, rolLabel, links, languageSwitch }: Props = $props();

	const panelId = $props.id();
	let open = $state(false);
	let root = $state<HTMLElement>();
	let trigger = $state<HTMLButtonElement>();

	function close({ restoreFocus = false } = {}) {
		if (!open) return;
		open = false;
		if (restoreFocus) trigger?.focus();
	}

	function onWindowKeydown(event: KeyboardEvent) {
		if (open && event.key === 'Escape') close({ restoreFocus: true });
	}

	function onWindowPointerdown(event: PointerEvent) {
		if (open && root && !root.contains(event.target as Node)) close();
	}

	// Close the panel when the user tabs out of it.
	function onFocusout(event: FocusEvent) {
		const next = event.relatedTarget as Node | null;
		if (open && next && root && !root.contains(next)) close();
	}

	afterNavigate(() => close());
</script>

<svelte:window onkeydown={onWindowKeydown} onpointerdown={onWindowPointerdown} />

<div class="user-menu" bind:this={root} onfocusout={onFocusout}>
	<button
		bind:this={trigger}
		type="button"
		class="trigger"
		aria-label="Abrir menú"
		aria-expanded={open}
		aria-controls={panelId}
		onclick={() => (open = !open)}
	>
		<span class="mobile-icon">
			{#if open}
				<X size={ICON_SIZE.md} aria-hidden="true" />
			{:else}
				<Menu size={ICON_SIZE.md} aria-hidden="true" />
			{/if}
		</span>
		<span class="desktop-icon"><CircleUser size={ICON_SIZE.md} aria-hidden="true" /></span>
		<span class="trigger-name" aria-hidden="true">{nombre}</span>
	</button>

	<div class="panel" id={panelId} hidden={!open}>
		<div class="identity">
			<span class="name">{nombre}</span>
			<span class="role">{rolLabel}</span>
		</div>

		<div class="mobile-only">
			<NavLinks {links} variant="menu" />
		</div>

		<div class="mobile-only section">
			<ThemeSelect />
		</div>

		{#if languageSwitch}
			<!-- Reserved: ES/EN language switch (Paraglide i18n follow-up). -->
			<div class="section">{@render languageSwitch()}</div>
		{/if}

		<form method="POST" action="/logout" class="section">
			<button type="submit" class="logout">
				<LogOut size={ICON_SIZE.sm} aria-hidden="true" />
				Salir
			</button>
		</form>
	</div>
</div>

<style>
	.user-menu {
		display: flex;
	}

	.trigger {
		display: inline-flex;
		align-items: center;
		gap: var(--space-2);
		min-width: var(--touch);
		min-height: var(--touch);
		justify-content: center;
		padding: 0 var(--space-2);
		border: var(--border-width) solid var(--color-brand-contrast-muted);
		border-radius: var(--radius-sm);
		background: transparent;
		color: var(--color-brand-contrast);
		font-size: var(--text-sm);
		font-weight: 600;
		cursor: pointer;
		transition: background-color var(--duration-fast) var(--ease-out);
	}

	.trigger:hover,
	.trigger[aria-expanded='true'] {
		background: var(--color-brand-strong);
	}

	.trigger:focus-visible {
		outline-color: var(--color-brand-contrast);
	}

	.mobile-icon,
	.desktop-icon {
		display: inline-flex;
	}

	.desktop-icon,
	.trigger-name {
		display: none;
	}

	.trigger-name {
		max-width: 12rem;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	/* Mobile: full-width sheet anchored to the header (the header is the positioned ancestor). */
	.panel {
		position: absolute;
		top: 100%;
		left: 0;
		right: 0;
		display: grid;
		gap: var(--space-3);
		padding: var(--space-4) var(--gutter) var(--space-5);
		background: var(--color-surface);
		color: var(--color-text);
		border-bottom: var(--border-width) solid var(--color-border);
		box-shadow: var(--shadow-lg);
		animation: panel-in var(--duration-base) var(--ease-out);
	}

	.panel[hidden] {
		display: none;
	}

	.identity {
		display: grid;
		gap: var(--space-1);
		padding-bottom: var(--space-3);
		border-bottom: var(--border-width) solid var(--color-border);
		min-width: 0;
	}

	.name {
		font-weight: 600;
		overflow-wrap: anywhere;
	}

	.role {
		font-size: var(--text-xs);
		color: var(--color-text-muted);
	}

	.section {
		padding-top: var(--space-3);
		border-top: var(--border-width) solid var(--color-border);
	}

	.logout {
		display: flex;
		align-items: center;
		gap: var(--space-2);
		width: 100%;
		min-height: var(--touch);
		padding: 0 var(--space-3);
		border: none;
		border-radius: var(--radius-sm);
		background: transparent;
		color: var(--color-link);
		font-size: var(--text-sm);
		font-weight: 600;
		cursor: pointer;
	}

	.logout:hover {
		background: var(--color-surface-alt);
	}

	/* Transform-only entrance: the panel stays fully visible even if animations are paused. */
	@keyframes panel-in {
		from {
			transform: translateY(calc(var(--space-1) * -1));
		}
	}

	@media (min-width: 640px) {
		.user-menu {
			position: relative;
		}

		.mobile-icon,
		.mobile-only {
			display: none;
		}

		.desktop-icon {
			display: inline-flex;
		}

		.panel {
			left: auto;
			top: calc(100% + var(--space-2));
			width: max-content;
			min-width: 14rem;
			max-width: 20rem;
			padding: var(--space-3);
			border: var(--border-width) solid var(--color-border);
			border-radius: var(--radius-md);
		}

		.section:first-of-type {
			padding-top: 0;
			border-top: none;
		}
	}

	@media (min-width: 1024px) {
		.trigger {
			padding-inline: var(--space-2) var(--space-3);
		}

		.trigger-name {
			display: inline;
		}
	}
</style>
