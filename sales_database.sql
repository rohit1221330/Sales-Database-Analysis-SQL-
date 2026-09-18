/* ============================================================
   SALES ANALYSIS DATABASE
   ============================================================

   Project: Sales Analysis

   Purpose:
   This script creates and populates a relational sales database
   for practicing SQL-based business and financial analysis.

   Database Structure:
       customers    -> Customer master data
       products     -> Product master data
       orders       -> Order-level transactions
       order_items  -> Product-level order details

   Generated Dataset:
       Customers    : 500
       Products     : 100
       Orders       : 600
       Order Items  : 1,800

   Data is synthetically generated for analytical practice.
   ============================================================ */


/* ============================================================
   1. DATABASE SETUP
   ============================================================ */

-- Remove the existing database so the project can be
-- executed from a clean state every time.
DROP DATABASE IF EXISTS sales_analysis;

-- Create a fresh database for the sales analysis project.
CREATE DATABASE sales_analysis;

-- Set the newly created database as the active database.
USE sales_analysis;


/* ============================================================
   2. CREATE CUSTOMERS TABLE
   ============================================================

   Stores customer master information including:
   - Customer identity
   - Contact information
   - Geographic information
   - Customer segment
   - Signup date

   Primary Key:
       customer_id
   ============================================================ */

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    city VARCHAR(50),
    state VARCHAR(50),
    region VARCHAR(20),
    segment VARCHAR(20),
    signup_date DATE
);


/* ============================================================
   3. CREATE PRODUCTS TABLE
   ============================================================

   Stores product master information including:
   - Product name
   - Category and subcategory
   - Selling price
   - Cost price

   Primary Key:
       product_id

   unit_price:
       Selling price of the product.

   cost_price:
       Estimated product cost used for profitability analysis.
   ============================================================ */

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    subcategory VARCHAR(50),
    unit_price DECIMAL(10,2),
    cost_price DECIMAL(10,2)
);


/* ============================================================
   4. CREATE ORDERS TABLE
   ============================================================

   Stores order-level transaction information.

   Each order belongs to exactly one customer.

   Primary Key:
       order_id

   Foreign Key:
       customer_id -> customers.customer_id

   Order statuses:
       Completed
       Pending
       Returned
       Cancelled

   Payment methods:
       Credit Card
       UPI
       Debit Card
       Net Banking
   ============================================================ */

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE,
    status VARCHAR(20),
    payment_method VARCHAR(30),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


/* ============================================================
   5. CREATE ORDER_ITEMS TABLE
   ============================================================

   Stores individual products included within each order.

   This table creates the relationship between:
       orders <-> products

   An order can contain multiple products, and a product
   can appear in multiple orders.

   Primary Key:
       order_item_id

   Foreign Keys:
       order_id   -> orders.order_id
       product_id -> products.product_id

   quantity:
       Number of units purchased.

   unit_price:
       Selling price captured at the time of the transaction.
   ============================================================ */

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT,
    unit_price DECIMAL(10,2),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);


/* ============================================================
   6. GENERATE CUSTOMER DATA
   ============================================================

   Generates 500 synthetic customers.

   Recursive CTE:
       numbers

   Creates a sequence from 1 to 500, which is then used
   to generate customer records.

   Customer attributes such as city, region and segment
   are distributed using deterministic MOD-based logic.
   ============================================================ */

INSERT INTO customers (
    customer_id,
    customer_name,
    email,
    city,
    state,
    region,
    segment,
    signup_date
)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM numbers
    WHERE n < 500
)
SELECT
    n,

    -- Generate a unique customer name.
    CONCAT('Customer ', n),

    -- Generate a unique email address.
    CONCAT(
        'customer',
        n,
        '@example.com'
    ),

    -- Assign customers across major Indian cities.
    CASE MOD(n, 10)
        WHEN 0 THEN 'Delhi'
        WHEN 1 THEN 'Mumbai'
        WHEN 2 THEN 'Bangalore'
        WHEN 3 THEN 'Hyderabad'
        WHEN 4 THEN 'Chennai'
        WHEN 5 THEN 'Pune'
        WHEN 6 THEN 'Kolkata'
        WHEN 7 THEN 'Ahmedabad'
        WHEN 8 THEN 'Jaipur'
        ELSE 'Lucknow'
    END,

    -- Map each city to its corresponding state.
    CASE MOD(n, 10)
        WHEN 0 THEN 'Delhi'
        WHEN 1 THEN 'Maharashtra'
        WHEN 2 THEN 'Karnataka'
        WHEN 3 THEN 'Telangana'
        WHEN 4 THEN 'Tamil Nadu'
        WHEN 5 THEN 'Maharashtra'
        WHEN 6 THEN 'West Bengal'
        WHEN 7 THEN 'Gujarat'
        WHEN 8 THEN 'Rajasthan'
        ELSE 'Uttar Pradesh'
    END,

    -- Distribute customers across four geographic regions.
    CASE MOD(n, 4)
        WHEN 0 THEN 'North'
        WHEN 1 THEN 'West'
        WHEN 2 THEN 'South'
        ELSE 'East'
    END,

    -- Distribute customers across business segments.
    CASE MOD(n, 3)
        WHEN 0 THEN 'Consumer'
        WHEN 1 THEN 'SMB'
        ELSE 'Enterprise'
    END,

    -- Generate signup dates across approximately 1,000 days.
    DATE_ADD(
        '2022-01-01',
        INTERVAL MOD(n * 17, 1000) DAY
    )

