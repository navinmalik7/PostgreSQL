-- Active: 1744294451759@@127.0.0.1@5432@interview_questions@public
CREATE DATABASE interview_questions;

-- Create tables
CREATE TABLE sensors (
    sensor_id SERIAL PRIMARY KEY,
    location VARCHAR(100) NOT NULL,
    installed_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE sensor_readings (
    reading_id BIGSERIAL PRIMARY KEY,
    sensor_id INTEGER REFERENCES sensors(sensor_id),
    reading_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    temperature DECIMAL(5,2) NOT NULL
);

-- Insert sample data
INSERT INTO sensors (location) VALUES 
('Server Room A'), 
('Greenhouse B'), 
('Factory Floor C');

INSERT INTO sensor_readings (sensor_id, temperature) VALUES
(1, 22.5), (1, 22.7), (1, 22.4), (1, 35.1), -- Anomaly in Server Room
(2, 18.2), (2, 18.3), (2, 18.1),
(3, 26.0), (3, 26.2), (3, 26.1), (3, 50.8); -- Anomaly in Factory

TRUNCATE TABLE sensor_readings;


 SELECT 
        sensor_id,
        AVG(temperature) AS mean_temp,
        STDDEV(temperature) AS stddev_temp
    FROM sensor_readings
    GROUP BY sensor_id

-- Find anomalies using window functions
WITH stats AS (
    SELECT 
        sensor_id,
        AVG(temperature) AS mean_temp,
        STDDEV(temperature) AS stddev_temp
    FROM sensor_readings
    GROUP BY sensor_id
)
SELECT 
    r.reading_id,
    s.location,
    r.temperature,
    stats.mean_temp,
    stats.stddev_temp
FROM sensor_readings r
JOIN sensors s ON r.sensor_id = s.sensor_id
JOIN stats ON r.sensor_id = stats.sensor_id
WHERE r.temperature = stats.mean_temp + (stats.stddev_temp);


















-- Create table with self-reference
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    position VARCHAR(100),
    manager_id INTEGER REFERENCES employees(employee_id)
);

-- Insert sample org chart
INSERT INTO employees (name, position, manager_id) VALUES
('Alice', 'CEO', NULL),
('Bob', 'CTO', 1),
('Carol', 'CFO', 1),
('Dave', 'Lead Developer', 2),
('Eve', 'Product Manager', 2),
('Frank', 'Accountant', 3);

-- Recursive query to find reporting chain
WITH RECURSIVE org_chart AS (
    -- Base case: Start with employee
    SELECT employee_id, name, position, manager_id, 1 AS level
    FROM employees
    WHERE name = 'Dave'
    UNION ALL
    -- Recursive case: Go up to manager
    SELECT e.employee_id, e.name, e.position, e.manager_id, oc.level + 1
    FROM employees e
    JOIN org_chart oc ON e.employee_id = oc.manager_id
)
SELECT 
    LPAD(' ', (level-1)*4, ' ') || name AS hierarchy,
    position
FROM org_chart
ORDER BY level DESC;
















-- Create tables
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL
);

-- Insert sample data
INSERT INTO customers (email) VALUES 
('alice@example.com'),
('bob@example.com'),
('carol@example.com');

INSERT INTO orders (customer_id, order_date, amount) VALUES
(1, '2023-01-15', 100.00),
(1, '2023-03-20', 150.00),
(1, '2023-06-01', 200.00),  -- Alice: Frequent, high-value
(2, '2022-12-10', 50.00),   -- Bob: Lapsed, low-frequency
(3, '2023-05-25', 75.00),
(3, '2023-06-10', 125.00);  -- Carol: Recent, mid-value

-- RFM analysis
;WITH rfm AS (
    SELECT
        c.customer_id,
        c.email,
        CURRENT_DATE - MAX(o.order_date) AS recency,
        COUNT(o.order_id) AS frequency,
        SUM(o.amount) AS monetary,
        NTILE(3) OVER (ORDER BY CURRENT_DATE - MAX(o.order_date) DESC) AS r_score,
        NTILE(3) OVER (ORDER BY COUNT(o.order_id)) AS f_score,
        NTILE(3) OVER (ORDER BY SUM(o.amount)) AS m_score
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.email
)
SELECT 
    customer_id,
    email,
    recency || ' days' AS recency,
    frequency,
    monetary,
    CAST(r_score AS TEXT) || CAST(f_score AS TEXT) || CAST(m_score AS TEXT) AS rfm_cell
FROM rfm
ORDER BY rfm_cell DESC;