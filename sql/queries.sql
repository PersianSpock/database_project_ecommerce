USE ecommerce_platform_db;

-- =========================
-- CRUD OPERATIONS
-- =========================

-- CREATE: add a new customer
INSERT INTO customers (first_name, last_name, email, phone)
VALUES ('Nadia', 'Stone', 'nadia.stone@example.com', '0710000013');

-- CREATE: add a new product and its inventory
INSERT INTO products (category_id, supplier_id, product_name, description, price, sku, is_active)
VALUES (1, 2, 'Bluetooth Tracker', 'Compact item tracker with mobile app support', 24.99, 'ELEC-1006', 1);

INSERT INTO inventory (product_id, stock_quantity, reorder_level)
SELECT product_id, 30, 12
FROM products
WHERE sku = 'ELEC-1006';

-- CREATE: new order + item + payment to demonstrate trigger logic
INSERT INTO orders (customer_id, shipping_address_id, order_date)
VALUES (11, 13, CURRENT_TIMESTAMP);

SET @new_order_id = LAST_INSERT_ID();

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (@new_order_id, 21, 2, 39.99);

SELECT total_amount INTO @new_order_total
FROM orders
WHERE order_id = @new_order_id;

INSERT INTO payments (order_id, payment_method, payment_status, amount, transaction_reference)
VALUES (
    @new_order_id,
    'card',
    'completed',
    @new_order_total,
    CONCAT('TXN-', LPAD(@new_order_id + 200000, 6, '0'))
);

-- READ: list all products with category and supplier
SELECT p.product_id, p.product_name, c.category_name, s.supplier_name, p.price, p.sku
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers s ON p.supplier_id = s.supplier_id
ORDER BY p.product_id;

-- READ: show order details with customer name
SELECT o.order_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       o.order_date,
       o.order_status,
       o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date;

-- UPDATE: change product price
UPDATE products
SET price = 64.99
WHERE sku = 'ELEC-1001';

-- UPDATE: increase quantity on an order item (trigger adjusts inventory and totals)
UPDATE order_items
SET quantity = quantity + 1
WHERE order_id = 12 AND product_id = 14;

-- UPDATE: update customer contact info
UPDATE customers
SET phone = '0710000999'
WHERE email = 'mina.patel@example.com';

-- DELETE: remove a non-used billing address
DELETE FROM addresses
WHERE address_id = 4
  AND address_type = 'billing'
  AND address_id NOT IN (SELECT shipping_address_id FROM orders);

-- =========================
-- FUNCTIONAL QUERIES
-- =========================

-- 1. All orders with customer names
SELECT o.order_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       o.order_status,
       o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_id;

-- 2. Order items with product and category names
SELECT oi.order_id,
       p.product_name,
       c.category_name,
       oi.quantity,
       oi.unit_price,
       oi.line_total
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
ORDER BY oi.order_id, p.product_name;

-- 3. Total revenue generated from completed payments
SELECT ROUND(SUM(amount), 2) AS total_revenue
FROM payments
WHERE payment_status = 'completed';

-- 4. Revenue by category excluding cancelled orders
SELECT c.category_name,
       ROUND(SUM(oi.line_total), 2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status <> 'cancelled'
GROUP BY c.category_name
ORDER BY revenue DESC;

-- 5. Top 5 customers by total spending
SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       ROUND(SUM(o.total_amount), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status <> 'cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 5;

-- 6. Best-selling products by quantity sold
SELECT p.product_name,
       SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status <> 'cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC, p.product_name
LIMIT 5;

-- 7. Products with stock below reorder level
SELECT *
FROM low_stock_products
ORDER BY stock_quantity ASC;

-- 8. Orders not yet fully paid
SELECT o.order_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       o.order_status,
       o.total_amount,
       COALESCE(SUM(CASE WHEN p.payment_status = 'completed' THEN p.amount ELSE 0 END), 0) AS paid_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id, c.first_name, c.last_name, o.order_status, o.total_amount
HAVING paid_amount < o.total_amount OR o.order_status = 'cancelled'
ORDER BY o.order_id;

-- 9. Customers who placed more than 1 order
SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > 1
ORDER BY order_count DESC;

-- 10. Products never ordered
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL
ORDER BY p.product_id;

-- 11. Monthly sales summary
SELECT DATE_FORMAT(payment_date, '%Y-%m') AS sales_month,
       ROUND(SUM(amount), 2) AS monthly_revenue
FROM payments
WHERE payment_status = 'completed'
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY sales_month;

-- 12. Average order value excluding cancelled orders
SELECT ROUND(AVG(total_amount), 2) AS average_order_value
FROM orders
WHERE order_status <> 'cancelled';

-- 13. Supplier contribution to revenue
SELECT s.supplier_name,
       ROUND(SUM(oi.line_total), 2) AS supplier_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN suppliers s ON p.supplier_id = s.supplier_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status <> 'cancelled'
GROUP BY s.supplier_id, s.supplier_name
ORDER BY supplier_revenue DESC;

-- 14. Customers with no orders
SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

-- 15. Most popular category by units sold
SELECT c.category_name,
       SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status <> 'cancelled'
GROUP BY c.category_id, c.category_name
ORDER BY units_sold DESC
LIMIT 1;

-- 16. Customer lifetime value ranking using a window function (MySQL 8+)
WITH customer_totals AS (
    SELECT c.customer_id,
           CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
           COALESCE(SUM(CASE WHEN o.order_status <> 'cancelled' THEN o.total_amount ELSE 0 END), 0) AS lifetime_value
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT customer_id,
       customer_name,
       lifetime_value,
       DENSE_RANK() OVER (ORDER BY lifetime_value DESC) AS value_rank
FROM customer_totals
ORDER BY value_rank, customer_name;

-- 17. Monthly category revenue pivot-style summary
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
       ROUND(SUM(CASE WHEN c.category_name = 'Electronics' THEN oi.line_total ELSE 0 END), 2) AS electronics_revenue,
       ROUND(SUM(CASE WHEN c.category_name = 'Home & Kitchen' THEN oi.line_total ELSE 0 END), 2) AS home_kitchen_revenue,
       ROUND(SUM(CASE WHEN c.category_name = 'Fashion' THEN oi.line_total ELSE 0 END), 2) AS fashion_revenue,
       ROUND(SUM(CASE WHEN c.category_name = 'Books' THEN oi.line_total ELSE 0 END), 2) AS books_revenue,
       ROUND(SUM(CASE WHEN c.category_name = 'Sports' THEN oi.line_total ELSE 0 END), 2) AS sports_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE o.order_status <> 'cancelled'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;

-- 18. Payment reconciliation: compare order totals to completed payments
SELECT o.order_id,
       o.total_amount,
       COALESCE(SUM(CASE WHEN p.payment_status = 'completed' THEN p.amount ELSE 0 END), 0) AS completed_payments,
       ROUND(o.total_amount - COALESCE(SUM(CASE WHEN p.payment_status = 'completed' THEN p.amount ELSE 0 END), 0), 2) AS outstanding_balance
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id, o.total_amount
ORDER BY outstanding_balance DESC, o.order_id;
