/*
================================================================================
 SuperMart-TSQL-Capstone
 Introduction to T-SQL Capstone Project
================================================================================
*/


-- ============================================================
--               ACTIVITY 1 - CREATE THE DATABASE
-- ============================================================

-- Create the database
CREATE DATABASE SuperMart_Db;
GO

USE SuperMart_Db;
GO

--- Customers table ---
-- Only Phone is allowed to be NULL; everything else is mandatory.
CREATE TABLE Customers (
    CustomerId  INT IDENTITY(1,1) NOT NULL,
    FirstName   VARCHAR(50)       NOT NULL,
    LastName    VARCHAR(50)       NOT NULL,
    City        VARCHAR(50)       NOT NULL,
    Country     VARCHAR(50)       NOT NULL,   -- province/region, see note above
    Phone       VARCHAR(20)       NULL,       -- the only nullable column
    Email       VARCHAR(100)      NOT NULL,
    CONSTRAINT PK_Customers PRIMARY KEY (CustomerId)
);
GO

--- Orders table ---
-- StatusCode is restricted to P (Pending), D (Delivered), C (Canceled).
CREATE TABLE Orders (
    OrderId     INT IDENTITY(1,1) NOT NULL,
    CustomerId  INT                NOT NULL,
    OrderDate   DATE               NOT NULL,
    StatusCode  CHAR(1)            NOT NULL,
    TotalAmount DECIMAL(10,2)      NOT NULL,
    CONSTRAINT PK_Orders PRIMARY KEY (OrderId),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId)
        REFERENCES Customers(CustomerId),
    CONSTRAINT CK_Orders_StatusCode CHECK (StatusCode IN ('P','D','C'))
);
GO


-- ============================================================
--              ACTIVITY 2 - POPULATE THE DATABASE
-- ============================================================

-- 7 customers across 3 provinces (Gauteng, Western Cape, KwaZulu-Natal),
-- with some NULL phone numbers, and 2 customers (CustomerId 6 and 7)
-- deliberately left with no orders.
INSERT INTO Customers (FirstName, LastName, City, Country, Phone, Email)
VALUES
    ('Thabo',   'Nkosi',        'Johannesburg', 'Gauteng',        '0821234567', 'thabo.nkosi@email.com'),
    ('Lerato',  'Dlamini',      'Pretoria',     'Gauteng',        NULL,         'lerato.dlamini@email.com'),
    ('Sipho',   'Khumalo',      'Cape Town',    'Western Cape',   '0712345678', 'sipho.khumalo@email.com'),
    ('Naledi',  'Mokoena',      'Johannesburg', 'Gauteng',        NULL,         'naledi.mokoena@email.com'),
    ('Johan',   'van der Merwe','Cape Town',    'Western Cape',   '0833456789', 'johan.vandermerwe@email.com'),
    ('Zanele',  'Mthembu',      'Durban',       'KwaZulu-Natal',  '0844567890', 'zanele.mthembu@email.com'),
    ('Pieter',  'Botha',        'Pretoria',     'Gauteng',        NULL,         'pieter.botha@email.com');
GO

-- 10 orders, spread across 2026, with different amounts and statuses.
-- Customers 6 (Zanele) and 7 (Pieter) intentionally have no orders.
INSERT INTO Orders (CustomerId, OrderDate, StatusCode, TotalAmount)
VALUES
    (1, '2026-01-15', 'D', 1250.00),
    (2, '2026-02-10', 'P',  899.50),
    (3, '2026-03-05', 'D', 2100.75),
    (1, '2026-04-20', 'C',  450.00),
    (4, '2026-01-28', 'D', 3200.00),
    (5, '2026-05-12', 'P',  675.25),
    (2, '2026-06-30', 'D', 1899.99),
    (3, '2026-07-14', 'C',  320.00),
    (4, '2026-08-22', 'D', 4500.50),
    (5, '2026-03-25', 'P', 1100.00);
GO


-- ============================================================
--              ACTIVITY 3 - BASIC DATA RETRIEVAL
-- ============================================================
-- Customer contact report for the Sales Manager.

