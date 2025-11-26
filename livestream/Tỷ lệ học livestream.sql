SELECT 
    u.id,
    u.user AS username,
    u.email,
    u.code,
    COUNT(CASE WHEN tt.total_minutes > 5 THEN 1 END) AS sessions_over_5min,
    COUNT(tt.session_number) AS total_sessions,
    ROUND(
        COUNT(CASE WHEN tt.total_minutes > 5 THEN 1 END) * 100.0 / 
        NULLIF(COUNT(tt.session_number), 0),
        2
    ) AS livestream_participation_rate
FROM users u
LEFT JOIN tu_timelearning_2526 tt 
    ON u.code = tt.subject_code
   AND u.learn_number = tt.session_number
WHERE DATE(tt.start_time) > '2025-09-01' 
GROUP BY 
    u.name, tt.subject_code 
ORDER BY livestream_participation_rate DESC;
