-- Lấy ra data livestream của từng user theo buổi
SELECT * from (
SELECT
    SUBSTRING_INDEX(u.name, ' - ', 1) AS user_id,
    sub.username,
    ROUND(
        SUM(sub.total_minutes) / NULLIF(
            SUM(ABS(TIMESTAMPDIFF(MINUTE, sub.start_time, sub.end_time))),
            0
        ) * 100,
        2
    ) AS learn_rate,
    sub.platform,
    sub.package_id,
    sub.session_number AS learn_number,	
    SUM(sub.total_minutes) AS total_duration_attended,
    SUM(ABS(TIMESTAMPDIFF(MINUTE, sub.start_time, sub.end_time))) AS total_duration,
    MIN(sub.start_time) AS start_time,
    MAX(sub.end_time) AS end_time
FROM (
    SELECT
        t.username,
        'livestream' AS platform,
        8552 AS package_id,
        t.subject_code,
        t.session_number,
        t.learn_date,
        SUM(t.total_minutes) AS total_minutes,
        MIN(t.start_time) AS start_time,
        MAX(t.end_time) AS end_time
    FROM tu_report_timelearning_2526 t
    WHERE t.subject_code = 'tongontoan2026'
    GROUP BY t.username, t.subject_code, t.session_number
) AS sub
LEFT JOIN users u ON sub.username = u.user
GROUP BY u.name, sub.username, sub.session_number, sub.platform, sub.package_id
HAVING DATE(MIN(start_time)) >= '2025-09-01'
AND sub.session_number IN ('1', '2', '3', '4', '5', '6')
ORDER BY sub.username, sub.session_number
) as ti



