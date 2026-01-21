-- Check user roles in the database
SELECT u.email, r.name as role_name 
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id;
