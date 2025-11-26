-- Truy vấn hiển thị tất cả tuần, kể cả tuần không học
SELECT
    u.user,
    u.name,
    w.week_number,
    DATE_ADD('2025-09-01', INTERVAL (w.week_number - 1) * 7 DAY) AS week_start,
    DATE_ADD('2025-09-01', INTERVAL ((w.week_number - 1) * 7 + 6) DAY) AS week_end,
    IF(COUNT(tu.learn_date) >= 1, '1', '0') AS learn_status
FROM
    users u
-- Sinh tuần từ 1 → tuần hiện tại (tự động, không cần UNION)
JOIN (
    SELECT 
        @row := @row + 1 AS week_number
    FROM 
        (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL 
         SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL 
         SELECT 8 UNION ALL SELECT 9) t1,
        (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL 
         SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL 
         SELECT 8 UNION ALL SELECT 9) t2,
        (SELECT @row := 0) r
    WHERE 
        @row < FLOOR(DATEDIFF(CURDATE(), '2025-09-01') / 7) + 1
) w
LEFT JOIN
    tu_report_timelearning_2526 tu
    ON u.user = tu.username
    AND FLOOR(DATEDIFF(tu.learn_date, '2025-09-01') / 7) + 1 = w.week_number
WHERE
    u.user = '0325212810'
GROUP BY
    u.user,
    w.week_number
ORDER BY
    u.user,
    w.week_number;


-- Chỉ hiện thị các tuần có học
SELECT
    u.user,
    u.name,
    FLOOR(DATEDIFF(tu.learn_date, '2025-09-01') / 7) + 1 AS week_number,
    DATE_ADD('2025-09-01', INTERVAL FLOOR(DATEDIFF(tu.learn_date, '2025-09-01') / 7) * 7 DAY) AS week_start,
    DATE_ADD('2025-09-01', INTERVAL (FLOOR(DATEDIFF(tu.learn_date, '2025-09-01') / 7) * 7 + 6) DAY) AS week_end,
    IF(COUNT(tu.learn_date) >= 1, '1', '0') AS learn_status
FROM
    users u
LEFT JOIN
    tu_report_timelearning_2526 tu
    ON u.user = tu.username
WHERE u.user = '0325212810'
GROUP BY
    u.user,
    week_number
ORDER BY
    u.user,
    week_number;


