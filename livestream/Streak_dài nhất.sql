-- Tính theo môn
-- 🟩 Tính streak học dài nhất kể từ 1/9/2025 cho user 0325212810 theo từng môn
SELECT 
    uw.user,
    uw.subject_code,
    MAX(streak_length) AS longest_streak
FROM (
    SELECT 
        user,
        subject_code,
        week_number,
        learn_status,

        -- Tăng streak nếu learn_status = 1, reset nếu = 0
        @streak :=
            IF(
                @prev_user = user AND @prev_subject = subject_code,
                IF(learn_status = 1, @streak + 1, 0),
                IF(learn_status = 1, 1, 0)
            ) AS streak_length,

        @prev_user := user,
        @prev_subject := subject_code
    FROM (
        SELECT
            u.user,
            tu.subject_code,
            w.week_number,
            IF(COUNT(tu.learn_date) >= 1, 1, 0) AS learn_status
        FROM users u

        -- Tạo tuần 1 → tuần hiện tại (100 tuần max để an toàn)
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

        LEFT JOIN tu_report_timelearning_2526 tu
            ON u.user = tu.username
            AND FLOOR(DATEDIFF(tu.learn_date, '2025-09-01') / 7) + 1 = w.week_number

--         WHERE u.user = '0325212810'

        GROUP BY
            u.user,
            tu.subject_code,
            w.week_number

        HAVING tu.subject_code IS NOT NULL   -- ✅ Chỉ lấy các môn thực sự học

        ORDER BY
            u.user,
            tu.subject_code,
            w.week_number
    ) uw,
    (SELECT @streak := 0, @prev_user := '', @prev_subject := '') vars
) uw
GROUP BY uw.user, uw.subject_code
ORDER BY uw.user, uw.subject_code;


-- 🟩 Tính streak học dài nhất kể từ 1/9/2025 cho user 0325212810
SELECT 
    uw.user,
    MAX(streak_length) AS longest_streak
FROM (
    SELECT 
        user,
        week_number,
        learn_status,
        -- tăng streak nếu learn_status=1, reset về 0 nếu learn_status=0
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
            u.user = '0325212810'
        GROUP BY
            u.user,
            w.week_number
        ORDER BY
            u.user,
            w.week_number
    ) uw,
    (SELECT @streak := 0) vars
) uw
GROUP BY uw.user;
