SELECT
--   uw.user_id,
  uw.username,
--   uw.email,
--   uw.name,
  uw.code,
  uw.learn_number,
  uw.islearn,
--   uw.phone,
  uw.week_index,
  uw.total_duration_attended,
  prev.total_duration_attended AS prev_total_duration_attended,
  ROUND(
    CASE
      WHEN prev.total_duration_attended IS NULL OR prev.total_duration_attended = 0 THEN NULL
      ELSE abs(uw.total_duration_attended - prev.total_duration_attended)
    END
  , 2) AS delta_change
FROM (
  -- tổng phút học của mỗi user theo tuần (tuần bắt đầu từ 2025-09-01)
  SELECT
    u.id AS user_id,
    u.user AS username,
    -- u.email,
    u.name,
    u.code,
    u.learn_number,
    u.islearn,
    u.phone,
    FLOOR(DATEDIFF(DATE(tt.start_time), '2025-09-01') / 7) + 1 AS week_index,
    SUM(tt.total_minutes) AS total_duration_attended
  FROM users u
  JOIN tu_timelearning_2526 tt
    ON u.user = tt.username
  WHERE tt.start_time >= '2025-09-01'
  GROUP BY
    u.id, u.user, u.email, u.name, u.code, u.learn_number, u.islearn, u.phone,
    week_index
) AS uw
LEFT JOIN (
  -- bản ghi tuần trước (để so sánh)
  SELECT
    u.id AS user_id,
    FLOOR(DATEDIFF(DATE(tt.start_time), '2025-09-01') / 7) + 1 AS week_index,
    SUM(tt.total_minutes) AS total_duration_attended
  FROM users u
  JOIN tu_timelearning_2526 tt
    ON u.user = tt.username
  WHERE tt.start_time >= '2025-09-01'
  GROUP BY u.id, week_index
) AS prev
  ON uw.user_id = prev.user_id
 AND uw.week_index = prev.week_index + 1
ORDER BY uw.user_id, uw.week_index;
