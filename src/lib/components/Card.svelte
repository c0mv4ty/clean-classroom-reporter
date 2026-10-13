<script lang="ts">
	import type { Snippet } from 'svelte';

	let {
		title,
		padded = true,
		children
	}: { title?: string; padded?: boolean; children: Snippet } = $props();
</script>

<section class="card" class:padded>
	{#if title}<h2 class="title">{title}</h2>{/if}
	{@render children()}
</section>

<style>
	.card {
		display: grid;
		gap: var(--space-4);
		background: var(--color-surface);
		border: var(--border-width) solid var(--color-border);
		border-radius: var(--radius-md);
		box-shadow: var(--shadow-sm);
		min-width: 0;
	}

	.padded {
		padding: var(--space-4);
	}

	.title {
		font-size: var(--text-lg);
	}

	@media (min-width: 640px) {
		.padded {
			padding: var(--space-5);
		}
	}
</style>
