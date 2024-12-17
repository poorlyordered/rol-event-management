<script>
	import { user } from '$lib/stores/session';
	import { onMount } from 'svelte';

	// Placeholder data - this would come from your Supabase database
	let events = [
		{
			id: 1,
			title: 'League of Legends Championship',
			date: '2024-01-15',
			time: '18:00',
			game: 'League of Legends',
			type: 'Tournament',
			participants: 128,
			prizePool: '$5,000',
			status: 'upcoming',
			image: '/images/eventmanagement.jpg'
		},
		{
			id: 2,
			title: 'Valorant Weekly Cup',
			date: '2024-01-20',
			time: '20:00',
			game: 'Valorant',
			type: 'Cup',
			participants: 64,
			prizePool: '$1,000',
			status: 'registration',
			image: '/images/max-raber-wZZhkTvB9pI-unsplash.jpg'
		},
		{
			id: 3,
			title: 'CS:GO Pro League',
			date: '2024-02-01',
			time: '19:00',
			game: 'CS:GO',
			type: 'League',
			participants: 32,
			prizePool: '$10,000',
			status: 'upcoming',
			image: '/images/sadshah-cR0bLCSpGfw-unsplash.jpg'
		}
	];

	let filterGame = 'all';
	let filterType = 'all';
	let filterStatus = 'all';
	let searchQuery = '';

	$: filteredEvents = events.filter(event => {
		const matchesGame = filterGame === 'all' || event.game === filterGame;
		const matchesType = filterType === 'all' || event.type === filterType;
		const matchesStatus = filterStatus === 'all' || event.status === filterStatus;
		const matchesSearch = event.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
							event.game.toLowerCase().includes(searchQuery.toLowerCase());
		
		return matchesGame && matchesType && matchesStatus && matchesSearch;
	});

	const games = ['League of Legends', 'Valorant', 'CS:GO'];
	const types = ['Tournament', 'Cup', 'League'];
	const statuses = ['upcoming', 'registration', 'in-progress', 'completed'];
</script>

<svelte:head>
	<title>Events - ROL Events</title>
</svelte:head>

