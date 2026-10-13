<script lang="ts">
	import EstadoIcon from './EstadoIcon.svelte';
	import { ESTADO_LABEL } from '#lib/estados.ts';
	import type { EstadoAula } from '#lib/types/database.ts';

	let { estado }: { estado: EstadoAula } = $props();
</script>

<span class="badge {estado}">
	<EstadoIcon {estado} />
	{ESTADO_LABEL[estado]}
</span>

<style>
	.badge {
		display: inline-flex;
		align-items: center;
		gap: var(--space-1);
		padding: var(--space-1) var(--space-2);
		border: var(--border-width) solid;
		border-radius: var(--radius-pill);
		font-size: var(--text-xs);
		font-weight: 600;
		line-height: var(--leading-tight);
		white-space: nowrap;
	}

	.limpio {
		background: var(--color-limpio-bg);
		border-color: var(--color-limpio-border);
		color: var(--color-limpio-fg);
	}

	.medio_limpio {
		background: var(--color-medio-bg);
		border-color: var(--color-medio-border);
		color: var(--color-medio-fg);
	}

	.sucio {
		background: var(--color-sucio-bg);
		border-color: var(--color-sucio-border);
		color: var(--color-sucio-fg);
	}
</style>
