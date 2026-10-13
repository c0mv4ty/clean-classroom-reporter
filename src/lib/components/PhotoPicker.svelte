<script lang="ts">
	import { Camera, ImageIcon } from '@lucide/svelte';
	import { m } from '#lib/paraglide/messages.js';
	import { ICON_SIZE } from './icon-size.ts';

	type Props = {
		name: string;
		label: string;
		hint?: string;
		required?: boolean;
	};

	let { name, label, hint, required = false }: Props = $props();

	const inputId = $props.id();
	const hintId = `${inputId}-hint`;

	let input = $state<HTMLInputElement>();
	let fileName = $state<string | null>(null);
	let previewUrl = $state<string | null>(null);

	function setPreview(file: File | null) {
		if (previewUrl) URL.revokeObjectURL(previewUrl);
		previewUrl = file ? URL.createObjectURL(file) : null;
		fileName = file?.name ?? null;
	}

	function onchange(event: Event & { currentTarget: HTMLInputElement }) {
		setPreview(event.currentTarget.files?.[0] ?? null);
	}

	function clear() {
		if (input) input.value = '';
		setPreview(null);
	}

	// Clear the preview when the enclosing form is reset (e.g. after a successful submit).
	$effect(() => {
		const form = input?.form;
		if (!form) return;
		const onReset = () => setPreview(null);
		form.addEventListener('reset', onReset);
		return () => form.removeEventListener('reset', onReset);
	});

	$effect(() => {
		return () => {
			if (previewUrl) URL.revokeObjectURL(previewUrl);
		};
	});
</script>

<div class="field picker" class:required>
	<span class="field-label" id="{inputId}-label">{label}</span>
	{#if hint}<p class="field-hint hint" id={hintId}>{hint}</p>{/if}

	<div class="row">
		<input
			bind:this={input}
			id={inputId}
			class="visually-hidden"
			type="file"
			{name}
			accept="image/*"
			capture="environment"
			{required}
			aria-labelledby="{inputId}-label {inputId}-action"
			aria-describedby={hint ? hintId : undefined}
			{onchange}
		/>
		<label class="btn trigger" for={inputId} id="{inputId}-action">
			<Camera size={ICON_SIZE.md} aria-hidden="true" />
			{fileName ? m.photo_change() : m.photo_choose()}
		</label>

		{#if fileName}
			<div class="selected">
				{#if previewUrl}
					<img class="thumb" src={previewUrl} alt={m.photo_preview_alt()} />
				{/if}
				<div class="meta">
					<span class="file-name">{fileName}</span>
					<button type="button" class="remove" onclick={clear}>{m.photo_remove()}</button>
				</div>
			</div>
		{:else}
			<span class="empty"
				><ImageIcon size={ICON_SIZE.sm} aria-hidden="true" /> {m.photo_none()}</span
			>
		{/if}
	</div>
</div>

<style>
	.row {
		display: grid;
		gap: var(--space-3);
		padding: var(--space-3);
		border: var(--border-width) dashed var(--color-border-strong);
		border-radius: var(--radius-md);
		background: var(--color-surface-alt);
	}

	.required .row {
		border-color: var(--color-medio-solid);
		background: var(--color-medio-bg);
	}

	.required .hint {
		color: var(--color-medio-fg);
	}

	.trigger {
		width: 100%;
	}

	.row:has(input:focus-visible) .trigger {
		outline: var(--border-width-strong) solid var(--color-focus);
		outline-offset: 2px;
	}

	.selected {
		display: flex;
		align-items: center;
		gap: var(--space-3);
		min-width: 0;
	}

	.thumb {
		width: var(--thumb);
		height: var(--thumb);
		flex: none;
		object-fit: cover;
		border-radius: var(--radius-sm);
		border: var(--border-width) solid var(--color-border);
		background: var(--color-surface);
	}

	.meta {
		display: grid;
		gap: var(--space-1);
		justify-items: start;
		min-width: 0;
	}

	.file-name {
		font-size: var(--text-sm);
		font-weight: 500;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
		max-width: 100%;
	}

	.remove {
		min-height: var(--touch);
		padding: 0;
		border: none;
		background: none;
		color: var(--color-link);
		font-size: var(--text-sm);
		font-weight: 600;
		text-decoration: underline;
		text-underline-offset: 0.18em;
		cursor: pointer;
	}

	.empty {
		display: inline-flex;
		align-items: center;
		gap: var(--space-2);
		font-size: var(--text-sm);
		color: var(--color-text-muted);
	}

	@media (min-width: 640px) {
		.row {
			grid-template-columns: auto minmax(0, 1fr);
			align-items: center;
		}

		.trigger {
			width: auto;
		}
	}
</style>
