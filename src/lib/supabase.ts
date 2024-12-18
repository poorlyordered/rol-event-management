import { createClient } from '@supabase/supabase-js';
import type { 
    Profile, Organization, Team, Player, 
    Tournament, League, Match, StaffMember,
    RiotRegion 
} from './types';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl) throw new Error('Missing PUBLIC_SUPABASE_URL');
if (!supabaseAnonKey) throw new Error('Missing PUBLIC_SUPABASE_ANON_KEY');

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Auth helpers
export const signIn = async ({ email, password }: { email: string; password: string }) => {
    const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
    });
    return { data, error };
};

export const signUp = async ({ email, password }: { email: string; password: string }) => {
    const { data, error } = await supabase.auth.signUp({
        email,
        password
    });
    return { data, error };
};

export const signOut = async () => {
    const { error } = await supabase.auth.signOut();
    return { error };
};

// Profile helpers
export const getProfile = async (userId: string) => {
    const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();
    return { data: data as Profile | null, error };
};

export const updateProfile = async (userId: string, updates: Partial<Profile>) => {
    const { data, error } = await supabase
        .from('profiles')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();
    return { data: data as Profile | null, error };
};

// Organization helpers
export const getOrganizations = async () => {
    const { data, error } = await supabase
        .from('organizations')
        .select('*')
        .order('name');
    return { data: data as Organization[] | null, error };
};

export const getOrganization = async (id: string) => {
    const { data, error } = await supabase
        .from('organizations')
        .select(`
            *,
            teams (*)
        `)
        .eq('id', id)
        .single();
    return { data: data as (Organization & { teams: Team[] }) | null, error };
};

// Team helpers
export const getTeams = async (region?: RiotRegion) => {
    let query = supabase.from('teams').select(`
        *,
        organization:organizations(name),
        players(*)
    `);
    
    if (region) {
        query = query.eq('region', region);
    }
    
    const { data, error } = await query.order('name');
    return { data, error };
};

export const getTeam = async (id: string) => {
    const { data, error } = await supabase
        .from('teams')
        .select(`
            *,
            organization:organizations(name),
            players(
                *,
                profile:profiles(*)
            ),
            captain:profiles!teams_captain_id_fkey(*)
        `)
        .eq('id', id)
        .single();
    return { data, error };
};

// Tournament helpers
export const getTournaments = async (region?: RiotRegion) => {
    let query = supabase.from('tournaments').select(`
        *,
        tournament_teams(
            team:teams(*)
        )
    `);
    
    if (region) {
        query = query.eq('region', region);
    }
    
    const { data, error } = await query.order('start_date', { ascending: false });
    return { data, error };
};

export const getTournament = async (id: string) => {
    const { data, error } = await supabase
        .from('tournaments')
        .select(`
            *,
            tournament_teams(
                team:teams(
                    *,
                    players(
                        *,
                        profile:profiles(*)
                    )
                )
            ),
            matches(*)
        `)
        .eq('id', id)
        .single();
    return { data, error };
};

// League helpers
export const getLeagues = async (region?: RiotRegion) => {
    let query = supabase.from('leagues').select(`
        *,
        league_teams(
            team:teams(*)
        )
    `);
    
    if (region) {
        query = query.eq('region', region);
    }
    
    const { data, error } = await query.order('start_date', { ascending: false });
    return { data, error };
};

export const getLeague = async (id: string) => {
    const { data, error } = await supabase
        .from('leagues')
        .select(`
            *,
            league_teams(
                team:teams(
                    *,
                    players(
                        *,
                        profile:profiles(*)
                    )
                )
            )
        `)
        .eq('id', id)
        .single();
    return { data, error };
};

// Staff helpers
export const getStaffMembers = async (organizationId?: string) => {
    let query = supabase.from('staff_members').select(`
        *,
        user:profiles(*)
    `);
    
    if (organizationId) {
        query = query.eq('organization_id', organizationId);
    }
    
    const { data, error } = await query;
    return { data: data as (StaffMember & { user: Profile })[] | null, error };
};

// Region statistics
export const getRegionStats = async (region: RiotRegion) => {
    const { data, error } = await supabase
        .rpc('get_region_statistics', { region_code: region });
    return { data, error };
};
