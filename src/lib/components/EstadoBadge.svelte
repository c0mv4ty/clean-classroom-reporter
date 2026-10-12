<script lang="ts">
	import { ESTADO_LABEL } from '#lib/estados.ts';
	import type { EstadoAula } from '#lib/types/database.ts';

	let { estado }: { estado: EstadoAula } = $props();
</script>

<span class="badge {estado}">{ESTADO_LABEL[estado]}</span>
