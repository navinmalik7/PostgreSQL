-- Active: 1744294451759@@127.0.0.1@5432@ecommerce_joins_demo
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    join_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT true
);

SELECT * FROM customers;

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50),
    stock_quantity INT DEFAULT 0
);

SELECT * FROM products;

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('pending', 'shipped', 'delivered', 'cancelled'))
);

SELECT * FROM orders;

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

SELECT * FROM order_items;

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    position VARCHAR(50),
    manager_id INT REFERENCES employees(employee_id),
    hire_date DATE
);

SELECT * FROM employees

-- Insert customers
INSERT INTO customers (name, email, join_date, is_active) VALUES
('John Smith', 'john.smith@email.com', '2022-01-15', true),
('Sarah Johnson', 'sarah.j@email.com', '2022-02-20', true),
('Mike Brown', 'mike.b@email.com', '2022-03-10', false),
('Emily Davis', 'emily.d@email.com', '2022-01-05', true),
('David Wilson', 'david.w@email.com', '2022-04-18', true);

-- Insert products
INSERT INTO products (name, price, category, stock_quantity) VALUES
('Wireless Headphones', 99.99, 'Electronics', 50),
('Smart Watch', 199.99, 'Electronics', 30),
('Coffee Maker', 49.99, 'Home', 25),
('Yoga Mat', 29.99, 'Fitness', 100),
('Water Bottle', 19.99, 'Fitness', 200),
('Desk Lamp', 39.99, 'Home', 40);

-- Insert orders
INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2023-01-10 09:30:00', 'delivered'),
(1, '2023-02-15 14:22:00', 'shipped'),
(2, '2023-01-20 11:05:00', 'delivered'),
(3, '2023-03-05 16:45:00', 'cancelled'),
(4, '2023-03-12 10:15:00', 'pending'),
(5, '2023-03-18 13:30:00', 'shipped');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 99.99),  -- John's 1st order: headphones
(1, 3, 1, 49.99),  -- John's 1st order: coffee maker
(2, 2, 1, 199.99), -- John's 2nd order: smart watch
(3, 4, 2, 29.99),  -- Sarah's order: 2 yoga mats
(3, 5, 1, 19.99),  -- Sarah's order: water bottle
(4, 6, 1, 39.99),  -- Mike's cancelled order: desk lamp
(5, 1, 1, 99.99),  -- Emily's pending order: headphones
(6, 3, 1, 49.99);  -- David's order: coffee maker

-- Insert employees (with manager hierarchy)
INSERT INTO employees (name, position, manager_id, hire_date) VALUES
('Robert Chen', 'CEO', NULL, '2020-01-10'),
('Lisa Wong', 'Sales Manager', 1, '2021-03-15'),
('James Wilson', 'Marketing Manager', 1, '2021-02-20'),
('Emma Thompson', 'Sales Associate', 2, '2022-05-10'),
('Daniel Lee', 'Marketing Specialist', 3, '2022-06-15');



-- Find all customers who placed orders and their order details
SELECT c.name AS customer, o.order_id, o.order_date, o.status
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;




-- Find all customers and any orders they've made
SELECT c.name AS customer, o.order_id, o.status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.name;


-- Find all products and any orders containing them
SELECT p.name AS product, oi.order_id, oi.quantity
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id;


-- Create a customer-product matrix (artificial example)
SELECT c.name AS customer, p.name AS product
FROM customers c
FULL OUTER JOIN products p ON 1=1  -- Artificial condition for demo
LIMIT 20;  -- This would produce 30 rows (5 customers × 6 products)


-- Find all possible product bundles (for promotion ideas)
SELECT p1.name AS product1, p2.name AS product2
FROM products p1
CROSS JOIN products p2
WHERE p1.product_id < p2.product_id;  -- Avoids duplicate pairs



-- Show employee-manager relationships
SELECT e.name AS employee, m.name AS manager, e.position
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;