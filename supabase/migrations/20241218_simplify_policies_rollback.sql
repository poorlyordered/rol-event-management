-- Drop all new policies
DROP POLICY IF EXISTS "Staff members viewable by authenticated users" ON staff_members;
DROP POLICY IF EXISTS "Staff managed by owner" ON staff_members;
DROP POLICY IF EXISTS "Organizations viewable by everyone" ON organizations;
DROP POLICY IF EXISTS "Organizations managed by ROL staff or org owners" ON organizations;
DROP POLICY IF EXISTS "Teams viewable by everyone" ON teams;
DROP POLICY IF EXISTS "Teams managed by organization staff" ON teams;
DROP POLICY IF EXISTS "Tournaments viewable by everyone" ON tournaments;
DROP POLICY IF EXISTS "Tournaments managed by ROL staff" ON tournaments;
DROP POLICY IF EXISTS "Tournaments updated by coordinators" ON tournaments;
DROP POLICY IF EXISTS "Leagues viewable by everyone" ON leagues;
DROP POLICY IF EXISTS "Leagues managed by ROL staff" ON leagues;
DROP POLICY IF EXISTS "Leagues updated by coordinators" ON leagues;
DROP POLICY IF EXISTS "Org members viewable by authenticated users" ON org_members;
DROP POLICY IF EXISTS "Org members managed by org owners" ON org_members;

-- Drop org_members table
DROP TABLE IF EXISTS org_members;

-- Recreate original staff_role type
ALTER TYPE staff_role RENAME TO staff_role_temp;
CREATE TYPE staff_role AS ENUM (
    'owner',              -- Super Admin with full access
    'platform_admin',     -- Platform-wide administration
    'customer_service',   -- Customer support and user assistance
    'org_manager',        -- Assists esports organizations
    'tournament_director',
    'tournament_coordinator',
    'league_director',
    'league_coordinator'
);

-- Update staff_members table
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
    END;

DROP TYPE staff_role_temp;
DROP TYPE IF EXISTS org_role;

-- Recreate original policies
CREATE POLICY "Staff members are viewable by everyone"
    ON staff_members FOR SELECT
    USING (true);

CREATE POLICY "Super admins can manage all staff"
    ON staff_members FOR ALL
    USING (is_super_admin(auth.uid()));

CREATE POLICY "Staff can manage lower-level roles"
    ON staff_members FOR ALL
    USING (
        CASE 
            WHEN (SELECT role FROM staff_members WHERE user_id = auth.uid()) = 'owner'
                THEN (SELECT role FROM staff_members WHERE user_id = auth.uid()) != 'owner'
            WHEN (SELECT role FROM staff_members WHERE user_id = auth.uid()) = 'platform_admin'
                THEN (SELECT role FROM staff_members WHERE user_id = auth.uid()) NOT IN ('owner', 'platform_admin')
            ELSE false
        END
    );

CREATE POLICY "Organization management restricted to admins"
    ON organizations FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM staff_members sm
            WHERE sm.user_id = auth.uid()
            AND sm.role IN ('owner', 'platform_admin')
        )
    );

CREATE POLICY "Tournament creation restricted to staff"
    ON tournaments FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM staff_members sm
            WHERE sm.user_id = auth.uid()
            AND (
                sm.role IN ('owner', 'platform_admin', 'tournament_director', 'tournament_coordinator')
                OR (sm.role = 'org_manager' AND sm.organization_id IS NOT NULL)
            )
        )
    );

CREATE POLICY "Tournament updates restricted to staff"
    ON tournaments FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM staff_members sm
            WHERE sm.user_id = auth.uid()
            AND (
                sm.role IN ('owner', 'platform_admin', 'tournament_director', 'tournament_coordinator')
                OR (sm.role = 'org_manager' AND sm.organization_id IS NOT NULL)
            )
        )
    );

CREATE POLICY "League creation restricted to staff"
    ON leagues FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM staff_members sm
            WHERE sm.user_id = auth.uid()
            AND (
                sm.role IN ('owner', 'platform_admin', 'league_director', 'league_coordinator')
                OR (sm.role = 'org_manager' AND sm.organization_id IS NOT NULL)
            )
        )
    );

CREATE POLICY "League updates restricted to staff"
    ON leagues FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM staff_members sm
            WHERE sm.user_id = auth.uid()
            AND (
                sm.role IN ('owner', 'platform_admin', 'league_director', 'league_coordinator')
                OR (sm.role = 'org_manager' AND sm.organization_id IS NOT NULL)
            )
        )
    );
