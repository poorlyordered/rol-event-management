-- Create required enums
DO $$ BEGIN
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

    CREATE TYPE riot_region AS ENUM (
        'BR',    -- Brazil
        'EUN',   -- Europe Nordic & East
        'EUW',   -- Europe West
        'LAN',   -- Latin America North
        'LAS',   -- Latin America South
        'NA',    -- North America
        'OCE',   -- Oceania
        'RU',    -- Russia
        'TR',    -- Turkey
        'JP',    -- Japan
        'KR',    -- Korea
        'PH',    -- Philippines
        'SG',    -- Singapore
        'TH',    -- Thailand
        'TW',    -- Taiwan
        'VN'     -- Vietnam
    );

    CREATE TYPE tournament_status AS ENUM (
        'draft',
        'registration',
        'in_progress',
        'completed',
        'cancelled'
    );

    CREATE TYPE player_role AS ENUM (
        'top',
        'jungle',
        'mid',
        'adc',
        'support',
        'substitute'
    );

    CREATE TYPE player_rank AS ENUM (
        'iron',
        'bronze',
        'silver',
        'gold',
        'platinum',
        'emerald',
        'diamond',
        'master',
        'grandmaster',
        'challenger'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS tournament_teams CASCADE;
DROP TABLE IF EXISTS league_teams CASCADE;
DROP TABLE IF EXISTS leagues CASCADE;
DROP TABLE IF EXISTS matches CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE IF EXISTS tournaments CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP TABLE IF EXISTS teams CASCADE;
DROP TABLE IF EXISTS staff_members CASCADE;
DROP TABLE IF EXISTS organizations CASCADE;

-- Create organizations table
CREATE TABLE organizations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    website TEXT,
    contact_email TEXT,
    logo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create profiles table
CREATE TABLE profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    summoner_name TEXT,
    region riot_region,
    PUUID TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create teams table
CREATE TABLE teams (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    tag TEXT NOT NULL,
    logo_url TEXT,
    captain_id UUID REFERENCES auth.users NOT NULL,
    region riot_region NOT NULL,
    organization_id UUID REFERENCES organizations,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT team_org_region UNIQUE (organization_id, name, region)
);

-- Create players table
CREATE TABLE players (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    profile_id UUID REFERENCES profiles NOT NULL,
    team_id UUID REFERENCES teams,
    summoner_name TEXT NOT NULL,
    role player_role NOT NULL,
    rank player_rank,
    region riot_region NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create trigger function for player-team region consistency
CREATE OR REPLACE FUNCTION check_player_team_region()
RETURNS TRIGGER AS $$
DECLARE
    team_region riot_region;
BEGIN
    IF NEW.team_id IS NOT NULL THEN
        SELECT region INTO team_region FROM teams WHERE id = NEW.team_id;
        IF NEW.region != team_region THEN
            RAISE EXCEPTION 'Player region must match team region';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for player-team region check
DROP TRIGGER IF EXISTS check_player_team_region ON players;
CREATE TRIGGER check_player_team_region
    BEFORE INSERT OR UPDATE ON players
    FOR EACH ROW
    EXECUTE FUNCTION check_player_team_region();

-- Create tournaments table
CREATE TABLE tournaments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    region riot_region NOT NULL,
    status tournament_status NOT NULL DEFAULT 'draft',
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    max_teams INTEGER NOT NULL,
    current_teams INTEGER NOT NULL DEFAULT 0,
    organizer_id UUID REFERENCES auth.users NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT tournament_dates CHECK (start_date <= end_date),
    CONSTRAINT tournament_team_limit CHECK (current_teams <= max_teams)
);

-- Create tournament_teams table
CREATE TABLE tournament_teams (
    tournament_id UUID REFERENCES tournaments ON DELETE CASCADE,
    team_id UUID REFERENCES teams ON DELETE CASCADE,
    registration_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (tournament_id, team_id)
);

-- Create trigger function for checking tournament team limit and status
CREATE OR REPLACE FUNCTION check_tournament_team_limit()
RETURNS TRIGGER AS $$
DECLARE
    current_count INTEGER;
    max_teams INTEGER;
    tournament_status tournament_status;
BEGIN
    SELECT t.current_teams, t.max_teams, t.status
    INTO current_count, max_teams, tournament_status
    FROM tournaments t 
    WHERE t.id = NEW.tournament_id;
    
    IF tournament_status != 'registration' THEN
        RAISE EXCEPTION 'Tournament is not open for registration';
    END IF;

    IF current_count >= max_teams THEN
        RAISE EXCEPTION 'Tournament has reached maximum team limit';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for tournament team limit check
DROP TRIGGER IF EXISTS check_tournament_team_limit ON tournament_teams;
CREATE TRIGGER check_tournament_team_limit
    BEFORE INSERT ON tournament_teams
    FOR EACH ROW
    EXECUTE FUNCTION check_tournament_team_limit();

-- Create trigger function for tournament-team region consistency
CREATE OR REPLACE FUNCTION check_tournament_team_region()
RETURNS TRIGGER AS $$
DECLARE
    team_region riot_region;
    tournament_region riot_region;
BEGIN
    SELECT region INTO team_region FROM teams WHERE id = NEW.team_id;
    SELECT region INTO tournament_region FROM tournaments WHERE id = NEW.tournament_id;
    
    IF team_region != tournament_region THEN
        RAISE EXCEPTION 'Team region must match tournament region';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for tournament-team region check
DROP TRIGGER IF EXISTS check_tournament_team_region ON tournament_teams;
CREATE TRIGGER check_tournament_team_region
    BEFORE INSERT OR UPDATE ON tournament_teams
    FOR EACH ROW
    EXECUTE FUNCTION check_tournament_team_region();

-- Create trigger function for updating tournament team count
CREATE OR REPLACE FUNCTION update_tournament_team_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE tournaments 
        SET current_teams = current_teams + 1
        WHERE id = NEW.tournament_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE tournaments 
        SET current_teams = current_teams - 1
        WHERE id = OLD.tournament_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for tournament team count
DROP TRIGGER IF EXISTS update_tournament_team_count ON tournament_teams;
CREATE TRIGGER update_tournament_team_count
    AFTER INSERT OR DELETE ON tournament_teams
    FOR EACH ROW
    EXECUTE FUNCTION update_tournament_team_count();

-- Create matches table
CREATE TABLE matches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    tournament_id UUID REFERENCES tournaments NOT NULL,
    round INTEGER NOT NULL,
    team1_id UUID REFERENCES teams NOT NULL,
    team2_id UUID REFERENCES teams NOT NULL,
    winner_id UUID REFERENCES teams,
    status tournament_status NOT NULL DEFAULT 'draft',
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT match_teams_different CHECK (team1_id != team2_id),
    CONSTRAINT winner_must_be_participant CHECK (
        winner_id IS NULL OR 
        winner_id = team1_id OR 
        winner_id = team2_id
    )
);