SELECT
    CustomerId,
    FirstName + ' ' + LastName            AS [Customer Name],
    Country,
    City,
    COALESCE(Phone, 'No Phone Number')    AS Phone
FROM Customers;
GO


-- ============================================================
--              ACTIVITY 4 - FILTERING DATA
-- ============================================================

-- --- A) Customers in Gauteng (Joburg & Pretoria) using IN ---
SELECT
    FirstName + ' ' + LastName AS [Customer Name],
    Email,
    City
FROM Customers
WHERE City IN ('Johannesburg', 'Pretoria');
GO

--- B) Orders placed in Q1 2026 using BETWEEN ---
SELECT
    OrderId,
    CustomerId,
    OrderDate,
    StatusCode AS Status,
    TotalAmount
FROM Orders
WHERE OrderDate BETWEEN '2026-01-01' AND '2026-03-31';
GO


-- ============================================================
--                     ACTIVITY 5 - SQL JOINS
-- ============================================================

--- INNER JOIN --- customers who have placed orders
SELECT
    c.FirstName + ' ' + c.LastName AS [Customer Name],
    o.OrderId,
    o.OrderDate,
    o.TotalAmount
FROM Customers c
INNER JOIN Orders o ON c.CustomerId = o.CustomerId;
GO

--- LEFT JOIN --- all customers, including those with no orders
SELECT
    c.FirstName + ' ' + c.LastName AS [Customer Name],
    o.OrderId,
    o.OrderDate,
    o.TotalAmount
FROM Customers c
LEFT JOIN Orders o ON c.CustomerId = o.CustomerId;
GO

--- RIGHT JOIN --- every order, including any without a matching customer
SELECT
    c.FirstName + ' ' + c.LastName AS [Customer Name],
    o.OrderId,
    o.OrderDate,
    o.TotalAmount
FROM Customers c
RIGHT JOIN Orders o ON c.CustomerId = o.CustomerId;
GO

--- FULL OUTER JOIN --- data integrity audit: every customer and every order
SELECT
    c.FirstName + ' ' + c.LastName AS [Customer Name],
    o.OrderId,
    o.OrderDate,
    o.TotalAmount
FROM Customers c
FULL OUTER JOIN Orders o ON c.CustomerId = o.CustomerId;
GO


-- ============================================================
-- ACTIVITY 6 - SORTING, AGGREGATION, DATE AND STRING FUNCTIONS
-- ============================================================

--- Task 1: customer directory, sorted alphabetically by first name ---
SELECT
    UPPER(FirstName + ' ' + LastName) AS [Customer Name],
    Country,
    LEN(FirstName)                    AS FirstNameLength
FROM Customers
ORDER BY FirstName ASC;
GO

--- Task 2: customer distribution by country/region ---
SELECT
    Country,
    COUNT(*) AS TotalCustomers
FROM Customers
GROUP BY Country
ORDER BY TotalCustomers DESC;
GO

--- Task 3: order summary report ---
SELECT
    COUNT(*)         AS TotalOrders,
    AVG(TotalAmount) AS AverageOrderAmount,
    MAX(TotalAmount) AS HighestOrderAmount,
    MIN(TotalAmount) AS LowestOrderAmount
FROM Orders;
GO

--- Task 4: order activity, sorted by highest amount to lowest ---
SELECT
    OrderId,
    OrderDate,
    YEAR(OrderDate)                            AS OrderYear,
    MONTH(OrderDate)                           AS OrderMonth,
    DATEDIFF(DAY, OrderDate, GETDATE())        AS DaysSinceOrder,
    TotalAmount
FROM Orders
ORDER BY TotalAmount DESC;
GO


-- ============================================================
--      ACTIVITY 7 - ADVANCED QUERIES AND STORED PROCEDURES
-- ============================================================

--- Section A: customers who have placed at least one order ---

-- Query 1: using IN subquery
SELECT
    CustomerId,
    FirstName + ' ' + LastName AS [Customer Name],
    Country
FROM Customers
WHERE CustomerId IN (SELECT DISTINCT CustomerId FROM Orders);
GO

-- Query 2: using EXISTS subquery
SELECT
    c.CustomerId,
    c.FirstName + ' ' + c.LastName AS [Customer Name],
    c.Country
