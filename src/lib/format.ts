// Server renders on Cloudflare (UTC), so pin the school's time zone explicitly.
const APP_TIME_ZONE = 'America/Lima';

const dateTime = new Intl.DateTimeFormat('es', {
	dateStyle: 'short',
	timeStyle: 'short',
	timeZone: APP_TIME_ZONE
});

export function formatDateTime(value: string | null | undefined) {
	return value ? dateTime.format(new Date(value)) : '—';
}
