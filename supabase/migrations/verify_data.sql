-- Verify Organizations
SELECT name, created_at FROM organizations;

-- Verify Teams
SELECT name, tag, region FROM teams ORDER BY name;

-- Verify Players
SELECT summoner_name, role, rank, region FROM players;

-- Verify Tournaments
SELECT name, region, status, max_teams FROM tournaments;

-- Verify Tournament Teams
SELECT 
    t.name as team_name,
    t.region as team_region,
    tour.name as tournament_name,
    tour.region as tournament_region
FROM tournament_teams tt
JOIN teams t ON tt.team_id = t.id
JOIN tournaments tour ON tt.tournament_id = tour.id;
