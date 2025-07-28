

# SQL Interview Prep Notes

## 1. Find the Second Highest Salary

```sql
SELECT MAX(salary) 
FROM employee 
WHERE salary < (SELECT MAX(salary) FROM employee);
```

## 2. Types of SQL JOINs with Examples

* **INNER JOIN**: Returns only rows with matching values in both tables.

```sql
SELECT *
FROM employees e
INNER JOIN departments d ON e.dept_id = d.id;
```

* **LEFT JOIN**: Returns all rows from the left table and matched rows from the right.

```sql
SELECT *
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.id;
```

* **RIGHT JOIN**: Returns all rows from the right table and matched rows from the left.

```sql
SELECT *
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.id;
```

* **FULL OUTER JOIN**: Returns rows when there is a match in one of the tables.

```sql
SELECT *
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.id;
```

* **SELF JOIN**: A table is joined with itself.

```sql
SELECT e1.name, e2.name AS manager
FROM employees e1
JOIN employees e2 ON e1.manager_id = e2.id;
```

* **CROSS JOIN**: Returns the Cartesian product of two tables.

```sql
SELECT *
FROM products p
CROSS JOIN categories c;
```

## 3. Handling Duplicate Records in SQL

### 1. Spot Duplicates

```sql
SELECT name, email, COUNT(*) AS occurrences
FROM customers
GROUP BY name, email
HAVING COUNT(*) > 1;
```

### 2. Filter Out Duplicates

```sql
SELECT DISTINCT name, email
FROM customers;
```

### 3. Keep First of Each Duplicate Set

```sql
WITH ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY name, email ORDER BY id) AS rn
  FROM customers
)
SELECT id, name, email
FROM ranked
WHERE rn = 1;
```

### 4. Delete True Duplicates

```sql
WITH duplicates AS (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY name, email ORDER BY id) AS rn
  FROM customers
)
DELETE FROM customers
WHERE id IN (SELECT id FROM duplicates WHERE rn > 1);
```

### 5. Prevent Duplicates

```sql
ALTER TABLE customers ADD CONSTRAINT unique_email_name UNIQUE (name, email);
```



## 4. Window Functions vs Aggregate Functions

### Traditional Aggregates

| Function      | Description           | Example                       |
| ------------- | --------------------- | ----------------------------- |
| COUNT()       | Number of rows        | `COUNT(*)`                    |
| SUM()         | Total sum             | `SUM(salary)`                 |
| AVG()         | Average               | `AVG(salary)`                 |
| MIN(), MAX()  | Min/Max values        | `MIN(salary)` / `MAX(salary)` |
| STRING\_AGG() | Concatenates strings  | `STRING_AGG(name, ', ')`      |
| ARRAY\_AGG()  | Aggregates into array | `ARRAY_AGG(id)`               |

### Window Functions

| Function                      | Description                    | Example                                                 |
| ----------------------------- | ------------------------------ | ------------------------------------------------------- |
| ROW\_NUMBER()                 | Unique row per partition       | `ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary)` |
| RANK(), DENSE\_RANK()         | Ranks with/without gaps        | `RANK() OVER (...)`                                     |
| NTILE(n)                      | Divides rows into `n` buckets  | `NTILE(4) OVER (...)`                                   |
| LAG(), LEAD()                 | Access previous/next row value | `LAG(salary) OVER (...)`, `LEAD(salary) OVER (...)`     |
| FIRST\_VALUE(), LAST\_VALUE() | First/last in partition        | `FIRST_VALUE(salary) OVER (...)`                        |

---

## 5. Cumulative Sum of Sales Per Day

```sql
SELECT sale_date, 
       SUM(amount) OVER (ORDER BY sale_date) AS cumulative_sales
FROM sales;
```

### If multiple sales per day:

```sql
WITH data AS (
  SELECT sale_date, SUM(amount) AS daily_total
  FROM sales
  GROUP BY sale_date
)
SELECT sale_date, 
       SUM(daily_total) OVER (ORDER BY sale_date) AS cumulative_sale_amount
FROM data;
```

### Postgres-specific version:

```sql
SELECT sale_date, 
       SUM(SUM(amount)) OVER (ORDER BY sale_date) AS cumulative_sale_amount
FROM sales
GROUP BY sale_date;
```

---

## 6. 7-Day Moving Average of Daily Sales

```sql
WITH data AS (
  SELECT txn_date, SUM(txn_amount) AS daily_total
  FROM customer_transactions
  GROUP BY txn_date
)
SELECT txn_date,
       AVG(daily_total) OVER (
         ORDER BY txn_date 
         RANGE BETWEEN INTERVAL '6 days' PRECEDING AND CURRENT ROW
       ) AS moving_avg_range,
       AVG(daily_total) OVER (
         ORDER BY txn_date 
         ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ) AS moving_avg_7_days
FROM data;
```


## 7. Customers with More Than One Purchase

```sql
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(customer_id) > 1;
```

---

## 8. Rolling Sum & Lag/Lead Calculations

### Identify Users with Gaps > 7 Days Between Logins

```sql
WITH data AS (
  SELECT 
    customer_id, 
    txn_date - LAG(txn_date) OVER (PARTITION BY customer_id ORDER BY txn_date) AS difference,
    txn_date
  FROM customer_transactions
)
SELECT customer_id, difference
FROM data 
WHERE difference > 10;
```

---

## 9. Identify Churned Users (No Transactions in 30+ Days)

```sql
WITH data AS (
  SELECT 
    customer_id, 
    MAX(txn_date) AS last_transaction_date
  FROM customer_transactions
  GROUP BY customer_id
)
SELECT customer_id
FROM data
WHERE last_transaction_date < CURRENT_DATE - INTERVAL '30 days';
```

---

## 10. Indexing on Composite Keys

A composite index includes multiple columns and helps optimize queries that filter, join, or sort on those columns.

### Example

```sql
CREATE INDEX idx_user_city_age ON users (city, age);
```

This index sorts first by `city`, then by `age` within each city.

### Uses the Index

```sql
SELECT * FROM users WHERE city = 'Boston';
SELECT * FROM users WHERE city = 'Boston' AND age = 30;
```

### Won’t Use the Index Efficiently

```sql
SELECT * FROM users WHERE age = 30;
```

---

## 11. WHERE vs HAVING

* `WHERE` filters rows **before** aggregation.
* `HAVING` filters **after** aggregation.

### Example:

```sql
-- WHERE used before grouping
SELECT * FROM sales
WHERE amount > 100;

-- HAVING used after aggregation
SELECT customer_id, SUM(amount) AS total
FROM sales
GROUP BY customer_id
HAVING SUM(amount) > 500;
```

---

## 12. SQL Execution Order

1. `FROM`
2. `JOIN`
3. `WHERE`
4. `GROUP BY`
5. `HAVING`
6. `SELECT`
7. `DISTINCT`
8. `ORDER BY`
9. `LIMIT / OFFSET`

---

## 13. Write a Query That Performs Better Without `DISTINCT`

### Less Efficient (Uses `DISTINCT`)

```sql
SELECT DISTINCT c.name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;
```

This works, but if a customer has many orders, it generates duplicates, which `DISTINCT` has to clean up—slowing things down.

### Better Approach (Uses `EXISTS`)

```sql
SELECT c.name
FROM customers c
WHERE EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.customer_id = c.customer_id
);
```
