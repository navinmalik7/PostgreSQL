EXPLAIN ANALYZE SELECT * FROM customers WHERE last_name = 'Smith';


CREATE INDEX idx_customers_last_name ON customers(last_name);