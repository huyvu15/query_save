-------- Main
SELECT 
  a.week_index AS week_n,
  a.subject_code,
  DATE_ADD('2025-09-01', INTERVAL a.week_index * 7 DAY) AS week_start,
  DATE_ADD('2025-09-01', INTERVAL a.week_index * 7 + 6 DAY) AS week_end,
  COUNT(DISTINCT a.username) AS N_n,
  COUNT(DISTINCT b.username) AS N_n_plus_1,
  ROUND(
    100 * (1 - COUNT(DISTINCT b.username) / NULLIF(COUNT(DISTINCT a.username), 0)),
    2
  ) AS dropoff_percent
FROM (
  -- Danh sách học sinh active mỗi tuần và mỗi môn
  SELECT 
    tt.username,
    tt.subject_code,
    FLOOR(DATEDIFF(DATE(tt.start_time), '2025-09-01') / 7) AS week_index
  FROM tu_report_timelearning_2526 tt
  WHERE tt.start_time >= '2025-09-01'
    AND tt.learn_date IS NOT NULL
  GROUP BY tt.username, tt.subject_code, week_index
) a
LEFT JOIN (
  -- Danh sách học sinh active tuần kế tiếp và cùng môn
  SELECT 
    tt.username,
    tt.subject_code,
    FLOOR(DATEDIFF(DATE(tt.start_time), '2025-09-01') / 7) AS week_index
  FROM tu_report_timelearning_2526 tt
  WHERE tt.start_time >= '2025-09-01'
    AND tt.learn_date IS NOT NULL
  GROUP BY tt.username, tt.subject_code, week_index
) b
  ON a.username = b.username
  AND a.subject_code = b.subject_code
  AND b.week_index = a.week_index + 1
GROUP BY a.week_index, a.subject_code
ORDER BY a.week_index, a.subject_code;



-------- Cho tu_timelearning_2526
SELECT 
  a.week_index AS week_n,
  DATE_ADD('2025-09-01', INTERVAL a.week_index * 7 DAY) AS week_start,
  DATE_ADD('2025-09-01', INTERVAL a.week_index * 7 + 6 DAY) AS week_end,
  COUNT(DISTINCT a.username) AS N_n,
  COUNT(DISTINCT b.username) AS N_n_plus_1,
  ROUND(100 * (1 - COUNT(DISTINCT b.username) / COUNT(DISTINCT a.username)), 2) AS dropoff_percent
FROM (
  -- Danh sách học sinh active mỗi tuần (≥5 phút)
  SELECT 
    tt.username,
    FLOOR(DATEDIFF(DATE(tt.start_time), '2025-09-01') / 7) AS week_index
  FROM tu_timelearning_2526 tt
  WHERE tt.start_time >= '2025-09-01'
    AND tt.total_minutes >= 5
  GROUP BY tt.username, week_index
) a   
LEFT JOIN (
  -- Danh sách học sinh active tuần kế tiếp
  SELECT 
    tt.username,
    FLOOR(DATEDIFF(DATE(tt.start_time), '2025-09-01') / 7) AS week_index
  FROM tu_timelearning_2526 tt   
  WHERE tt.start_time >= '2025-09-01'
    AND tt.total_minutes >= 5
  GROUP BY tt.username, week_index
) b
  ON a.username = b.username
 AND b.week_index = a.week_index + 1
GROUP BY a.week_index
ORDER BY a.week_index;


------- Cho tu_report_timelearning_2526 -------
SELECT 
  a.week_index AS week_n,
  DATE_ADD('2025-09-01', INTERVAL a.week_index * 7 DAY) AS week_start,
  DATE_ADD('2025-09-01', INTERVAL a.week_index * 7 + 6 DAY) AS week_end,
  COUNT(DISTINCT a.user) AS N_n,
  COUNT(DISTINCT b.user) AS N_n_plus_1,
  ROUND(
    100 * (1 - COUNT(DISTINCT b.user) / NULLIF(COUNT(DISTINCT a.user), 0)),
    2
  ) AS dropoff_percent
FROM (
  -- Danh sách học sinh active mỗi tuần (chỉ cần có learn_date)
  SELECT 
    tt.username,
    FLOOR(DATEDIFF(DATE(tt.start_time), '2025-09-01') / 7) AS week_index
  FROM tu_report_timelearning_2526 tt
  WHERE tt.start_time >= '2025-09-01'
    AND tt.learn_date IS NOT NULL
  GROUP BY tt.username, week_index
) a
LEFT JOIN (
  -- Danh sách học sinh active tuần kế tiếp
  SELECT 
    tt.username,
    FLOOR(DATEDIFF(DATE(tt.start_time), '2025-09-01') / 7) AS week_index
  FROM tu_report_timelearning_2526 tt
  WHERE tt.start_time >= '2025-09-01'
    AND tt.learn_date IS NOT NULL
  GROUP BY tt.username, week_index
) b
  ON a.user = b.user
  AND b.week_index = a.week_index + 1
GROUP BY a.week_index
ORDER BY a.week_index;
