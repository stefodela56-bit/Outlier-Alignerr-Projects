-- Rolling 7-day active users per giorno
WITH daily AS (
  SELECT user_id, CAST(event_time AS DATE) AS d
  FROM events
  WHERE event_name = 'login'
),
dau AS (
  SELECT d, COUNT(DISTINCT user_id) AS dau
  FROM daily
  GROUP BY d
)
SELECT
  d,
  SUM(dau) OVER (ORDER BY d ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS dau_7d
FROM dau
ORDER BY d;

-- Top-K per categoria con window
SELECT *
FROM (
  SELECT
    category,
    item_id,
    revenue,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rk
  FROM item_revenue
) t
WHERE rk <= 5
ORDER BY category, rk;

-- Cohort retention (mesi 0..6)
WITH first_seen AS (
  SELECT user_id, DATE_TRUNC('month', MIN(event_time)) AS cohort
  FROM events
  GROUP BY 1
),
monthly_active AS (
  SELECT user_id, DATE_TRUNC('month', event_time) AS m
  FROM events
  GROUP BY 1,2
)
SELECT
  fs.cohort,
  EXTRACT(MONTH FROM AGE(ma.m, fs.cohort)) AS month_index,
  COUNT(DISTINCT ma.user_id) AS active_users
FROM first_seen fs
JOIN monthly_active ma USING(user_id)
WHERE ma.m BETWEEN fs.cohort AND fs.cohort + INTERVAL '6 months'
GROUP BY fs.cohort, month_index
ORDER BY fs.cohort, month_index;
