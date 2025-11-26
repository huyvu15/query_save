SELECT * from users u join tu_timelearning_2526 tu on u.code = tu.subject_code and u.learn_number = tu.session_number 
where DATE(tu.start_time) >= '2025-09-01'



--- Tinh streak: Từ '2025-09-01' có bao nhiêu tuần liên tiếp (phải liên tiếp đến tuần hiện tại), user có tổng số buổi học >=1 
-- làm sao để biết được tuần nào đến hiện tại user có số buổi 

săp xếp theo tuần học của user

-- tính số buổi học của user theo tuần as learn_week

-- Từ bảng learn_week đấy lấy ra  




---
limit 1000