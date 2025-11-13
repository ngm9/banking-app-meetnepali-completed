-- Report: All transactions for a customer by email
-- (Very slow due to absence of join key indexes)
EXPLAIN ANALYZE
SELECT t.*
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE c.email = 'alice@example.com';

-- Report: Total balance per customer
EXPLAIN ANALYZE
SELECT c.email, SUM(a.balance) AS total_balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.email;

-- Report: Accounts with large transaction volumes
EXPLAIN ANALYZE
SELECT a.account_number, COUNT(t.transaction_id) AS txn_count
FROM accounts a
JOIN transactions t ON t.account_id = a.account_id
GROUP BY a.account_number
HAVING COUNT(t.transaction_id) > 100;