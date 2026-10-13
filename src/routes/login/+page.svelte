<script lang="ts">
	import { enhance } from '$app/forms';
	import Button from '#lib/components/Button.svelte';
	import LanguageSwitch from '#lib/components/LanguageSwitch.svelte';
	import { m } from '#lib/paraglide/messages.js';
	import ThemeToggle from '#lib/components/ThemeToggle.svelte';
	import { ICON_SIZE } from '#lib/components/icon-size.ts';
	import { TriangleAlert } from '@lucide/svelte';
	import type { PageProps } from './$types';

	let { form }: PageProps = $props();
	let submitting = $state(false);
</script>

<svelte:head>
	<title>{m.meta_title({ page: m.login_title() })}</title>
</svelte:head>

<div class="login-page">
	<div class="theme"><ThemeToggle /></div>
	<div class="brand">
		<p class="mark">ESPOCH</p>
		<p class="sub">{m.app_name()}</p>
	</div>

	<section class="card" aria-labelledby="login-titulo">
		<div class="intro">
			<h1 id="login-titulo">{m.login_title()}</h1>
			<p class="muted">{m.login_intro()}</p>
		</div>

		<form
			method="POST"
			use:enhance={() => {
				submitting = true;
				return async ({ update }) => {
					await update();
					submitting = false;
				};
			}}
		>
			<label class="field">
				<span class="field-label">{m.field_email()}</span>
				<input
					class="input"
					name="email"
					type="email"
					autocomplete="email"
					required
					value={form?.email ?? ''}
				/>
			</label>
			<label class="field">
				<span class="field-label">{m.field_password()}</span>
				<input
					class="input"
					name="password"
					type="password"
					autocomplete="current-password"
					required
				/>
			</label>

			{#if form?.message}
				<p class="alert error" role="alert">
					<TriangleAlert size={ICON_SIZE.sm} aria-hidden="true" />
					{form.message}
				</p>
			{/if}

			<Button type="submit" variant="primary" block disabled={submitting}>
				{submitting ? m.login_submitting() : m.login_title()}
			</Button>
		</form>
	</section>

	<LanguageSwitch variant="link" />

	<p class="foot">{m.login_institution()}</p>
</div>

<style>
	.login-page {
		--band: 16rem;
		position: relative;
		min-height: 100dvh;
		display: grid;
		align-content: start;
		justify-items: center;
		gap: var(--space-5);
		padding: var(--space-7) var(--gutter) var(--space-6);
		background:
			linear-gradient(var(--color-header), var(--color-header)) top / 100% var(--band) no-repeat,
			var(--color-bg);
	}

	.theme {
		position: absolute;
		top: var(--space-2);
		right: var(--space-2);
	}

	.brand {
		display: grid;
		justify-items: center;
		gap: var(--space-1);
		color: var(--color-brand-contrast);
		text-align: center;
	}

	.mark {
		font-family: var(--font-heading);
		font-weight: 700;
		font-size: var(--text-2xl);
		letter-spacing: 0.04em;
		line-height: 1;
	}

	.sub {
		font-size: var(--text-sm);
		font-weight: 500;
		color: var(--color-brand-contrast-muted);
		padding-top: var(--space-2);
		border-top: 2px solid var(--color-accent);
	}

	.card {
		width: 100%;
		max-width: 24rem;
		display: grid;
		gap: var(--space-5);
		padding: var(--space-5);
		background: var(--color-surface);
		border-radius: var(--radius-lg);
		box-shadow: var(--shadow-lg);
	}

	.intro {
		display: grid;
		gap: var(--space-1);
	}

	form {
		display: grid;
		gap: var(--space-4);
	}

	.foot {
		font-size: var(--text-xs);
		color: var(--color-text-muted);
		text-align: center;
	}

	@media (min-width: 640px) {
		.login-page {
			--band: 20rem;
			padding-top: calc(var(--space-7) * 1.5);
		}

		.card {
			padding: var(--space-6);
		}
	}
</style>
