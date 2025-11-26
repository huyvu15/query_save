SELECT 
-- 	COUNT(*) 
    u.user,
    u.email,
    u.name,
    u.code,
    u.learn_number,
    u.islearn,
    u.learn_date,
    sum(tu.total_minutes) as tutal_duration_attended,
    u.created_at,
    u.updated_at,
    tu.start_time,
    tu.end_time,
    sum(tu.end_time  - tu.start_time)  as tutal_duration
FROM 
    users u
LEFT JOIN 
    -- tu_report_timelearning_ext_2526 tu
    tu_timelearning_2526 tu
    ON tu.learn_number = u.learn_number
    AND tu.code = u.code
WHERE 
    u.code IN (
        'tongonvatli2026',
        'tongontienganh2026',
        'tongonhoahoc2026',
        'tongonsinhhoc2026',
        'tongontoan2026',
        'tongonnguvan2026',
        'luyendetoantsakg12026',    
        'luyendekhoahoctsakg12026',
        'luyendedochieutsakg12026'
    )
    and   DATE(start_time) >= '2025-09-01'
GROUP BY
    u.user,
    u.code,
    u.learn_number,
    u.name,
    u.islearn,
    u.learn_date,
    u.created_at,
    u.updated_at
    ;


