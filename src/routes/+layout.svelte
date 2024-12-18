<script>
	import Header from './Header.svelte';
	import '../app.css';
	import { supabase } from '$lib/supabase/client';
	import { user } from '$lib/stores/session';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { invalidate } from '$app/navigation';

	/** @type {{children: import('svelte').Snippet}} */
	let { children } = $props();

	onMount(() => {
		const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
			if (session) {
				user.set(session.user);
				invalidate('supabase:auth');
			} else {
				user.set(null);
				goto('/auth/login');
			}
		});

		return () => {
			subscription.unsubscribe();
		};
	});
</script>

<div class="app">
	<Header />
	<main>
		{@render children()}
	</main>
	<footer id="footer" class="footer">
		<div class="container footer-top">
			<div class="row gy-4">
				<div class="col-lg-5 col-md-12 footer-about">
					<a href="/" class="logo d-flex align-items-center">
						<span>ROL Events</span>
					</a>
					<p>Your premier platform for organizing and managing eSports events. Join us in creating unforgettable gaming experiences.</p>
					<div class="social-links d-flex mt-4">
						<a href="#"><i class="fa-brands fa-twitter"></i></a>
						<a href="#"><i class="fa-brands fa-facebook"></i></a>
						<a href="#"><i class="fa-brands fa-discord"></i></a>
						<a href="#"><i class="fa-brands fa-twitch"></i></a>
					</div>
				</div>

				<div class="col-lg-2 col-6 footer-links">
					<h4>Useful Links</h4>
					<ul>
						<li><a href="/">Home</a></li>
						<li><a href="/about">About</a></li>
						<li><a href="/events">Events</a></li>
						<li><a href="/teams">Teams</a></li>
						<li><a href="/contact">Contact</a></li>
					</ul>
				</div>

				<div class="col-lg-2 col-6 footer-links">
					<h4>Our Services</h4>
					<ul>
						<li><a href="/tournaments">Tournament Management</a></li>
						<li><a href="/teams">Team Management</a></li>
						<li><a href="/brackets">Bracket Generation</a></li>
						<li><a href="/stats">Statistics</a></li>
					</ul>
				</div>

				<div class="col-lg-3 col-md-12 footer-contact text-center text-md-start">
					<h4>Contact Us</h4>
					<p>Email: support@rolevents.com</p>
					<p>Discord: ROL Events#1234</p>
				</div>
			</div>
		</div>

		<div class="container copyright text-center mt-4">
			<p>&copy; {new Date().getFullYear()} <span>ROL Events</span>. All Rights Reserved</p>
		</div>
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
		max-width: 1024px;
		margin: 0 auto;
		box-sizing: border-box;
	}

	.footer {
		background-color: var(--color-text-primary);
		color: #fff;
		padding: var(--spacing-xl) 0;
		margin-top: auto;
	}

	.footer-top {
		padding-bottom: var(--spacing-xl);
	}

	.footer a {
		color: #fff;
		text-decoration: none;
		transition: var(--transition-speed);
	}

	.footer a:hover {
		color: var(--color-primary);
		text-decoration: none;
	}

	.footer-about .logo {
		font-size: 30px;
		margin-bottom: var(--spacing-md);
		font-weight: bold;
	}

	.footer-about p {
		font-size: 14px;
		margin-bottom: var(--spacing-md);
	}

	.social-links {
		gap: var(--spacing-md);
	}

	.social-links a {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 40px;
		height: 40px;
		border-radius: 50%;
		border: 1px solid rgba(255, 255, 255, 0.2);
		font-size: 16px;
		transition: var(--transition-speed);
	}

	.social-links a:hover {
		border-color: var(--color-primary);
		background-color: var(--color-primary);
		color: #fff;
	}

	.footer-links h4 {
		font-size: 16px;
		font-weight: bold;
		margin-bottom: var(--spacing-lg);
	}

	.footer-links ul {
		list-style: none;
		padding: 0;
		margin: 0;
	}

	.footer-links li {
		margin-bottom: var(--spacing-sm);
	}

	.footer-contact h4 {
		font-size: 16px;
		font-weight: bold;
		margin-bottom: var(--spacing-lg);
	}

	.copyright {
		padding-top: var(--spacing-lg);
		border-top: 1px solid rgba(255, 255, 255, 0.1);
	}

	.row {
		display: flex;
		flex-wrap: wrap;
		margin-right: -15px;
		margin-left: -15px;
	}

	.col-lg-5 { width: 41.66667%; }
	.col-lg-3 { width: 25%; }
	.col-lg-2 { width: 16.66667%; }
	.col-6 { width: 50%; }

	@media (max-width: 992px) {
		.col-lg-5, .col-lg-3, .col-lg-2 {
			width: 100%;
			margin-bottom: var(--spacing-xl);
		}
	}

	.gy-4 > * {
		padding-top: 1.5rem;
		padding-bottom: 1.5rem;
	}

	.mt-4 {
		margin-top: 1.5rem;
	}

	.text-center {
		text-align: center;
	}

	@media (min-width: 768px) {
		.text-md-start {
			text-align: left;
		}
	}
</style>
