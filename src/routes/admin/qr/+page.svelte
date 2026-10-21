<script lang="ts">
	import { Printer, TriangleAlert } from '@lucide/svelte';
	import Button from '#lib/components/Button.svelte';
	import { ICON_SIZE } from '#lib/components/icon-size.ts';
	import PageHeader from '#lib/components/PageHeader.svelte';
	import { m } from '#lib/paraglide/messages.js';
	import type { PageProps } from './$types';

	let { data }: PageProps = $props();
</script>

<svelte:head>
	<title>{m.meta_title({ page: m.nav_qr() })}</title>
</svelte:head>

<div class="screen-only">
	<PageHeader title={m.admin_qr_title()} description={m.admin_qr_description()}>
		{#snippet aside()}
			<Button variant="primary" onclick={() => window.print()}>
				<Printer size={ICON_SIZE.md} aria-hidden="true" />
				{m.admin_qr_print()}
			</Button>
		{/snippet}
	</PageHeader>

	<div class="origin">
		<p class="field-label">{m.admin_qr_origin_label()}</p>
		<p class="origin-value">{data.origin}</p>
		<p class="field-hint">{m.admin_qr_origin_hint()}</p>
	</div>

	{#if data.isLocalOrigin}
		<p class="alert warning" role="status">
			<TriangleAlert size={ICON_SIZE.md} aria-hidden="true" />
			<span>{m.admin_qr_local_warning()}</span>
		</p>
	{/if}
</div>

{#if data.aulas.length === 0}
	<p class="muted">{m.admin_qr_empty()}</p>
{:else}
	<ul class="sheet">
		{#each data.aulas as aula (aula.id)}
			<li class="label">
				<div class="qr" role="img" aria-label={m.admin_qr_aria({ name: aula.nombre })}>
					<!-- eslint-disable-next-line svelte/no-at-html-tags -- SVG generated server-side by uqr from a numeric id and the request origin -->
					{@html aula.svg}
				</div>
				<a class="name" href="/aulas/{aula.id}">{aula.nombre}</a>
				<p class="cta">{m.admin_qr_label_cta()}</p>
			</li>
		{/each}
	</ul>
{/if}

<style>
	.screen-only {
		display: grid;
		gap: var(--space-4);
	}

	.origin {
		display: grid;
		gap: var(--space-1);
	}

	.origin-value {
		font-weight: 600;
		color: var(--color-heading);
	}

	.sheet {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(12rem, 1fr));
		gap: var(--space-4);
		margin: 0;
		padding: 0;
		list-style: none;
	}

	.label {
		display: grid;
		justify-items: center;
		align-content: start;
		gap: var(--space-2);
		padding: var(--space-4);
		background: var(--color-surface);
		border: var(--border-width) solid var(--color-border);
		border-radius: var(--radius-md);
		box-shadow: var(--shadow-sm);
		text-align: center;
		min-width: 0;
	}

	/* Always black on white, in every theme: scanners need the contrast. */
	.qr {
		width: 100%;
		max-width: 11rem;
		background: #fff;
		line-height: 0;
	}

	.qr :global(svg) {
		display: block;
		width: 100%;
		height: auto;
	}

	.name {
		display: inline-flex;
		align-items: center;
		min-height: var(--touch);
		font-family: var(--font-heading);
		font-size: var(--text-lg);
		font-weight: 700;
		line-height: var(--leading-tight);
		color: var(--color-heading);
	}

	.cta {
		font-size: var(--text-sm);
		color: var(--color-text-muted);
	}

	@page {
		size: A4;
		margin: 12mm;
	}

	/* Print: a plain sheet of cut-out labels, 2 columns by 3 rows per A4 page. */
	@media print {
		:global(body) {
			background: #fff;
		}

		:global(.app-header),
		.screen-only {
			display: none;
		}

		:global(.app-main) {
			padding: 0;
			max-width: none;
		}

		.sheet {
			grid-template-columns: repeat(2, 1fr);
			grid-auto-rows: 88mm;
			gap: 0;
		}

		.label {
			align-content: center;
			gap: 3mm;
			padding: 6mm;
			background: #fff;
			border: 0.25mm solid #888;
			border-radius: 0;
			box-shadow: none;
			break-inside: avoid;
			color: #000;
		}

		.qr {
			max-width: 56mm;
		}

		.name {
			min-height: 0;
			font-size: 18pt;
			color: #000;
			text-decoration: none;
		}

		.cta {
			font-size: 11pt;
			color: #000;
		}
	}
</style>
