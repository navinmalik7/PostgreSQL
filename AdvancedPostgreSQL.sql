

-- Create partitioned table
CREATE TABLE orders_p (
    order_id BIGSERIAL,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2)
) PARTITION BY RANGE (order_date);


-- Create partitions
CREATE TABLE orders_2023_q1 PARTITION OF orders_p
    FOR VALUES FROM ('2023-01-01') TO ('2023-04-01');

CREATE TABLE orders_2023_q2 PARTITION OF orders_p
    FOR VALUES FROM ('2023-04-01') TO ('2023-07-01');

-- Insert data (goes to correct partition automatically)
INSERT INTO orders_p VALUES (1, 100, '2023-05-15', 99.99);


-- Querying the partitioned table
SELECT * FROM orders_p WHERE order_date >= '2023-01-01' AND order_date < '2023-04-01';
-- This will only scan the orders_2023_q1 partition.
SELECT * FROM orders_p WHERE order_date >= '2023-04-01' AND order_date < '2023-07-01';






-- Products with JSONB attributes
CREATE TABLE products_p (
    id SERIAL PRIMARY KEY,
    name TEXT,
    attributes JSONB
);

INSERT INTO products_p VALUES 
(1, 'Smartphone', '{"color": "black", "storage": "128GB", "tags": ["new", "popular"]}');

-- Query JSONB data
SELECT name FROM products_p 
WHERE attributes->>'color' = 'black';

-- Find products with "popular" tag
SELECT name FROM products_p 
WHERE attributes->'tags' ? 'popular';

-- JSONB indexing for performance
CREATE INDEX idx_product_tags ON products_p USING GIN (attributes jsonb_path_ops);

SELECT * FROM products_p 
WHERE attributes->'tags' ? 'popular';




-- Blog posts with tags
CREATE TABLE posts_p (
    id SERIAL PRIMARY KEY,
    title TEXT,
    tags TEXT[],
    comments TEXT[]
);


INSERT INTO posts_p VALUES 
(1, 'PostgreSQL Guide', 
 ARRAY['database', 'tutorial'], 
 ARRAY['Great post!', 'Very helpful']);


-- Find posts with 'tutorial' tag
SELECT title FROM posts_p WHERE 'tutorial' = ANY(tags);


-- Update array elements
UPDATE posts_p SET tags = array_append(tags, 'advanced') 
WHERE id = 1;


SELECT * FROM posts_p --WHERE id = 1;








-- Articles table
CREATE TABLE articles (
    id SERIAL PRIMARY KEY,
    title TEXT,
    content TEXT,
    search_vector TSVECTOR
);

-- Create search vector
UPDATE articles SET search_vector = 
    to_tsvector('english', title || ' ' || content);

-- Create index
CREATE INDEX idx_fts_search ON articles USING GIN(search_vector);

-- Search for "database performance"
SELECT title FROM articles 
WHERE search_vector @@ to_tsquery('english', 'database & performance');

-- Highlight matches
SELECT ts_headline('english', content, to_tsquery('database'), 
       'StartSel=<mark>, StopSel=</mark>') 
FROM articles;







CREATE EXTENSION IF NOT EXISTS btree_gist;
-- Hotel room bookings
CREATE TABLE bookings (
    room_id INT,
    booking_dates DATERANGE,
    EXCLUDE USING GIST (room_id WITH =, booking_dates WITH &&)
);

INSERT INTO bookings VALUES
(101, '[2023-06-01, 2023-06-05)'),
(101, '[2023-06-10, 2023-06-15)');

-- This would fail (overlapping dates):
-- INSERT INTO bookings VALUES (101, '[2023-06-04, 2023-06-08)');

-- Find bookings spanning June 2023
SELECT * FROM bookings 
WHERE booking_dates && '[2023-06-01, 2023-07-01)';

-- Calculate booking length
SELECT room_id, upper(booking_dates) - lower(booking_dates) AS nights 
FROM bookings;