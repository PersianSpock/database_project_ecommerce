USE ecommerce_platform_db;

CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_addresses_customer_id ON addresses(customer_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_supplier_id ON products(supplier_id);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_status_date ON payments(payment_status, payment_date);
CREATE INDEX idx_inventory_stock_quantity ON inventory(stock_quantity);

CREATE VIEW customer_order_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(CASE WHEN o.order_status <> 'cancelled' THEN o.total_amount ELSE 0 END), 0) AS lifetime_spend
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

CREATE VIEW product_sales_summary AS
SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(CASE WHEN o.order_status <> 'cancelled' THEN oi.quantity ELSE 0 END), 0) AS total_units_sold,
    COALESCE(SUM(CASE WHEN o.order_status <> 'cancelled' THEN oi.line_total ELSE 0 END), 0) AS total_sales_value
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name;

CREATE VIEW low_stock_products AS
SELECT
    p.product_id,
    p.product_name,
    i.stock_quantity,
    i.reorder_level,
    (i.reorder_level - i.stock_quantity) AS shortage_units
FROM products p
JOIN inventory i ON p.product_id = i.product_id
WHERE i.stock_quantity < i.reorder_level;


CREATE PROCEDURE sp_refresh_order_total(IN p_order_id INT)
BEGIN
    UPDATE orders o
    SET o.total_amount = (
        SELECT COALESCE(SUM(oi.line_total), 0)
        FROM order_items oi
        WHERE oi.order_id = p_order_id
    )
    WHERE o.order_id = p_order_id;
END;

CREATE TRIGGER trg_order_items_before_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;
    DECLARE v_status VARCHAR(20);
    DECLARE v_price DECIMAL(10,2);

    SELECT stock_quantity INTO v_stock
    FROM inventory
    WHERE product_id = NEW.product_id
    FOR UPDATE;

    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Inventory record missing for product';
    END IF;

    IF NEW.unit_price IS NULL OR NEW.unit_price = 0 THEN
        SELECT price INTO v_price
        FROM products
        WHERE product_id = NEW.product_id;
        SET NEW.unit_price = v_price;
    END IF;

    IF v_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient stock for requested product quantity';
    END IF;

    SELECT order_status INTO v_status
    FROM orders
    WHERE order_id = NEW.order_id;

    IF v_status = 'cancelled' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot add items to a cancelled order';
    END IF;
END;

CREATE TRIGGER trg_order_items_after_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET stock_quantity = stock_quantity - NEW.quantity,
        last_updated = CURRENT_TIMESTAMP
    WHERE product_id = NEW.product_id;

    CALL sp_refresh_order_total(NEW.order_id);
END;

CREATE TRIGGER trg_order_items_before_update
BEFORE UPDATE ON order_items
FOR EACH ROW
BEGIN
    DECLARE v_delta INT;
    DECLARE v_stock INT;

    SET v_delta = NEW.quantity - OLD.quantity;

    SELECT stock_quantity INTO v_stock
    FROM inventory
    WHERE product_id = NEW.product_id
    FOR UPDATE;

    IF NEW.product_id <> OLD.product_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Updating product_id on existing order items is not supported';
    END IF;

    IF v_stock < v_delta THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient stock for updated quantity';
    END IF;
END;

CREATE TRIGGER trg_order_items_after_update
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET stock_quantity = stock_quantity - (NEW.quantity - OLD.quantity),
        last_updated = CURRENT_TIMESTAMP
    WHERE product_id = NEW.product_id;

    CALL sp_refresh_order_total(NEW.order_id);
END;

CREATE TRIGGER trg_order_items_after_delete
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET stock_quantity = stock_quantity + OLD.quantity,
        last_updated = CURRENT_TIMESTAMP
    WHERE product_id = OLD.product_id;

    CALL sp_refresh_order_total(OLD.order_id);
END;

CREATE TRIGGER trg_payments_after_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
    DECLARE v_paid_total DECIMAL(10,2);
    DECLARE v_order_total DECIMAL(10,2);

    SELECT COALESCE(SUM(amount), 0) INTO v_paid_total
    FROM payments
    WHERE order_id = NEW.order_id
      AND payment_status = 'completed';

    SELECT total_amount INTO v_order_total
    FROM orders
    WHERE order_id = NEW.order_id;

    IF v_paid_total >= v_order_total AND v_order_total > 0 THEN
        UPDATE orders
        SET order_status = 'paid'
        WHERE order_id = NEW.order_id
          AND order_status = 'pending';
    END IF;
END;
