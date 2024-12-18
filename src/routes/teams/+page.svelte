<script lang="ts">
    import { RoleGuard } from '$lib/components/RoleGuard.svelte';
    import { RegionSelect } from '$lib/components/RegionSelect.svelte';
    import { supabase } from '$lib/supabase';
    import type { Team, Organization } from '$lib/types';
    import { onMount } from 'svelte';

    let teams: Team[] = [];
    let organizations: Organization[] = [];
    let loading = true;
    let error: string | null = null;
    let selectedRegion: string | null = null;

    // New team form
    let showCreateForm = false;
    let newTeam = {
        name: '',
        organization_id: '',
        region: '',
        description: '',
        discord_invite: ''
    };

    onMount(async () => {
        await Promise.all([
            loadTeams(),
            loadOrganizations()
        ]);
        loading = false;
    });

    async function loadTeams() {
        const query = supabase
            .from('teams')
            .select(`
                *,
                organization:organizations(name),
                players(
                    *,
                    profile:profiles(*)
                ),
                captain:profiles(*)
            `)
            .order('name');

        if (selectedRegion) {
            query.eq('region', selectedRegion);
        }

        const { data, error: fetchError } = await query;

        if (fetchError) {
            error = fetchError.message;
        } else {
            teams = data;
        }
    }

    async function loadOrganizations() {
        const { data, error: fetchError } = await supabase
            .from('organizations')
            .select('id, name, region')
            .order('name');

        if (fetchError) {
            error = fetchError.message;
        } else {
            organizations = data;
        }
    }

    async function handleCreateTeam() {
        const { data, error: createError } = await supabase
            .from('teams')
            .insert(newTeam)
            .select()
            .single();

        if (createError) {
            error = createError.message;
        } else {
            await loadTeams();
            showCreateForm = false;
            newTeam = {
                name: '',
                organization_id: '',
                region: '',
                description: '',
                discord_invite: ''
            };
        }
    }

    $: {
        if (selectedRegion !== null) {
            loadTeams();
        }
    }
</script>

