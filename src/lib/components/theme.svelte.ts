// Shared theme state for ThemeToggle and ThemeSelect.
// Keep STORAGE_KEY in sync with the pre-paint script in src/app.html.
export type Theme = 'system' | 'light' | 'dark';

export const THEMES: readonly Theme[] = ['system', 'light', 'dark'];
export const THEME_LABEL: Record<Theme, string> = {
	system: 'Sistema',
	light: 'Claro',
	dark: 'Oscuro'
};

const STORAGE_KEY = 'theme';

export const theme = $state<{ current: Theme }>({ current: 'system' });

/** Reads the theme applied by the pre-paint script. Call from onMount. */
export function syncTheme() {
	const applied = document.documentElement.dataset.theme;
	theme.current = applied === 'light' || applied === 'dark' ? applied : 'system';
}

export function setTheme(next: Theme) {
	theme.current = next;
	const root = document.documentElement;
	if (next === 'system') delete root.dataset.theme;
	else root.dataset.theme = next;
	try {
		if (next === 'system') localStorage.removeItem(STORAGE_KEY);
		else localStorage.setItem(STORAGE_KEY, next);
	} catch {
		// Storage can be unavailable (private mode); the choice still applies to this page.
	}
}
