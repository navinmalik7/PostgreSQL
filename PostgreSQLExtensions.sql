-- Active: 1744294451759@@127.0.0.1@5432@quickinvoicedb@quickinvoice
SELECT * FROM pg_available_extensions;


CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

SELECT * FROM pg_extension;

CREATE EXTENSION postgis;
SELECT PostGIS_version();

SELECT * FROM pg_available_extensions WHERE name LIKE '%postgis%'

CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    location GEOGRAPHY(POINT, 4326)
);

-- Insert sample cities (New York, Los Angeles, London)
INSERT INTO cities (name, location) VALUES
    ('New York', ST_GeogFromText('POINT(-74.0060 40.7128)')),
    ('Los Angeles', ST_GeogFromText('POINT(-118.2437 34.0522)')),
    ('London', ST_GeogFromText('POINT(-0.1276 51.5074)'));

SELECT ST_Distance(
  ST_GeomFromText('POINT(-74.0060 40.7128)', 4326), -- New York
  ST_GeomFromText('POINT(-118.2437 34.0522)', 4326) -- Los Angeles
) AS distance_in_meters;



-- Enable the extension
CREATE EXTENSION pg_stat_statements;

-- See top 5 slowest queries
SELECT * FROM pg_stat_statements 
--ORDER BY total_time DESC 
LIMIT 5;



CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(10, 2),
    order_date DATE
);

-- Insert 1000 random orders
INSERT INTO orders (customer_id, amount, order_date)
SELECT 
    (random() * 100)::INT,
    (random() * 500 + 10)::DECIMAL(10, 2),
    CURRENT_DATE - (random() * 365)::INT
FROM generate_series(1, 1000);



-- Run a few queries to generate stats
SELECT COUNT(*) FROM orders WHERE amount > 200;
SELECT customer_id, SUM(amount) FROM orders GROUP BY customer_id;

-- Now check pg_stat_statements
SELECT query, calls,  rows, shared_blks_read, shared_blks_written
FROM pg_stat_statements
WHERE query LIKE '%orders%';


CREATE EXTENSION pgcrypto;

SELECT crypt('mypassword', gen_salt('bf', 8)) AS encrypted_password;



SELECT uuid_generate_v4() AS unique_id;



-- Enable tablefunc
CREATE EXTENSION tablefunc;

-- Create a pivot table
SELECT * FROM crosstab(
  'SELECT product, quarter, sales FROM sales_data ORDER BY 1,2'
) AS ct (product text, Q1 int, Q2 int, Q3 int, Q4 int);