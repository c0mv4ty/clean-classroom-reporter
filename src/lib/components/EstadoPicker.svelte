<script lang="ts">
	import EstadoIcon from './EstadoIcon.svelte';
	import { ESTADO_LABEL, ESTADOS } from '#lib/estados.ts';
	import type { EstadoAula } from '#lib/types/database.ts';

	let { name, value = $bindable(null) }: { name: string; value?: EstadoAula | null } = $props();
</script>

<fieldset class="picker">
	<legend class="field-label">Estado del aula</legend>
	<div class="options">
		{#each ESTADOS as opcion (opcion)}
			<label class="option {opcion}">
				<input
					class="visually-hidden"
					type="radio"
					{name}
					value={opcion}
					bind:group={value}
					required
				/>
				<span class="icon"><EstadoIcon estado={opcion} size="md" /></span>
				<span class="text">{ESTADO_LABEL[opcion]}</span>
			</label>
		{/each}
	</div>
</fieldset>

<style>
	.picker {
		border: none;
		margin: 0;
		padding: 0;
		min-width: 0;
	}

	.picker legend {
		padding: 0;
		margin-bottom: var(--space-2);
	}

	.options {
		display: grid;
		gap: var(--space-2);
	}

	.option {
		position: relative;
		display: flex;
		align-items: center;
		gap: var(--space-3);
		min-height: calc(var(--touch) * 1.25);
		padding: var(--space-2) var(--space-3);
		border: var(--border-width-strong) solid var(--color-border);
		border-radius: var(--radius-md);
		background: var(--color-surface);
		font-weight: 600;
		cursor: pointer;
		transition:
			border-color var(--duration-fast) var(--ease-out),
			background-color var(--duration-fast) var(--ease-out);
	}

	.option:hover {
		border-color: var(--color-border-strong);
	}

	.icon {
		display: inline-grid;
		place-items: center;
		flex: none;
	}

	.option:has(input:focus-visible) {
		outline: var(--border-width-strong) solid var(--color-focus);
		outline-offset: 2px;
	}

	.limpio .icon {
		color: var(--color-limpio-fg);
	}

	.medio_limpio .icon {
		color: var(--color-medio-fg);
	}

	.sucio .icon {
		color: var(--color-sucio-fg);
	}

	.limpio:has(input:checked) {
		border-color: var(--color-limpio-solid);
		background: var(--color-limpio-bg);
		color: var(--color-limpio-fg);
	}

	.medio_limpio:has(input:checked) {
		border-color: var(--color-medio-solid);
		background: var(--color-medio-bg);
		color: var(--color-medio-fg);
	}

	.sucio:has(input:checked) {
		border-color: var(--color-sucio-solid);
		background: var(--color-sucio-bg);
		color: var(--color-sucio-fg);
	}

	@media (min-width: 640px) {
		.options {
			grid-template-columns: repeat(3, minmax(0, 1fr));
		}

		.option {
			flex-direction: column;
			justify-content: center;
			text-align: center;
			gap: var(--space-2);
			padding: var(--space-4) var(--space-3);
		}
	}
</style>
