<script>
	import { page } from '$app/stores';
	import { user } from '$lib/stores/session';
	import { onMount } from 'svelte';

	// Placeholder event data - would come from Supabase
	let event = {
		id: $page.params.id,
		title: 'League of Legends Championship',
		date: '2024-01-15',
		time: '18:00',
		game: 'League of Legends',
		type: 'Tournament',
		format: 'Single Elimination',
		participants: {
			current: 64,
			max: 128
		},
		prizePool: {
			total: '$5,000',
			breakdown: [
				{ place: '1st', amount: '$2,500' },
				{ place: '2nd', amount: '$1,500' },
				{ place: '3rd', amount: '$1,000' }
			]
		},
		status: 'registration',
		description: `Join us for the biggest League of Legends tournament of the year! This event features:
		- Professional tournament organization
		- Live streaming of all matches
		- Professional casting
		- Anti-cheat measures
		- Discord community for participants`,
		rules: `1. All participants must be at least 16 years old
		2. Teams must have 5 primary players and up to 2 substitutes
		3. All matches will be played on the latest tournament patch
		4. Check-in required 30 minutes before scheduled match time
		5. Default game settings will be used for all matches`,
		schedule: [
			{ phase: 'Registration Deadline', date: '2024-01-14', time: '23:59' },
			{ phase: 'Group Stage', date: '2024-01-15-17', time: '18:00-22:00' },
			{ phase: 'Quarter Finals', date: '2024-01-18', time: '18:00-22:00' },
			{ phase: 'Semi Finals', date: '2024-01-19', time: '18:00-22:00' },
			{ phase: 'Finals', date: '2024-01-20', time: '19:00-23:00' }
		],
		image: '/images/eventmanagement.jpg'
	};

	let activeTab = 'overview';
</script>

<svelte:head>
	<title>{event.title} - ROL Events</title>
</svelte:head>

