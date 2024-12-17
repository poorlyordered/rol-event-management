<script>
  import { page } from '$app/stores';
  import { user } from '$lib/stores/session';
  import { supabase } from '../supabase.js';
  import { goto } from '$app/navigation';

  let mobileNavActive = false;

  function toggleMobileNav() {
    mobileNavActive = !mobileNavActive;
    const navMenu = document.querySelector('.navmenu ul');
    navMenu?.classList.toggle('show');
  }

  async function handleLogout() {
    const { error } = await supabase.auth.signOut();
    if (!error) {
      goto('/');
    }
  }
</script>

<header class="header fixed-top">
  <div class="container-fluid container-xl d-flex align-items-center justify-content-between">
    <a href="/" class="logo d-flex align-items-center">
      <span class="sitename">ROL</span>
    </a>

    <nav id="navmenu" class="navmenu">
      <ul>
        <li><a href="/" class:active={$page.url.pathname === '/'}>Home</a></li>
        {#if $user}
          <li><a href="/events" class:active={$page.url.pathname === '/events'}>Events</a></li>
          <li><a href="/teams" class:active={$page.url.pathname === '/teams'}>Teams</a></li>
          <li><a href="/tournaments" class:active={$page.url.pathname === '/tournaments'}>Tournaments</a></li>
          <li><a href="/profile" class:active={$page.url.pathname === '/profile'}>Profile</a></li>
        {/if}
        <li>
          {#if $user}
            <button class="btn-logout" on:click={handleLogout}>Logout</button>
          {:else}
            <a href="/auth" class="btn-login">Login</a>
          {/if}
        </li>
      </ul>
      <button class="mobile-nav-toggle d-xl-none bi bi-list" aria-label="Toggle Navigation" on:click={toggleMobileNav}>
        <i class="fas fa-bars"></i>
      </button>
    </nav>
  </div>
</header>

<style>
  .header {
    transition: all 0.5s;
    z-index: 997;
    padding: 30px 0;
    background: #fff;
    box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
  }

  .header .logo {
    text-decoration: none;
  }

  .header .sitename {
    font-size: 30px;
    font-weight: 700;
    color: var(--color-primary, #0d42ff);
    font-family: var(--font-primary, "Poppins", sans-serif);
  }

  .navmenu {
    padding: 0;
    margin: 0;
  }

  .navmenu ul {
    margin: 0;
    padding: 0;
    display: flex;
    list-style: none;
    align-items: center;
    gap: 2rem;
  }

  .navmenu a,
  .btn-logout,
  .btn-login {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0;
    font-family: var(--font-primary, "Poppins", sans-serif);
    font-size: 16px;
    font-weight: 500;
    color: #172e59;
    white-space: nowrap;
    transition: 0.3s;
    text-decoration: none;
    background: none;
    border: none;
    cursor: pointer;
  }

  .navmenu a:hover,
  .navmenu .active,
  .btn-logout:hover,
  .btn-login:hover {
    color: var(--color-primary, #0d42ff);
  }

  .btn-login,
  .btn-logout {
    padding: 8px 20px;
    border-radius: 50px;
    border: 1px solid var(--color-primary, #0d42ff);
    color: var(--color-primary, #0d42ff);
  }

  .btn-login:hover,
  .btn-logout:hover {
    background-color: var(--color-primary, #0d42ff);
    color: #fff;
  }

  .mobile-nav-toggle {
    display: none;
    color: #172e59;
    font-size: 28px;
    cursor: pointer;
    line-height: 0;
    transition: 0.5s;
    position: relative;
    z-index: 9999;
    padding: 0;
    border: none;
    background: none;
    margin-left: auto;
  }

  @media (max-width: 1200px) {
    .mobile-nav-toggle {
      display: block;
    }

    .navmenu ul {
      display: none;
      position: fixed;
      top: 100px;
      right: -100%;
      width: 100%;
      max-width: 300px;
      background: #fff;
      box-shadow: 0px 0px 30px rgba(127, 137, 161, 0.25);
      transition: 0.3s;
      flex-direction: column;
      padding: 20px 0;
    }

    .navmenu ul.show {
      right: 0;
      display: flex;
    }
  }
</style>
