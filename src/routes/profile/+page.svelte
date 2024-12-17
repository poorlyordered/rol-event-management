<script lang="ts">
    import { user } from '$lib/stores/session';
    import { supabase } from '../../supabase.js';

    let loading = false;
    let message = '';

    $: userEmail = $user?.email;
    $: userId = $user?.id;
</script>

<div class="profile-container">
    <h1>Profile</h1>
    
    <div class="profile-info">
        <h2>User Information</h2>
        <p><strong>Email:</strong> {userEmail}</p>
        <p><strong>User ID:</strong> {userId}</p>
    </div>

    {#if message}
        <div class="message" role="alert">
            {message}
        </div>
    {/if}
</div>

<style>
    .profile-container {
        max-width: 800px;
        margin: 2rem auto;
        padding: 2rem;
        background-color: var(--primary-bg);
        border-radius: 8px;
        color: var(--primary-text);
    }

    .profile-info {
        margin-top: 2rem;
        padding: 1rem;
        background-color: rgba(255, 255, 255, 0.05);
        border-radius: 4px;
    }

    h1 {
        color: var(--accent-primary);
        margin-bottom: 1rem;
    }

    h2 {
        color: var(--accent-secondary);
        font-size: 1.2rem;
        margin-bottom: 1rem;
    }

    .message {
        margin-top: 1rem;
        padding: 1rem;
        border-radius: 4px;
        background-color: rgba(255, 255, 255, 0.1);
    }

    p {
        margin: 0.5rem 0;
    }

    strong {
        color: var(--accent-primary);
    }
</style>
