/*
===============================================================================
PROJECT: 2025 SALES PERFORMANCE ANALYSIS
DATABASE: Sales Database
SQL DIALECT: MySQL

OBJECTIVE
---------
Analyze completed sales transactions from 2025 to identify:
1. Regional sales performance
2. Top-performing products
3. Revenue contribution by category
4. Regional and customer rankings
5. Customer segmentation
6. Regional product performance
7. Key revenue drivers

BUSINESS SCOPE
--------------
- Only orders with status = 'Completed'
- Analysis year = 2025
- Revenue = quantity * unit_price

TABLES USED
-----------
customers     : Customer master data
products      : Product master data
orders        : Order-level transaction data
order_items   : Product-level order details

KEY SQL CONCEPTS
----------------
- INNER JOIN
- GROUP BY
- CTEs
- CASE statements
- Aggregate functions
- Window functions
- RANK() / DENSE_RANK()
- PARTITION BY
- Revenue contribution calculations
===============================================================================
*/


/*
===============================================================================
DATA PREVIEW
===============================================================================
Purpose: Quickly inspect the main tables before starting the analysis.
===============================================================================
*/

SELECT *
FROM customers
LIMIT 10;

SELECT *
FROM products
LIMIT 10;

SELECT *
FROM orders
LIMIT 10;

SELECT *
FROM order_items
LIMIT 10;


/*
===============================================================================
TASK 1: REGIONAL SALES PERFORMANCE
===============================================================================

Business Question:
How much completed sales revenue did each region generate in 2025?

Logic:
Revenue = quantity * unit_price

Only completed orders from 2025 are included.
===============================================================================
*/

SELECT
    c.region,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
  AND YEAR(o.order_date) = 2025
GROUP BY c.region
ORDER BY total_sales DESC;

/*
Business Insight:
South generated the highest completed sales in 2025,
with total sales of ₹94,33,620.
*/


/*
===============================================================================
TASK 2: TOP 10 PRODUCTS BY SALES
===============================================================================

Business Question:
Which products generated the highest completed sales revenue in 2025?

Output:
- Product name
- Product category
- Total sales

The result is limited to the top 10 products.
===============================================================================
*/

SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM products AS p
JOIN order_items AS oi
    ON oi.product_id = p.product_id
JOIN orders AS o
    ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
  AND YEAR(o.order_date) = 2025
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY total_sales DESC
LIMIT 10;

/*
Business Insight:
Smartphone Model 93 generated the highest completed sales in 2025,
with sales of ₹11,91,690.
*/


/*
===============================================================================
TASK 3: REVENUE CONTRIBUTION BY PRODUCT CATEGORY
===============================================================================

Business Question:
How much completed revenue did each product category generate in 2025,
and what percentage of total revenue came from each category?

Approach:
1. Aggregate revenue by category using a CTE.
2. Calculate each category's percentage of total revenue
   using a window function.
===============================================================================
*/

WITH category_revenue AS (
    SELECT
        p.category,
        SUM(oi.quantity * oi.unit_price) AS category_wise_sales
    FROM products AS p
    JOIN order_items AS oi
        ON oi.product_id = p.product_id
    JOIN orders AS o
        ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
      AND YEAR(o.order_date) = 2025
    GROUP BY p.category
)

SELECT
    category,
    category_wise_sales,
    ROUND(
        (category_wise_sales / SUM(category_wise_sales) OVER ()) * 100,
        2
    ) AS revenue_percentage
FROM category_revenue
ORDER BY category_wise_sales DESC;

/*
Business Insight:
Electronics contributed 63.70% of completed 2025 revenue,
while Accessories contributed 36.30%.
*/


/*
===============================================================================
TASK 4: REGIONAL SALES RANKING
===============================================================================

Business Question:
What is each region's completed 2025 revenue and its rank compared
with other regions?

Approach:
1. Calculate total revenue for each region.
2. Rank regions based on total revenue using RANK().
===============================================================================
*/

WITH region_revenue AS (
    SELECT
        c.region,
        SUM(oi.quantity * oi.unit_price) AS total_sales
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
      AND YEAR(o.order_date) = 2025
    GROUP BY c.region
)

