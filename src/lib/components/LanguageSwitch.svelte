<script lang="ts">
	import { m } from '#lib/paraglide/messages.js';
	import { getLocale, locales, setLocale } from '#lib/paraglide/runtime.js';

	type Locale = (typeof locales)[number];
	type Props = {
		/** `bar` sits on the red header, `menu` inside the menu panel, `link` is a discreet text link. */
		variant?: 'bar' | 'menu' | 'link';
	};

	let { variant = 'bar' }: Props = $props();

	const NAME: Record<Locale, () => string> = { es: m.language_es, en: m.language_en };

	const current = $derived(getLocale());
	const other = $derived(locales.find((locale) => locale !== current) ?? current);

	function choose(locale: Locale) {
		if (locale !== current) void setLocale(locale);
	}
</script>

{#if variant === 'link'}
	<button type="button" class="link" lang={other} onclick={() => choose(other)}>
		{NAME[other]()}
	</button>
{:else}
	<div class="switch {variant}" role="group" aria-label={m.language_label()}>
		{#if variant === 'menu'}
			<span class="legend" aria-hidden="true">{m.language_label()}</span>
		{/if}
		<div class="options">
			{#each locales as locale (locale)}
				<button
					type="button"
					class="option"
					lang={locale}
					aria-label={NAME[locale]()}
					aria-pressed={locale === current}
					onclick={() => choose(locale)}
				>
					{locale.toUpperCase()}
				</button>
			{/each}
		</div>
	</div>
{/if}

<style>
	.options {
		display: inline-flex;
		gap: var(--space-1);
	}

	.option,
	.link {
		font: inherit;
		font-size: var(--text-sm);
		font-weight: 600;
		cursor: pointer;
		transition:
			background-color var(--duration-fast) var(--ease-out),
			color var(--duration-fast) var(--ease-out);
	}

	.option {
		min-width: var(--touch);
		min-height: var(--touch);
		padding: 0 var(--space-2);
		border: var(--border-width) solid transparent;
		border-radius: var(--radius-sm);
		background: transparent;
	}

	/* On the red header bar */
	.bar .option {
		color: var(--color-brand-contrast-muted);
	}

	.bar .option:hover {
		background: var(--color-brand-strong);
		color: var(--color-brand-contrast);
	}

	.bar .option[aria-pressed='true'] {
		color: var(--color-brand-contrast);
		border-color: var(--color-brand-contrast-muted);
	}

	.bar .option:focus-visible {
		outline-color: var(--color-brand-contrast);
	}

	/* Inside the menu panel */
	.menu {
		display: grid;
		gap: var(--space-2);
	}

	.legend {
		font-size: var(--text-xs);
		font-weight: 600;
		color: var(--color-text-muted);
	}

	.menu .options {
		display: grid;
		grid-template-columns: repeat(2, minmax(0, 1fr));
		padding: var(--space-1);
		border-radius: var(--radius-md);
		background: var(--color-surface-alt);
	}

	.menu .option {
		color: var(--color-text);
	}

	.menu .option[aria-pressed='true'] {
		background: var(--color-brand-tint);
		color: var(--color-brand-tint-fg);
	}

	/* Discreet link (login page) */
	.link {
		min-height: var(--touch);
		padding: 0 var(--space-3);
		border: none;
		background: transparent;
		color: var(--color-link);
		text-decoration: underline;
		text-underline-offset: 0.2em;
	}

	.link:hover {
		color: var(--color-link-hover);
	}
</style>
