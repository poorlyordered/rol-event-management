<script lang="ts">
    import RoleGuard from '$lib/components/RoleGuard.svelte';
    import RegionSelect from '$lib/components/RegionSelect.svelte';
    import { page } from '$app/stores';
    import { supabase } from '$lib/supabase';
    import type { Organization, RiotRegion } from '$lib/types';
    import { onMount } from 'svelte';

    export let data;
    let organizations: (Organization & { teams?: any[]; region?: RiotRegion })[] = data.organizations;
    let loading = true;
    let error: string | null = null;

    // New organization form
    let showCreateForm = false;
    let newOrg: Partial<Organization & { region?: RiotRegion }> = {
        name: '',
        description: '',
        region: undefined,
        website: ''
    };

    onMount(async () => {
        const { data: fetchData, error: fetchError } = await supabase
            .from('organizations')
            .select(`
                *,
                teams(*)
            `)
            .order('name');

        if (fetchError) {
            error = fetchError.message;
        } else {
            organizations = fetchData;
        }
        loading = false;
    });

    async function handleCreateOrg() {
        const { data, error: createError } = await supabase
            .from('organizations')
            .insert(newOrg)
            .select()
            .single();

        if (createError) {
            error = createError.message;
        } else {
            organizations = [...organizations, data];
            showCreateForm = false;
            newOrg = {
                name: '',
                description: '',
                region: undefined,
                website: ''
            };
        }
    }
</script>

<div class="organizations">
    <header>
        <h1>Organizations</h1>
        <RoleGuard roles={['owner', 'platform_admin']}>
            <button class="create-button" on:click={() => showCreateForm = true}>
                Create Organization
            </button>
        </RoleGuard>
    </header>

    {#if loading}
        <div class="loading">Loading organizations...</div>
    {:else if error}
        <div class="error">{error}</div>
    {:else}
        <div class="org-grid">
            {#each organizations as org}
                <div class="org-card">
                    <h2>{org.name}</h2>
                    <div class="meta">
                        <span class="region">{org.region}</span>
                        {#if org.website}
                            <a href={org.website} target="_blank" rel="noopener noreferrer">Website</a>
                        {/if}
                    </div>
                    <p>{org.description}</p>
                    <div class="stats">
                        <span>Teams: {org.teams?.length || 0}</span>
                    </div>
                    <RoleGuard roles={['owner', 'platform_admin', 'org_manager']} organizationId={org.id}>
                        <div class="actions">
                            <button on:click={() => window.location.href = `/organizations/${org.id}`}>
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
            <h2>Create Organization</h2>
            <form on:submit|preventDefault={handleCreateOrg}>
                <div class="form-group">
                    <label for="name">Organization Name</label>
                    <input
                        type="text"
                        id="name"
                        bind:value={newOrg.name}
                        required
                        minlength="3"
                        maxlength="100"
                    />
                </div>

                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea
                        id="description"
                        bind:value={newOrg.description}
                        required
                        rows="4"
                    ></textarea>
                </div>

                <div class="form-group">
                    <label for="region">Region</label>
                    <RegionSelect bind:value={newOrg.region} required />
                </div>

                <div class="form-group">
                    <label for="website">Website (optional)</label>
                    <input
                        type="url"
                        id="website"
                        bind:value={newOrg.website}
                        placeholder="https://"
                    />
                </div>

                <div class="form-actions">
                    <button type="button" class="secondary" on:click={() => showCreateForm = false}>
                        Cancel
                    </button>
                    <button type="submit">
                        Create Organization
                    </button>
                </div>
            </form>
        </div>
    </div>
{/if}

<style>
    .organizations {
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

    h1 {
        margin: 0;
        color: var(--color-primary);
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

    .org-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 2rem;
    }

    .org-card {
        background: white;
        padding: 1.5rem;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    .org-card h2 {
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

    .stats {
        margin-top: 1rem;
        padding-top: 1rem;
        border-top: 1px solid var(--color-border);
        color: var(--color-text-secondary);
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

    input, textarea {
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
