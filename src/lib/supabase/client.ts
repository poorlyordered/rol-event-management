import { createBrowserClient } from '@supabase/ssr';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl) throw new Error('Missing PUBLIC_SUPABASE_URL');
if (!supabaseAnonKey) throw new Error('Missing PUBLIC_SUPABASE_ANON_KEY');

export const supabase = createBrowserClient(
    supabaseUrl,
    supabaseAnonKey
);