SELECT
    region,
    total_sales,
    RANK() OVER (
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM region_revenue
ORDER BY sales_rank;

/*
Why a CTE is useful:
The CTE first converts transaction-level data into one row per region.
The ranking logic can then be applied to this summarized result.
*/


/*
===============================================================================
TASK 5: TOP 10 CUSTOMERS BY SALES
===============================================================================

Business Question:
Who are the top 10 customers based on completed sales in 2025?

Additional Business Question:
Does the highest-value customer necessarily have the highest number
of orders?

Answer:
Not necessarily. A customer can place fewer orders but purchase
higher-priced products, resulting in higher total revenue.
===============================================================================
*/

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.region,
        SUM(oi.quantity * oi.unit_price) AS total_sales
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
      AND YEAR(o.order_date) = 2025
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.region
)

SELECT
    customer_name,
    region,
    total_sales,
    RANK() OVER (
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM customer_revenue
ORDER BY total_sales DESC
LIMIT 10;


/*
===============================================================================
TASK 6: PRODUCT RANKING WITHIN EACH CATEGORY
===============================================================================

Business Question:
Within each product category, which products performed best
based on completed sales in 2025?

Approach:
- Calculate product-level revenue.
- Use RANK() with PARTITION BY category.
- Each category gets its own ranking.
===============================================================================
*/

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS total_sales
    FROM products AS p
    JOIN order_items AS oi
        ON oi.product_id = p.product_id
    JOIN orders AS o
        ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
      AND YEAR(o.order_date) = 2025
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
)

SELECT
    product_name,
    category,
    total_sales,
    RANK() OVER (
        PARTITION BY category
        ORDER BY total_sales DESC
    ) AS category_rank
FROM product_revenue
ORDER BY
    category,
    category_rank;


/*
===============================================================================
TASK 7: CUSTOMER SEGMENTATION
===============================================================================

Business Question:
Classify customers based on their completed 2025 revenue.

Segmentation Rules:
- High Value   : Revenue >= ₹300,000
- Medium Value : Revenue >= ₹150,000 and < ₹300,000
- Low Value    : Revenue < ₹150,000

Part A:
Assign a segment to every customer.

Part B:
Summarize each segment by:
- Number of customers
- Total revenue
- Revenue contribution percentage
===============================================================================
*/


/* ---------------------------------------------------------------------------
PART A: CUSTOMER-LEVEL SEGMENTATION
--------------------------------------------------------------------------- */

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.unit_price) AS total_sales
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
      AND YEAR(o.order_date) = 2025
    GROUP BY
        c.customer_id,
        c.customer_name
)

SELECT
    customer_name,
    total_sales,
    CASE
        WHEN total_sales >= 300000 THEN 'High Value'
        WHEN total_sales >= 150000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_revenue;


/* ---------------------------------------------------------------------------
PART B: SEGMENT SUMMARY
--------------------------------------------------------------------------- */

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.unit_price) AS total_sales
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
      AND YEAR(o.order_date) = 2025
    GROUP BY
        c.customer_id,
        c.customer_name
),

customer_segments AS (
    SELECT
        customer_id,
        customer_name,
        total_sales,
        CASE
            WHEN total_sales >= 300000 THEN 'High Value'
            WHEN total_sales >= 150000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM customer_revenue
),

segment_revenue AS (
    SELECT
        customer_segment,
        COUNT(*) AS customer_count,
        SUM(total_sales) AS total_revenue
    FROM customer_segments
    GROUP BY customer_segment
)

SELECT
    customer_segment,
    customer_count,
    total_revenue,
    ROUND(
        (total_revenue / SUM(total_revenue) OVER ()) * 100,
        2
    ) AS revenue_percentage
FROM segment_revenue
ORDER BY total_revenue DESC;

/*
Business Insights:
- Low Value customers generated the largest share of revenue at 62.83%.
- Medium Value customers contributed 30.25% of total revenue.
- High Value customers contributed 6.92% of total revenue.
- The largest revenue contribution came from the broader Low Value
  customer base rather than only from High Value customers.

Important:
"Low Value" is a revenue-based segment label defined for this analysis.
It does not mean that these customers are unimportant to the business.
*/


/*
===============================================================================
TASK 8: REVENUE CONTRIBUTION BY REGION
===============================================================================

Business Question:
What percentage of total company revenue did each region contribute
in 2025?

Approach:
1. Calculate revenue for each region.
2. Divide regional revenue by total regional revenue.
===============================================================================
*/

