/* Main colors */
  --primary-bg: var(--night);      /* Dark background */
  --primary-text: var(--nyanza);   /* Light text for readability */
  --accent-primary: var(--keppel); /* Main accent color */
  --accent-secondary: var(--orange-peel); /* Secondary accent */
  --highlight: var(--bright-pink-crayola); /* Call-to-action elements */
}

<script>
  // Import any necessary components or libraries here
  import { onMount } from 'svelte';

  // Example of a function to handle login and registration
  function handleLogin() {
    // Logic for handling login
  }

  function handleRegister() {
    // Logic for handling registration
  }
</script>

<style>
  :root {
    --night: #141414;
    --keppel: #58b09c;
    --nyanza: #caf7e2;
    --orange-peel: #ffa62b;
    --bright-pink: #ff5d73;
  }

  .landing {
    text-align: center;
    padding: 2rem;
    background-color: var(--night); /* Dark background */
    color: var(--nyanza); /* Light text color */
  }

  .small-image {
    max-width: 100%; /* Responsive */
    height: auto; /* Maintain aspect ratio */
    width: 300px; /* Set a specific width */
  }

  .cta-buttons {
    margin-top: 2rem;
  }

  .cta-button {
    background-color: var(--orange-peel); /* Button color */
    color: var(--night); /* Text color for buttons */
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 5px;
    cursor: pointer;
  }

  .cta-button:hover {
    background-color: var(--keppel); /* Hover color */
  }
</style>

<main class="landing">
  <h1>Welcome to the Ranking of Legends Event Management Platform</h1>
  <p>Your one-stop solution for organizing and managing tournaments effortlessly.</p>
  <img class="small-image" src="/images/ROL Profile (1).png" alt="Event Management" />

  <div class="cta-buttons">
    <button class="cta-button" on:click={handleLogin}>Login</button>
    <button class="cta-button" on:click={handleRegister}>Register</button>
  </div>
</main>