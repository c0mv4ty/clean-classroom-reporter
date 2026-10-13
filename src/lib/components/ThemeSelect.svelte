<script lang="ts">
	import { Monitor, Moon, Sun } from '@lucide/svelte';
	import { onMount } from 'svelte';
	import { ICON_SIZE } from './icon-size.ts';
	import { setTheme, syncTheme, theme, THEME_LABEL, THEMES } from './theme.svelte.ts';

	const ICON = { system: Monitor, light: Sun, dark: Moon };
	const name = $props.id();

	onMount(syncTheme);
</script>

<fieldset class="theme-select">
	<legend class="legend">Tema</legend>
	<div class="options">
		{#each THEMES as option (option)}
			{@const Icon = ICON[option]}
			<label class="option">
				<input
					class="visually-hidden"
					type="radio"
					{name}
					value={option}
					checked={theme.current === option}
					onchange={() => setTheme(option)}
				/>
				<Icon size={ICON_SIZE.sm} aria-hidden="true" />
				{THEME_LABEL[option]}
			</label>
		{/each}
	</div>
</fieldset>

<style>
	.theme-select {
		border: none;
		margin: 0;
		padding: 0;
		min-width: 0;
	}

	.legend {
		padding: 0;
		margin-bottom: var(--space-2);
		font-size: var(--text-xs);
		font-weight: 600;
		color: var(--color-text-muted);
	}

	.options {
		display: grid;
		grid-template-columns: repeat(3, minmax(0, 1fr));
		gap: var(--space-1);
		padding: var(--space-1);
		border-radius: var(--radius-md);
		background: var(--color-surface-alt);
	}

	.option {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		gap: var(--space-1);
		min-height: var(--touch);
		padding-inline: var(--space-2);
		border-radius: var(--radius-sm);
		font-size: var(--text-sm);
		font-weight: 600;
		color: var(--color-text-muted);
		cursor: pointer;
		transition:
			background-color var(--duration-fast) var(--ease-out),
			color var(--duration-fast) var(--ease-out);
	}

	.option:has(input:checked) {
		background: var(--color-surface);
		color: var(--color-text);
		box-shadow: var(--shadow-sm);
	}

	.option:has(input:focus-visible) {
		outline: var(--border-width-strong) solid var(--color-focus);
		outline-offset: 1px;
	}
</style>
