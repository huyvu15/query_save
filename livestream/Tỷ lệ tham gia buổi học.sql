SELECT 
    SUM(islearn = 1) / COUNT(*) AS ratio
FROM users;
