<script lang="ts">
	import { Camera, ImageIcon, LoaderCircle, TriangleAlert } from '@lucide/svelte';
	import { MAX_PHOTO_BYTES } from '#lib/constants.ts';
	import { compressImage, PhotoError } from '#lib/image.ts';
	import { m } from '#lib/paraglide/messages.js';
	import { ICON_SIZE } from './icon-size.ts';

	type Props = {
		name: string;
		label: string;
		hint?: string;
		/** Visual and ARIA emphasis only; validation is done by the parent so the message is localized. */
		required?: boolean;
		error?: string;
		/** True while the photo is being optimized; the parent must not submit until it is false. */
		busy?: boolean;
		onselect?: (file: File | null) => void;
	};

	let {
		name,
		label,
		hint,
		required = false,
		error,
		busy = $bindable(false),
		onselect
	}: Props = $props();

	const inputId = $props.id();
	const hintId = `${inputId}-hint`;
	const errorId = `${inputId}-error`;
	let input = $state<HTMLInputElement>();
	let fileName = $state<string | null>(null);
	let previewUrl = $state<string | null>(null);
	let processingError = $state<string>();
	// Bumped on every selection, clear and unmount so a slow compression never overwrites newer state.
	let run = 0;

	const shownError = $derived(processingError ?? error);
	const describedBy = $derived(
		[hint ? hintId : null, shownError ? errorId : null].filter(Boolean).join(' ')
	);

	function setPreview(file: File | null) {
		if (previewUrl) URL.revokeObjectURL(previewUrl);
		previewUrl = file ? URL.createObjectURL(file) : null;
		fileName = file?.name ?? null;
	}

	async function onchange(event: Event & { currentTarget: HTMLInputElement }) {
		const el = event.currentTarget;
		const original = el.files?.[0] ?? null;
		const current = ++run;
		processingError = undefined;

		if (!original) {
			busy = false;
			setPreview(null);
			onselect?.(null);
			return;
		}

		busy = true;
		try {
			const file = await compressImage(original, MAX_PHOTO_BYTES);
			if (current !== run) return;
			if (file !== original) {
				// Swap in the optimized file so FormData (and use:enhance) submits it.
				const transfer = new DataTransfer();
				transfer.items.add(file);
				el.files = transfer.files;
			}
			setPreview(file);
			onselect?.(file);
		} catch (cause) {
			if (current !== run) return;
			el.value = '';
			setPreview(null);
			processingError =
				cause instanceof PhotoError && cause.reason === 'too_large'
					? m.photo_error_too_large({ max: MAX_PHOTO_BYTES / (1024 * 1024) })
					: m.photo_error_unreadable();
			onselect?.(null);
		} finally {
			if (current === run) busy = false;
		}
	}

	function clear() {
		run++;
		busy = false;
		processingError = undefined;
		if (input) input.value = '';
		setPreview(null);
		onselect?.(null);
	}

	// Clear the preview when the enclosing form is reset (e.g. after a successful submit).
	$effect(() => {
		const form = input?.form;
		if (!form) return;
		const onReset = () => {
			run++;
			busy = false;
			processingError = undefined;
			setPreview(null);
		};
		form.addEventListener('reset', onReset);
		return () => form.removeEventListener('reset', onReset);
	});

	$effect(() => {
		return () => {
			// Unmounted (e.g. the state switched to `limpio`): drop any pending compression.
			run++;
			busy = false;
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
			aria-required={required || undefined}
			aria-invalid={shownError ? true : undefined}
			aria-busy={busy || undefined}
			aria-labelledby="{inputId}-label {inputId}-action"
			aria-describedby={describedBy || undefined}
			{onchange}
		/>
		<label class="btn trigger" class:busy for={inputId} id="{inputId}-action">
			<Camera size={ICON_SIZE.md} aria-hidden="true" />
			{fileName ? m.photo_change() : m.photo_choose()}
		</label>

		{#if busy}
			<span class="processing" aria-hidden="true">
				<LoaderCircle class="spin" size={ICON_SIZE.sm} />
				{m.photo_processing()}
			</span>
		{:else if fileName}
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

	<span class="visually-hidden" role="status">{busy ? m.photo_processing() : ''}</span>

	{#if shownError}
		<p class="alert error" id={errorId} role="alert">
			<TriangleAlert size={ICON_SIZE.sm} aria-hidden="true" />
			{shownError}
		</p>
	{/if}
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
		border-color: var(--color-warning-solid);
		background: var(--color-warning-bg);
	}

	.required .hint {
		color: var(--color-warning-fg);
	}

	.trigger {
		width: 100%;
	}

	.trigger.busy {
		opacity: 0.65;
		pointer-events: none;
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

	.processing,
	.empty {
		display: inline-flex;
		align-items: center;
		gap: var(--space-2);
		font-size: var(--text-sm);
		color: var(--color-text-muted);
	}

	/* Reduced motion collapses animation-duration globally (app.css), so this stays a static icon. */
	.processing :global(.spin) {
		animation: spin 1s linear infinite;
	}

	@keyframes spin {
		to {
			transform: rotate(360deg);
		}
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
