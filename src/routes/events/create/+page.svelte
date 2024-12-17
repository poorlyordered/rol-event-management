<script>
	import { user } from '$lib/stores/session';
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';

	let formData = {
		title: '',
		game: '',
		type: '',
		format: '',
		date: '',
		time: '',
		maxParticipants: '',
		prizePool: '',
		description: '',
		rules: '',
		image: ''
	};

	let errors = {};
	let isSubmitting = false;

	const gameTypes = ['League of Legends', 'Valorant', 'CS:GO', 'Dota 2', 'Other'];
	const eventTypes = ['Tournament', 'Casual', 'Ranked', 'Championship'];
	const formatTypes = ['Single Elimination', 'Double Elimination', 'Round Robin', 'Swiss'];

	function validateForm() {
		errors = {};
		
		if (!formData.title) errors.title = 'Title is required';
		if (!formData.game) errors.game = 'Game is required';
		if (!formData.type) errors.type = 'Event type is required';
		if (!formData.date) errors.date = 'Date is required';
		if (!formData.time) errors.time = 'Time is required';
		if (!formData.maxParticipants) errors.maxParticipants = 'Maximum participants is required';
		if (!formData.description) errors.description = 'Description is required';
		
		return Object.keys(errors).length === 0;
	}

	async function handleSubmit() {
		if (!validateForm()) return;
		
		isSubmitting = true;
		
		try {
			// TODO: Implement Supabase create event logic here
			// const { data, error } = await supabase
			//   .from('events')
			//   .insert([formData]);
			
			// if (error) throw error;
			
			// Simulate successful creation
			await new Promise(resolve => setTimeout(resolve, 1000));
			goto('/events');
		} catch (error) {
			console.error('Error creating event:', error);
			errors.submit = 'Failed to create event. Please try again.';
		} finally {
			isSubmitting = false;
		}
	}
</script>

<svelte:head>
	<title>Create Event - ROL Events</title>
</svelte:head>

