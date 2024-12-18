-- Create test organization and teams
INSERT INTO organizations (name)
VALUES ('Test Org');

-- Create 5 teams in NA
INSERT INTO teams (name, organization_id, region, captain_id, tag)
SELECT 
    'NA Team ' || generate_series(1,5),
    id,
    'NA',
    '138b25e9-d29a-483b-918c-8e19ef982b59',
    'NAT' || generate_series(1,5)
FROM organizations
WHERE name = 'Test Org';

-- Test 1: Tournament Status Restrictions

-- Create tournaments in different states
INSERT INTO tournaments (name, region, start_date, end_date, max_teams, status, organizer_id)
VALUES 
    ('Draft Tournament', 'NA', NOW(), NOW() + INTERVAL '7 days', 8, 'draft', '138b25e9-d29a-483b-918c-8e19ef982b59'),
    ('Registration Tournament', 'NA', NOW(), NOW() + INTERVAL '7 days', 8, 'registration', '138b25e9-d29a-483b-918c-8e19ef982b59'),
    ('In Progress Tournament', 'NA', NOW(), NOW() + INTERVAL '7 days', 8, 'in_progress', '138b25e9-d29a-483b-918c-8e19ef982b59');

-- This should fail - can't register for draft tournament
INSERT INTO tournament_teams (tournament_id, team_id)
SELECT 
    t.id,
    team.id
FROM tournaments t
CROSS JOIN teams team
WHERE t.name = 'Draft Tournament'
AND team.name = 'NA Team 1';

-- This should succeed - registration is open
INSERT INTO tournament_teams (tournament_id, team_id)
SELECT 
    t.id,
    team.id
FROM tournaments t
CROSS JOIN teams team
WHERE t.name = 'Registration Tournament'
AND team.name = 'NA Team 1';

-- This should fail - tournament is in progress
INSERT INTO tournament_teams (tournament_id, team_id)
SELECT 
    t.id,
    team.id
FROM tournaments t
CROSS JOIN teams team
WHERE t.name = 'In Progress Tournament'
AND team.name = 'NA Team 1';

-- Test 2: Team Limit Restrictions

-- Create a small tournament
INSERT INTO tournaments (name, region, start_date, end_date, max_teams, status, organizer_id)
VALUES ('Small Tournament', 'NA', NOW(), NOW() + INTERVAL '7 days', 2, 'registration', '138b25e9-d29a-483b-918c-8e19ef982b59');

-- This should succeed - first team
INSERT INTO tournament_teams (tournament_id, team_id)
SELECT 
    t.id,
    team.id
FROM tournaments t
CROSS JOIN teams team
WHERE t.name = 'Small Tournament'
AND team.name = 'NA Team 1';

SELECT name, max_teams, current_teams, status 
FROM tournaments 
WHERE name = 'Small Tournament';

-- This should succeed - second team (reaching max)
INSERT INTO tournament_teams (tournament_id, team_id)
SELECT 
    t.id,
    team.id
FROM tournaments t
CROSS JOIN teams team
WHERE t.name = 'Small Tournament'
AND team.name = 'NA Team 2';

SELECT name, max_teams, current_teams, status 
FROM tournaments 
WHERE name = 'Small Tournament';

-- This should fail - tournament is full
INSERT INTO tournament_teams (tournament_id, team_id)
SELECT 
    t.id,
    team.id
FROM tournaments t
CROSS JOIN teams team
WHERE t.name = 'Small Tournament'
AND team.name = 'NA Team 3';

-- Verify final state
SELECT 
    t.name as tournament_name,
    t.status,
    t.max_teams,
    t.current_teams,
    COUNT(tt.team_id) as actual_teams
FROM tournaments t
LEFT JOIN tournament_teams tt ON t.id = tt.tournament_id
GROUP BY t.id, t.name, t.status, t.max_teams, t.current_teams
ORDER BY t.name;

-- Cleanup
DELETE FROM tournament_teams;
DELETE FROM tournaments;
DELETE FROM teams;
DELETE FROM organizations;
