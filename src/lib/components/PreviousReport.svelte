<script lang="ts">
	import EstadoBadge from './EstadoBadge.svelte';
	import { m } from '#lib/paraglide/messages.js';
	import { formatDateTime } from '#lib/format.ts';
	import type { EstadoAula } from '#lib/types/database.ts';

	type Previous = { nombre: string; estado: EstadoAula; creado_en: string };

	let { previous }: { previous: Previous | null } = $props();
</script>

{#if previous}
	<div class="previous">
		<strong>{previous.nombre}</strong>
		<span class="meta">
			<EstadoBadge estado={previous.estado} />
			<time datetime={previous.creado_en}>{formatDateTime(previous.creado_en)}</time>
		</span>
	</div>
{:else}
	<span class="muted">{m.admin_previous_none()}</span>
{/if}

<style>
	.previous {
		display: grid;
		gap: var(--space-1);
		justify-items: start;
	}

	.meta {
		display: flex;
		flex-wrap: wrap;
		align-items: center;
		gap: var(--space-2);
	}

	time {
		font-size: var(--text-xs);
		color: var(--color-text-muted);
		white-space: nowrap;
	}
</style>
