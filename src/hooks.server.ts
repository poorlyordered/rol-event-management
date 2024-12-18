import { createServerClient } from '@supabase/ssr';
import type { Handle } from '@sveltejs/kit';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl) throw new Error('Missing PUBLIC_SUPABASE_URL');
if (!supabaseAnonKey) throw new Error('Missing PUBLIC_SUPABASE_ANON_KEY');

export const handle: Handle = async ({ event, resolve }) => {
    event.locals.supabase = createServerClient(
        supabaseUrl,
        supabaseAnonKey,
        {
            cookies: {
                get: (key) => event.cookies.get(key),
                set: (key, value, options) => {
                    event.cookies.set(key, value, options);
                },
                remove: (key, options) => {
                    event.cookies.delete(key, options);
                },
            },
        }
    );

    /**
     * A convenience helper so we can just call await getSession() instead of
     * await event.locals.supabase.auth.getSession() in our code
     */
    event.locals.getSession = async () => {
        const {
            data: { session },
        } = await event.locals.supabase.auth.getSession();
        return session;
    };

    return resolve(event, {
        filterSerializedResponseHeaders(name) {
            return name === 'content-range';
        },
    });
};
