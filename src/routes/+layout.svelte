<script>
	import Header from './Header.svelte';
	import '../app.css';
	import { supabase } from '../supabase.js';
	import { user } from '$lib/stores/session';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	/** @type {{children: import('svelte').Snippet}} */
	let { children } = $props();

	onMount(() => {
		// Set up auth state listener
		const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
			if (session) {
				user.set(session.user);
			} else {
				user.set(null);
			}
		});

		// Check current session on load
		checkSession();

		// Cleanup subscription on unmount
		return () => {
			subscription.unsubscribe();
		};
	});

	async function checkSession() {
		const { data: { session } } = await supabase.auth.getSession();
		if (session) {
			user.set(session.user);
		}
	}
</script>

<div class="app">
	<Header />

	<main>
		{@render children()}
	</main>

	<footer>
		<p>
			Ranking of Legends Event Management Platform
		</p>
	</footer>
</div>

<style>
	.app {
		display: flex;
		flex-direction: column;
		min-height: 100vh;
	}

	main {
		flex: 1;
		display: flex;
		flex-direction: column;
		padding: 1rem;
		width: 100%;
		max-width: 64rem;
		margin: 0 auto;
		box-sizing: border-box;
	}

	footer {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		padding: 12px;
	}

	footer a {
		font-weight: bold;
	}

	@media (min-width: 480px) {
		footer {
			padding: 12px 0;
		}
	}
</style>
