--step 1 : adding the primary keys 

ALTER TABLE customers
ADD CONSTRAINT pk_customers PRIMARY KEY (customer_id);

ALTER TABLE accounts
ADD CONSTRAINT pk_accounts PRIMARY KEY (account_id);

ALTER TABLE transactions
ADD CONSTRAINT pk_transactions PRIMARY KEY (transaction_id);

-- step 2: adding the foreign keys 

ALTER TABLE accounts
ADD CONSTRAINT fk_accounts_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_accounts FOREIGN KEY (account_id) REFERENCES accounts(account_id)    
ON DELETE CASCADE
ON UPDATE CASCADE;

-- step 3 : adding not null constraints

--customer table 
ALTER TABLE customers
ALTER COLUMN first_name SET NOT NULL,
ALTER COLUMN last_name SET NOT NULL,
ALTER COLUMN email SET NOT NULL;

--account table
ALTER TABLE accounts
ALTER COLUMN customer_id SET NOT NULL,
ALTER COLUMN account_number SET NOT NULL,
ALTER COLUMN balance SET NOT NULL;

--transaction table
ALTER TABLE transactions
ALTER COLUMN account_id SET NOT NULL,
ALTER COLUMN txn_timestamp SET NOT NULL,
ALTER COLUMN txn_type SET NOT NULL,
ALTER COLUMN amount SET NOT NULL;

-- step 4 adding unique contraints

ALTER TABLE customers
ADD CONSTRAINT uk_customers_email UNIQUE (email);

ALTER TABLE accounts
ADD CONSTRAINT uk_accounts_account_number UNIQUE (account_number);  


--step 5 ADDING INDEXES

-- Indexes on Primary Keys (already have unique index from PK constraint, but explicit for clarity)
-- CREATE INDEX idx_customers_id ON customers(customer_id); -- Not needed, PK creates index
-- CREATE INDEX idx_accounts_account_id ON accounts(account_id); -- Not needed, PK creates index

-- Foreign Key Indexes (critical for join performance and CASCADE operations)
CREATE INDEX idx_accounts_customer_id ON accounts(customer_id);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);

-- Query-specific Indexes (based on sample_queries.sql patterns)
-- For customer email lookups (WHERE c.email = '...')
CREATE INDEX idx_customers_email ON customers(email);

-- For transaction timestamp queries (range queries, sorting by date)
CREATE INDEX idx_transactions_timestamp ON transactions(txn_timestamp);

-- For transaction type filtering (WHERE txn_type = '...')
CREATE INDEX idx_transactions_type ON transactions(txn_type);

-- Composite index for transaction queries filtered by account and timestamp
CREATE INDEX idx_transactions_account_timestamp ON transactions(account_id, txn_timestamp);

-- For account number lookups (already have unique constraint which creates index)
-- CREATE INDEX idx_accounts_account_number ON accounts(account_number); -- Not needed, UNIQUE creates index

-- step 6: ADDING CHECK CONSTRAINTS

-- Ensure email format is valid
ALTER TABLE customers
ADD CONSTRAINT chk_customers_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Ensure balance is non-negative
ALTER TABLE accounts
ADD CONSTRAINT chk_accounts_balance_positive CHECK (balance >= 0);

-- Ensure transaction amount is positive
ALTER TABLE transactions
ADD CONSTRAINT chk_transactions_amount_positive CHECK (amount > 0);

-- Ensure transaction type is valid
ALTER TABLE transactions
ADD CONSTRAINT chk_transactions_type_valid CHECK (txn_type IN ('deposit', 'withdrawal', 'transfer'));

-- step 7: ADDING DEFAULT VALUES

-- Set default balance for new accounts
ALTER TABLE accounts
ALTER COLUMN balance SET DEFAULT 0.00;

-- Set default timestamp for transactions to current time
ALTER TABLE transactions
ALTER COLUMN txn_timestamp SET DEFAULT CURRENT_TIMESTAMP;