<section class="events-section">
	<div class="container">
		<div class="section-header" data-aos="fade-up">
			<h1>Gaming Events</h1>
			<p>Discover and join exciting eSports tournaments and competitions</p>
		</div>

		<!-- Filters and Search -->
		<div class="filters-container" data-aos="fade-up">
			<div class="search-box">
				<i class="fas fa-search"></i>
				<input 
					type="text" 
					bind:value={searchQuery} 
					placeholder="Search events..."
				>
			</div>

			<div class="filters">
				<select bind:value={filterGame}>
					<option value="all">All Games</option>
					{#each games as game}
						<option value={game}>{game}</option>
					{/each}
				</select>

				<select bind:value={filterType}>
					<option value="all">All Types</option>
					{#each types as type}
						<option value={type}>{type}</option>
					{/each}
				</select>

				<select bind:value={filterStatus}>
					<option value="all">All Statuses</option>
					{#each statuses as status}
						<option value={status}>{status.charAt(0).toUpperCase() + status.slice(1)}</option>
					{/each}
				</select>
			</div>

			{#if $user}
				<a href="/events/create" class="btn-create">
					<i class="fas fa-plus"></i> Create Event
				</a>
			{/if}
		</div>

		<!-- Events Grid -->
		<div class="events-grid" data-aos="fade-up">
			{#each filteredEvents as event (event.id)}
				<div class="event-card" data-aos="fade-up">
					<div class="event-image" style="background-image: url('{event.image}')">
						<div class="event-overlay">
							<span class="event-type">{event.type}</span>
							<span class="event-status {event.status}">{event.status}</span>
						</div>
					</div>
					<div class="event-content">
						<h3>{event.title}</h3>
						<div class="event-details">
							<div class="detail">
								<i class="fas fa-gamepad"></i>
								<span>{event.game}</span>
							</div>
							<div class="detail">
								<i class="fas fa-calendar"></i>
								<span>{event.date}</span>
							</div>
							<div class="detail">
								<i class="fas fa-clock"></i>
								<span>{event.time}</span>
							</div>
							<div class="detail">
								<i class="fas fa-users"></i>
								<span>{event.participants} Players</span>
							</div>
							<div class="detail">
								<i class="fas fa-trophy"></i>
								<span>{event.prizePool}</span>
							</div>
						</div>
						<div class="event-actions">
							<a href="/events/{event.id}" class="btn-details">View Details</a>
							{#if $user}
								<button class="btn-register">Register Now</button>
							{/if}
						</div>
					</div>
				</div>
			{/each}
		</div>

		{#if filteredEvents.length === 0}
			<div class="no-events" data-aos="fade-up">
				<i class="fas fa-search"></i>
				<h3>No events found</h3>
				<p>Try adjusting your filters or search criteria</p>
			</div>
		{/if}
	</div>
</section>

<style>
	.events-section {
		padding: 120px 0 60px;
		background-color: #f8f9fa;
	}

	.section-header {
		text-align: center;
		margin-bottom: 40px;
	}

	.section-header h1 {
		font-size: 36px;
		color: var(--color-text-primary);
		margin-bottom: 10px;
	}

	.section-header p {
		color: var(--color-text-secondary);
		font-size: 18px;
	}

	.filters-container {
		display: flex;
		flex-wrap: wrap;
		gap: 20px;
		margin-bottom: 40px;
		align-items: center;
	}

	.search-box {
		flex: 1;
		position: relative;
		min-width: 200px;
	}

	.search-box i {
		position: absolute;
		left: 15px;
		top: 50%;
		transform: translateY(-50%);
		color: var(--color-text-secondary);
	}

	.search-box input {
		width: 100%;
		padding: 12px 20px 12px 45px;
		border: 1px solid var(--color-border);
		border-radius: 50px;
		font-size: 16px;
		transition: var(--transition-speed);
	}

	.search-box input:focus {
		outline: none;
		border-color: var(--color-primary);
		box-shadow: 0 0 0 2px rgba(13, 66, 255, 0.1);
	}

	.filters {
		display: flex;
		gap: 15px;
	}

	.filters select {
		padding: 12px 20px;
		border: 1px solid var(--color-border);
		border-radius: 50px;
		font-size: 16px;
		background-color: white;
		cursor: pointer;
		transition: var(--transition-speed);
	}

	.filters select:focus {
		outline: none;
		border-color: var(--color-primary);
	}

	.btn-create {
		padding: 12px 25px;
		background-color: var(--color-primary);
		color: white;
		border: none;
		border-radius: 50px;
		font-size: 16px;
		cursor: pointer;
		text-decoration: none;
		transition: var(--transition-speed);
		display: flex;
		align-items: center;
		gap: 8px;
	}

	.btn-create:hover {
		background-color: #0834d1;
		transform: translateY(-2px);
	}

	.events-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
		gap: 30px;
		margin-top: 30px;
	}

	.event-card {
		background: white;
		border-radius: 15px;
		overflow: hidden;
		box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
		transition: var(--transition-speed);
	}

	.event-card:hover {
		transform: translateY(-10px);
		box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
	}

	.event-image {
		height: 200px;
		background-size: cover;
		background-position: center;
		position: relative;
	}

	.event-overlay {
		position: absolute;
		top: 15px;
		left: 15px;
		right: 15px;
		display: flex;
		justify-content: space-between;
	}

	.event-type,
	.event-status {
		padding: 5px 15px;
		border-radius: 20px;
		font-size: 14px;
		font-weight: 500;
	}

	.event-type {
		background-color: var(--color-primary);
		color: white;
	}

	.event-status {
		background-color: rgba(255, 255, 255, 0.9);
	}

	.event-status.upcoming { color: #2ecc71; }
	.event-status.registration { color: #3498db; }
	.event-status.in-progress { color: #f1c40f; }
	.event-status.completed { color: #95a5a6; }

	.event-content {
		padding: 25px;
	}

	.event-content h3 {
		font-size: 20px;
		margin-bottom: 15px;
		color: var(--color-text-primary);
	}

	.event-details {
		display: grid;
		grid-template-columns: repeat(2, 1fr);
		gap: 15px;
		margin-bottom: 20px;
	}

	.detail {
		display: flex;
		align-items: center;
		gap: 8px;
		color: var(--color-text-secondary);
		font-size: 14px;
	}

	.detail i {
		color: var(--color-primary);
	}

	.event-actions {
		display: flex;
		gap: 15px;
	}

	.btn-details,
	.btn-register {
		flex: 1;
		padding: 10px 20px;
		border-radius: 25px;
		font-size: 16px;
		text-align: center;
		text-decoration: none;
		transition: var(--transition-speed);
		cursor: pointer;
	}

	.btn-details {
		background-color: transparent;
		border: 2px solid var(--color-primary);
		color: var(--color-primary);
	}

	.btn-register {
		background-color: var(--color-primary);
		border: none;
		color: white;
	}

	.btn-details:hover,
	.btn-register:hover {
		transform: translateY(-2px);
	}

	.btn-register:hover {
		background-color: #0834d1;
	}

	.no-events {
		text-align: center;
		padding: 60px 0;
		color: var(--color-text-secondary);
	}

	.no-events i {
		font-size: 48px;
		margin-bottom: 20px;
		color: var(--color-text-secondary);
	}

	.no-events h3 {
		font-size: 24px;
		margin-bottom: 10px;
		color: var(--color-text-primary);
	}

	@media (max-width: 768px) {
		.filters-container {
			flex-direction: column;
			align-items: stretch;
		}

		.filters {
			flex-direction: column;
		}

		.events-grid {
			grid-template-columns: 1fr;
		}

		.event-details {
			grid-template-columns: 1fr;
		}
	}
</style>
