CREATE TABLE accounts (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    balance DECIMAL(10,2) NOT NULL,
    CHECK (balance >= 0) -- Enforces consistency
);

-- Insert sample data
INSERT INTO accounts (username, balance) VALUES
('Alice', 1000.00),
('Bob', 500.00),
('Charlie', 200.00);

-- Create an events table for isolation demo
CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    event_name VARCHAR(100),
    seats_available INTEGER NOT NULL
);

INSERT INTO events (event_name, seats_available) VALUES
('Concert', 1); -- Only 1 seat left!


SELECT * FROM accounts;
SELECT * FROM events;


-- Transaction 1: Successful transfer
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE username = 'Alice';
    UPDATE accounts SET balance = balance + 100 WHERE username = 'Bob';
COMMIT;

-- Verify results
SELECT * FROM accounts;



-- Transaction 2: Failed transfer (rolled back)
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE username = 'Alice';
    UPDATE accounts SET balance = balance + 100 WHERE username = 'Nonexistent'; -- Will fail
COMMIT;
-- ERROR:  duplicate key value violates unique constraint "accounts_pkey"



-- Suppose we have a CHECK constraint preventing negative balances
ALTER TABLE accounts ADD CONSTRAINT no_negative_balance CHECK (balance >= 0);

-- This will fail (consistency enforced!)
UPDATE accounts SET balance = balance - 200 WHERE user_id = 1; -- Alice has only $100


-- Try to make Alice's balance negative (violates CHECK constraint)
BEGIN;
    UPDATE accounts SET balance = balance - 1000 WHERE username = 'Alice';
COMMIT;
-- ERROR:  new row for relation "accounts" violates check constraint "accounts_balance_check"
-- Transaction is automatically rolled back

-- Verify balance remains unchanged
SELECT * FROM accounts WHERE username = 'Alice';
/*
 user_id | username | balance 
---------+----------+---------
       1 | Alice    |  900.00
*/