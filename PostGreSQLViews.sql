DROP TABLE customers;
DROP TABLE products;
DROP TABLE orders;
DROP TABLE order_items;

-- Customers table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    join_date DATE DEFAULT CURRENT_DATE
);

-- Products table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50)
);

-- Orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('pending', 'shipped', 'delivered'))
);

-- Order items table
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- Insert sample data
INSERT INTO customers (first_name, last_name, email) VALUES
('John', 'Doe', 'john@example.com'),
('Jane', 'Smith', 'jane@example.com'),
('Bob', 'Johnson', 'bob@example.com');

INSERT INTO products (name, price, category) VALUES
('Laptop', 999.99, 'Electronics'),
('Smartphone', 699.99, 'Electronics'),
('Headphones', 99.99, 'Accessories');

INSERT INTO orders (customer_id, status) VALUES
(1, 'delivered'),
(2, 'shipped'),
(3, 'pending');

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 999.99),
(1, 3, 2, 99.99),
(2, 2, 1, 699.99),
(3, 1, 1, 999.99);


SELECT * FROM customers;
SELECT * FROM products;     
SELECT * FROM orders;
SELECT * FROM order_items;




CREATE VIEW active_customers AS
SELECT first_name, last_name, email 
FROM customers
WHERE join_date > CURRENT_DATE - INTERVAL '6 months';

SELECT * FROM active_customers;




CREATE VIEW order_summary AS
SELECT 
    c.first_name || ' ' || c.last_name AS customer,
    o.order_id,
    o.order_date,
    SUM(oi.quantity * oi.price) AS total_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, o.order_id;


SELECT * FROM order_summary;
SELECT * FROM order_summary WHERE total_amount > 500;




CREATE VIEW customer_emails AS
SELECT customer_id, email FROM customers;   

SELECT * FROM customer_emails;


-- This works:
UPDATE customer_emails SET email = 'newjohn@example.com' 
WHERE customer_id = 1;


-- This fails (view with joins):
UPDATE order_summary SET total_amount = 0 WHERE order_id = 1;
-- ERROR: cannot update view "order_summary" because it contains joins


CREATE MATERIALIZED VIEW top_selling_products AS
SELECT 
    p.product_id,
    p.name,
    p.category,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY total_revenue DESC;


SELECT * FROM top_selling_products LIMIT 3;



REFRESH MATERIALIZED VIEW top_selling_products;

SELECT * FROM top_selling_products LIMIT 3;


REFRESH MATERIALIZED VIEW CONCURRENTLY top_selling_products;


CREATE VIEW customer_limited_view AS
SELECT first_name, last_name FROM customers;