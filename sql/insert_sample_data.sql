USE ecommerce_platform_db;

INSERT INTO customers (first_name, last_name, email, phone) VALUES
('Aisha', 'Rahman', 'aisha.rahman@example.com', '0710000001'),
('Daniel', 'Carter', 'daniel.carter@example.com', '0710000002'),
('Mina', 'Patel', 'mina.patel@example.com', '0710000003'),
('Lucas', 'Meyer', 'lucas.meyer@example.com', '0710000004'),
('Grace', 'Wilson', 'grace.wilson@example.com', '0710000005'),
('Noah', 'Kim', 'noah.kim@example.com', '0710000006'),
('Sofia', 'Garcia', 'sofia.garcia@example.com', '0710000007'),
('Ethan', 'Brown', 'ethan.brown@example.com', '0710000008'),
('Priya', 'Shah', 'priya.shah@example.com', '0710000009'),
('Leo', 'Martin', 'leo.martin@example.com', '0710000010'),
('Hannah', 'Cole', 'hannah.cole@example.com', '0710000011'),
('Omar', 'Bennett', 'omar.bennett@example.com', '0710000012');

INSERT INTO addresses (customer_id, street, city, postal_code, country, address_type) VALUES
(1, '14 River Lane', 'London', 'E14 2AB', 'UK', 'shipping'),
(1, '14 River Lane', 'London', 'E14 2AB', 'UK', 'billing'),
(2, '89 Green Street', 'Manchester', 'M1 4CD', 'UK', 'shipping'),
(2, '89 Green Street', 'Manchester', 'M1 4CD', 'UK', 'billing'),
(3, '22 Willow Avenue', 'Birmingham', 'B2 1EF', 'UK', 'shipping'),
(4, '7 King Road', 'Leeds', 'LS1 3GH', 'UK', 'shipping'),
(5, '105 Market Square', 'Bristol', 'BS1 4JK', 'UK', 'shipping'),
(6, '31 Oak Drive', 'Liverpool', 'L1 6LM', 'UK', 'shipping'),
(7, '44 Lakeside View', 'Glasgow', 'G1 2NP', 'UK', 'shipping'),
(8, '18 Queens Park', 'Sheffield', 'S1 5QR', 'UK', 'shipping'),
(9, '63 Cedar Close', 'Leicester', 'LE1 7ST', 'UK', 'shipping'),
(10, '27 Station Road', 'Nottingham', 'NG1 8UV', 'UK', 'shipping'),
(11, '52 Harbour Way', 'Cardiff', 'CF10 1AA', 'UK', 'shipping'),
(12, '9 Meadow Rise', 'Oxford', 'OX1 2ZZ', 'UK', 'shipping');

INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Phones, audio devices, and smart accessories'),
('Home & Kitchen', 'Appliances and household essentials'),
('Fashion', 'Apparel and accessories'),
('Books', 'Print and study materials'),
('Sports', 'Fitness and outdoor products');

INSERT INTO suppliers (supplier_name, contact_email, phone) VALUES
('Nova Wholesale', 'sales@novawholesale.com', '+44-20-4000-1001'),
('Peak Distribution', 'contact@peakdist.com', '+44-20-4000-1002'),
('Urban Source Ltd', 'hello@urbansource.com', '+44-20-4000-1003');

INSERT INTO products (category_id, supplier_id, product_name, description, price, sku, is_active) VALUES
(1, 1, 'Wireless Earbuds', 'Noise-isolating Bluetooth earbuds', 59.99, 'ELEC-1001', 1),
(1, 1, 'Smartphone Stand', 'Adjustable aluminum desk stand', 19.50, 'ELEC-1002', 1),
(1, 2, 'USB-C Charger 65W', 'Fast wall charger for laptops and phones', 34.99, 'ELEC-1003', 1),
(1, 2, 'Fitness Smartwatch', 'Heart-rate and sleep tracking watch', 129.00, 'ELEC-1004', 1),
(2, 3, 'Air Fryer 5L', 'Compact digital air fryer', 89.99, 'HOME-2001', 1),
(2, 1, 'Electric Kettle', '1.7L stainless steel kettle', 29.99, 'HOME-2002', 1),
(2, 2, 'Ceramic Cookware Set', 'Non-stick 6-piece cookware set', 149.00, 'HOME-2003', 1),
(2, 3, 'LED Desk Lamp', 'Dimmable USB powered desk lamp', 24.99, 'HOME-2004', 1),
(3, 2, 'Classic Hoodie', 'Cotton blend unisex hoodie', 39.99, 'FASH-3001', 1),
(3, 3, 'Running Shoes', 'Lightweight everyday trainers', 84.50, 'FASH-3002', 1),
(3, 1, 'Leather Wallet', 'Slim RFID-blocking wallet', 32.00, 'FASH-3003', 1),
(3, 2, 'Sports Cap', 'Breathable adjustable cap', 18.50, 'FASH-3004', 1),
(4, 1, 'SQL Fundamentals', 'Introductory database textbook', 44.95, 'BOOK-4001', 1),
(4, 2, 'Python for Analysts', 'Data-focused Python guide', 49.99, 'BOOK-4002', 1),
(4, 3, 'Project Management Handbook', 'Practical planning reference', 36.00, 'BOOK-4003', 1),
(4, 1, 'UX Design Basics', 'Foundations of user experience design', 27.50, 'BOOK-4004', 1),
(5, 3, 'Yoga Mat', 'Non-slip 6mm exercise mat', 25.00, 'SPRT-5001', 1),
(5, 2, 'Resistance Bands Set', '5-level home workout bands', 21.99, 'SPRT-5002', 1),
(5, 1, 'Cycling Water Bottle', 'Insulated 750ml sports bottle', 14.00, 'SPRT-5003', 1),
(5, 3, 'Dumbbell Pair 10kg', 'Rubber-coated strength set', 69.99, 'SPRT-5004', 1),
(1, 2, 'Portable Power Bank', '10000mAh fast-charging power bank', 39.99, 'ELEC-1005', 1),
(2, 1, 'Coffee Grinder', 'Electric burr coffee grinder', 54.99, 'HOME-2005', 1);