FROM numbers;


/* ============================================================
   7. GENERATE PRODUCT DATA
   ============================================================

   Generates 100 synthetic products.

   Product types:
       Laptop
       Monitor
       Keyboard
       Smartphone
       Headphones

   Pricing:
       unit_price -> Selling price
       cost_price -> Estimated cost based on a percentage
                     of the selling price

   The generated pricing allows later analysis of:
       Revenue
       Gross Profit
       Gross Margin
       Product profitability
   ============================================================ */

INSERT INTO products (
    product_id,
    product_name,
    category,
    subcategory,
    unit_price,
    cost_price
)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM numbers
    WHERE n < 100
)
SELECT
    n,

    -- Generate product names using five product types.
    CONCAT(
        CASE MOD(n, 5)
            WHEN 0 THEN 'Laptop'
            WHEN 1 THEN 'Monitor'
            WHEN 2 THEN 'Keyboard'
            WHEN 3 THEN 'Smartphone'
            ELSE 'Headphones'
        END,
        ' Model ',
        n
    ),

    -- Assign product categories.
    CASE MOD(n, 5)
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Electronics'
        WHEN 2 THEN 'Accessories'
        WHEN 3 THEN 'Electronics'
        ELSE 'Accessories'
    END,

    -- Assign product subcategories.
    CASE MOD(n, 5)
        WHEN 0 THEN 'Computers'
        WHEN 1 THEN 'Displays'
        WHEN 2 THEN 'Peripherals'
        WHEN 3 THEN 'Mobile'
        ELSE 'Audio'
    END,

    -- Generate selling prices between approximately 500 and 95,500.
    ROUND(
        500 + MOD(n * 137, 95000),
        2
    ),

    -- Generate estimated product cost as 55%–69% of selling price.
    ROUND(
        (500 + MOD(n * 137, 95000))
        * (0.55 + MOD(n, 15) / 100),
        2
    )

FROM numbers;


/* ============================================================
   8. GENERATE ORDER DATA
   ============================================================

   Generates 600 synthetic orders.

   Customer assignment:
       Each order is mapped to one of the 500 customers.

   Order dates:
       Distributed across the 2025 calendar year.

   Status distribution:
       Completed
       Pending
       Returned
       Cancelled

   The data intentionally contains multiple order statuses
   so that later analysis can distinguish between completed
   sales and non-completed transactions.
   ============================================================ */

INSERT INTO orders (
    order_id,
    customer_id,
    order_date,
    status,
    payment_method
)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM numbers
    WHERE n < 600
)
SELECT
    n,

    -- Map each order to one of the 500 customers.
    1 + MOD(n * 37, 500),

    -- Generate order dates across the 2025 calendar year.
    DATE_ADD(
        '2025-01-01',
        INTERVAL MOD(n * 19, 365) DAY
    ),

    -- Generate realistic order statuses.
    CASE MOD(n, 10)
        WHEN 0 THEN 'Cancelled'
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Returned'
        ELSE 'Completed'
    END,

    -- Generate payment methods.
    CASE MOD(n, 4)
        WHEN 0 THEN 'Credit Card'
        WHEN 1 THEN 'UPI'
        WHEN 2 THEN 'Debit Card'
        ELSE 'Net Banking'
    END

FROM numbers;


/* ============================================================
   9. INCREASE RECURSIVE CTE LIMIT
   ============================================================

   MySQL's default recursive CTE limit is 1,000 iterations.

   order_items requires 1,800 generated rows, so the session
   limit is increased before running the recursive CTE.

   This affects only the current database session.
   ============================================================ */

SET SESSION cte_max_recursion_depth = 2000;


/* ============================================================
   10. GENERATE ORDER ITEM DATA
   ============================================================

   Generates 1,800 order-item records across 600 orders.

   Relationship:
       orders 1 ---- many order_items
       products 1 ---- many order_items

   Each order item contains:
       - Order ID
       - Product ID
       - Quantity
       - Transaction unit price

   The unit price is retrieved directly from the products
   table to maintain consistency with the product master data.

   Average order items:
       1,800 items / 600 orders = 3 items per order
   ============================================================ */

INSERT INTO order_items (
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price
)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM numbers
    WHERE n < 1800
)
SELECT
    n,

    -- Distribute order items across the 600 orders.
    1 + MOD(n * 17, 600),

    -- Distribute products across the 100-product catalogue.
    1 + MOD(n * 31, 100),

    -- Generate quantities between 1 and 5 units.
    1 + MOD(n * 7, 5),

    -- Pull the product's selling price from the products table.
    p.unit_price

FROM numbers

JOIN products p
    ON p.product_id = 1 + MOD(n * 31, 100);


/* ============================================================
   11. DATA VALIDATION
   ============================================================

   Optional checks to confirm that the dataset was populated
   correctly before beginning analysis.
   ============================================================ */

-- Check customer count.
SELECT COUNT(*) AS total_customers
FROM customers;

-- Check product count.
SELECT COUNT(*) AS total_products
FROM products;

-- Check order count.
SELECT COUNT(*) AS total_orders
FROM orders;

-- Check order-item count.
SELECT COUNT(*) AS total_order_items
FROM order_items;


/* ============================================================
   END OF DATA GENERATION SCRIPT
   ============================================================ */