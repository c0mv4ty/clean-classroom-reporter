<script lang="ts">
	import { m } from '#lib/paraglide/messages.js';
	import { formatDateTime } from '#lib/format.ts';

	type Item = { id: string; nombre: string; veces: number; ultimaVez: string };

	let { items, aulaNombre }: { items: Item[]; aulaNombre: string | null } = $props();
</script>

<section class="summary" aria-labelledby="reporter-summary-title">
	<div class="head">
		<h2 id="reporter-summary-title">{m.admin_summary_title()}</h2>
		<p class="muted">
			{aulaNombre ? m.admin_summary_aula({ aula: aulaNombre }) : m.admin_filter_all()}
		</p>
		<p class="note">{m.admin_summary_note()}</p>
	</div>

	{#if items.length === 0}
		<p class="empty muted">{m.admin_summary_empty()}</p>
	{:else}
		<div class="table-card">
			<table class="rtable">
				<thead>
					<tr>
						<th scope="col">{m.admin_summary_col_user()}</th>
						<th scope="col">{m.admin_summary_col_times()}</th>
						<th scope="col">{m.admin_summary_col_last()}</th>
					</tr>
				</thead>
				<tbody>
					{#each items as item (item.id)}
						<tr>
							<td data-label={m.admin_summary_col_user()}><strong>{item.nombre}</strong></td>
							<td data-label={m.admin_summary_col_times()}>{item.veces}</td>
							<td data-label={m.admin_summary_col_last()}>
								<span class="nowrap">{formatDateTime(item.ultimaVez)}</span>
							</td>
						</tr>
					{/each}
				</tbody>
			</table>
		</div>
	{/if}
</section>

<style>
	.summary {
		display: grid;
		gap: var(--space-3);
	}

	.head {
		display: grid;
		gap: var(--space-1);
	}

	.note {
		font-size: var(--text-sm);
		max-width: 65ch;
	}

	.nowrap {
		white-space: nowrap;
	}

	.empty {
		padding: var(--space-5);
		text-align: center;
		background: var(--color-surface);
		border: var(--border-width) dashed var(--color-border-strong);
		border-radius: var(--radius-md);
	}
</style>
