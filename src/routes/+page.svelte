<script>
  import { goto } from '$app/navigation';

  // Example of a function to handle login and registration
  function handleLogin() {
    goto('/auth');
  }

  function handleRegister() {
    goto('/auth?mode=register');
  }
</script>

<style>
  /* Add styles for the landing page */
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