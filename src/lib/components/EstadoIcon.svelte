<script lang="ts">
	import { CircleCheck, CircleX } from '@lucide/svelte';
	import { ICON_SIZE } from './icon-size.ts';
	import type { EstadoAula } from '#lib/types/database.ts';

	let { estado, size = 'sm' }: { estado: EstadoAula; size?: keyof typeof ICON_SIZE } = $props();

	// Distinct shapes per state so meaning never depends on color alone.
	const ICONS = { limpio: CircleCheck, sucio: CircleX };
	const Icon = $derived(ICONS[estado]);
</script>

<Icon size={ICON_SIZE[size]} aria-hidden="true" />
