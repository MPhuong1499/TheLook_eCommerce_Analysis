--- Average order per day of week
--- Output: day_of_week_number, day_of_week, avg_orders_per_day

WITH daily_orders AS (
  SELECT 
    DATE(created_at) AS order_date,
    EXTRACT(DAYOFWEEK FROM created_at) AS day_of_week_number,
    CASE EXTRACT(DAYOFWEEK FROM created_at)
      WHEN 1 THEN 'Sunday'
      WHEN 2 THEN 'Monday'
      WHEN 3 THEN 'Tuesday'
      WHEN 4 THEN 'Wednesday'
      WHEN 5 THEN 'Thursday'
      WHEN 6 THEN 'Friday'
      WHEN 7 THEN 'Saturday'
    END AS day_of_week,
    COUNT(DISTINCT order_id) AS order_count
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE created_at IS NOT NULL
  GROUP BY order_date, day_of_week_number, day_of_week
),
orders_by_day_of_week AS (
  SELECT 
    day_of_week_number,
    day_of_week,
    SUM(order_count) AS total_orders
  FROM daily_orders
  GROUP BY day_of_week_number, day_of_week
),
day_counts AS (
  SELECT 
    EXTRACT(DAYOFWEEK FROM date) AS day_of_week_number,
    CASE EXTRACT(DAYOFWEEK FROM date)
      WHEN 1 THEN 'Sunday'
      WHEN 2 THEN 'Monday'
      WHEN 3 THEN 'Tuesday'
      WHEN 4 THEN 'Wednesday'
      WHEN 5 THEN 'Thursday'
      WHEN 6 THEN 'Friday'
      WHEN 7 THEN 'Saturday'
    END AS day_of_week,
    COUNT(*) AS day_count
  FROM UNNEST(
    GENERATE_DATE_ARRAY(
      (SELECT DATE(MIN(created_at)) FROM `bigquery-public-data.thelook_ecommerce.orders`),
      (SELECT DATE(MAX(created_at)) FROM `bigquery-public-data.thelook_ecommerce.orders`)
    )
  ) AS date
  GROUP BY day_of_week_number, day_of_week
)
SELECT 
  odw.day_of_week_number,
  odw.day_of_week,
  ROUND(odw.total_orders / dc.day_count, 2) AS avg_orders_per_day
FROM orders_by_day_of_week odw
JOIN day_counts dc
  ON odw.day_of_week_number = dc.day_of_week_number
ORDER BY odw.day_of_week_number;
