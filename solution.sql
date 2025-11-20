DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(32) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    unit_price DECIMAL(10,2) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `orders` (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(12,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'PLACED',
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    line_total DECIMAL(12,2) AS (quantity * unit_price) PERSISTENT,
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES `orders`(order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Sample data
INSERT INTO products (sku, name, category, unit_price) VALUES
('SKU-1001','USB Cable','Accessories',199.00),
('SKU-1002','Bluetooth Mouse','Peripherals',799.00),
('SKU-1003','Mechanical Keyboard','Peripherals',2499.00),
('SKU-1004','Webcam HD','Accessories',1299.00);

INSERT INTO customers (name, email, phone) VALUES
('Ravi Kumar','ravi@example.com','9876543210'),
('Sita Sharma','sita@example.com','9123456780'),
('Ajay','ajay@example.com','9000000000');

-- Create an order transaction (example)
START TRANSACTION;
INSERT INTO `orders` (customer_id, order_date, status) VALUES (1, '2025-10-01 10:30:00', 'PLACED');
SET @last_order_id = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(@last_order_id, 1, 2, 199.00),
(@last_order_id, 2, 1, 799.00);
-- Update order total
UPDATE `orders` o
JOIN (
    SELECT order_id, SUM(quantity * unit_price) AS tot FROM order_items WHERE order_id = @last_order_id GROUP BY order_id
) t ON o.order_id = t.order_id
SET o.total_amount = t.tot;
COMMIT;

-- Reporting queries

-- 1) Daily sales summary
-- Returns total orders and total revenue per day
SELECT DATE(order_date) AS sales_date,
       COUNT(*) AS total_orders,
       SUM(total_amount) AS total_revenue
FROM `orders`
GROUP BY DATE(order_date)
ORDER BY sales_date DESC;

-- 2) Top selling products (by quantity)
SELECT p.product_id, p.name, SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.name
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- 3) Customer order history (example for customer_id = 1)
SELECT o.order_id, o.order_date, o.total_amount, o.status,
       JSON_ARRAYAGG(JSON_OBJECT('product', p.name, 'qty', oi.quantity, 'line_total', oi.line_total)) AS items
FROM `orders` o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.customer_id = 1
GROUP BY o.order_id, o.order_date, o.total_amount, o.status
ORDER BY o.order_date DESC;

-- 4) Index suggestions
CREATE INDEX idx_orders_date ON `orders` (order_date);
CREATE INDEX idx_orderitems_product ON order_items (product_id);

-- Stored procedure: monthly sales totals
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_get_monthly_sales $$
CREATE PROCEDURE sp_get_monthly_sales(IN in_year INT)
BEGIN
    SELECT YEAR(order_date) AS yr, MONTH(order_date) AS mth, SUM(total_amount) AS revenue, COUNT(*) AS orders_count
    FROM `orders`
    WHERE YEAR(order_date) = in_year
    GROUP BY YEAR(order_date), MONTH(order_date)
    ORDER BY mth;
END $$
DELIMITER ;

