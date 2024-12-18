<script lang="ts">
    import RoleGuard from '$lib/components/RoleGuard.svelte';
    import { page } from '$app/stores';
    import { supabase } from '$lib/supabase';
    import type { Organization, Profile, StaffMember } from '$lib/types';
    import { onMount } from 'svelte';

    let staffMembers: (StaffMember & { user: Profile; organization?: Organization })[] = [];
    let organizations: Organization[] = [];
    let searchTimeout: ReturnType<typeof setTimeout> | null = null;
    let searchResults: Profile[] = [];
    let selectedUser: Profile | null = null;
    let loading = true;
    let error: string | null = null;

    // New staff member form
    let showCreateForm = false;
    let newStaff = {
        user_id: '',
        role: '',
        organization_id: '',
        notes: ''
    };

    // User search
    let userSearch = '';
    let searching = false;

    onMount(async () => {
        await Promise.all([
            fetchStaffMembers(),
            fetchOrganizations()
        ]);
        loading = false;
    });

    async function fetchStaffMembers() {
        const { data, error: fetchError } = await supabase
            .from('staff_members')
            .select(`
                *,
                user:profiles(*),
                organization:organizations(*)
            `)
            .order('created_at', { ascending: false });

        if (fetchError) {
            error = fetchError.message;
        } else {
            staffMembers = data;
        }
    }

    async function fetchOrganizations() {
        const { data, error: fetchError } = await supabase
            .from('organizations')
            .select('id, name, created_at, updated_at');
        
        if (fetchError) {
            error = fetchError.message;
        } else {
            organizations = data || [];
        }
    }

    async function searchUsers() {
        if (userSearch.length < 3) return;
        
        searching = true;
        const { data, error: searchError } = await supabase
            .from('profiles')
            .select('*')
            .ilike('username', `%${userSearch}%`)
            .limit(5);

        if (searchError) {
            error = searchError.message;
        } else {
            searchResults = data;
        }
        searching = false;
    }

    async function handleCreateStaff() {
        const { data, error: createError } = await supabase
            .from('staff_members')
            .insert(newStaff)
            .select()
            .single();

        if (createError) {
            error = createError.message;
        } else {
            await fetchStaffMembers();
            showCreateForm = false;
            newStaff = {
                user_id: '',
                role: '',
                organization_id: '',
                notes: ''
            };
        }
    }

    async function handleRemoveStaff(staffId: string) {
        if (!confirm('Are you sure you want to remove this staff member?')) return;

        const { error: deleteError } = await supabase
            .from('staff_members')
            .delete()
            .eq('id', staffId);

        if (deleteError) {
            error = deleteError.message;
        } else {
            await fetchStaffMembers();
        }
    }

    function debounceSearch() {
        if (searchTimeout) clearTimeout(searchTimeout);
        searchTimeout = setTimeout(searchUsers, 300);
    }

    $: if (userSearch) {
        debounceSearch();
    }
</script>

<RoleGuard roles={['owner', 'platform_admin']}>
    <div class="staff-management">
        <header>
            <h1>Staff Management</h1>
            <button class="create-button" on:click={() => showCreateForm = true}>
                Add Staff Member
            </button>
        </header>

        {#if loading}
            <div class="loading">Loading staff members...</div>
        {:else if error}
            <div class="error">{error}</div>
        {:else}
            <div class="staff-grid">
                {#each staffMembers as staff}
                    <div class="staff-card">
                        <div class="staff-info">
                            <h3>{staff.user.username}</h3>
                            <div class="meta">
                                <span class="role">{staff.role}</span>
                                {#if staff.organization}
                                    <span class="org">{staff.organization.name}</span>
                                {/if}
                            </div>
                            {#if staff.notes}
                                <p class="notes">{staff.notes}</p>
                            {/if}
                        </div>
                        <div class="actions">
                            <button 
                                class="remove-button" 
                                on:click={() => handleRemoveStaff(staff.id)}
                            >
                                Remove
                            </button>
                        </div>
                    </div>
                {/each}
            </div>
        {/if}
    </div>

    {#if showCreateForm}
        <div class="modal">
            <div class="modal-content">
                <h2>Add Staff Member</h2>
                <form on:submit|preventDefault={handleCreateStaff}>
                    <div class="form-group">
                        <label for="user">Search User</label>
                        <input
                            type="text"
                            id="user"
                            bind:value={userSearch}
                            placeholder="Enter username"
                            autocomplete="off"
                        />
                        {#if searching}
                            <div class="search-status">Searching...</div>
                        {:else if searchResults.length > 0}
                            <div class="search-results">
                                {#each searchResults as user}
                                    <button
                                        type="button"
                                        class="user-result"
                                        on:click={() => {
                                            newStaff.user_id = user.id;
                                            userSearch = user.username;
                                            searchResults = [];
                                        }}
                                    >
                                        {user.username}
                                    </button>
                                {/each}
                            </div>
                        {/if}
                    </div>

                    <div class="form-group">
                        <label for="role">Role</label>
                        <select id="role" bind:value={newStaff.role} required>
                            <option value="">Select Role</option>
                            <option value="platform_admin">Platform Admin</option>
                            <option value="customer_service">Customer Service</option>
                            <option value="org_manager">Organization Manager</option>
                            <option value="tournament_director">Tournament Director</option>
                            <option value="league_director">League Director</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="organization">Organization (Optional)</label>
                        <select id="organization" bind:value={newStaff.organization_id}>
                            <option value="">No Organization</option>
                            {#each organizations as org}
                                <option value={org.id}>{org.name}</option>
                            {/each}
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="notes">Notes (Optional)</label>
                        <textarea
                            id="notes"
                            bind:value={newStaff.notes}
                            rows="3"
                            placeholder="Add any relevant notes..."
                        ></textarea>
                    </div>

                    <div class="form-actions">
                        <button type="button" class="secondary" on:click={() => showCreateForm = false}>
                            Cancel
                        </button>
                        <button type="submit">
                            Add Staff Member
                        </button>
                    </div>
                </form>
            </div>
        </div>
    {/if}
</RoleGuard>

<style>
    .staff-management {
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

    .staff-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 2rem;
    }

    .staff-card {
        background: white;
        padding: 1.5rem;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        display: flex;
        justify-content: space-between;
    }

    .staff-info h3 {
        margin: 0 0 0.5rem;
        color: var(--color-primary);
    }

    .meta {
        display: flex;
        align-items: center;
        gap: 1rem;
        margin-bottom: 0.5rem;
    }

    .role {
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

    .notes {
        color: var(--color-text-secondary);
        font-size: 0.875rem;
        margin: 0.5rem 0 0;
    }

    .remove-button {
        padding: 0.5rem 1rem;
        background-color: var(--color-error);
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        transition: background-color 0.2s;
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
        position: relative;
    }

    .search-results {
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        background: white;
        border: 1px solid var(--color-border);
        border-radius: 4px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        z-index: 1;
    }

    .user-result {
        width: 100%;
        padding: 0.5rem;
        border: none;
        background: none;
        text-align: left;
        cursor: pointer;
    }

    .user-result:hover {
        background-color: var(--color-background);
    }

    .search-status {
        color: var(--color-text-secondary);
        font-size: 0.875rem;
        margin-top: 0.5rem;
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
