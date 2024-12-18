-- First, drop ALL existing policies that reference the role column
DROP POLICY IF EXISTS "Organization management restricted to admins" ON organizations;
DROP POLICY IF EXISTS "Teams can be updated by captain or admins" ON teams;
DROP POLICY IF EXISTS "Tournament creation restricted to staff" ON tournaments;
DROP POLICY IF EXISTS "Tournament updates restricted to staff" ON tournaments;
DROP POLICY IF EXISTS "League creation restricted to staff" ON leagues;
DROP POLICY IF EXISTS "League updates restricted to staff" ON leagues;
DROP POLICY IF EXISTS "Staff can manage lower-level roles" ON staff_members;
DROP POLICY IF EXISTS "Staff managed by owner" ON staff_members;
DROP POLICY IF EXISTS "Staff members are viewable by everyone" ON staff_members;
DROP POLICY IF EXISTS "Super admins can manage all staff" ON staff_members;
DROP POLICY IF EXISTS "Platform admins can manage non-owner staff" ON staff_members;
DROP POLICY IF EXISTS "Owner can manage all staff" ON staff_members;

-- Now we can safely alter the type
ALTER TYPE staff_role RENAME TO staff_role_old;
CREATE TYPE staff_role AS ENUM (
    'owner',              -- ROL platform owner
    'platform_admin',     -- ROL platform administrator
    'customer_service',   -- ROL customer support
    'tournament_director',-- ROL tournament management
    'tournament_coordinator',
    'league_director',    -- ROL league management
    'league_coordinator'
);

-- Update the column type
ALTER TABLE staff_members 
    ALTER COLUMN role TYPE staff_role 
    USING CASE 
        WHEN role::text = 'owner' THEN 'owner'::staff_role
        WHEN role::text = 'platform_admin' THEN 'platform_admin'::staff_role
        WHEN role::text = 'customer_service' THEN 'customer_service'::staff_role
        WHEN role::text = 'tournament_director' THEN 'tournament_director'::staff_role
        WHEN role::text = 'tournament_coordinator' THEN 'tournament_coordinator'::staff_role
        WHEN role::text = 'league_director' THEN 'league_director'::staff_role
        WHEN role::text = 'league_coordinator' THEN 'league_coordinator'::staff_role
        ELSE 'customer_service'::staff_role
    END;

-- Create org_role enum
CREATE TYPE org_role AS ENUM (
    'org_owner',         -- Esports organization owner
    'org_manager',       -- Esports organization manager
    'org_staff'          -- Esports organization staff
);

-- Create org_members table
CREATE TABLE IF NOT EXISTS org_members (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    organization_id UUID REFERENCES organizations NOT NULL,
    role org_role NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, organization_id)
);

-- Enable RLS on org_members
ALTER TABLE org_members ENABLE ROW LEVEL SECURITY;

-- Now we can create all the new policies

-- Simplified ROL Staff Policies
CREATE POLICY "Staff members viewable by authenticated users"
    ON staff_members FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Staff managed by owner"
    ON staff_members FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM staff_members
            WHERE user_id = auth.uid()
            AND role = 'owner'
        )
    );

-- Organization Policies
CREATE POLICY "Organizations viewable by everyone"
    ON organizations FOR SELECT
    USING (true);

CREATE POLICY "Organizations managed by ROL staff or org owners"
    ON organizations FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM staff_members
            WHERE user_id = auth.uid()
            AND role IN ('owner', 'platform_admin')
        )
        OR
        EXISTS (
            SELECT 1 FROM org_members
            WHERE user_id = auth.uid()
            AND organization_id = organizations.id
            AND role = 'org_owner'
        )
    );

-- Team Policies
CREATE POLICY "Teams viewable by everyone"
    ON teams FOR SELECT
    USING (true);

CREATE POLICY "Teams managed by organization staff"
    ON teams FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM org_members
            WHERE user_id = auth.uid()
            AND organization_id = teams.organization_id
            AND role IN ('org_owner', 'org_manager')
        )
        OR
        EXISTS (
            SELECT 1 FROM staff_members
            WHERE user_id = auth.uid()
            AND role IN ('owner', 'platform_admin')
        )
    );

-- Tournament Policies
CREATE POLICY "Tournaments viewable by everyone"
    ON tournaments FOR SELECT
    USING (true);

CREATE POLICY "Tournaments managed by ROL staff"
    ON tournaments FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM staff_members
            WHERE user_id = auth.uid()
            AND role IN ('owner', 'platform_admin', 'tournament_director')
        )
    );

CREATE POLICY "Tournaments updated by coordinators"
    ON tournaments FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM staff_members
            WHERE user_id = auth.uid()
            AND role = 'tournament_coordinator'
        )
    );

-- League Policies
CREATE POLICY "Leagues viewable by everyone"
    ON leagues FOR SELECT
    USING (true);

CREATE POLICY "Leagues managed by ROL staff"
    ON leagues FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM staff_members
            WHERE user_id = auth.uid()
            AND role IN ('owner', 'platform_admin', 'league_director')
        )
    );

CREATE POLICY "Leagues updated by coordinators"
    ON leagues FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM staff_members
            WHERE user_id = auth.uid()
            AND role = 'league_coordinator'
        )
    );

-- Org Members Policies
CREATE POLICY "Org members viewable by authenticated users"
    ON org_members FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Org members managed by org owners"
    ON org_members FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM org_members
            WHERE user_id = auth.uid()
            AND organization_id = org_members.organization_id
            AND role = 'org_owner'
        )
        OR
        EXISTS (
            SELECT 1 FROM staff_members
            WHERE user_id = auth.uid()
            AND role IN ('owner', 'platform_admin')
        )
    );

-- Finally, drop the old enum
DROP TYPE staff_role_old;