-- Create leagues table
CREATE TABLE leagues (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    region riot_region NOT NULL,
    status tournament_status NOT NULL DEFAULT 'draft',
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    max_teams INTEGER NOT NULL,
    current_teams INTEGER NOT NULL DEFAULT 0,
    organizer_id UUID REFERENCES auth.users NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT league_dates CHECK (start_date <= end_date),
    CONSTRAINT league_team_limit CHECK (current_teams <= max_teams)
);

-- Create league_teams table
CREATE TABLE league_teams (
    league_id UUID REFERENCES leagues ON DELETE CASCADE,
    team_id UUID REFERENCES teams ON DELETE CASCADE,
    registration_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (league_id, team_id)
);

-- Create trigger function for league-team region consistency
CREATE OR REPLACE FUNCTION check_league_team_region()
RETURNS TRIGGER AS $$
DECLARE
    team_region riot_region;
    league_region riot_region;
BEGIN
    SELECT region INTO team_region FROM teams WHERE id = NEW.team_id;
    SELECT region INTO league_region FROM leagues WHERE id = NEW.league_id;
    
    IF team_region != league_region THEN
        RAISE EXCEPTION 'Team region must match league region';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for league-team region check
DROP TRIGGER IF EXISTS check_league_team_region ON league_teams;
CREATE TRIGGER check_league_team_region
    BEFORE INSERT OR UPDATE ON league_teams
    FOR EACH ROW
    EXECUTE FUNCTION check_league_team_region();

-- Create staff_members table
CREATE TABLE staff_members (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    role staff_role NOT NULL,
    organization_id UUID REFERENCES organizations,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, organization_id)
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE leagues ENABLE ROW LEVEL SECURITY;
ALTER TABLE league_teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