<div class="teams">
    <header>
        <div class="header-content">
            <h1>Teams</h1>
            <div class="filters">
                <RegionSelect
                    bind:value={selectedRegion}
                    placeholder="Filter by Region"
                />
            </div>
        </div>
        <RoleGuard roles={['owner', 'platform_admin', 'org_manager']}>
            <button class="create-button" on:click={() => showCreateForm = true}>
                Create Team
            </button>
        </RoleGuard>
    </header>

    {#if loading}
        <div class="loading">Loading teams...</div>
    {:else if error}
        <div class="error">{error}</div>
    {:else}
        <div class="team-grid">
            {#each teams as team}
                <div class="team-card">
                    <h2>{team.name}</h2>
                    <div class="meta">
                        <span class="region">{team.region}</span>
                        {#if team.organization}
                            <span class="org">
                                {team.organization.name}
                            </span>
                        {/if}
                    </div>
                    <p>{team.description}</p>
                    <div class="stats">
                        <span>Players: {team.players?.length || 0}</span>
                        {#if team.captain}
                            <span>Captain: {team.captain.username}</span>
                        {/if}
                    </div>
                    <RoleGuard 
                        roles={['owner', 'platform_admin', 'org_manager']} 
                        organizationId={team.organization_id}
                    >
                        <div class="actions">
                            <button on:click={() => window.location.href = `/teams/${team.id}`}>
                                Manage
                            </button>
                        </div>
                    </RoleGuard>
                </div>
            {/each}
        </div>
    {/if}
</div>

{#if showCreateForm}
    <div class="modal">
        <div class="modal-content">
            <h2>Create Team</h2>
            <form on:submit|preventDefault={handleCreateTeam}>
                <div class="form-group">
                    <label for="name">Team Name</label>
                    <input
                        type="text"
                        id="name"
                        bind:value={newTeam.name}
                        required
                        minlength="3"
                        maxlength="100"
                    />
                </div>

                <div class="form-group">
                    <label for="organization">Organization</label>
                    <select
                        id="organization"
                        bind:value={newTeam.organization_id}
                        required
                    >
                        <option value="">Select Organization</option>
                        {#each organizations as org}
                            <option value={org.id}>{org.name}</option>
                        {/each}
                    </select>
                </div>

                <div class="form-group">
                    <label for="region">Region</label>
                    <RegionSelect bind:value={newTeam.region} required />
                </div>

                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea
                        id="description"
                        bind:value={newTeam.description}
                        required
                        rows="4"
                    ></textarea>
                </div>

                <div class="form-group">
                    <label for="discord">Discord Invite (optional)</label>
                    <input
                        type="url"
                        id="discord"
                        bind:value={newTeam.discord_invite}
                        placeholder="https://discord.gg/..."
                    />
                </div>

                <div class="form-actions">
                    <button type="button" class="secondary" on:click={() => showCreateForm = false}>
                        Cancel
                    </button>
                    <button type="submit">
                        Create Team
                    </button>
                </div>
            </form>
        </div>
    </div>
{/if}

<style>
    .teams {
        max-width: 1200px;
        margin: 2rem auto;
        padding: 0 2rem;
    }

    header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 2rem;
    }

    .header-content {
        display: flex;
        align-items: center;
        gap: 2rem;
    }

    h1 {
        margin: 0;
        color: var(--color-primary);
    }

    .filters {
        display: flex;
        gap: 1rem;
        align-items: center;
    }

    .create-button {
        padding: 0.75rem 1.5rem;
        background-color: var(--color-primary);
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        transition: background-color 0.2s;
    }

    .create-button:hover {
        background-color: var(--color-primary-dark);
    }

    .team-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 2rem;
    }

    .team-card {
        background: white;
        padding: 1.5rem;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    .team-card h2 {
        margin: 0 0 1rem;
        color: var(--color-primary);
    }

    .meta {
        display: flex;
        align-items: center;
        gap: 1rem;
        margin-bottom: 1rem;
    }

    .region {
        background-color: var(--color-accent);
        color: white;
        padding: 0.25rem 0.5rem;
        border-radius: 4px;
        font-size: 0.875rem;
    }

    .org {
        color: var(--color-text-secondary);
        font-size: 0.875rem;
    }

    .stats {
        margin-top: 1rem;
        padding-top: 1rem;
        border-top: 1px solid var(--color-border);
        color: var(--color-text-secondary);
        display: flex;
        justify-content: space-between;
    }

    .actions {
        margin-top: 1rem;
    }

    .modal {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: rgba(0, 0, 0, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
    }

    .modal-content {
        background: white;
        padding: 2rem;
        border-radius: 8px;
        width: 100%;
        max-width: 500px;
        max-height: 90vh;
        overflow-y: auto;
    }

    .form-group {
        margin-bottom: 1.5rem;
    }

    label {
        display: block;
        margin-bottom: 0.5rem;
        font-weight: 500;
    }

    input, textarea, select {
        width: 100%;
        padding: 0.5rem;
        border: 1px solid var(--color-border);
        border-radius: 4px;
        font-size: 1rem;
    }

    .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: 1rem;
        margin-top: 2rem;
    }

    .form-actions button {
        padding: 0.75rem 1.5rem;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 1rem;
        transition: background-color 0.2s;
    }

    .form-actions button.secondary {
        background-color: var(--color-border);
        color: var(--color-text);
    }

    .form-actions button:not(.secondary) {
        background-color: var(--color-primary);
        color: white;
    }

    .error {
        color: var(--color-error);
        padding: 1rem;
        background-color: rgba(var(--color-error-rgb), 0.1);
        border-radius: 4px;
        margin-bottom: 2rem;
    }

    .loading {
        text-align: center;
        padding: 2rem;
        color: var(--color-text-secondary);
    }
</style>
