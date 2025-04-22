--- Number of users and orders with completed status
--- Output: month_year, total_user, total_order
SELECT
  FORMAT_TIMESTAMP('%Y-%m', created_at) AS month_year,
  COUNT(DISTINCT user_id) AS total_user,
  COUNT(order_id) AS total_order,
FROM bigquery-public-data.thelook_ecommerce.orders
WHERE status = 'Complete'
  AND FORMAT_TIMESTAMP('%Y-%m', created_at) BETWEEN '2021-05' AND '2022-04'
GROUP BY FORMAT_TIMESTAMP('%Y-%m', created_at)
ORDER BY FORMAT_TIMESTAMP('%Y-%m', created_at);

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
  FROM bigquery-public-data.thelook_ecommerce.orders
  WHERE DATE(created_at) BETWEEN '2021-05-01' AND '2022-05-01'
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
    EXTRACT(DAYOFWEEK FROM order_date) AS day_of_week_number,
    CASE EXTRACT(DAYOFWEEK FROM order_date)
      WHEN 1 THEN 'Sunday'
      WHEN 2 THEN 'Monday'
      WHEN 3 THEN 'Tuesday'
      WHEN 4 THEN 'Wednesday'
      WHEN 5 THEN 'Thursday'
      WHEN 6 THEN 'Friday'
      WHEN 7 THEN 'Saturday'
    END AS day_of_week,
    COUNT(*) AS day_count
  FROM (SELECT DISTINCT DATE(created_at) AS order_date
  FROM bigquery-public-data.thelook_ecommerce.orders
  WHERE created_at IS NOT NULL
  AND DATE(created_at) BETWEEN '2021-05-01' AND '2022-05-01'
  )
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

--- Average revenue per day of week
--- Output: day_of_week_number, day_of_week, avg_revenue_per_day

WITH daily_revenue AS (
  SELECT 
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
    SUM(sale_price) AS revenue
  FROM bigquery-public-data.thelook_ecommerce.order_items
  WHERE DATE(created_at) BETWEEN '2021-05-01' AND '2022-05-01'
  GROUP BY day_of_week_number, day_of_week
),
day_counts AS (
  SELECT 
    EXTRACT(DAYOFWEEK FROM order_date) AS day_of_week_number,
    CASE EXTRACT(DAYOFWEEK FROM order_date)
      WHEN 1 THEN 'Sunday'
      WHEN 2 THEN 'Monday'
      WHEN 3 THEN 'Tuesday'
      WHEN 4 THEN 'Wednesday'
      WHEN 5 THEN 'Thursday'
      WHEN 6 THEN 'Friday'
      WHEN 7 THEN 'Saturday'
    END AS day_of_week,
    COUNT(*) AS day_count
  FROM (SELECT DISTINCT DATE(created_at) AS order_date
  FROM bigquery-public-data.thelook_ecommerce.order_items
  WHERE created_at IS NOT NULL
  AND DATE(created_at) BETWEEN '2021-05-01' AND '2022-05-01'
  )
  GROUP BY day_of_week_number, day_of_week
)
SELECT 
  dr.day_of_week_number,
  dr.day_of_week,
  ROUND(dr.revenue / dc.day_count, 2) AS avg_revenue_per_day
FROM daily_revenue dr
JOIN day_counts dc
  ON dr.day_of_week_number = dc.day_of_week_number
ORDER BY dr.day_of_week_number;