FROM Customers c
WHERE EXISTS (
    SELECT 1 FROM Orders o WHERE o.CustomerId = c.CustomerId
);
GO

--- Section B.1: View - CustomerOrders ---
CREATE VIEW CustomerOrders AS
SELECT
    c.FirstName + ' ' + c.LastName AS CustomerName,
    o.OrderDate,
    o.TotalAmount
FROM Customers c
INNER JOIN Orders o ON c.CustomerId = o.CustomerId;
GO

-- Demonstrate the view
SELECT * FROM CustomerOrders;
GO

--- Section B.2: CTE - total orders per customer ---
WITH CustomerOrderCounts AS (
    SELECT
        c.CustomerId,
        c.FirstName + ' ' + c.LastName AS CustomerName,
        COUNT(o.OrderId)               AS NumberOfOrders
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerId = o.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
)
SELECT
    CustomerName,
    NumberOfOrders
FROM CustomerOrderCounts
ORDER BY NumberOfOrders DESC;
GO

--- Section C: Stored Procedure - GetCustomerOrders ---
CREATE PROCEDURE GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        OrderId,
        OrderDate,
        StatusCode AS OrderStatus,
        TotalAmount
    FROM Orders
    WHERE CustomerId = @CustomerID;
END
GO

-- Execute the stored procedure to demonstrate it works
EXEC GetCustomerOrders @CustomerID = 1;
GO


-- ============================================================
--          ACTIVITY 8 - TRANSACTIONS AND ERROR HANDLING
-- ============================================================
-- Demonstrates a transaction wrapped in TRY...CATCH: a new order is only
-- committed if the customer exists; otherwise the error is caught and the
-- transaction is rolled back.

--- Successful case: valid CustomerId ---
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerId = 6)
        THROW 50001, 'Customer does not exist.', 1;

    INSERT INTO Orders (CustomerId, OrderDate, StatusCode, TotalAmount)
    VALUES (6, '2026-09-01', 'P', 999.99);

    COMMIT TRANSACTION;
    PRINT 'Order inserted successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH
GO

--- Failure case: invalid CustomerId, to prove the rollback works ---
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerId = 999)
        THROW 50001, 'Customer does not exist.', 1;

    INSERT INTO Orders (CustomerId, OrderDate, StatusCode, TotalAmount)
    VALUES (999, '2026-09-02', 'P', 500.00);

    COMMIT TRANSACTION;
    PRINT 'Order inserted successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH
GO

-- Confirm the failed insert was rolled back (should NOT show CustomerId 999)
SELECT * FROM Orders WHERE CustomerId = 999;
GO

-- =========================================================
--                 PART 9 - STORED PROCEDURE
-- ========================================================= 
CREATE PROCEDURE dbo.GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        OrderId,
        OrderDate,
        StatusCode AS [Order Status],
        TotalAmount
    FROM dbo.Orders
    WHERE CustomerId = @CustomerID
    ORDER BY OrderDate;
END;
GO

-- Demonstrate the procedure for CustomerID = 1 
EXEC dbo.GetCustomerOrders @CustomerID = 1;
GO

-- =========================================================
--       PART 10 - TRANSACTION AND ERROR HANDLING
-- ========================================================= 

-- Transaction: demonstrate a safe update with rollback 
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE dbo.Orders
    SET TotalAmount = TotalAmount + 100.00
    WHERE OrderId = 1001;

    PRINT 'Transaction test update completed. Rolling back for demonstration.';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT CONCAT('Transaction error: ', ERROR_MESSAGE());
END CATCH;
GO

-- TRY...CATCH demonstration with an intentional duplicate-key error 
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Orders
        (OrderId, CustomerId, OrderDate, StatusCode, TotalAmount)
    VALUES
        (1001, 1, '2026-12-31', 'P', 500.00);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        'Transaction rolled back successfully.' AS Resolution;
END CATCH;
GO

-- Final verification 
SELECT COUNT(*) AS [Customer Count] FROM dbo.Customers;
SELECT COUNT(*) AS [Order Count] FROM dbo.Orders;
GO