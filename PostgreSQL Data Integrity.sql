--PostgreSQL Data Integrity

CREATE TABLE customers1 (
    customer_id SERIAL PRIMARY KEY,  -- Auto-incrementing primary key
    customer_name VARCHAR(100) NOT NULL,
    MobileNo numeric(10,0) NOT NULL
);


CREATE TABLE orders1 (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers1(customer_id),  -- Foreign key
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO orders1 (customer_id) VALUES (999);


CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE,  -- No duplicate usernames
    email VARCHAR(100) UNIQUE NOT NULL
);


INSERT INTO users (username, email) VALUES ('johndoe', 'john@example.com');
INSERT INTO users (username, email) VALUES ('johndoe', 'john2@example.com');  


CREATE TABLE employees1 (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,  -- Must be provided
    last_name VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL
);


CREATE TABLE products1 (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) CHECK (price > 0),  -- Price must be positive
    stock_quantity INT CHECK (stock_quantity >= 0)
);


INSERT INTO products1 (name, price, stock_quantity) VALUES ('Widget', -10, 5);





DROP TABLE customers

DROP TABLE orders

DROP TABLE products

DROP TABLE order_items

-- Customers table with multiple constraints
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    phone VARCHAR(20) UNIQUE CHECK (phone ~ '^[0-9]{10,15}$'),
    join_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(10) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'banned'))
);

-- Products table with validation
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    sku VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    category VARCHAR(50) CHECK (category IN ('Electronics', 'Clothing', 'Home', 'Other')),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    discontinued BOOLEAN DEFAULT false
);

-- Orders with referential actions
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

-- Order items with composite key
CREATE TABLE order_items (
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(product_id) ON UPDATE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    PRIMARY KEY (order_id, product_id)  -- Composite primary key
);




INSERT INTO products (sku, name, price, category, stock_quantity)
VALUES ('GADGET-01', 'Cool Gadget', -19.99, 'Electronics', 10);


DELETE FROM orders WHERE order_id = 1001;


INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (9999, 101, 1, 29.99);