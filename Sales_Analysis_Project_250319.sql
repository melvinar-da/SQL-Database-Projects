create table Customers_Man (
	CustomerID int Primary Key,
	--Adds columns into tables allowing for max characters in of eng or forigen character, alt is to use text,integer,etc--
	Name NVARCHAR (100),
	Email NVARCHAR (100),
	City NVARCHAR (100),
	State NVARCHAR (100),
	JoinDate Date);

	Create table Orders_Man (
	OrderID Int Primary Key,
	CustomerID Int Foreign key references Customers (CustomerID),
	ProductID INT,
	Quanitity INT,
	OrderDate Date);

	Create Table Products_Man (
	ProductID INT PRIMARY KEY,
	ProductName NVARCHAR (100),
	Category NVARCHAR (100),
	Price Decimal (10,2));

insert into Customers_Man (CustomerID,Name, Email, City, State, JoinDate)
select CustomerID, Name, Email, City, State, JoinDate from Customers;

select * from Customers_Man

Drop Customers

insert into Orders_Man (OrderID, CustomerID, ProductID,Quantity,OrderDate)
select OrderID, CustomerID, ProductID,Quantity, OrderDate from Orders

select * from Orders_Man


Drop Orders

Insert into Products_Man (ProductID,ProductName,Category,Price)
select ProductID,ProductName,Category,Price from Products

select 8 from Products_Man

drop Products

--Cleaning process_Removing duplicates--
--Creating and naming a temp table useable in rest of query--
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY JoinDate) AS rn
    FROM Customers_Man)
DELETE FROM CTE WHERE rn > 1;
--result 0 rows affected--

--Cleaning Nulls from Quantity--
Update Orders_Man
Set Quantity = 1
Where Quantity is Null;
--result 0 rows affected--

--Analysis Queries--
--Totaling Sales by Product--
SELECT p.ProductName, format(SUM(o.Quantity * p.Price), 'N2') AS TotalSales
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalSales DESC;

--Display top 5 customer by total spending--
SELECT c.Name, SUM(o.Quantity * p.Price) AS TotalSpend
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY c.Name
ORDER BY TotalSpend DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

--Display monthly sales trends--
SELECT FORMAT(OrderDate, '2024-02') AS Month, 
       FORMAT(SUM(o.Quantity * p.Price), 'N2') AS MonthlySales
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY FORMAT(OrderDate, '2024-02')
ORDER BY Month;

--Creat Views for Easy Analysis--
vw_TopProducts AS
SELECT p.ProductName, SUM(o.Quantity * p.Price) AS TotalSales
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY p.ProductName;

CREATE VIEW vw_TopCustomers AS
SELECT c.Name, SUM(o.Quantity * p.Price) AS TotalSpend
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY c.Name;

select * from vw_TopProducts
select * from vw_TopCustomers

DROP VIEW IF EXISTS vw_TopProducts;
DROP VIEW IF EXISTS vw_TopCustomers;

CREATE VIEW vw_TopProducts AS
SELECT p.ProductName, format(SUM(o.Quantity * p.Price), 'n2') AS TotalSales
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY p.ProductName;

CREATE VIEW vw_TopCustomers AS
SELECT c.Name, format(SUM(o.Quantity * p.Price),'n2') AS TotalSpend
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY c.Name;

select * from vw_TopProducts
select * from vw_TopCustomers