# TheLook_eCommerce_Analysis
# Customer Retention and Segmentation Analysis for TheLook eCommerce

## Overview
This project analyzes customer behavior for TheLook eCommerce using cohort analysis and RFM segmentation to improve retention and revenue. The dataset is sourced from `bigquery-public-data.thelook_ecommerce`.

## Objective
- Identify retention trends using cohort analysis.
- Segment users with RFM (Recency, Frequency, Monetary) analysis.
- Provide actionable recommendations to reduce churn and increase customer lifetime value (LTV).

## Dataset
- **Source**: `bigquery-public-data.thelook_ecommerce`
- **Tables Used**: `orders`, `order_items`, `products`, `users`
- **Time Range**: May 2021 to April 2022

## Methodology
1. **Cohort Analysis**: Calculated user and revenue retention over 12 months.
2. **RFM Segmentation**: Segmented users into 11 categories (e.g., Champions, At Risk) based on Recency, Frequency, and Monetary scores.

## Key Findings
- **Cohort Analysis**: 94-97% churn after the first month, with stable 1-3% long-term retention. Seasonal spikes in February 2022.
- **RFM Segmentation**: 55% of users are disengaged ("At Risk," "Hibernating," "Lost"), while 14.4% are loyal ("Champions," "Loyal Customers").

## Visualizations
- **Cohort Retention Heatmap**: [Link to Google Data Studio]
- **RFM Segment Pie Chart**: [See `visualizations/rfm_pie_chart.png`]

## Recommendations
- Re-engage "At Risk" users with personalized offers to improve `t2` retention.
- Nurture "Potential Loyalists" with loyalty programs.
- Leverage seasonal trends to maximize revenue from "Champions."

## Tools Used
- BigQuery (SQL)
- Google Sheet (visualizations)
- GitHub (project hosting)

## How to Run
1. Set up BigQuery access with the `thelook_ecommerce` dataset.
2. Run the SQL scripts in `queries/` to generate cohort and RFM tables.
3. Use `visualizations/visualize.py` to create charts.

## Files
- `queries/cohort_analysis.sql`: Cohort analysis query.
- `queries/rfm_segmentation.sql`: RFM segmentation query.
- `visualizations/visualize.py`: Python script for visualizations.

## Learnings
- Optimized SQL queries for large datasets using `CROSS JOIN`.
- Gained insights into customer retention strategies using cohort and RFM analysis.
