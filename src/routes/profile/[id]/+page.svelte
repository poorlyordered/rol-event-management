<script lang="ts">
    import { page } from '$app/stores';
    import { supabase } from '$lib/supabase';
    import type { Profile, Team, Tournament, Organization } from '$lib/types';
    import { onMount } from 'svelte';

    export let data: { profile: Profile | null };
    let profile = data.profile;
    let teams: (Team & { organization?: Organization })[] = [];
    let tournaments: Tournament[] = [];
    let loading = true;
    let error: string | null = null;
    let editing = false;

    $: canEdit = profile && $page.data.session?.user.id === profile.id;

    onMount(async () => {
        if (profile) {
            await Promise.all([
                fetchTeams(),
                fetchTournaments()
            ]);
        }
        loading = false;
    });

    async function fetchTeams() {
        const { data: teamData } = await supabase
            .from('teams')
            .select(`
                *,
                organization:organizations (
                    id,
                    name
                )
            `)
            .eq('captain_id', profile?.id);
        teams = teamData || [];
    }

    async function fetchTournaments() {
        const { data: tournamentData } = await supabase
            .from('tournaments')
            .select('*')
            .eq('organizer_id', profile?.id);
        tournaments = tournamentData || [];
    }

    async function handleSave() {
        if (!profile) return;

        const { error: updateError } = await supabase
            .from('profiles')
            .update({
                username: profile.username,
                full_name: profile.full_name,
                bio: profile.bio,
                discord_username: profile.discord_username,
                twitter_username: profile.twitter_username,
                twitch_username: profile.twitch_username
            })
            .eq('id', profile.id);

        if (updateError) {
            error = updateError.message;
        } else {
            editing = false;
        }
    }
</script>

<div class="profile">
    {#if loading}
        <p>Loading...</p>
    {:else if error}
        <p class="error">{error}</p>
    {:else if profile}
        <div class="profile-header">
            <div class="profile-info">
                <h1 class="text-3xl font-bold">{profile.username}</h1>
                <p class="text-lg">{profile.full_name}</p>
                {#if profile.bio}
                    <p class="mt-4">{profile.bio}</p>
                {/if}
                {#if profile.discord_username}
                    <div class="mt-4">
                        <a href="https://discord.com/users/{profile.discord_username}" class="text-blue-500 hover:text-blue-700">
                            <i class="fab fa-discord"></i> {profile.discord_username}
                        </a>
                    </div>
                {/if}
                {#if profile.twitter_username}
                    <div class="mt-2">
                        <a href="https://twitter.com/{profile.twitter_username}" target="_blank" rel="noopener noreferrer" class="text-blue-500 hover:text-blue-700">
                            <i class="fab fa-twitter"></i> @{profile.twitter_username}
                        </a>
                    </div>
                {/if}
                {#if profile.twitch_username}
                    <div class="mt-2">
                        <a href="https://twitch.tv/{profile.twitch_username}" target="_blank" rel="noopener noreferrer" class="text-purple-500 hover:text-purple-700">
                            <i class="fab fa-twitch"></i> {profile.twitch_username}
                        </a>
                    </div>
                {/if}
                {#if canEdit}
                    <button 
                        class="edit-button"
                        on:click={() => editing = !editing}
                    >
                        {editing ? 'Cancel' : 'Edit Profile'}
                    </button>
                {/if}
            </div>
        </div>

        {#if editing}
            <div class="edit-form">
                <h2>Edit Profile</h2>
                <form on:submit|preventDefault={handleSave}>
                    <div class="form-group">
                        <label for="username">Username</label>
                        <input
                            type="text"
                            id="username"
                            bind:value={profile.username}
                            required
                            minlength="3"
                            maxlength="30"
                        />
                    </div>

                    <div class="form-group">
                        <label for="full_name">Full Name</label>
                        <input
                            type="text"
                            id="full_name"
                            bind:value={profile.full_name}
                            maxlength="100"
                        />
                    </div>

                    <div class="form-group">
                        <label for="bio">Bio</label>
                        <textarea
                            id="bio"
                            bind:value={profile.bio}
                            rows="4"
                            maxlength="500"
                        ></textarea>
                    </div>

                    <div class="form-group">
                        <label for="discord">Discord Username</label>
                        <input
                            type="text"
                            id="discord"
                            bind:value={profile.discord_username}
                            placeholder="username#0000"
                        />
                    </div>

                    <div class="form-group">
                        <label for="twitter">Twitter Username</label>
                        <input
                            type="text"
                            id="twitter"
                            bind:value={profile.twitter_username}
                            placeholder="@username"
                        />
                    </div>

                    <div class="form-group">
                        <label for="twitch">Twitch Username</label>
                        <input
                            type="text"
                            id="twitch"
                            bind:value={profile.twitch_username}
                        />
                    </div>

                    <div class="form-actions">
                        <button type="submit">Save Changes</button>
                    </div>
                </form>
            </div>
        {:else}
            <div class="profile-content">
                {#if teams.length > 0}
                    <section class="teams">
                        <h2>Teams</h2>
                        <div class="teams-grid">
                            {#each teams as team}
                                <div class="team-card">
                                    <h3>{team.name}</h3>
                                    {#if team.organization}
                                        <p>{team.organization.name}</p>
                                    {/if}
                                </div>
                            {/each}
                        </div>
                    </section>
                {/if}

                {#if tournaments.length > 0}
                    <section class="tournaments">
                        <h2>Tournaments</h2>
                        <div class="tournament-list">
                            {#each tournaments as tournament}
                                <div class="tournament-card">
                                    <h3>{tournament.name}</h3>
                                    <div class="tournament-meta">
                                        <span>{tournament.start_date} - {tournament.end_date}</span>
                                        <span class="region">{tournament.region}</span>
                                    </div>
                                </div>
                            {/each}
                        </div>
                    </section>
                {/if}
            </div>
        {/if}
    {/if}
</div>

<style>
    .profile-header {
        margin-bottom: 2rem;
    }

    .profile-info {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    .teams, .tournaments {
        margin-top: 2rem;
    }

    .teams h2, .tournaments h2 {
        font-size: 1.5rem;
        font-weight: bold;
        margin-bottom: 1rem;
    }

    .team-card, .tournament-card {
        background-color: white;
        border-radius: 0.5rem;
        padding: 1rem;
        margin-bottom: 1rem;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    }

    .team-card h3, .tournament-card h3 {
        font-size: 1.25rem;
        font-weight: bold;
        margin-bottom: 0.5rem;
    }

    .tournament-meta {
        font-size: 0.875rem;
        color: #666;
    }
</style>
