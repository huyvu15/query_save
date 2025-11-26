
--- main
SELECT
    w.week_n,
    DATE_ADD(min_date.min_learn_date, INTERVAL (w.week_n-1)*7 DAY) AS week_start,
    DATE_ADD(min_date.min_learn_date, INTERVAL w.week_n*7-1 DAY) AS week_end,
    stats.subject_code,
    COUNT(DISTINCT stats.drop_user) AS users_missed_week_n,
    COUNT(DISTINCT stats.comeback_user) AS users_returned_week_n_plus_1,
    ROUND(
        COUNT(DISTINCT stats.comeback_user) * 100.0 / NULLIF(COUNT(DISTINCT stats.drop_user), 0),
        2
    ) AS comeback_rate
FROM
    (SELECT DISTINCT FLOOR(DATEDIFF(learn_date, (SELECT MIN(learn_date) FROM tu_report_timelearning_2526)) / 7) + 1 AS week_n
     FROM tu_report_timelearning_2526
    ) AS w
CROSS JOIN (SELECT MIN(learn_date) AS min_learn_date FROM tu_report_timelearning_2526) AS min_date
LEFT JOIN
    (
        SELECT
            prev.week_number + 1 AS week_n,
            prev.username AS drop_user,
            prev.subject_code,
            next.username AS comeback_user
        FROM
            (SELECT DISTINCT username, subject_code,
                     FLOOR(DATEDIFF(learn_date, (SELECT MIN(learn_date) FROM tu_report_timelearning_2526)) / 7) + 1 AS week_number
             FROM tu_report_timelearning_2526
            ) AS prev
        LEFT JOIN
            (SELECT DISTINCT username,
                     FLOOR(DATEDIFF(learn_date, (SELECT MIN(learn_date) FROM tu_report_timelearning_2526)) / 7) + 1 AS week_number
             FROM tu_report_timelearning_2526
            ) AS curr
        ON prev.username = curr.username AND prev.week_number + 1 = curr.week_number
        LEFT JOIN
            (SELECT DISTINCT username,
                     FLOOR(DATEDIFF(learn_date, (SELECT MIN(learn_date) FROM tu_report_timelearning_2526)) / 7) + 1 AS week_number
             FROM tu_report_timelearning_2526
            ) AS next
        ON prev.username = next.username AND prev.week_number + 2 = next.week_number
        WHERE curr.username IS NULL
    ) AS stats
ON w.week_n = stats.week_n
GROUP BY w.week_n, stats.subject_code
ORDER BY w.week_n, stats.subject_code;


--- old
SELECT
    cur.week_number AS week_n,
    MIN(DATE_ADD('2025-09-01', INTERVAL (cur.week_number - 1) * 7 DAY)) AS week_start,
    MAX(DATE_ADD('2025-09-01', INTERVAL ((cur.week_number - 1) * 7 + 6) DAY)) AS week_end,
    COUNT(DISTINCT cur.user) AS total_drop,   
    COUNT(DISTINCT nxt.user) AS comeback,     
    ROUND(COUNT(DISTINCT nxt.user) / COUNT(DISTINCT cur.user) * 100, 2) AS comeback_rate
FROM
    (
        SELECT
            u.user,
            FLOOR(DATEDIFF(tu.learn_date, '2025-09-01') / 7) + 1 AS week_number,
            IF(COUNT(tu.learn_date) >= 1, 1, 0) AS learn_status
        FROM
            users u
        LEFT JOIN
            tu_report_timelearning_2526 tu
            ON u.user = tu.username
            AND tu.learn_date >= '2025-09-01'
        GROUP BY
            u.user,
            week_number
    ) cur
LEFT JOIN
    (
        SELECT
            u.user,
            FLOOR(DATEDIFF(tu.learn_date, '2025-09-01') / 7) + 1 AS week_number,
            IF(COUNT(tu.learn_date) >= 1, 1, 0) AS learn_status
        FROM
            users u
        LEFT JOIN
            tu_report_timelearning_2526 tu
            ON u.user = tu.username
            AND tu.learn_date >= '2025-09-01'
        GROUP BY
            u.user,
            week_number
    ) nxt
    ON cur.user = nxt.user
    AND nxt.week_number = cur.week_number + 1
WHERE
    cur.learn_status = 0      -- tuần n: drop
    AND nxt.learn_status = 1  -- tuần n+1: học lại
GROUP BY
    cur.week_number
ORDER BY
    cur.week_number;
