<script>
  import { goto } from '$app/navigation';
  import { user } from '$lib/stores/session';

  // Example of a function to handle login and registration
  function handleLogin() {
    goto('/auth');
  }

  function handleRegister() {
    goto('/auth?mode=register');
  }
</script>

<svelte:head>
	<title>ROL Events - eSports Event Management Platform</title>
</svelte:head>

<!-- Hero Section -->
<section id="hero" class="hero">
	<div class="hero-bg"></div>
	
	<div class="container">
		<div class="row hero-content">
			<div class="col-lg-6 hero-text">
				<h1 data-aos="fade-up">Your Premier eSports Event Platform</h1>
				<p data-aos="fade-up" data-aos-delay="100">
					Create, manage, and participate in competitive gaming events with ease. From small tournaments to large-scale championships, 
					we provide the tools you need to make your eSports event a success.
				</p>
				<div class="cta-buttons" data-aos="fade-up" data-aos-delay="200">
					{#if $user}
						<a href="/events/create" class="btn-primary">Create Event</a>
						<a href="/events" class="btn-secondary">Browse Events</a>
					{:else}
						<a href="/auth" class="btn-primary">Get Started</a>
						<a href="/about" class="btn-secondary">Learn More</a>
					{/if}
				</div>
			</div>
			
			<div class="col-lg-6 hero-stats" data-aos="fade-up" data-aos-delay="200">
				<div class="stats-grid">
					<div class="stat-card">
						<span class="stat-number">500+</span>
						<span class="stat-label">Events Hosted</span>
					</div>
					<div class="stat-card">
						<span class="stat-number">10K+</span>
						<span class="stat-label">Active Players</span>
					</div>
					<div class="stat-card">
						<span class="stat-number">50+</span>
						<span class="stat-label">Game Titles</span>
					</div>
					<div class="stat-card">
						<span class="stat-number">24/7</span>
						<span class="stat-label">Support</span>
					</div>
				</div>
			</div>
		</div>
	</div>
</section>

<!-- Features Section -->
<section id="features" class="features section">
	<div class="container">
		<div class="section-header" data-aos="fade-up">
			<h2>Why Choose ROL Events?</h2>
			<p>Comprehensive tools and features designed for the eSports community</p>
		</div>

		<div class="row feature-cards">
			<div class="col-lg-4" data-aos="fade-up" data-aos-delay="100">
				<div class="feature-card">
					<i class="fas fa-trophy"></i>
					<h3>Tournament Management</h3>
					<p>Create and manage tournaments with automated brackets, scheduling, and real-time updates.</p>
				</div>
			</div>

			<div class="col-lg-4" data-aos="fade-up" data-aos-delay="200">
				<div class="feature-card">
					<i class="fas fa-users"></i>
					<h3>Team Organization</h3>
					<p>Form teams, manage rosters, and coordinate with team members all in one place.</p>
				</div>
			</div>

			<div class="col-lg-4" data-aos="fade-up" data-aos-delay="300">
				<div class="feature-card">
					<i class="fas fa-chart-line"></i>
					<h3>Statistics & Analytics</h3>
					<p>Track performance, view match history, and analyze team statistics with detailed insights.</p>
				</div>
			</div>
		</div>
	</div>
</section>

<style>
	:root {
		/* Main colors */
		--primary-bg: var(--night);      /* Dark background */
		--primary-text: var(--nyanza);   /* Light text for readability */
		--accent-primary: var(--keppel); /* Main accent color */
		--accent-secondary: var(--orange-peel); /* Secondary accent */
		--highlight: var(--bright-pink-crayola); /* Call-to-action elements */
	}

	.small-image {
		max-width: 100%; /* Responsive */
		height: auto; /* Maintain aspect ratio */
		width: 300px; /* Set a specific width */
		/* You can adjust the width as needed */
	}

	.landing {
		text-align: center;
		padding: 2rem;
		background-color: var(--primary-bg); /* Use the primary background */
		color: var(--primary-text); /* Use the primary text color */
	}

	.cta-buttons {
		margin-top: 2rem;
	}

	.cta-button {
		margin: 0 1rem;
		padding: 1rem 2rem;
		background-color: var(--accent-secondary); /* Use accent color */
		color: var(--primary-bg);
		border: none;
		border-radius: 5px;
		cursor: pointer;
		font-size: 1rem;
	}

	.cta-button:hover {
		background-color: var(--accent-primary); /* Change to primary accent on hover */
	}

	.hero {
		position: relative;
		min-height: 100vh;
		background-color: var(--color-text-primary);
		color: #fff;
		overflow: hidden;
		padding: 120px 0 60px;
	}

	.hero-bg {
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background: url('/images/stem-list-FqewNnB378s-unsplash.jpg') center/cover;
		opacity: 0.15;
	}

	.hero-content {
		position: relative;
		z-index: 1;
		display: flex;
		align-items: center;
		gap: 2rem;
	}

	.hero-text h1 {
		font-size: 48px;
		font-weight: 700;
		margin-bottom: 20px;
		color: #fff;
	}

	.hero-text p {
		font-size: 18px;
		margin-bottom: 30px;
		color: rgba(255, 255, 255, 0.8);
	}

	.cta-buttons {
		display: flex;
		gap: 20px;
	}

	.btn-primary, .btn-secondary {
		display: inline-block;
		padding: 15px 30px;
		border-radius: 50px;
		font-weight: 500;
		text-decoration: none;
		transition: var(--transition-speed);
	}

	.btn-primary {
		background: var(--color-primary);
		color: #fff;
	}

	.btn-primary:hover {
		background: #0834d1;
		transform: translateY(-2px);
	}

	.btn-secondary {
		background: transparent;
		border: 2px solid #fff;
		color: #fff;
	}

	.btn-secondary:hover {
		background: #fff;
		color: var(--color-text-primary);
		transform: translateY(-2px);
	}

	.hero-stats {
		padding: 20px;
	}

	.stats-grid {
		display: grid;
		grid-template-columns: repeat(2, 1fr);
		gap: 20px;
	}

	.stat-card {
		background: rgba(255, 255, 255, 0.1);
		padding: 30px;
		border-radius: 15px;
		text-align: center;
		transition: var(--transition-speed);
	}

	.stat-card:hover {
		transform: translateY(-5px);
		background: rgba(255, 255, 255, 0.15);
	}

	.stat-number {
		display: block;
		font-size: 36px;
		font-weight: 700;
		color: var(--color-primary);
		margin-bottom: 5px;
	}

	.stat-label {
		font-size: 16px;
		color: rgba(255, 255, 255, 0.8);
	}

	.features {
		padding: 80px 0;
		background-color: #f8f9fa;
	}

	.section-header {
		text-align: center;
		margin-bottom: 60px;
	}

	.section-header h2 {
		font-size: 32px;
		font-weight: 700;
		color: var(--color-text-primary);
		margin-bottom: 20px;
	}

	.section-header p {
		color: var(--color-text-secondary);
	}

	.feature-cards {
		display: flex;
		gap: 30px;
	}

	.feature-card {
		background: #fff;
		padding: 40px 30px;
		border-radius: 15px;
		text-align: center;
		transition: var(--transition-speed);
		box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
	}

	.feature-card:hover {
		transform: translateY(-10px);
	}

	.feature-card i {
		font-size: 40px;
		color: var(--color-primary);
		margin-bottom: 20px;
	}

	.feature-card h3 {
		font-size: 24px;
		margin-bottom: 15px;
		color: var(--color-text-primary);
	}

	.feature-card p {
		color: var(--color-text-secondary);
		line-height: 1.6;
	}

	@media (max-width: 992px) {
		.hero-content {
			flex-direction: column;
			text-align: center;
		}

		.hero-text h1 {
			font-size: 36px;
		}

		.cta-buttons {
			justify-content: center;
		}

		.feature-cards {
			flex-direction: column;
		}

		.col-lg-4 {
			width: 100%;
		}
	}

	@media (max-width: 768px) {
		.stats-grid {
			grid-template-columns: 1fr;
		}
	}
</style>

<main class="landing">
  <h1>Welcome to the Ranking of Legends Event Management Platform</h1>
  <p>Your one-stop solution for organizing and managing eSports teams effortlessly.</p>
  <img class="small-image" src="/images/ROL Profile (1).png" alt="Event Management" />

  <div class="cta-buttons">
    <button class="cta-button" on:click={handleLogin}>Login</button>
    <button class="cta-button" on:click={handleRegister}>Register</button>
  </div>

  <section>
    <h2>Why Choose Us?</h2>
    <ul>
      <li>Easy tournament setup</li>
      <li>Real-time updates and notifications</li>
      <li>Comprehensive player and team management</li>
      <li>Analytics and performance tracking</li>
    </ul>
  </section>
</main>