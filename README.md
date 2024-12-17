# Ranking of Legends Event Management Platform

A modern web application for managing eSports events, built with SvelteKit and Supabase.

## Features

- **Authentication**
  - Email/Password registration and login
  - Email verification
  - Google OAuth integration
  - Protected routes
  - Session management

- **User Management**
  - User profiles
  - Session persistence
  - Secure authentication state

## Getting Started

1. **Prerequisites**
   - Node.js (v14 or higher)
   - npm (v6 or higher)
   - Supabase account

2. **Environment Setup**
   Create a `.env` file in the root directory with:
   ```bash
   VITE_SUPABASE_URL=your-project-url
   VITE_SUPABASE_ANON_KEY=your-anon-key
   ```

3. **Installation**
   ```bash
   # Install dependencies
   npm install

   # Start development server
   npm run dev

   # Build for production
   npm run build
   ```

## Project Structure

```
src/
├── lib/
│   └── stores/          # Svelte stores (session management)
├── routes/
│   ├── auth/            # Authentication pages
│   ├── profile/         # User profile (protected)
│   └── events/          # Event management (protected)
└── supabase.js          # Supabase client configuration
```

## Development Notes

- Authentication is handled through Supabase Auth
- Protected routes redirect to login if accessed without authentication
- Session state is managed through Svelte stores
- Styling uses CSS variables for consistent theming

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
