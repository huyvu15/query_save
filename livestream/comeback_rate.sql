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
