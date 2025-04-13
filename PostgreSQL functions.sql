-- Customers table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    signup_date DATE,
    last_login TIMESTAMP
);

-- Products table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2),
    stock_quantity INT,
    release_date DATE
);

-- Orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date TIMESTAMP,
    total_amount DECIMAL(10,2)
);


-- Insert sample data
INSERT INTO customers (first_name, last_name, email, signup_date, last_login) VALUES
('John', 'Doe', 'john.doe@example.com', '2023-01-15', '2023-06-10 09:30:00'),
('Alice', 'Smith', 'alice.smith@example.com', '2023-02-20', '2023-06-12 14:15:00'),
('Bob', 'Johnson', NULL, '2023-03-10', NULL);

INSERT INTO products (name, price, stock_quantity, release_date) VALUES
('Wireless Headphones', 99.99, 50, '2023-01-01'),
('Smart Watch', 199.99, 30, '2023-02-15'),
('Bluetooth Speaker', 59.99, 25, '2022-12-10');

INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2023-05-01 10:00:00', 99.99),
(1, '2023-05-15 14:30:00', 199.99),
(2, '2023-06-01 09:15:00', 59.99);


SELECT * FROM customers;
SELECT * FROM products;     
SELECT * FROM orders;


SELECT first_name || ' ' || last_name AS full_name FROM customers;


-- Uppercase emails
SELECT UPPER(email) AS email_upper FROM customers;


-- Extract domain from email
SELECT SUBSTRING(email FROM '@(.*)$') AS domain FROM customers;


-- Replace text
SELECT REPLACE(name, 'Wireless', 'Bluetooth') AS renamed_product FROM products;


-- Calculate discounted price (20% off)
SELECT name, price, ROUND(price * 0.8, 2) AS discounted_price FROM products;

-- Random sampling (get 2 random products)
SELECT name FROM products ORDER BY RANDOM() LIMIT 2;


-- Random sampling (get 2 random products)
SELECT name FROM products ORDER BY RANDOM() LIMIT 2;


-- Days since product release
SELECT name, release_date, CURRENT_DATE - release_date AS days_since_release FROM products;


SELECT order_id, TO_CHAR(order_date, 'MM/DD/YYYY HH12:MI AM') AS formatted_date FROM orders;



-- String to integer
SELECT '100'::INTEGER + 50 AS result;  -- Returns 150

-- Date to string
SELECT order_id, CAST(order_date AS VARCHAR) AS date_string FROM orders;

-- Implicit vs explicit casting
SELECT 5 / 2;           -- Returns 2 (integer division)
SELECT 5 / 2.0;         -- Returns 2.5 (floating point)
SELECT CAST(5 AS FLOAT) / 2;  -- Returns 2.5


SELECT first_name, COALESCE(email, 'no-email@example.com') AS safe_email FROM customers;


-- Avoid division by zero
SELECT 10 / NULLIF(stock_quantity, 0) FROM products;


CREATE OR REPLACE FUNCTION get_discounted_price(original_price DECIMAL, discount DECIMAL) 
RETURNS DECIMAL AS $$
BEGIN
    RETURN original_price * (1 - discount);
END;
$$ LANGUAGE plpgsql;


-- Use the function
SELECT name, price, get_discounted_price(price, 0.2) AS sale_price FROM products;



SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    COALESCE(c.email, 'NO EMAIL') AS contact_email,
    TO_CHAR(MAX(o.order_date), 'YYYY-MM-DD') AS last_purchase_date,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE c.last_login < CURRENT_DATE - INTERVAL '30 days' OR c.last_login IS NULL
GROUP BY c.customer_id
ORDER BY total_spent DESC NULLS LAST;