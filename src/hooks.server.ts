import { getTextDirection } from '#lib/paraglide/runtime.js';
import { paraglideMiddleware } from '#lib/paraglide/server.js';
import { createServerClient } from '@supabase/ssr';
import { redirect } from '@sveltejs/kit';
import { sequence } from '@sveltejs/kit/hooks';
import type { Handle } from '@sveltejs/kit/hooks';
import { PUBLIC_SUPABASE_ANON_KEY, PUBLIC_SUPABASE_URL } from '$app/env/public';
import type { Database } from '#lib/types/database.ts';

const supabase: Handle = async ({ event, resolve }) => {
	event.locals.supabase = createServerClient<Database>(
		PUBLIC_SUPABASE_URL,
		PUBLIC_SUPABASE_ANON_KEY,
		{
			cookies: {
				getAll: () => event.cookies.getAll(),
				setAll: (cookiesToSet) => {
					cookiesToSet.forEach(({ name, value, options }) => {
						event.cookies.set(name, value, { ...options, path: '/' });
					});
				}
			}
		}
	);

	/**
	 * Unlike `getSession()`, this validates the JWT by calling `auth.getUser()`
	 * against the Supabase Auth server, so the returned user can be trusted.
	 */
	event.locals.safeGetSession = async () => {
		const {
			data: { session }
		} = await event.locals.supabase.auth.getSession();
		if (!session) return { session: null, user: null };

		const {
			data: { user },
			error
		} = await event.locals.supabase.auth.getUser();
		if (error || !user) return { session: null, user: null };

		return { session, user };
	};

	return resolve(event, {
		filterSerializedResponseHeaders(name) {
			return name === 'content-range' || name === 'x-supabase-api-version';
		}
	});
};

const PUBLIC_PATHS = ['/login'];

function isPublicPath(pathname: string) {
	return PUBLIC_PATHS.some((p) => pathname === p || pathname.startsWith(`${p}/`));
}

const authGuard: Handle = async ({ event, resolve }) => {
	const { session, user } = await event.locals.safeGetSession();
	event.locals.session = session;
	event.locals.user = user;
	event.locals.profile = null;

	if (user) {
		const { data: profile } = await event.locals.supabase
			.from('profiles')
			.select('*')
			.eq('id', user.id)
			.maybeSingle();
		event.locals.profile = profile;
	}

	const { pathname, search } = event.url;

	if (!user && !isPublicPath(pathname)) {
		const redirectTo = encodeURIComponent(pathname + search);
		redirect(303, `/login?redirectTo=${redirectTo}`);
	}

	if (user && pathname === '/login') {
		redirect(303, '/');
	}

	if (
		(pathname === '/admin' || pathname.startsWith('/admin/')) &&
		event.locals.profile?.rol !== 'admin'
	) {
		redirect(303, '/');
	}

	return resolve(event);
};

const handleParaglide: Handle = ({ event, resolve }) =>
	paraglideMiddleware(event.request, ({ request, locale }) =>
		resolve(
			{ ...event, request },
			{
				transformPageChunk: ({ html }) =>
					html
						.replace('%paraglide.lang%', locale)
						.replace('%paraglide.dir%', getTextDirection(locale))
			}
		)
	);

export const handle = sequence(handleParaglide, supabase, authGuard);
