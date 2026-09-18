# 📊 2025 Sales Performance Analysis — SQL

## 📌 Project Overview

This project analyzes a company's **2025 sales performance** using MySQL.

The analysis focuses only on **Completed orders** and uses customer, product, order, and order-item data to identify the company's major revenue drivers.

The main objective is to answer practical business questions around:

* Regional sales performance
* Product performance
* Revenue contribution
* Customer performance
* Customer segmentation
* Regional product performance
* Regional customer rankings

The project demonstrates how SQL can be used to transform transaction-level data into **business-focused insights**.

---

## 🎯 Business Objective

Management wants to understand:

1. Which regions generate the most revenue?
2. Which products perform best?
3. How much revenue does each product category contribute?
4. Which customers generate the most sales?
5. How are customers distributed across value segments?
6. Which products perform best within each region?
7. Which customers are driving revenue within each region?

---

## 🗂️ Dataset Structure

The analysis uses four tables:

| Table         | Description                                                       |
| ------------- | ----------------------------------------------------------------- |
| `customers`   | Customer information including customer name and region           |
| `products`    | Product information including product name and category           |
| `orders`      | Order-level information including order date, customer and status |
| `order_items` | Product-level order details including quantity and unit price     |

### 🔗 Basic Data Relationship

```text
customers
    │
    │ customer_id
    ▼
 orders
    │
    │ order_id
    ▼
order_items
    │
    │ product_id
    ▼
products
```

---

## 📐 Revenue Calculation

Revenue is calculated at the order-item level:

```sql
quantity * unit_price
```

Only orders satisfying the following conditions are included:

```sql
status = 'Completed'
AND YEAR(order_date) = 2025
```

Therefore, all revenue metrics in this project represent **completed sales from 2025**.

---

# 🔍 Analysis Performed

## 1. Regional Sales Performance

### Business Question

How much completed sales revenue did each region generate in 2025?

### SQL Concepts Used

* `JOIN`
* `SUM()`
* `GROUP BY`
* `ORDER BY`
* `WHERE`

### Key Insight

* South generated the highest completed sales with approximately **₹94.34 lakh**.
* North followed closely with approximately **₹91.87 lakh**.
* South and North together contributed **63.12%** of total revenue.

---

## 2. Top 10 Products by Sales

### Business Question

Which products generated the highest completed sales revenue in 2025?

The analysis calculates product-level revenue and returns the top 10 products.

### SQL Concepts Used

* Multiple `JOIN`s
* `SUM()`
* `GROUP BY`
* `ORDER BY`
* `LIMIT`

### Key Insight

**Smartphone Model 93** generated the highest completed sales with approximately **₹11.92 lakh**.

---

## 3. Revenue Contribution by Product Category

### Business Question

How much revenue did each product category generate, and what percentage of total revenue did each category contribute?

A CTE is used to first calculate category-level revenue. A window function is then used to calculate each category's percentage of total revenue.

### SQL Concepts Used

* CTE
* `SUM()`
* Window Functions
* Revenue percentage calculation

### Key Insight

* **Electronics:** 63.70%
* **Accessories:** 36.30%

Electronics generated the larger share of completed 2025 revenue.

---

## 4. Regional Sales Ranking

### Business Question

What is each region's revenue and rank compared with other regions?

The analysis first aggregates revenue by region and then applies a window function to rank regions.

### SQL Concepts Used

* CTE
* `RANK()`
* Window Functions
* `ORDER BY`

### Why Use a CTE?

The CTE converts transaction-level data into a summarized dataset with one row per region.

The ranking can then be applied to this summarized result.

---

## 5. Customer Performance

### Business Question

Who are the top 10 customers based on completed sales in 2025?

Customer-level revenue is calculated and ranked using a window function.

### SQL Concepts Used

* CTE
* `JOIN`
* `SUM()`
* `RANK()`
* `LIMIT`

### Business Question

Does the highest-value customer necessarily have the highest number of orders?

### Answer

Not necessarily.

A customer can place fewer orders but purchase higher-priced products, resulting in higher total revenue.

This highlights why **revenue and order frequency are different business metrics**.

---

## 6. Product Ranking Within Category

### Business Question

Which products perform best within each product category?

Instead of ranking all products together, products are ranked separately within each category.

### SQL Concepts Used

* CTE
* `RANK()`
* `PARTITION BY`
* Window Functions

Example logic:

```sql
RANK() OVER (
    PARTITION BY category
    ORDER BY total_sales DESC
)
```

`PARTITION BY` creates a separate ranking for each category.

---

## 7. Customer Segmentation

Customers are segmented according to their completed 2025 revenue.

### Segmentation Rules

| Segment      |             Revenue |
| ------------ | ------------------: |
| High Value   |          ≥ ₹300,000 |
| Medium Value | ₹150,000 – ₹299,999 |
| Low Value    |          < ₹150,000 |

### SQL Concepts Used

* CTEs
* `CASE`
* Aggregations
* Window Functions

### Segment Analysis

The project calculates:

* Number of customers in each segment
* Total revenue generated by each segment
* Revenue contribution percentage

### Key Insights

* **Low Value:** 62.83% of total revenue
* **Medium Value:** 30.25%
* **High Value:** 6.92%

