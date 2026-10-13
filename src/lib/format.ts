import { getLocale } from '#lib/paraglide/runtime.js';

// Server renders on Cloudflare (UTC), so pin the school's time zone explicitly.
const APP_TIME_ZONE = 'America/Lima';

const formatters = new Map<string, Intl.DateTimeFormat>();

function dateTimeFormat(locale: string) {
	let formatter = formatters.get(locale);
	if (!formatter) {
		formatter = new Intl.DateTimeFormat(locale, {
			dateStyle: 'short',
			timeStyle: 'short',
			timeZone: APP_TIME_ZONE
		});
		formatters.set(locale, formatter);
	}
	return formatter;
}

export function formatDateTime(value: string | null | undefined) {
	return value ? dateTimeFormat(getLocale()).format(new Date(value)) : '—';
}