-- Helper Functions
CREATE OR REPLACE FUNCTION is_owner(user_id uuid)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM staff_members
        WHERE user_id = $1
        AND role = 'owner'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_platform_admin(user_id uuid)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM staff_members
        WHERE user_id = $1
        AND (role = 'platform_admin' OR role = 'owner')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION can_manage_team(team_id uuid, user_id uuid)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM teams t
        WHERE t.id = $1
        AND (
            -- User is team captain
            t.captain_id = $2
            OR
            -- User is org admin
            EXISTS (
                SELECT 1 FROM staff_members sm
                WHERE sm.user_id = $2
                AND (
                    -- Platform-wide admin
                    sm.role IN ('owner', 'platform_admin')
                    OR
                    -- Org manager for team's organization
                    (sm.role = 'org_manager' AND sm.organization_id = t.organization_id)
                )
            )
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_org_admin(org_id uuid, user_id uuid)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM staff_members
        WHERE user_id = $2
        AND organization_id = $1
        AND role IN ('owner', 'platform_admin', 'org_manager')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if tournament is open for registration
CREATE OR REPLACE FUNCTION is_tournament_registration_open(tournament_id uuid)
RETURNS boolean AS $$
DECLARE
    t_status tournament_status;
    t_current_teams integer;
    t_max_teams integer;
BEGIN
    SELECT status, current_teams, max_teams 
    INTO t_status, t_current_teams, t_max_teams
    FROM tournaments 
    WHERE id = tournament_id;

    RETURN t_status = 'registration' AND t_current_teams < t_max_teams;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RLS Policies
-- Profiles
CREATE POLICY "Profiles are viewable by everyone"
    ON profiles FOR SELECT
    USING (true);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

-- Organizations
CREATE POLICY "Organizations are viewable by everyone"
    ON organizations FOR SELECT
    USING (true);

CREATE POLICY "Organization management restricted to admins"
    ON organizations FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM staff_members sm
            WHERE sm.user_id = auth.uid()
            AND sm.role IN ('owner', 'platform_admin')
        )
    );

-- Teams
CREATE POLICY "Teams are viewable by everyone"
    ON teams FOR SELECT
    USING (true);

CREATE POLICY "Team creation requires authentication"
    ON teams FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Teams can be updated by captain or admins"
    ON teams FOR UPDATE
    USING (can_manage_team(id, auth.uid()));

-- Tournaments
CREATE POLICY "Tournaments are viewable by everyone"
    ON tournaments FOR SELECT
    USING (true);

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

-- Tournament Teams
CREATE POLICY "Tournament teams are viewable by everyone"
    ON tournament_teams FOR SELECT
    USING (true);

CREATE POLICY "Team tournament registration"
    ON tournament_teams FOR INSERT
    WITH CHECK (
        can_manage_team(team_id, auth.uid()) AND
        is_tournament_registration_open(tournament_id)
    );

-- Matches
CREATE POLICY "Matches are viewable by everyone"
    ON matches FOR SELECT
    USING (true);

CREATE POLICY "Match updates restricted to tournament organizers and admins"
    ON matches FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM tournaments t
            WHERE t.id = tournament_id
            AND (
                auth.uid() = t.organizer_id OR
                is_platform_admin(auth.uid())
            )
        )
    );

-- Leagues
CREATE POLICY "Leagues are viewable by everyone"
    ON leagues FOR SELECT
    USING (true);

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

-- Staff Members
-- Enable Row Level Security
ALTER TABLE staff_members ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Staff members are viewable by everyone" ON staff_members;
DROP POLICY IF EXISTS "Super admin can manage staff" ON staff_members;
DROP POLICY IF EXISTS "Platform admins can manage non-owner staff" ON staff_members;
DROP POLICY IF EXISTS "Owner can manage all staff" ON staff_members;

-- Create a function to check if user is super admin without using staff_members table
CREATE OR REPLACE FUNCTION is_super_admin(user_id uuid)
RETURNS boolean AS $$
BEGIN
    -- Initially, only the specified user ID will be super admin
    RETURN user_id = '138b25e9-d29a-483b-918c-8e19ef982b59';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Staff member policies
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
            -- Owner can manage all except other owners
            WHEN (SELECT role FROM staff_members WHERE user_id = auth.uid()) = 'owner'
                THEN (SELECT role FROM staff_members WHERE user_id = auth.uid()) != 'owner'
            -- Platform admin can manage all except owners and other platform admins
            WHEN (SELECT role FROM staff_members WHERE user_id = auth.uid()) = 'platform_admin'
                THEN (SELECT role FROM staff_members WHERE user_id = auth.uid()) NOT IN ('owner', 'platform_admin')
            ELSE false
        END
    );

-- Players
CREATE POLICY "Players are viewable by everyone"
    ON players FOR SELECT
    USING (true);

CREATE POLICY "Players can update own profile"
    ON players FOR UPDATE
    USING (auth.uid() = profile_id);

CREATE POLICY "Players can insert own profile"
    ON players FOR INSERT
    WITH CHECK (auth.uid() = profile_id);