The largest share of revenue came from the broader Low Value customer segment.

> Note: "Low Value" is only a revenue-based label defined for this analysis. It does not mean that these customers are unimportant to the business.

---

## 8. Revenue Contribution by Region

### Business Question

What percentage of total company revenue did each region contribute in 2025?

### Regional Contribution

| Region | Revenue Contribution |
| ------ | -------------------: |
| South  |               31.98% |
| North  |               31.14% |
| East   |               20.11% |
| West   |               16.77% |

South and North together contributed **63.12%** of total revenue.

---

## 9. Top Product Within Each Region

### Business Question

Which product generated the highest completed revenue within each region?

The analysis:

1. Calculates product revenue by region.
2. Ranks products within each region.
3. Returns the top-ranked product.

### SQL Concepts Used

* CTEs
* `RANK()`
* `PARTITION BY`
* Multiple table joins

### Top Products by Region

| Region | Top Product         |       Sales |
| ------ | ------------------- | ----------: |
| South  | Smartphone Model 93 | ₹11.92 lakh |
| North  | Smartphone Model 83 | ₹10.68 lakh |
| East   | Laptop Model 100    | ₹10.22 lakh |
| West   | Laptop Model 90     |  ₹9.24 lakh |

The leading product differs across regions, showing that product performance is not identical across markets.

---

## 10. Regional Customer Performance

### Business Question

Which customers are driving revenue within each region?

The analysis:

1. Calculates customer revenue by region.
2. Ranks customers within each region.
3. Assigns each customer a value segment.

### SQL Concepts Used

* CTEs
* `DENSE_RANK()`
* `PARTITION BY`
* `CASE`
* Multiple table joins

### Example Findings

* East's top customer was **Customer 479**, with approximately ₹3.41 lakh in sales.
* North's top customer was **Customer 276**, with approximately ₹3.56 lakh.
* South's top customer was **Customer 166**, with approximately ₹3.97 lakh.
* West's top customer was **Customer 389**, with approximately ₹3.08 lakh.

Using `DENSE_RANK()` also allows customers with identical sales values to receive the same rank.

---

# 📊 Final Management Summary

The final analysis combines the major findings from the project.

### Regional Performance

The company generated approximately **₹2.95 crore** in completed sales during 2025.

* South generated ₹94.34 lakh.
* North generated ₹91.87 lakh.
* South and North together contributed 63.12% of total revenue.

### Product Performance

The top-performing product differed across regions:

* South → Smartphone Model 93
* North → Smartphone Model 83
* East → Laptop Model 100
* West → Laptop Model 90

### Customer Performance

The highest-revenue customers were distributed across different regions rather than being concentrated in a single region.

### Customer Segmentation

The Low Value segment generated the largest share of total revenue at 62.83%, followed by Medium Value at 30.25% and High Value at 6.92%.

### Overall Observation

The analysis shows that company revenue is influenced by multiple factors:

* Regional performance
* Product preferences by region
* Customer revenue contribution
* Customer segment distribution

This provides management with a clearer view of where revenue is coming from and which customers, products, and regions are contributing to overall sales.

---

# 🧠 SQL Skills Demonstrated

This project demonstrates practical use of:

### Core SQL

* `SELECT`
* `WHERE`
* `GROUP BY`
* `HAVING`
* `ORDER BY`
* `LIMIT`
* Aggregate Functions

### Joins

* `INNER JOIN`
* Joining multiple related tables

### Advanced SQL

* Common Table Expressions (`CTEs`)
* `CASE` statements
* Window Functions
* `RANK()`
* `DENSE_RANK()`
* `PARTITION BY`
* Revenue contribution calculations

### Business Analytics

* Revenue analysis
* Regional analysis
* Product analysis
* Customer analysis
* Customer segmentation
* Ranking analysis
* Management-level insights

---

# 🛠️ Tools Used

* **MySQL**
* SQL
* GitHub

---

# 📁 Project Structure

```text
2025-sales-performance-analysis/
│
├── README.md
├── sales_database.sql
└── sales_analysis.sql
```

### File Description

* **`sales_database.sql`** — Creates the `sales_analysis` database, tables, and generates the synthetic dataset.
* **`sales_analysis.sql`** — Contains SQL queries for sales performance and business analysis.

### 📊 Dataset

The dataset is synthetically generated using MySQL:

| Table         |  Rows |
| ------------- | ----: |
| `customers`   |   500 |
| `products`    |   100 |
| `orders`      |   600 |
| `order_items` | 1,800 |

### 🛠️ Tools

* MySQL
* SQL
* GitHub

### ▶️ How to Run

1. Run `sales_database.sql` to create and populate the database.
2. Run `sales_analysis.sql` to perform the analysis.
3. Review the query results and business insights.

### 🧠 Key SQL Concepts

`JOIN` • `GROUP BY` • `CTE` • `CASE` • `RANK()` • `DENSE_RANK()` • `Window Functions` • `PARTITION BY` • Aggregate Functions

### 🚀 Future Improvements

* Monthly sales trend analysis
* Profit & margin analysis
* Customer lifetime value
* Power BI dashboard