-- step 8: ADDITIONAL REPORTING QUERIES (as per README objectives)

-- Query 1: All transactions for a specific customer by email (optimized with indexes)
-- This query validates the FK indexes and email index are working
SELECT 
    c.first_name,
    c.last_name,
    c.email,
    a.account_number,
    t.txn_timestamp,
    t.txn_type,
    t.amount
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE c.email = 'alice@example.com'
ORDER BY t.txn_timestamp DESC;

-- Query 2: Customer account summary (total balance and transaction count)
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    SUM(a.balance) AS total_balance,
    COUNT(t.transaction_id) AS total_transactions
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
ORDER BY total_balance DESC;

-- Query 3: Account activity summary (deposits vs withdrawals)
SELECT 
    a.account_number,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(CASE WHEN t.txn_type = 'deposit' THEN 1 END) AS deposit_count,
    SUM(CASE WHEN t.txn_type = 'deposit' THEN t.amount ELSE 0 END) AS total_deposits,
    COUNT(CASE WHEN t.txn_type = 'withdrawal' THEN 1 END) AS withdrawal_count,
    SUM(CASE WHEN t.txn_type = 'withdrawal' THEN t.amount ELSE 0 END) AS total_withdrawals,
    a.balance AS current_balance
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_id, a.account_number, c.first_name, c.last_name, a.balance
ORDER BY a.account_number;

-- Query 4: Recent transactions (last 7 days) - uses timestamp index
SELECT 
    c.email,
    a.account_number,
    t.txn_timestamp,
    t.txn_type,
    t.amount
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE t.txn_timestamp >= NOW() - INTERVAL '7 days'
ORDER BY t.txn_timestamp DESC
LIMIT 50;

-- Query 5: Accounts with high transaction volume (identify active accounts)
SELECT 
    a.account_number,
    c.email,
    COUNT(t.transaction_id) AS transaction_count,
    a.balance
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_id, a.account_number, c.email, a.balance
HAVING COUNT(t.transaction_id) > 100
ORDER BY transaction_count DESC;

-- step 9: DATA INTEGRITY VERIFICATION QUERIES

-- Verify no orphaned accounts (all accounts have valid customers)
SELECT COUNT(*) AS orphaned_accounts
FROM accounts a
LEFT JOIN customers c ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Verify no orphaned transactions (all transactions have valid accounts)
SELECT COUNT(*) AS orphaned_transactions
FROM transactions t
LEFT JOIN accounts a ON t.account_id = a.account_id
WHERE a.account_id IS NULL;

-- Verify no duplicate emails
SELECT email, COUNT(*) AS duplicate_count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- Verify no duplicate account numbers
SELECT account_number, COUNT(*) AS duplicate_count
FROM accounts
GROUP BY account_number
HAVING COUNT(*) > 1;

-- Verify all balances are non-negative
SELECT COUNT(*) AS negative_balances
FROM accounts
WHERE balance < 0;

-- Verify all transaction amounts are positive
SELECT COUNT(*) AS invalid_amounts
FROM transactions
WHERE amount <= 0;

-- Verify all transaction types are valid
SELECT DISTINCT txn_type
FROM transactions
WHERE txn_type NOT IN ('deposit', 'withdrawal', 'transfer');

-- step 10: PERFORMANCE ANALYSIS QUERIES

-- Show indexes on each table
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
    AND tablename IN ('customers', 'accounts', 'transactions')
ORDER BY tablename, indexname;

-- Show table sizes and row counts
SELECT 
    relname AS table_name,
    n_live_tup AS row_count,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    pg_size_pretty(pg_relation_size(relid)) AS table_size,
    pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) AS indexes_size
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(relid) DESC;

-- Show constraint information
SELECT 
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
LEFT JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
LEFT JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.table_schema = 'public'
    AND tc.table_name IN ('customers', 'accounts', 'transactions')
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;
