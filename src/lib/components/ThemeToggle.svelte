<script lang="ts">
	import { Monitor, Moon, Sun } from '@lucide/svelte';
	import { onMount } from 'svelte';
	import { ICON_SIZE } from './icon-size.ts';
	import { setTheme, syncTheme, theme, THEME_LABEL, type Theme } from './theme.svelte.ts';

	const NEXT: Record<Theme, Theme> = { system: 'light', light: 'dark', dark: 'system' };
	const ICON = { system: Monitor, light: Sun, dark: Moon };
	const Icon = $derived(ICON[theme.current]);

	onMount(syncTheme);
</script>

<button
	type="button"
	class="toggle"
	aria-label="Cambiar tema (actual: {THEME_LABEL[theme.current]})"
	title="Tema: {THEME_LABEL[theme.current]}"
	onclick={() => setTheme(NEXT[theme.current])}
>
	<Icon size={ICON_SIZE.md} aria-hidden="true" />
</button>

<style>
	.toggle {
		display: inline-grid;
		place-items: center;
		width: var(--touch);
		height: var(--touch);
		flex: none;
		padding: 0;
		border: var(--border-width) solid transparent;
		border-radius: var(--radius-sm);
		background: transparent;
		color: var(--color-brand-contrast);
		cursor: pointer;
		transition: background-color var(--duration-fast) var(--ease-out);
	}

	.toggle:hover {
		background: var(--color-brand-strong);
	}

	.toggle:focus-visible {
		outline-color: var(--color-brand-contrast);
	}
</style>
