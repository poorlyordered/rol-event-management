<script lang="ts">
    import { page } from '$app/stores';
    import RegionSelect from '$lib/components/RegionSelect.svelte';
    import RoleGuard from '$lib/components/RoleGuard.svelte';
    import { enhance } from '$app/forms';
    import { supabase } from '$lib/supabase';
    import type { Tournament, RiotRegion } from '$lib/types';
    import { invalidateAll } from '$app/navigation';
    import { goto } from '$app/navigation';

    let loading = false;
    let error: string | null = null;

    let tournament: Partial<Tournament> = {
        name: '',
        description: '',
        start_date: '',
        end_date: '',
        max_teams: 8,
        current_teams: 0,
        organizer_id: '',
        region: undefined,
        status: 'draft'
    };

    async function handleSubmit(event: SubmitEvent) {
        loading = true;
        error = null;

        try {
            const { data, error: submitError } = await supabase
                .from('tournaments')
                .insert([tournament])
                .select()
                .single();

            if (submitError) throw submitError;
            if (data) {
                goto(`/events/${data.id}`);
            }
        } catch (e: any) {
            error = e?.message || 'An error occurred while creating the tournament';
        } finally {
            loading = false;
        }
    }
</script>

<RoleGuard roles={['owner', 'platform_admin', 'tournament_director']}>
    <div class="create-event">
        <h1>Create Tournament</h1>

        <form on:submit|preventDefault={handleSubmit}>
            <div class="form-group">
                <label for="name">Tournament Name</label>
                <input
                    type="text"
                    id="name"
                    bind:value={tournament.name}
                    required
                    minlength="3"
                    maxlength="100"
                    placeholder="Enter tournament name"
                />
            </div>

            <div class="form-group">
                <label for="description">Description</label>
                <textarea
                    id="description"
                    bind:value={tournament.description}
                    rows="4"
                    required
                    placeholder="Enter tournament description"
                ></textarea>
            </div>

            <div class="form-group">
                <label for="region">Region</label>
                <RegionSelect bind:value={tournament.region} required />
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="start_date">Start Date</label>
                    <input type="date" id="start_date" bind:value={tournament.start_date} required />
                </div>

                <div class="form-group">
                    <label for="end_date">End Date</label>
                    <input type="date" id="end_date" bind:value={tournament.end_date} required />
                </div>
            </div>

            <div class="form-group">
                <label for="max_teams">Maximum Teams</label>
                <input
                    type="number"
                    id="max_teams"
                    bind:value={tournament.max_teams}
                    required
                    min="2"
                    max="128"
                />
            </div>

            {#if error}
                <div class="error">{error}</div>
            {/if}

            <button type="submit" disabled={loading}>
                {loading ? 'Creating...' : 'Create Tournament'}
            </button>
        </form>
    </div>
</RoleGuard>

<style>
    .create-event {
        max-width: 800px;
        margin: 2rem auto;
        padding: 2rem;
        background: white;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    h1 {
        margin-bottom: 2rem;
        color: var(--color-primary);
    }

    .form-group {
        margin-bottom: 1.5rem;
    }

    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 1rem;
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

    input:focus, textarea:focus {
        outline: none;
        border-color: var(--color-primary);
        box-shadow: 0 0 0 2px rgba(var(--color-primary-rgb), 0.1);
    }

    .error {
        color: var(--color-error);
        margin-bottom: 1rem;
        padding: 0.5rem;
        background-color: rgba(var(--color-error-rgb), 0.1);
        border-radius: 4px;
    }

    button {
        width: 100%;
        padding: 0.75rem;
        background-color: var(--color-primary);
        color: white;
        border: none;
        border-radius: 4px;
        font-size: 1rem;
        font-weight: 500;
        cursor: pointer;
        transition: background-color 0.2s;
    }

    button:hover {
        background-color: var(--color-primary-dark);
    }

    button:disabled {
        background-color: var(--color-disabled);
        cursor: not-allowed;
    }
</style>