WITH region_revenue AS (
    SELECT
        c.region,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
      AND YEAR(o.order_date) = 2025
    GROUP BY c.region
)

SELECT
    region,
    total_revenue,
    ROUND(
        (total_revenue / SUM(total_revenue) OVER ()) * 100,
        2
    ) AS revenue_percentage
FROM region_revenue
ORDER BY total_revenue DESC;

/*
Business Insights:
- South contributed 31.98% of total revenue.
- North contributed 31.14%.
- East contributed 20.11%.
- West contributed 16.77%.
- South and North together contributed 63.12% of total revenue.
*/


/*
===============================================================================
TASK 8B: TOP-PERFORMING PRODUCT WITHIN EACH REGION
===============================================================================

Business Question:
Within each region, which product generated the highest completed
revenue in 2025?

Approach:
1. Calculate product revenue by region.
2. Rank products within each region.
3. Return products with rank = 1.

RANK() is used so that tied products can both appear.
===============================================================================
*/

WITH product_revenue AS (
    SELECT
        c.region,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    JOIN products AS p
        ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
      AND YEAR(o.order_date) = 2025
    GROUP BY
        c.region,
        p.product_id,
        p.product_name
),

ranked_products AS (
    SELECT
        region,
        product_name,
        total_revenue,
        RANK() OVER (
            PARTITION BY region
            ORDER BY total_revenue DESC
        ) AS region_rank
    FROM product_revenue
)

SELECT
    region,
    product_name,
    total_revenue,
    region_rank
FROM ranked_products
WHERE region_rank = 1
ORDER BY region;


/*
===============================================================================
TASK 9: REGIONAL CUSTOMER PERFORMANCE
===============================================================================

Business Question:
Which customers are driving revenue within each region?

Output:
- Region
- Customer
- Total sales
- Customer rank within region
- Customer segment

Approach:
1. Calculate customer revenue by region.
2. Rank customers within each region using DENSE_RANK().
3. Assign a revenue-based customer segment.
===============================================================================
*/

WITH customer_revenue AS (
    SELECT
        c.region,
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.unit_price) AS total_sales
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
      AND YEAR(o.order_date) = 2025
    GROUP BY
        c.region,
        c.customer_id,
        c.customer_name
),

ranked_customers AS (
    SELECT
        region,
        customer_id,
        customer_name,
        total_sales,
        DENSE_RANK() OVER (
            PARTITION BY region
            ORDER BY total_sales DESC
        ) AS customer_rank
    FROM customer_revenue
),

segmented_customers AS (
    SELECT
        region,
        customer_id,
        customer_name,
        total_sales,
        customer_rank,
        CASE
            WHEN total_sales >= 300000 THEN 'High Value'
            WHEN total_sales >= 150000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM ranked_customers
)

SELECT
    region,
    customer_name,
    total_sales,
    customer_rank,
    customer_segment
FROM segmented_customers
ORDER BY
    region,
    customer_rank;

/*
Business Insights:
- East has a High Value customer at the top, Customer 479,
  with ₹3,40,800 in sales.
- North has multiple High Value customers among the top positions.
- Many customers across the regions fall into the Low Value segment.
- Equal sales values can produce the same rank when DENSE_RANK() is used.
*/


/*
===============================================================================
TASK 10: FINAL 2025 SALES PERFORMANCE REPORT
===============================================================================

Management Request:
Create a consolidated analysis covering the company's major revenue drivers.

The report contains:
1. Regional Performance
2. Top Product in Each Region
3. Top 3 Customers in Each Region

All calculations are based on completed orders from 2025.
===============================================================================
*/


/* ---------------------------------------------------------------------------
10.1 REGIONAL PERFORMANCE
---------------------------------------------------------------------------

Output:
- Region
- Total revenue
- Revenue percentage
- Region rank
--------------------------------------------------------------------------- */

WITH region_revenue AS (
    SELECT
        c.region,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
      AND YEAR(o.order_date) = 2025
    GROUP BY c.region
),

ranked_regions AS (
    SELECT
        region,
        total_revenue,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS region_rank
    FROM region_revenue
)