<section class="event-details">
	<div class="event-header" style="background-image: url('{event.image}')">
		<div class="overlay">
			<div class="container">
				<div class="header-content" data-aos="fade-up">
					<h1>{event.title}</h1>
					<div class="event-meta">
						<span><i class="fas fa-gamepad"></i> {event.game}</span>
						<span><i class="fas fa-trophy"></i> {event.type}</span>
						<span><i class="fas fa-users"></i> {event.participants.current}/{event.participants.max} Teams</span>
						<span><i class="fas fa-money-bill-wave"></i> {event.prizePool.total} Prize Pool</span>
					</div>
					{#if $user}
						<button class="btn-register">Register Now</button>
					{:else}
						<a href="/auth" class="btn-register">Login to Register</a>
					{/if}
				</div>
			</div>
		</div>
	</div>

	<div class="container">
		<div class="event-nav" data-aos="fade-up">
			<button 
				class:active={activeTab === 'overview'} 
				on:click={() => activeTab = 'overview'}
			>
				Overview
			</button>
			<button 
				class:active={activeTab === 'rules'} 
				on:click={() => activeTab = 'rules'}
			>
				Rules
			</button>
			<button 
				class:active={activeTab === 'schedule'} 
				on:click={() => activeTab = 'schedule'}
			>
				Schedule
			</button>
			<button 
				class:active={activeTab === 'prizes'} 
				on:click={() => activeTab = 'prizes'}
			>
				Prizes
			</button>
		</div>

		<div class="event-content" data-aos="fade-up">
			{#if activeTab === 'overview'}
				<div class="tab-content">
					<h2>Event Overview</h2>
					<p>{event.description}</p>
					
					<div class="key-info">
						<div class="info-item">
							<i class="fas fa-calendar"></i>
							<div>
								<h3>Date & Time</h3>
								<p>{event.date} at {event.time}</p>
							</div>
						</div>
						<div class="info-item">
							<i class="fas fa-brackets"></i>
							<div>
								<h3>Tournament Format</h3>
								<p>{event.format}</p>
							</div>
						</div>
						<div class="info-item">
							<i class="fas fa-users"></i>
							<div>
								<h3>Team Size</h3>
								<p>5 Players + 2 Substitutes</p>
							</div>
						</div>
					</div>
				</div>
			{:else if activeTab === 'rules'}
				<div class="tab-content">
					<h2>Tournament Rules</h2>
					<div class="rules-content">
						{#each event.rules.split('\n') as rule}
							<p>{rule}</p>
						{/each}
					</div>
				</div>
			{:else if activeTab === 'schedule'}
				<div class="tab-content">
					<h2>Event Schedule</h2>
					<div class="schedule-timeline">
						{#each event.schedule as phase}
							<div class="timeline-item">
								<div class="timeline-marker"></div>
								<div class="timeline-content">
									<h3>{phase.phase}</h3>
									<p>{phase.date}</p>
									<p>{phase.time}</p>
								</div>
							</div>
						{/each}
					</div>
				</div>
			{:else if activeTab === 'prizes'}
				<div class="tab-content">
					<h2>Prize Pool</h2>
					<div class="prize-pool">
						<div class="total-prize">
							<h3>Total Prize Pool</h3>
							<span class="prize-amount">{event.prizePool.total}</span>
						</div>
						<div class="prize-breakdown">
							{#each event.prizePool.breakdown as prize}
								<div class="prize-item">
									<span class="place">{prize.place}</span>
									<span class="amount">{prize.amount}</span>
								</div>
							{/each}
						</div>
					</div>
				</div>
			{/if}
		</div>
	</div>
</section>

<style>
	.event-details {
		padding-top: 90px;
	}

	.event-header {
		height: 400px;
		background-size: cover;
		background-position: center;
		position: relative;
		color: white;
	}

	.overlay {
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background: linear-gradient(to bottom, rgba(0,0,0,0.7), rgba(0,0,0,0.9));
		display: flex;
		align-items: center;
	}

	.header-content {
		text-align: center;
		width: 100%;
	}

	.header-content h1 {
		font-size: 48px;
		margin-bottom: 20px;
	}

	.event-meta {
		display: flex;
		justify-content: center;
		gap: 30px;
		margin-bottom: 30px;
	}

	.event-meta span {
		display: flex;
		align-items: center;
		gap: 8px;
	}

	.btn-register {
		padding: 15px 40px;
		background-color: var(--color-primary);
		color: white;
		border: none;
		border-radius: 50px;
		font-size: 18px;
		cursor: pointer;
		transition: var(--transition-speed);
		text-decoration: none;
		display: inline-block;
	}

	.btn-register:hover {
		background-color: #0834d1;
		transform: translateY(-2px);
	}

	.event-nav {
		display: flex;
		justify-content: center;
		gap: 20px;
		margin: 40px 0;
		border-bottom: 1px solid var(--color-border);
		padding-bottom: 20px;
	}

	.event-nav button {
		background: none;
		border: none;
		padding: 10px 20px;
		font-size: 16px;
		color: var(--color-text-secondary);
		cursor: pointer;
		transition: var(--transition-speed);
		position: relative;
	}

	.event-nav button.active {
		color: var(--color-primary);
	}

	.event-nav button.active::after {
		content: '';
		position: absolute;
		bottom: -21px;
		left: 0;
		right: 0;
		height: 3px;
		background-color: var(--color-primary);
	}

	.tab-content {
		padding: 40px 0;
	}

	.tab-content h2 {
		font-size: 32px;
		margin-bottom: 30px;
		color: var(--color-text-primary);
	}

	.key-info {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: 30px;
		margin-top: 40px;
	}

	.info-item {
		display: flex;
		gap: 15px;
		padding: 20px;
		background-color: #f8f9fa;
		border-radius: 10px;
	}

	.info-item i {
		font-size: 24px;
		color: var(--color-primary);
	}

	.info-item h3 {
		font-size: 18px;
		margin-bottom: 5px;
		color: var(--color-text-primary);
	}

	.info-item p {
		color: var(--color-text-secondary);
	}

	.schedule-timeline {
		position: relative;
		padding-left: 50px;
	}

	.timeline-item {
		position: relative;
		margin-bottom: 40px;
	}

	.timeline-marker {
		position: absolute;
		left: -50px;
		width: 20px;
		height: 20px;
		border-radius: 50%;
		background-color: var(--color-primary);
		border: 4px solid #fff;
		box-shadow: 0 0 0 2px var(--color-primary);
	}

	.timeline-item::before {
		content: '';
		position: absolute;
		left: -41px;
		top: 20px;
		bottom: -40px;
		width: 2px;
		background-color: var(--color-primary);
	}

	.timeline-item:last-child::before {
		display: none;
	}

	.timeline-content h3 {
		font-size: 20px;
		margin-bottom: 5px;
		color: var(--color-text-primary);
	}

	.timeline-content p {
		color: var(--color-text-secondary);
	}

	.prize-pool {
		text-align: center;
	}

	.total-prize {
		margin-bottom: 40px;
	}

	.total-prize h3 {
		font-size: 24px;
		margin-bottom: 10px;
		color: var(--color-text-primary);
	}

	.prize-amount {
		font-size: 48px;
		font-weight: 700;
		color: var(--color-primary);
	}

	.prize-breakdown {
		display: flex;
		flex-direction: column;
		gap: 20px;
		max-width: 400px;
		margin: 0 auto;
	}

	.prize-item {
		display: flex;
		justify-content: space-between;
		padding: 15px 30px;
		background-color: #f8f9fa;
		border-radius: 10px;
		font-size: 18px;
	}

	.prize-item .place {
		font-weight: 600;
		color: var(--color-text-primary);
	}

	.prize-item .amount {
		color: var(--color-primary);
	}

	.rules-content {
		white-space: pre-line;
	}

	@media (max-width: 768px) {
		.event-meta {
			flex-direction: column;
			gap: 15px;
		}

		.event-nav {
			flex-wrap: wrap;
		}

		.header-content h1 {
			font-size: 36px;
		}
	}
</style>
