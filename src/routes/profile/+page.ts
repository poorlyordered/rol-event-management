import { redirect } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import { user } from '$lib/stores/session';
import { get } from 'svelte/store';

export const load: PageLoad = async () => {
    const currentUser = get(user);
    
    if (!currentUser) {
        throw redirect(307, '/auth');
    }

    return {
        user: currentUser
    };
};
