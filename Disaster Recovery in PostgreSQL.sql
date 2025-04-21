-- Active: 1744294451759@@127.0.0.1@5432@newrestaurant_db
CREATE DATABASE restaurant_db;

-- Create tables
CREATE TABLE menu_items (
    item_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    order_date TIMESTAMP DEFAULT NOW(),
    total_amount DECIMAL(10,2)
);


-- Insert sample data
INSERT INTO menu_items (name, price, category) VALUES
('Margherita Pizza', 12.99, 'Pizza'),
('Caesar Salad', 8.50, 'Salad'),
('Chocolate Cake', 6.75, 'Dessert');

INSERT INTO orders (customer_name, total_amount) VALUES
('John Smith', 25.48),
('Emma Johnson', 15.25);




SELECT * FROM menu_items;

SELECT * FROM orders;



SELECT 'Menu Items Count:' AS description, COUNT(*) FROM menu_items
UNION ALL
SELECT 'Orders Count:', COUNT(*) FROM orders;