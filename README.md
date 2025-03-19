# SQL Database Project

This repository contains an SQL script that demonstrates how to create and manage a relational database for customer order tracking and sales analysis. The script includes table creation, data import from existing tables, data cleanup, and several queries for analysis and reporting.

## Project Overview

The SQL script covers the following key components:
- **Table Creation**: Defines tables for `Customers`, `Orders`, and `Products` with appropriate relationships (primary and foreign keys).
- **Data Import**: Transfers data from existing tables (`Customers`, `Orders`, `Products`) into new tables for better management and analysis.
- **Data Cleanup**: Includes steps for removing duplicate records and fixing null values in the data.
- **Analysis Queries**: 
  - Totals sales by product.
  - Displays the top 5 customers by total spending.
  - Shows monthly sales trends.
- **Views Creation**: Creates SQL views (`vw_TopProducts` and `vw_TopCustomers`) for easier reporting and data access.

## How to Use

1. **Prerequisites**: 
   - Ensure you have access to an SQL Server environment (e.g., SQL Server Management Studio, Azure SQL Database).
   - Have sample `Customers`, `Orders`, and `Products` data available if you plan to run the import queries.

2. **Running the Script**:
   - Download or clone this repository.
   - Open the SQL script in your SQL management tool (e.g., SSMS).
   - Run the script to create the tables, import the data, and perform the analysis.

3. **Expected Output**:
   - The script will create three tables: `Customers_Man`, `Orders_Man`, and `Products_Man`.
   - It will clean the data (e.g., removing duplicates, fixing null values).
   - It will generate analysis reports, such as total sales by product and top customers by spending.

4. **Analysis Queries**:
   - The script includes various queries to analyze sales data, including top products and customers, as well as monthly sales trends.

## Example Queries

Here are some example queries included in the script:

### Total Sales by Product:
```sql
SELECT p.ProductName, FORMAT(SUM(o.Quantity * p.Price), 'N2') AS TotalSales
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalSales DESC;


---
## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

### Acknowledgment for Database Records:

The database records, including table structures and sample data, were generated with the assistance of **ChatGPT**, an AI language model developed by **OpenAI**. The data provided is for demonstration and educational purposes only and is not derived from real-world sources.