<div class="create-event">
	<div class="container">
		<h1>Create New Event</h1>
		
		<form on:submit|preventDefault={handleSubmit} class="event-form">
			<div class="form-grid">
				<div class="form-group">
					<label for="title">Event Title *</label>
					<input
						type="text"
						id="title"
						bind:value={formData.title}
						class:error={errors.title}
						placeholder="Enter event title"
					/>
					{#if errors.title}
						<span class="error-message">{errors.title}</span>
					{/if}
				</div>

				<div class="form-group">
					<label for="game">Game *</label>
					<select
						id="game"
						bind:value={formData.game}
						class:error={errors.game}
					>
						<option value="">Select a game</option>
						{#each gameTypes as game}
							<option value={game}>{game}</option>
						{/each}
					</select>
					{#if errors.game}
						<span class="error-message">{errors.game}</span>
					{/if}
				</div>

				<div class="form-group">
					<label for="type">Event Type *</label>
					<select
						id="type"
						bind:value={formData.type}
						class:error={errors.type}
					>
						<option value="">Select event type</option>
						{#each eventTypes as type}
							<option value={type}>{type}</option>
						{/each}
					</select>
					{#if errors.type}
						<span class="error-message">{errors.type}</span>
					{/if}
				</div>

				<div class="form-group">
					<label for="format">Tournament Format *</label>
					<select
						id="format"
						bind:value={formData.format}
						class:error={errors.format}
					>
						<option value="">Select format</option>
						{#each formatTypes as format}
							<option value={format}>{format}</option>
						{/each}
					</select>
					{#if errors.format}
						<span class="error-message">{errors.format}</span>
					{/if}
				</div>

				<div class="form-group">
					<label for="date">Event Date *</label>
					<input
						type="date"
						id="date"
						bind:value={formData.date}
						class:error={errors.date}
					/>
					{#if errors.date}
						<span class="error-message">{errors.date}</span>
					{/if}
				</div>

				<div class="form-group">
					<label for="time">Start Time *</label>
					<input
						type="time"
						id="time"
						bind:value={formData.time}
						class:error={errors.time}
					/>
					{#if errors.time}
						<span class="error-message">{errors.time}</span>
					{/if}
				</div>

				<div class="form-group">
					<label for="maxParticipants">Maximum Participants *</label>
					<input
						type="number"
						id="maxParticipants"
						bind:value={formData.maxParticipants}
						class:error={errors.maxParticipants}
						min="2"
						step="2"
					/>
					{#if errors.maxParticipants}
						<span class="error-message">{errors.maxParticipants}</span>
					{/if}
				</div>

				<div class="form-group">
					<label for="prizePool">Prize Pool</label>
					<input
						type="text"
						id="prizePool"
						bind:value={formData.prizePool}
						placeholder="e.g. $1,000"
					/>
				</div>
			</div>

			<div class="form-group full-width">
				<label for="description">Event Description *</label>
				<textarea
					id="description"
					bind:value={formData.description}
					class:error={errors.description}
					rows="5"
					placeholder="Describe your event..."
				></textarea>
				{#if errors.description}
					<span class="error-message">{errors.description}</span>
				{/if}
			</div>

			<div class="form-group full-width">
				<label for="rules">Tournament Rules</label>
				<textarea
					id="rules"
					bind:value={formData.rules}
					rows="5"
					placeholder="Enter tournament rules..."
				></textarea>
			</div>

			<div class="form-group full-width">
				<label for="image">Event Image URL</label>
				<input
					type="url"
					id="image"
					bind:value={formData.image}
					placeholder="Enter image URL"
				/>
			</div>

			{#if errors.submit}
				<div class="error-message submit-error">
					{errors.submit}
				</div>
			{/if}

			<div class="form-actions">
				<button type="button" class="btn-secondary" on:click={() => goto('/events')}>
					Cancel
				</button>
				<button type="submit" class="btn-primary" disabled={isSubmitting}>
					{isSubmitting ? 'Creating...' : 'Create Event'}
				</button>
			</div>
		</form>
	</div>
</div>

<style>
	.create-event {
		padding: 40px 0;
		min-height: calc(100vh - 90px);
	}

	.container {
		max-width: 1200px;
		margin: 0 auto;
		padding: 0 20px;
	}

	h1 {
		font-size: 32px;
		margin-bottom: 40px;
		color: var(--color-text-primary);
	}

	.event-form {
		background: white;
		padding: 30px;
		border-radius: 10px;
		box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
	}

	.form-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: 20px;
		margin-bottom: 30px;
	}

	.form-group {
		margin-bottom: 20px;
	}

	.full-width {
		grid-column: 1 / -1;
	}

	label {
		display: block;
		margin-bottom: 8px;
		font-weight: 500;
		color: var(--color-text-primary);
	}

	input,
	select,
	textarea {
		width: 100%;
		padding: 12px;
		border: 1px solid var(--color-border);
		border-radius: 6px;
		font-size: 16px;
		transition: var(--transition-speed);
	}

	input:focus,
	select:focus,
	textarea:focus {
		outline: none;
		border-color: var(--color-primary);
		box-shadow: 0 0 0 2px rgba(var(--color-primary-rgb), 0.1);
	}

	.error {
		border-color: var(--color-error);
	}

	.error-message {
		color: var(--color-error);
		font-size: 14px;
		margin-top: 5px;
		display: block;
	}

	.submit-error {
		text-align: center;
		margin-bottom: 20px;
		padding: 10px;
		background-color: rgba(var(--color-error-rgb), 0.1);
		border-radius: 6px;
	}

	.form-actions {
		display: flex;
		justify-content: flex-end;
		gap: 15px;
		margin-top: 30px;
	}

	button {
		padding: 12px 30px;
		border: none;
		border-radius: 6px;
		font-size: 16px;
		cursor: pointer;
		transition: var(--transition-speed);
	}

	button:disabled {
		opacity: 0.7;
		cursor: not-allowed;
	}

	.btn-primary {
		background-color: var(--color-primary);
		color: white;
	}

	.btn-primary:hover:not(:disabled) {
		background-color: #0834d1;
	}

	.btn-secondary {
		background-color: #f0f0f0;
		color: var(--color-text-primary);
	}

	.btn-secondary:hover {
		background-color: #e0e0e0;
	}

	@media (max-width: 768px) {
		.create-event {
			padding: 20px 0;
		}

		.event-form {
			padding: 20px;
		}

		.form-actions {
			flex-direction: column;
		}

		button {
			width: 100%;
		}
	}
</style>
