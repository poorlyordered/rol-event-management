<script lang="ts">
    import RoleGuard from '$lib/components/RoleGuard.svelte';
    import { page } from '$app/stores';
    import { supabase } from '$lib/supabase';
    import type { Tournament, Team, Match } from '$lib/types';
    import { onMount } from 'svelte';

    interface TournamentTeam {
        team: Team;
    }

    export let data: { tournament: Tournament & { tournament_teams?: TournamentTeam[]; matches?: Match[] } };
    let tournament = data.tournament;
    let loading = true;
    let error: string | null = null;

    $: tournamentTeams = tournament?.tournament_teams || [];
    $: matches = tournament?.matches || [];
    $: hasTeams = tournamentTeams.length > 0;
    $: hasMatches = matches.length > 0;

    onMount(async () => {
        const { data, error: fetchError } = await supabase
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
            .eq('id', $page.params.id)
            .single();

        if (fetchError) {
            error = fetchError.message;
        } else {
            tournament = data;
        }
        loading = false;
    });

    async function loadTeam(teamId: string) {
        const { data: teamData } = await supabase
            .from('teams')
            .select('*')
            .eq('id', teamId)
            .single();
        return teamData;
    }

    async function handleTeamJoin() {
        if (!tournament) return;

        const { error: joinError } = await supabase
            .from('tournament_teams')
            .insert({
                tournament_id: tournament.id,
                team_id: 'YOUR_TEAM_ID' // Replace with actual team selection logic
            });

        if (joinError) {
            error = joinError.message;
        } else {
            // Refresh tournament data
            window.location.reload();
        }
    }
</script>

{#if loading}
    <div class="loading">Loading tournament details...</div>
{:else if error}
    <div class="error">{error}</div>
{:else if tournament}
    <div class="tournament-details">
        <header>
            <h1>{tournament.name}</h1>
            <div class="meta">
                <span class="region">{tournament.region}</span>
                <span class="dates">
                    {new Date(tournament.start_date).toLocaleDateString()} - 
                    {new Date(tournament.end_date).toLocaleDateString()}
                </span>
            </div>
        </header>

        <section class="description">
            <h2>About</h2>
            <p>{tournament.description}</p>
        </section>

        <section class="teams">
            <h2>Teams ({tournament.tournament_teams?.length || 0}/{tournament.max_teams})</h2>
            
            <RoleGuard roles={['owner', 'platform_admin', 'tournament_director']}>
                <div class="admin-controls">
                    <button on:click={() => window.location.href = `/events/${tournament.id}/edit`}>
                        Edit Tournament
                    </button>
                    <button on:click={() => window.location.href = `/events/${tournament.id}/matches`}>
                        Manage Matches
                    </button>
                </div>
            </RoleGuard>

            {#if hasTeams}
                <div class="teams-grid">
                    {#each tournamentTeams as { team }}
                        <div class="team-card">
                            <h3>{team.name}</h3>
                            <p>Players: {team.players?.length || 0}</p>
                        </div>
                    {/each}
                </div>
            {:else}
                <p class="no-teams">No teams have joined this tournament yet.</p>
            {/if}

            {#if tournament.tournament_teams?.length < tournament.max_teams}
                <button class="join-button" on:click={handleTeamJoin}>
                    Join Tournament
                </button>
            {/if}
        </section>

        {#if hasMatches}
            <section class="matches">
                <h2>Matches</h2>
                <div class="matches-list">
                    {#each matches as match}
                        <div class="match-card">
                            <!-- Add match display logic here -->
                        </div>
                    {/each}
                </div>
            </section>
        {/if}
    </div>
{/if}

<style>
    .tournament-details {
        max-width: 1200px;
        margin: 2rem auto;
        padding: 2rem;
    }

    header {
        margin-bottom: 2rem;
        padding-bottom: 1rem;
        border-bottom: 1px solid var(--color-border);
    }

    h1 {
        margin: 0;
        color: var(--color-primary);
    }

    .meta {
        margin-top: 0.5rem;
        color: var(--color-text-secondary);
    }

    .region {
        background-color: var(--color-accent);
        color: white;
        padding: 0.25rem 0.5rem;
        border-radius: 4px;
        margin-right: 1rem;
    }

    section {
        margin-bottom: 2rem;
    }

    .teams-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
        gap: 1rem;
        margin-top: 1rem;
    }

    .team-card {
        padding: 1rem;
        background: white;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    .team-card h3 {
        margin: 0;
        color: var(--color-primary);
    }

    .admin-controls {
        margin-bottom: 1rem;
    }

    .admin-controls button {
        margin-right: 1rem;
    }

    .join-button {
        width: 100%;
        padding: 0.75rem;
        background-color: var(--color-primary);
        color: white;
        border: none;
        border-radius: 4px;
        font-size: 1rem;
        cursor: pointer;
        transition: background-color 0.2s;
    }

    .join-button:hover {
        background-color: var(--color-primary-dark);
    }

    .loading {
        text-align: center;
        padding: 2rem;
        color: var(--color-text-secondary);
    }

    .error {
        color: var(--color-error);
        padding: 1rem;
        background-color: rgba(var(--color-error-rgb), 0.1);
        border-radius: 4px;
        margin: 2rem auto;
        max-width: 800px;
    }

    .no-teams {
        text-align: center;
        color: var(--color-text-secondary);
        padding: 2rem;
        background-color: #f5f5f5;
        border-radius: 4px;
    }
</style>