SELECT
    region,
    total_revenue,
    ROUND(
        (total_revenue / SUM(total_revenue) OVER ()) * 100,
        2
    ) AS revenue_percentage,
    region_rank
FROM ranked_regions
ORDER BY region_rank;


/* ---------------------------------------------------------------------------
10.2 TOP PRODUCT IN EACH REGION
---------------------------------------------------------------------------

Output:
- Region
- Product
- Product sales
- Product rank

Only the top-ranked product(s) from each region are returned.
--------------------------------------------------------------------------- */

WITH product_revenue AS (
    SELECT
        c.region,
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS product_sales
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    JOIN products AS p
        ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
      AND YEAR(o.order_date) = 2025
    GROUP BY
        c.region,
        p.product_id,
        p.product_name
),

ranked_products AS (
    SELECT
        region,
        product_name,
        product_sales,
        RANK() OVER (
            PARTITION BY region
            ORDER BY product_sales DESC
        ) AS product_rank
    FROM product_revenue
)

SELECT
    region,
    product_name,
    product_sales,
    product_rank
FROM ranked_products
WHERE product_rank = 1
ORDER BY region;


/* ---------------------------------------------------------------------------
10.3 TOP 3 CUSTOMERS IN EACH REGION
---------------------------------------------------------------------------

Output:
- Region
- Customer
- Customer sales
- Customer rank
- Customer segment

DENSE_RANK() is used so customers with the same sales receive the same rank.
--------------------------------------------------------------------------- */

WITH customer_revenue AS (
    SELECT
        c.region,
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.unit_price) AS customer_sales
    FROM customers AS c
    JOIN orders AS o
        ON o.customer_id = c.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
      AND YEAR(o.order_date) = 2025
    GROUP BY
        c.region,
        c.customer_id,
        c.customer_name
),

ranked_customers AS (
    SELECT
        region,
        customer_id,
        customer_name,
        customer_sales,
        DENSE_RANK() OVER (
            PARTITION BY region
            ORDER BY customer_sales DESC
        ) AS customer_rank
    FROM customer_revenue
),

segmented_customers AS (
    SELECT
        region,
        customer_id,
        customer_name,
        customer_sales,
        customer_rank,
        CASE
            WHEN customer_sales >= 300000 THEN 'High Value'
            WHEN customer_sales >= 150000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM ranked_customers
)

SELECT
    region,
    customer_name,
    customer_sales,
    customer_rank,
    customer_segment
FROM segmented_customers
WHERE customer_rank <= 3
ORDER BY
    region,
    customer_rank;


/*
===============================================================================
MANAGEMENT SUMMARY — 2025 SALES PERFORMANCE
===============================================================================

1. REGIONAL PERFORMANCE
-----------------------
- South generated ₹94.34 lakh and contributed 31.98% of total revenue.
- North generated ₹91.87 lakh and contributed 31.14%.
- South and North together contributed 63.12% of total revenue.

2. PRODUCT PERFORMANCE
----------------------
Top products varied by region:
- South : Smartphone Model 93 — ₹11.92 lakh
- North : Smartphone Model 83 — ₹10.68 lakh
- East  : Laptop Model 100   — ₹10.22 lakh
- West  : Laptop Model 90    — ₹9.24 lakh

This indicates that product performance differs across regions.

3. CUSTOMER PERFORMANCE
-----------------------
Highest-value customers identified in each region:
- East  : Customer 479 — ₹3.41 lakh
- North : Customer 276 — ₹3.56 lakh
- South : Customer 166 — ₹3.97 lakh
- West  : Customer 389 — ₹3.08 lakh

Revenue is distributed across customers in multiple regions.

4. CUSTOMER SEGMENTS
--------------------
Based on the defined revenue thresholds:
- Low Value    : 62.83% of total revenue
- Medium Value : 30.25%
- High Value   : 6.92%

The largest share of revenue came from the broader Low Value
customer segment.

5. OVERALL OBSERVATION
----------------------
The company generated approximately ₹2.95 crore in completed
2025 sales. Revenue was concentrated in the South and North regions,
while the leading product varied by region. Customer revenue was
distributed across multiple customer groups rather than being
generated only by High Value customers.

===============================================================================
END OF ANALYSIS
===============================================================================