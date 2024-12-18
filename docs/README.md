# Ranking of Legends Event Management Platform

A modern web application for managing eSports events, built with SvelteKit and Supabase.

## Features

### Core Features
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

### Database Features
- **Schema Design**
  - Comprehensive tournament system
  - Team management
  - League structure
  - Player profiles
  - Staff roles and permissions

- **Security**
  - Row Level Security (RLS)
  - Role-based access control
  - Region-based constraints
  - Tournament registration rules

### Current Development Status
- Basic authentication and user management
- Database schema implementation
- Tournament registration system
- Team management structure
- Staff permissions system (In Progress)
- League management (Planned)
- Match scheduling (Planned)
- Tournament brackets (Planned)

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

## Development

### Testing
The project includes several test scripts in the `supabase/migrations` directory:
- `test_tournament_registration.sql`: Validates tournament registration constraints
- `test_staff_permissions.sql`: Tests role-based access control
- `verify_data.sql`: Verifies data integrity
- `cleanup.sql`: Resets the database for testing

To run tests:
1. Run cleanup.sql to reset the database
2. Run 00_schema.sql to create tables and policies
3. Run individual test files to verify functionality

### Known Issues
1. **Staff permissions policies currently have recursion issues**:
   - **Description**: There are known recursion issues within the staff permissions policies, which may lead to unexpected behavior when determining access levels for certain roles. This issue arises from the complex relationships between staff roles, permissions, and the tournament structure. As a result, the system may incorrectly grant or deny access to certain features or data.
   - **Next Steps**: Investigate the logic used in the permission checks to identify potential circular references or unintended recursive calls. A review of the policy definitions may be necessary to ensure clarity and correctness. Consider implementing a more robust permission system that can handle complex relationships and recursive checks.

2. **Role-based access control needs refinement**:
   - **Description**: The current implementation of role-based access control requires refinement to ensure that permissions align correctly with user roles. The system currently relies on a simple role-based system, which may not accurately reflect the nuances of staff roles and permissions within the tournament structure.
   - **Next Steps**: Review the role definitions and associated permissions to ensure they accurately reflect the intended access levels. Consider conducting user testing to gather feedback on access issues and identify areas where the current implementation falls short. Implement a more granular permission system that can accommodate the complexities of staff roles and tournament structure.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
