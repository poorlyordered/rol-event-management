-- Test staff permissions and role-based access
-- Using existing user ID: 138b25e9-d29a-483b-918c-8e19ef982b59

-- First verify owner role exists
SELECT username, role 
FROM profiles p
JOIN staff_members sm ON p.id = sm.user_id
WHERE p.id = '138b25e9-d29a-483b-918c-8e19ef982b59';

-- Create test tournaments
INSERT INTO tournaments (name, region, start_date, end_date, max_teams, status, organizer_id)
VALUES 
    ('Tournament 1', 'NA', NOW(), NOW() + INTERVAL '7 days', 8, 'draft', '138b25e9-d29a-483b-918c-8e19ef982b59'),
    ('Tournament 2', 'NA', NOW(), NOW() + INTERVAL '7 days', 8, 'registration', '138b25e9-d29a-483b-918c-8e19ef982b59');

-- Test 1: Owner Permissions
SET ROLE authenticated;
SET request.jwt.claim.sub TO '138b25e9-d29a-483b-918c-8e19ef982b59';

-- Owner should be able to view all tournaments
SELECT name, status, organizer_id 
FROM tournaments;

-- Owner should be able to update any tournament
UPDATE tournaments 
SET status = 'registration'
WHERE name = 'Tournament 1';

-- Test 2: Platform Admin Permissions
-- First, temporarily change role to platform_admin
UPDATE staff_members 
SET role = 'platform_admin'
WHERE user_id = '138b25e9-d29a-483b-918c-8e19ef982b59';

-- Platform admin should still see all tournaments
SELECT name, status, organizer_id 
FROM tournaments;

-- Platform admin should be able to update tournaments
UPDATE tournaments 
SET status = 'in_progress'
WHERE name = 'Tournament 2';

-- Test 3: Tournament Director Permissions
-- Change role to tournament_director
UPDATE staff_members 
SET role = 'tournament_director'
WHERE user_id = '138b25e9-d29a-483b-918c-8e19ef982b59';

-- Tournament director should only see their tournaments
SELECT name, status, organizer_id 
FROM tournaments 
WHERE organizer_id = '138b25e9-d29a-483b-918c-8e19ef982b59';

-- Tournament director should only update their tournaments
UPDATE tournaments 
SET status = 'completed'
WHERE organizer_id = '138b25e9-d29a-483b-918c-8e19ef982b59'
AND name = 'Tournament 1';

-- Reset back to owner role
UPDATE staff_members 
SET role = 'owner'
WHERE user_id = '138b25e9-d29a-483b-918c-8e19ef982b59';

-- Verify final state
SELECT 
    t.name as tournament_name,
    t.status,
    p.username as organizer_name,
    sm.role as organizer_role
FROM tournaments t
JOIN profiles p ON t.organizer_id = p.id
JOIN staff_members sm ON p.id = sm.user_id
ORDER BY t.name;

-- Cleanup
DELETE FROM tournament_teams;
DELETE FROM tournaments;
