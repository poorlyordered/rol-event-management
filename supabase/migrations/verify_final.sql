-- Check tournament statuses and team counts
SELECT 
    t.name as tournament_name,
    t.status,
    t.max_teams,
    t.current_teams,
    COUNT(tt.team_id) as registered_teams
FROM tournaments t
LEFT JOIN tournament_teams tt ON t.id = tt.tournament_id
GROUP BY t.id, t.name, t.status, t.max_teams, t.current_teams
ORDER BY t.name;

-- Check which teams are registered where
SELECT 
    team.name as team_name,
    t.name as tournament_name,
    t.status as tournament_status
FROM teams team
LEFT JOIN tournament_teams tt ON team.id = tt.team_id
LEFT JOIN tournaments t ON tt.tournament_id = t.id
ORDER BY team.name;
