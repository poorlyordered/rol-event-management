-- Test region constraints between teams and players

-- Create a test organization
INSERT INTO organizations (name)
VALUES ('Test Org');

-- Create a team in NA
INSERT INTO teams (name, organization_id, region, captain_id, tag)
SELECT 'NA Team', id, 'NA', '138b25e9-d29a-483b-918c-8e19ef982b59', 'NAT'
FROM organizations
WHERE name = 'Test Org';

-- This should succeed - player in same region as team
INSERT INTO players (profile_id, team_id, region, role, rank, summoner_name)
SELECT 
    '138b25e9-d29a-483b-918c-8e19ef982b59',
    t.id,
    'NA',
    'top',
    'challenger',
    'TestPlayer1'
FROM teams t
WHERE t.name = 'NA Team';

-- Create a tournament in NA
INSERT INTO tournaments (name, region, start_date, end_date, max_teams, status, organizer_id)
VALUES ('NA Tournament', 'NA', NOW(), NOW() + INTERVAL '7 days', 8, 'registration', '138b25e9-d29a-483b-918c-8e19ef982b59');

-- This should succeed - team in same region as tournament
INSERT INTO tournament_teams (tournament_id, team_id)
SELECT 
    t.id,
    team.id
FROM tournaments t
CROSS JOIN teams team
WHERE t.name = 'NA Tournament'
AND team.name = 'NA Team';

-- Create an EUW team (this should succeed)
INSERT INTO teams (name, organization_id, region, captain_id, tag)
SELECT 'EUW Team', id, 'EUW', '138b25e9-d29a-483b-918c-8e19ef982b59', 'EUW'
FROM organizations
WHERE name = 'Test Org';

-- This should fail - trying to register EUW team in NA tournament
INSERT INTO tournament_teams (tournament_id, team_id)
SELECT 
    t.id,
    team.id
FROM tournaments t
CROSS JOIN teams team
WHERE t.name = 'NA Tournament'
AND team.name = 'EUW Team';

-- Verify our data
SELECT 
    t.name as team_name, 
    t.region as team_region,
    p.summoner_name,
    p.region as player_region,
    tour.name as tournament_name,
    tour.region as tournament_region
FROM teams t
LEFT JOIN players p ON t.id = p.team_id
LEFT JOIN tournament_teams tt ON t.id = tt.team_id
LEFT JOIN tournaments tour ON tt.tournament_id = tour.id
ORDER BY t.name;

-- Cleanup
DELETE FROM tournament_teams;
DELETE FROM players;
DELETE FROM teams;
DELETE FROM tournaments;
DELETE FROM organizations;
