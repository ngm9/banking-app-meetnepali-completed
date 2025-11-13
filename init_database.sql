-- Core banking schema with basic suboptimal design; realistic data for ~1–2 years exp.
-- Intentionally omits some PK/FK/constraints/indexes for the candidate's review

CREATE TABLE customers (
  customer_id SERIAL,
  first_name TEXT,
  last_name TEXT,
  email TEXT
);

CREATE TABLE accounts (
  account_id SERIAL,
  customer_id INTEGER,
  account_number TEXT,
  balance NUMERIC
);

CREATE TABLE transactions (
  transaction_id SERIAL,
  account_id INTEGER,
  txn_timestamp TIMESTAMP,
  txn_type TEXT,
  amount NUMERIC
);

-- Sample Customers
INSERT INTO customers (first_name, last_name, email) VALUES
('Alice', 'Johnson', 'alice@example.com'),
('Bob', 'Smith', 'bob@example.com'),
('Carol', 'Winslow', 'carol@example.com'),
('David', 'Nguyen', 'david@example.com'),
('Emily', 'Chen', 'emily@example.com');

-- Sample Accounts
INSERT INTO accounts (customer_id, account_number, balance) VALUES
(1, 'AC001', 7832.00),
(1, 'AC002', 150.50),
(2, 'AC003', 20500.00),
(3, 'AC004', 512.30),
(4, 'AC005', 1000.00),
(5, 'AC006', 1299.99);

-- Sample Transactions (plus random bulk insertions for load)
INSERT INTO transactions (account_id, txn_timestamp, txn_type, amount) VALUES
(1, NOW() - INTERVAL '2 days', 'deposit', 5000),
(1, NOW() - INTERVAL '36 hours', 'withdrawal', 200),
(2, NOW() - INTERVAL '18 hours', 'deposit', 100),
(3, NOW() - INTERVAL '6 hours', 'deposit', 15000),
(4, NOW() - INTERVAL '2 hours', 'withdrawal', 100),
(5, NOW() - INTERVAL '1 hour', 'deposit', 1000);

-- Bulk random transactions for each account (simulate basic load ~5k rows)
DO $$
DECLARE
  ac INT;
  t INT;
  i INT := 1;
BEGIN
  FOR ac IN 1..6 LOOP
    t := 1;
    WHILE t <= 800 LOOP
      INSERT INTO transactions (account_id, txn_timestamp, txn_type, amount)
      VALUES (ac, clock_timestamp() - (t || ' minutes')::interval,
              CASE WHEN random() < 0.5 THEN 'deposit' ELSE 'withdrawal' END,
              round((random()*500)::numeric,2));
      t := t + 1;
    END LOOP;
  END LOOP;
END $$;