INSERT INTO inventory (product_id, stock_quantity, reorder_level) VALUES
(1, 50, 15),
(2, 62, 20),
(3, 40, 10),
(4, 20, 8),
(5, 12, 12),
(6, 56, 15),
(7, 12, 10),
(8, 26, 10),
(9, 42, 15),
(10, 18, 10),
(11, 30, 8),
(12, 52, 20),
(13, 35, 12),
(14, 28, 10),
(15, 18, 6),
(16, 22, 8),
(17, 16, 15),
(18, 31, 10),
(19, 36, 12),
(20, 10, 8),
(21, 25, 10),
(22, 14, 8);

INSERT INTO orders (customer_id, shipping_address_id, order_date, order_status) VALUES
(1, 1, '2026-01-11 10:15:00', 'pending'),
(2, 3, '2026-01-14 14:20:00', 'pending'),
(3, 5, '2026-01-20 09:05:00', 'pending'),
(4, 6, '2026-02-02 16:30:00', 'pending'),
(5, 7, '2026-02-11 11:00:00', 'pending'),
(6, 8, '2026-02-18 13:10:00', 'pending'),
(7, 9, '2026-03-01 15:45:00', 'pending'),
(8, 10, '2026-03-05 17:00:00', 'pending'),
(9, 11, '2026-03-09 12:25:00', 'pending'),
(10, 12, '2026-03-14 08:40:00', 'pending'),
(3, 5, '2026-03-22 19:20:00', 'pending'),
(1, 1, '2026-04-01 10:00:00', 'pending');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 59.99),
(1, 13, 1, 44.95),
(1, 19, 2, 14.00),
(2, 5, 1, 89.99),
(2, 8, 2, 24.99),
(3, 4, 1, 129.00),
(3, 17, 1, 25.00),
(4, 10, 1, 84.50),
(4, 18, 2, 21.99),
(4, 12, 1, 18.50),
(5, 3, 2, 34.99),
(5, 2, 1, 19.50),
(6, 7, 1, 149.00),
(6, 6, 1, 29.99),
(7, 14, 1, 49.99),
(7, 15, 1, 36.00),
(7, 16, 1, 27.50),
(8, 9, 1, 39.99),
(8, 11, 1, 32.00),
(9, 20, 1, 69.99),
(10, 1, 2, 59.99),
(10, 4, 1, 129.00),
(10, 18, 1, 21.99),
(11, 17, 2, 25.00),
(11, 19, 1, 14.00),
(12, 5, 1, 89.99),
(12, 3, 1, 34.99),
(12, 14, 1, 49.99);

INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount, transaction_reference) VALUES
(1, '2026-01-11 10:30:00', 'card', 'completed', 132.94, 'TXN-100001'),
(2, '2026-01-14 14:35:00', 'bank_transfer', 'completed', 139.97, 'TXN-100002'),
(3, '2026-01-20 09:15:00', 'bank_transfer', 'completed', 154.00, 'TXN-100003'),
(4, '2026-02-02 16:45:00', 'bank_transfer', 'completed', 146.98, 'TXN-100004'),
(5, '2026-02-11 11:20:00', 'bank_transfer', 'completed', 89.48, 'TXN-100005'),
(6, '2026-02-18 13:30:00', 'cash_on_delivery', 'completed', 178.99, 'TXN-100006'),
(7, '2026-03-01 16:00:00', 'card', 'pending', 113.49, 'TXN-100007'),
(8, '2026-03-05 17:20:00', 'paypal', 'refunded', 71.99, 'TXN-100008'),
(9, '2026-03-09 12:30:00', 'cash_on_delivery', 'completed', 69.99, 'TXN-100009'),
(10, '2026-03-14 08:55:00', 'card', 'completed', 270.97, 'TXN-100010'),
(11, '2026-03-22 19:35:00', 'card', 'completed', 64.00, 'TXN-100011'),
(12, '2026-04-01 10:15:00', 'cash_on_delivery', 'completed', 174.97, 'TXN-100012');

UPDATE orders
SET order_status = 'delivered'
WHERE order_id IN (1, 2, 4, 6, 10);

UPDATE orders
SET order_status = 'shipped'
WHERE order_id IN (5, 11, 12);

UPDATE orders
SET order_status = 'cancelled'
WHERE order_id = 8;
