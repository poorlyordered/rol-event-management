import { redirect } from '@sveltejs/kit';
import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals: { getSession }, url }) => {
    const session = await getSession();

    // Public routes that don't require authentication
    const publicRoutes = ['/', '/auth/login', '/auth/register'];
    
    // Staff-only routes
    const staffRoutes = [
        '/admin',
        '/organizations',
        '/tournaments/create',
        '/leagues/create'
    ];

    const path = url.pathname;

    // Redirect unauthenticated users from protected routes
    if (!session && !publicRoutes.includes(path)) {
        throw redirect(303, '/auth/login');
    }

    // Redirect authenticated users from auth pages
    if (session && ['/auth/login', '/auth/register'].includes(path)) {
        throw redirect(303, '/');
    }

    return {
        session
    };
};
