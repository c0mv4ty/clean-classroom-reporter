<script lang="ts">
	import type { Snippet } from 'svelte';

	let { title, description, aside }: { title: string; description?: string; aside?: Snippet } =
		$props();
</script>

<header class="page-header">
	<div class="text">
		<h1>{title}</h1>
		{#if description}<p class="muted">{description}</p>{/if}
	</div>
	{#if aside}<div class="aside">{@render aside()}</div>{/if}
</header>

<style>
	.page-header {
		display: flex;
		flex-wrap: wrap;
		align-items: flex-end;
		justify-content: space-between;
		gap: var(--space-3) var(--space-5);
		padding-bottom: var(--space-4);
		border-bottom: var(--border-width) solid var(--color-border);
	}

	.text {
		display: grid;
		gap: var(--space-1);
		min-width: 0;
	}

	.aside {
		min-width: 0;
	}
</style>
