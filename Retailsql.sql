-- Create the partition function
CREATE PARTITION FUNCTION pf_transaction_date(DATETIME)  
AS RANGE RIGHT FOR VALUES ('2023-01-01', '2024-01-01');

-- Create the partition scheme
CREATE PARTITION SCHEME ps_transaction_date  
    AS PARTITION pf_transaction_date  
    ALL TO ([PRIMARY]);

-- Create the partitioned table
CREATE TABLE customer_transactions (
    TransactionID INT IDENTITY(1,1), -- Primary key constraint will be added separately
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Category VARCHAR(50),
    Quantity INT,
    Price DECIMAL(10,2),
    TransactionDate DATETIME NOT NULL
) ON ps_transaction_date(TransactionDate);  -- Partitioning by TransactionDate

--Drop existing primary key constraint if exists (the primary key was created by default when the table was created)
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'PK_customer_transactions' AND object_id = OBJECT_ID('customer_transactions'))
    DROP INDEX PK_customer_transactions ON customer_transactions;  -- Drop the primary key

-- Create unique clustered index (necessary for partitioning)
CREATE UNIQUE CLUSTERED INDEX idx_transaction_partition
ON customer_transactions (TransactionDate, TransactionID) ON ps_transaction_date(TransactionDate); -- Corrected to ensure proper partitioning

-- Insert mock data into the customer_transactions table
DECLARE @i INT = 1;
WHILE @i <= 1000000
BEGIN
    INSERT INTO customer_transactions (CustomerName, Product, Category, Quantity, Price, TransactionDate)
    VALUES (
        'Customer ' + CAST(ABS(CHECKSUM(NEWID())) % 5000 AS VARCHAR), -- 5,000 unique customers
        'Product ' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS VARCHAR),  -- 100 unique products
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'Electronics' ELSE 'Home Appliances' END,
        ABS(CHECKSUM(NEWID())) % 10 + 1, -- Quantity between 1-10
        CAST(ROUND(RAND() * (999.99 - 10.00) + 10.00, 2) AS DECIMAL(10,2)), -- Price range: $10 - $999.99
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 730, GETDATE()) -- Random date within the last 2 years
    );
    SET @i = @i + 1;
END;

-- Query to check overall data and the partitioning logic applied
SELECT 
    $PARTITION.pf_transaction_date(TransactionDate) AS PartitionNumber,
    TransactionID, CustomerName, Price, TransactionDate
FROM customer_transactions
ORDER BY TransactionDate DESC;

-- Partition Check: Query to fetch records starting from January 1st, 2023, using partitioning logic
SELECT 
    $PARTITION.pf_transaction_date(TransactionDate) AS PartitionNumber,
    TransactionID, CustomerName, Price, TransactionDate
FROM customer_transactions
WHERE TransactionDate >= '2023-01-01'
ORDER BY TransactionDate DESC;

-- Create a non-clustered index to optimize queries on CustomerName and TransactionDate
CREATE NONCLUSTERED INDEX idx_customer_date ON customer_transactions (CustomerName, TransactionDate);

-- Query to check the records after index creation, ordered by TransactionDate
SELECT
    $PARTITION.pf_transaction_date(TransactionDate) AS PartitionNumber,
    TransactionID, CustomerName, Price, TransactionDate
FROM customer_transactions
ORDER BY TransactionDate ASC;

-- Enable statistics for query performance analysis
SET STATISTICS IO, TIME ON;
SELECT * FROM customer_transactions WHERE TransactionDate >= '2024-01-01';
