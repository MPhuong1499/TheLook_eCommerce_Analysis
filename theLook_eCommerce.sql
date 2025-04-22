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

--- Average revenue per order per day of week
--- Output: day_of_week_number, day_of_week, revenue_per_order_per_day

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
daily_revenue AS (
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
  FROM bigquery-public-data.thelook_ecommerce.orders
  WHERE created_at IS NOT NULL
  AND DATE(created_at) BETWEEN '2021-05-01' AND '2022-05-01'
  )
  GROUP BY day_of_week_number, day_of_week
)
SELECT 
  odw.day_of_week_number,
  odw.day_of_week,
  ROUND(dr.revenue / odw.total_orders, 2) AS revenue_per_order_per_day
FROM orders_by_day_of_week odw
JOIN day_counts dc
  ON odw.day_of_week_number = dc.day_of_week_number
JOIN daily_revenue dr
  ON dr.day_of_week_number = dc.day_of_week_number
ORDER BY odw.day_of_week_number;

--- Average products per order per day of week
--- Output: day_of_week_number, day_of_week, avg_orders_per_day, avg_products_per_day, avg_products_per_order

WITH daily_count AS (
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
    COUNT(DISTINCT order_id) AS order_count,
    COUNT(DISTINCT product_id) AS product_count
  FROM bigquery-public-data.thelook_ecommerce.order_items
  WHERE DATE(created_at) BETWEEN '2021-05-01' AND '2022-05-01'
  GROUP BY order_date, day_of_week_number, day_of_week
),
orders_by_day_of_week AS (
  SELECT 
    day_of_week_number,
    day_of_week,
    SUM(order_count) AS total_orders,
    SUM(product_count) AS total_products
  FROM daily_count
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
  ROUND(odw.total_orders / dc.day_count, 2) AS avg_orders_per_day,
  ROUND(odw.total_products / dc.day_count, 2) AS avg_products_per_day,
  ROUND(odw.total_products /odw.total_orders, 3) AS avg_products_per_order
FROM orders_by_day_of_week odw
JOIN day_counts dc
  ON odw.day_of_week_number = dc.day_of_week_number
ORDER BY odw.day_of_week_number;

--- top 3 category selling per day of week
--- Output: day_of_week_number, day_of_week, category, product_count, total_product, ranking, avg_category_price

WITH daily_category_count AS (
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
    p.category,
    COUNT(DISTINCT product_id) AS product_count
  FROM bigquery-public-data.thelook_ecommerce.order_items oi
  JOIN bigquery-public-data.thelook_ecommerce.products p  
    ON oi.product_id = p.id
  WHERE DATE(created_at) BETWEEN '2021-05-01' AND '2022-05-01'
  GROUP BY day_of_week_number, day_of_week, p.category
),
avg_category_price AS (
SELECT
    category,
    ROUND(AVG(retail_price),2) AS avg_category_price
  FROM bigquery-public-data.thelook_ecommerce.products
  GROUP BY category
),
summary_table AS (
SELECT *,
    SUM(product_count) OVER (PARTITION BY day_of_week_number, day_of_week) AS total_product,
    ROUND(product_count / (SUM(product_count) OVER (PARTITION BY day_of_week_number, day_of_week)),3) AS product_distribution,
    RANK() OVER (PARTITION BY day_of_week_number, day_of_week ORDER BY product_count DESC) AS ranking
  FROM daily_category_count
  ORDER BY day_of_week_number, product_count DESC
)
SELECT 
    st.day_of_week_number,
    st.day_of_week,
    st.category, 
    st.product_count,
    st.total_product,
    st.ranking,
    acp.avg_category_price
  FROM summary_table st
  JOIN avg_category_price acp
    ON st.category = acp.category
  WHERE st.ranking <= 3
  ORDER BY st.day_of_week_number, st.ranking;

--- Avrage users, order per user per day of week
--- Output: day_of_week_number, day_of_week, avg_orders_per_day, avg_users_per_day, avg_oders_per_user

WITH daily_count AS (
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
    COUNT(DISTINCT order_id) AS order_count,
    COUNT(DISTINCT user_id) AS user_count
  FROM bigquery-public-data.thelook_ecommerce.orders
  WHERE DATE(created_at) BETWEEN '2021-05-01' AND '2022-05-01'
  GROUP BY order_date, day_of_week_number, day_of_week
),
orders_by_day_of_week AS (
  SELECT 
    day_of_week_number,
    day_of_week,
    SUM(order_count) AS total_orders,
    SUM(user_count) AS total_users
  FROM daily_count
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
  ROUND(odw.total_orders / dc.day_count, 2) AS avg_orders_per_day,
  ROUND(odw.total_users / dc.day_count, 2) AS avg_users_per_day,
  ROUND(odw.total_orders / odw.total_users, 2) AS avg_oders_per_user
FROM orders_by_day_of_week odw
JOIN day_counts dc
  ON odw.day_of_week_number = dc.day_of_week_number
ORDER BY odw.day_of_week_number;

--- average users by traffic source
--- output: day_of_week_number, day_of_week, traffic_source, user_count, total_user, pct_of_total

WITH daily_count AS (
  SELECT 
    EXTRACT(DAYOFWEEK FROM o.created_at) AS day_of_week_number,
    CASE EXTRACT(DAYOFWEEK FROM o.created_at)
      WHEN 1 THEN 'Sunday'
      WHEN 2 THEN 'Monday'
      WHEN 3 THEN 'Tuesday'
      WHEN 4 THEN 'Wednesday'
      WHEN 5 THEN 'Thursday'
      WHEN 6 THEN 'Friday'
      WHEN 7 THEN 'Saturday'
    END AS day_of_week,
    traffic_source,
    COUNT(DISTINCT user_id) AS user_count
  FROM bigquery-public-data.thelook_ecommerce.orders o  
  LEFT JOIN bigquery-public-data.thelook_ecommerce.users us 
    ON o.user_id = us.id       
  WHERE DATE(o.created_at) BETWEEN '2021-05-01' AND '2022-05-01'
  GROUP BY day_of_week_number, day_of_week, traffic_source
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
  dlc.day_of_week_number,
  dlc.day_of_week,
  dlc.traffic_source,
  ROUND(dlc.user_count/ day_count,2) AS user_count,
  ROUND(SUM(dlc.user_count) OVER (PARTITION BY dlc.day_of_week_number, dlc.day_of_week) / day_count,2) AS total_user,
  ROUND(100.0* dlc.user_count / (SUM(dlc.user_count) OVER (PARTITION BY dlc.day_of_week_number, dlc.day_of_week)),2) AS pct_of_total
FROM daily_count dlc
JOIN day_counts dc
  ON dlc.day_of_week_number = dc.day_of_week_number
ORDER BY dlc.day_of_week_number, user_count DESC;
