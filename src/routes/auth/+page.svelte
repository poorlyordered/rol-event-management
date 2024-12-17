<script lang="ts">
  import { supabase } from '../../supabase.js';
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  
  let email = '';
  let password = '';
  let loading = false;
  let error: string | null = null;
  let isRegister = false;

  onMount(() => {
    // Check URL parameter for register mode
    const searchParams = new URLSearchParams(window.location.search);
    isRegister = searchParams.get('mode') === 'register';
  });

  async function handleAuth() {
    loading = true;
    error = null;

    try {
      if (isRegister) {
        const { data, error: signUpError } = await supabase.auth.signUp({
          email,
          password,
        });

        if (signUpError) throw signUpError;
        
        // Show success message or redirect
        alert('Please check your email for verification link');
      } else {
        const { data, error: signInError } = await supabase.auth.signInWithPassword({
          email,
          password,
        });

        if (signInError) throw signInError;
        
        // Redirect to home page for now
        goto('/');
      }
    } catch (e: any) {
      error = e.message || 'An error occurred';
      console.error('Auth error:', e);
    } finally {
      loading = false;
    }
  }

  async function handleGoogleAuth() {
    try {
      const { data, error: googleError } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: `${window.location.origin}/`
        }
      });

      if (googleError) throw googleError;
    } catch (e: any) {
      error = e.message || 'An error occurred with Google sign in';
      console.error('Google auth error:', e);
    }
  }

  function toggleMode() {
    isRegister = !isRegister;
    error = null; // Clear any previous errors
  }
</script>

<div class="auth-container">
  <h1>{isRegister ? 'Create Account' : 'Sign In'}</h1>
  
  {#if error}
    <div class="error-message" role="alert">
      {error}
    </div>
  {/if}

  <form on:submit|preventDefault={handleAuth}>
    <div class="form-group">
      <label for="email">Email</label>
      <input
        type="email"
        id="email"
        bind:value={email}
        required
        disabled={loading}
      />
    </div>

    <div class="form-group">
      <label for="password">Password</label>
      <input
        type="password"
        id="password"
        bind:value={password}
        required
        disabled={loading}
      />
    </div>

    <button type="submit" class="auth-button" disabled={loading}>
      {#if loading}
        Loading...
      {:else}
        {isRegister ? 'Register' : 'Sign In'}
      {/if}
    </button>
  </form>

  <button class="google-button" on:click={handleGoogleAuth} disabled={loading}>
    Sign in with Google
  </button>

  <button class="toggle-button" on:click={toggleMode}>
    {isRegister ? 'Already have an account? Sign In' : 'Need an account? Register'}
  </button>
</div>

<style>
  .auth-container {
    max-width: 400px;
    margin: 2rem auto;
    padding: 2rem;
    border-radius: 8px;
    background-color: var(--primary-bg);
    color: var(--primary-text);
  }

  .form-group {
    margin-bottom: 1rem;
  }

  .form-group label {
    display: block;
    margin-bottom: 0.5rem;
  }

  .form-group input {
    width: 100%;
    padding: 0.5rem;
    border: 1px solid var(--accent-primary);
    border-radius: 4px;
    background-color: var(--primary-bg);
    color: var(--primary-text);
  }

  .auth-button,
  .google-button,
  .toggle-button {
    width: 100%;
    padding: 0.75rem;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    margin-bottom: 1rem;
    font-size: 1rem;
  }

  .auth-button {
    background-color: var(--accent-secondary);
    color: var(--primary-bg);
  }

  .google-button {
    background-color: var(--accent-primary);
    color: var(--primary-bg);
  }

  .toggle-button {
    background: none;
    color: var(--accent-primary);
    text-decoration: underline;
  }

  .error-message {
    background-color: rgba(255, 0, 0, 0.1);
    color: #ff4444;
    padding: 0.5rem;
    margin-bottom: 1rem;
    border-radius: 4px;
  }

  button:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }
</style>
