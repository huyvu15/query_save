-- 🟩 Hiển thị các tuần học (từ 1/9/2025) và streak hiện tại của user 0325212810
SELECT 
    uw.user,
    uw.week_number,
    DATE_ADD('2025-09-01', INTERVAL (uw.week_number - 1) * 7 DAY) AS week_start,
    DATE_ADD('2025-09-01', INTERVAL uw.week_number * 7 - 1 DAY) AS week_end,
    uw.learn_status,
    @streak := IF(learn_status = 1, @streak + 1, 0) AS streak_length
FROM (
    -- 🔹 Subquery tạo dữ liệu từng tuần
    SELECT
        u.user,
        w.week_number,
        IF(COUNT(tu.learn_date) >= 1, 1, 0) AS learn_status
    FROM
        users u
    JOIN (
        -- 🔹 Sinh tuần từ 1/9/2025 → tuần hiện tại
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
        u.user IN ('0327891648', '0325212810', '03287596540', '328797269')
    GROUP BY
        u.user,
        w.week_number
    ORDER BY
        u.user,
        w.week_number
) uw,
(SELECT @streak := 0) vars;
	