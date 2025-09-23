-- Cohort retention example
SELECT
    user_id,
    MIN(DATE_TRUNC('month', signup_date)) AS cohort_month,
    DATE_TRUNC('month', activity_date) AS active_month,
    COUNT(*) AS activity_count
FROM user_activity
GROUP BY user_id, cohort_month, active_month
ORDER BY cohort_month, active_month;
