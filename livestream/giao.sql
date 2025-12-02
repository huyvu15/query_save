WITH base AS (
    SELECT username, "Source"
    FROM sheet_data
    WHERE "Source" IN ('livestream', 'Data chỉ livestream', 'Data trừ livestream')
),
-- Livestream ∩ VOD: User phải xuất hiện trên cả Livestream và VOD
livestream_and_vod AS (
    SELECT DISTINCT username
    FROM base
    WHERE "Source" = 'livestream'
    AND username IN (SELECT username FROM base WHERE "Source" = 'Data trừ livestream')
),
-- Livestream ∩ Chỉ học livestream: User phải xuất hiện trên cả Livestream và Chỉ học livestream
livestream_and_only_live AS (
    SELECT DISTINCT username
    FROM base
    WHERE "Source" = 'livestream'
    AND username IN (SELECT username FROM base WHERE "Source" = 'Data chỉ livestream')
),
-- Data trừ livestream ∩ Chỉ học livestream: User phải xuất hiện trên cả VOD và Chỉ học livestream
vod_and_only_live AS (
    SELECT DISTINCT username
    FROM base
    WHERE "Source" = 'Data trừ livestream'
    AND username IN (SELECT username FROM base WHERE "Source" = 'Data chỉ livestream')
),
-- Livestream ∩ Data trừ livestream ∩ Chỉ học livestream: User phải xuất hiện trên cả 3 nền tảng
intersection_3 AS (
    SELECT DISTINCT username
    FROM base
    WHERE "Source" = 'livestream'
    AND username IN (SELECT username FROM base WHERE "Source" = 'Data trừ livestream')
    AND username IN (SELECT username FROM base WHERE "Source" = 'Data chỉ livestream')
)
SELECT 
    -- Giao Livestream và VOD
    (SELECT COUNT(DISTINCT username) FROM livestream_and_vod) AS livestream_and_vod,
    -- Giao Livestream và Chỉ học livestream
    (SELECT COUNT(DISTINCT username) FROM livestream_and_only_live) AS livestream_and_only_live,
    -- Giao VOD và Chỉ học livestream
    (SELECT COUNT(DISTINCT username) FROM vod_and_only_live) AS vod_and_only_live,
    -- Giao 3 nền tảng
    (SELECT COUNT(DISTINCT username) FROM intersection_3) AS intersection_3;
