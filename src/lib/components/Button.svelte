<script lang="ts">
	import type { Snippet } from 'svelte';
	import type { HTMLButtonAttributes } from 'svelte/elements';

	type Props = HTMLButtonAttributes & {
		variant?: 'primary' | 'secondary' | 'ghost';
		block?: boolean;
		children: Snippet;
	};

	let {
		variant = 'secondary',
		block = false,
		type = 'button',
		class: className = '',
		children,
		...rest
	}: Props = $props();
</script>

<button
	{type}
	class="btn {className}"
	class:btn-primary={variant === 'primary'}
	class:btn-ghost={variant === 'ghost'}
	class:btn-block={block}
	{...rest}
>
	{@render children()}
</button>
