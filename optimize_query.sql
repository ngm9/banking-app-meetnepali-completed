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
