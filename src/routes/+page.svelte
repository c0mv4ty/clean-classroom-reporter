<script lang="ts">
	import { QrCode } from '@lucide/svelte';
	import AulaCard from '#lib/components/AulaCard.svelte';
	import Card from '#lib/components/Card.svelte';
	import MisReportes from '#lib/components/MisReportes.svelte';
	import PageHeader from '#lib/components/PageHeader.svelte';
	import StateSummary from '#lib/components/StateSummary.svelte';
	import { ICON_SIZE } from '#lib/components/icon-size.ts';
	import { m } from '#lib/paraglide/messages.js';
	import { formatDateTime } from '#lib/format.ts';
	import type { PageProps } from './$types';

	let { data }: PageProps = $props();

	const ultimaActualizacion = $derived(
		data.kind === 'admin'
			? data.aulas
					.map((a) => a.actualizado_en)
					.filter((d): d is string => Boolean(d))
					.sort()
					.at(-1)
			: undefined
	);
</script>

<svelte:head>
	<title>{m.meta_title({ page: data.kind === 'admin' ? m.nav_classrooms() : m.nav_home() })}</title>
</svelte:head>

{#if data.kind === 'admin'}
	<PageHeader
		title={m.home_heading()}
		description={ultimaActualizacion
			? m.home_description_updated({ date: formatDateTime(ultimaActualizacion) })
			: m.home_pick_hint()}
	/>

	<StateSummary estados={data.aulas.map((a) => a.estado_actual)} />

	{#if data.aulas.length === 0}
		<p class="empty muted">{m.home_empty()}</p>
	{:else}
		<ul class="grid" aria-label={m.nav_classrooms()}>
			{#each data.aulas as aula (aula.id)}
				<li><AulaCard {aula} /></li>
			{/each}
		</ul>
	{/if}
{:else}
	<PageHeader title={m.home_presidente_heading()} description={m.home_presidente_description()} />

	<div class="stack">
		<Card title={m.home_howto_title()}>
			<ol class="steps">
				<li>
					<span>
						{m.home_howto_step_scan()}
						<QrCode class="step-icon" size={ICON_SIZE.md} aria-hidden="true" />
					</span>
				</li>
				<li><span>{m.home_howto_step_login()}</span></li>
				<li><span>{m.home_howto_step_report()}</span></li>
			</ol>
		</Card>

		<MisReportes reportes={data.reportes} />
	</div>
{/if}

<style>
	.grid {
		list-style: none;
		padding: 0;
		margin: 0;
		display: grid;
		grid-template-columns: repeat(2, minmax(0, 1fr));
		gap: var(--space-3);
	}

	.grid li {
		min-width: 0;
	}

	.empty {
		padding: var(--space-5);
		text-align: center;
		background: var(--color-surface);
		border: var(--border-width) dashed var(--color-border-strong);
		border-radius: var(--radius-md);
	}

	.stack {
		display: grid;
		gap: var(--space-4);
		margin-top: var(--space-4);
	}

	.steps :global(.step-icon) {
		display: inline-block;
		vertical-align: text-bottom;
		margin-left: var(--space-1);
		color: var(--color-text-muted);
	}

	.steps {
		counter-reset: step;
		list-style: none;
		margin: 0;
		padding: 0;
		display: grid;
		gap: var(--space-3);
	}

	.steps li {
		counter-increment: step;
		display: grid;
		grid-template-columns: 2rem minmax(0, 1fr);
		gap: var(--space-3);
		align-items: start;
	}

	.steps li::before {
		content: counter(step);
		display: inline-flex;
		align-items: center;
		justify-content: center;
		width: 2rem;
		height: 2rem;
		border: var(--border-width-strong) solid var(--color-border-strong);
		border-radius: var(--radius-pill);
		font-family: var(--font-heading);
		font-weight: 700;
		font-size: var(--text-sm);
		color: var(--color-heading);
	}

	@media (min-width: 640px) {
		.grid {
			grid-template-columns: repeat(3, minmax(0, 1fr));
			gap: var(--space-4);
		}
	}

	@media (min-width: 1024px) {
		.grid {
			grid-template-columns: repeat(4, minmax(0, 1fr));
		}
	}
</style>
