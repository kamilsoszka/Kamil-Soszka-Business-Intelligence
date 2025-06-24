-- General Settings
-- Disables the message that shows the number of rows affected by a Transact-SQL statement.
SET NOCOUNT ON;
GO

-- Table Dropping
-- Checks if the 'Sales' table exists and drops it to ensure a clean slate for recreation.
IF OBJECT_ID('dbo.Sales', 'U') IS NOT NULL
    DROP TABLE dbo.Sales;
GO

-- Checks if the 'Dates' table exists and drops it to ensure a clean slate for recreation.
IF OBJECT_ID('dbo.Dates', 'U') IS NOT NULL
    DROP TABLE dbo.Dates;
GO

-- Dates Table Creation
-- Creates the 'Dates' table which will act as a dimension table for time-based analysis.
CREATE TABLE dbo.Dates
(
    DateKey INT PRIMARY KEY,         -- Unique key for each date (e.g., YYYYMMDD)
    [Date] DATETIME,                 -- Full date
    [Year] INT,                      -- Year part of the date
    [Quarter] INT,                   -- Quarter part of the date (1-4)
    [Month] INT,                     -- Month part of the date (1-12)
    [Day] INT,                       -- Day part of the date (1-31)
    [Week] INT,                      -- Week number of the year
    MonthName VARCHAR(20),           -- Full name of the month (e.g., January)
    QuarterName VARCHAR(6)           -- Name of the quarter (e.g., Q1, Q2)
);
GO

-- Populating Dates Table
-- Declares variables for the start and end dates for populating the Dates table.
DECLARE @StartDate DATETIME = GETDATE();
DECLARE @EndDate DATETIME = DATEADD(YEAR, -5, @StartDate); -- Populates dates for the last 5 years

-- Loop to insert each day from @EndDate up to @StartDate into the Dates table.
WHILE @EndDate <= @StartDate
BEGIN
    INSERT INTO dbo.Dates
    (
        DateKey,
        [Date],
        [Year],
        [Quarter],
        [Month],
        [Day],
        [Week],
        MonthName,
        QuarterName
    )
    SELECT CONVERT(INT, CONVERT(VARCHAR(8), @EndDate, 112)), -- Converts date to INT (YYYYMMDD)
           @EndDate,
           DATEPART(YEAR, @EndDate),
           DATEPART(QUARTER, @EndDate),
           DATEPART(MONTH, @EndDate),
           DATEPART(DAY, @EndDate),
           DATEPART(WEEK, @EndDate),
           DATENAME(MONTH, @EndDate),
           'Q' + CAST(DATEPART(QUARTER, @EndDate) AS VARCHAR(1));

    SET @EndDate = DATEADD(DAY, 1, @EndDate); -- Increments the date by one day
END;
GO

-- Sales Table Creation
-- Creates the 'Sales' fact table to store sales transaction data.
CREATE TABLE dbo.Sales
(
    SalesID INT IDENTITY(1, 1) PRIMARY KEY, -- Unique identifier for each sales record
    DateKey INT,                          -- Foreign key linking to the Dates table
    SalesAmount DECIMAL(10, 2),           -- Total sales amount for the transaction
    Price DECIMAL(10, 2),                 -- Price of a single unit of the product
    QuantitySold INT,                     -- Number of units sold in the transaction
    Category VARCHAR(50),                 -- Product category (e.g., Electronics, Clothing)
    Subcategory VARCHAR(50),              -- Product subcategory (e.g., Smartphones, Laptops)
    Product VARCHAR(100),                 -- Name of the product
    CONSTRAINT FK_Sales_Dates FOREIGN KEY (DateKey) REFERENCES dbo.Dates (DateKey) -- Foreign key constraint
);
GO

-- Product Data Initialization
-- Declares a table variable to hold static product information for simulation.
DECLARE @Products TABLE (
    ProductID INT IDENTITY(1,1),
    ProductName VARCHAR(100),
    CategoryName VARCHAR(50),
    SubcategoryName VARCHAR(50),
    BasePrice DECIMAL(10, 2)
);

-- Populates the @Products table with sample product data.
INSERT INTO @Products (ProductName, CategoryName, SubcategoryName, BasePrice) VALUES
('Smartphone X', 'Electronics', 'Smartphones', 899.99),
('Smartphone Y', 'Electronics', 'Smartphones', 799.99),
('Laptop A', 'Electronics', 'Laptops', 1499.99),
('Laptop B', 'Electronics', 'Laptops', 1299.99),
('Headphones Z', 'Electronics', 'Accessories', 49.99),
('Charger Kit', 'Electronics', 'Accessories', 25.00),
('Men''s Classic Shirt', 'Clothing', 'Men''s', 65.00),
('Men''s Casual Jeans', 'Clothing', 'Men''s', 85.00),
('Women''s Summer Dress', 'Clothing', 'Women''s', 95.00),
('Women''s Silk Blouse', 'Clothing', 'Women''s', 70.00),
('Kid''s Play T-shirt', 'Clothing', 'Children''s', 20.00),
('Kid''s Denim Shorts', 'Clothing', 'Children''s', 30.00),
('Blender Pro', 'Home & Garden', 'Kitchen', 120.00),
('Coffee Maker Deluxe', 'Home & Garden', 'Kitchen', 80.00),
('Ergonomic Chair', 'Home & Garden', 'Furniture', 350.00),
('Dining Table Set', 'Home & Garden', 'Furniture', 600.00),
('Gardening Gloves Set', 'Home & Garden', 'Gardening', 15.00),
('Garden Shovel Heavy Duty', 'Home & Garden', 'Gardening', 35.00),
('Fantasy Novel Series', 'Books', 'Fiction', 25.99),
('Thriller Best Seller', 'Books', 'Fiction', 18.50),
('History of the World', 'Books', 'Non-Fiction', 35.00),
('Biography of Innovators', 'Books', 'Non-Fiction', 28.00),
('Advanced Physics Book', 'Books', 'Science', 45.00),
('Chemistry Lab Guide', 'Books', 'Science', 22.00);

-- Populating Sales Table
-- Uses a Common Table Expression (CTE) to generate daily product sales data.
WITH DailyProductSales AS (
    SELECT
        d.DateKey,
        p.ProductName,
        p.CategoryName,
        p.SubcategoryName,
        p.BasePrice,
        FLOOR(RAND(CHECKSUM(NEWID())) * (5 - 1) + 1) AS CalculatedQuantity -- Generates a random quantity between 1 and 4
    FROM dbo.Dates d
    CROSS JOIN @Products p -- Creates a Cartesian product to generate sales for each product on each date
)
-- Inserts the generated sales data into the dbo.Sales table.
INSERT INTO dbo.Sales (DateKey, SalesAmount, Price, QuantitySold, Category, Subcategory, Product)
SELECT
    dps.DateKey,
    dps.BasePrice * dps.CalculatedQuantity AS SalesAmount, -- Calculates total sales amount
    dps.BasePrice AS Price,
    dps.CalculatedQuantity AS QuantitySold,
    dps.CategoryName,
    dps.SubcategoryName,
    dps.ProductName
FROM DailyProductSales dps;
GO

-- Verification and Sample Data
-- Displays the total number of sales records generated.
DECLARE @ActualTotalRecords INT;
SELECT @ActualTotalRecords = COUNT(*) FROM dbo.Sales;
PRINT 'Successfully generated ' + CAST(@ActualTotalRecords AS VARCHAR(10)) + ' sales records.';
PRINT 'The Sales and Dates tables have been created and populated.';
PRINT '---------------------------------------------------------';
PRINT 'Sample of 10 records from the Sales table:';

-- Selects and displays the top 10 sales records, joining with the Dates table for full date information.
SELECT TOP 10
    s.SalesID,
    d.[Date],
    s.SalesAmount,
    s.Price,
    s.QuantitySold,
    s.Category,
    s.Subcategory,
    s.Product,
    d.[Year],
    d.QuarterName,
    d.MonthName,
    d.[Week]
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
ORDER BY d.[Date];
GO

-- Sales Analysis - GROUP BY CUBE (Category, Subcategory)
-- Aggregates sales data using CUBE for Category and Subcategory, providing grand totals and subtotals.
SELECT s.Category,
       s.Subcategory,
       FORMAT(SUM(s.SalesAmount), '#,,#,K') AS 'Total Sales', -- Formats sales amount for readability
       'GROUP BY CUBE' AS 'Grouping Type'
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
WHERE s.Subcategory IN ('Science', 'Non-Fiction', 'Accessories', 'Smartphones')
GROUP BY CUBE(s.Category, s.Subcategory) -- Generates all possible groupings
ORDER BY s.Category;
GO

-- Sales Analysis - GROUP BY ROLLUP (Category, Subcategory)
-- Aggregates sales data using ROLLUP for Category and Subcategory, providing hierarchical subtotals and a grand total.
SELECT s.Category,
       s.Subcategory,
       FORMAT(SUM(s.SalesAmount), '#,,#,K') AS 'Total Sales',
       'GROUP BY ROLLUP' AS 'Grouping Type'
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
WHERE s.Subcategory IN ('Science', 'Non-Fiction', 'Accessories', 'Smartphones')
GROUP BY ROLLUP(s.Category, s.Subcategory) -- Generates hierarchical groupings
ORDER BY s.Category;
GO

-- Sales Analysis - GROUPING SETS (Category, Subcategory)
-- Aggregates sales data using GROUPING SETS for specific groupings of Category and Subcategory.
SELECT s.Category,
       s.Subcategory,
       FORMAT(SUM(s.SalesAmount), '#,,#,K') AS 'Total Sales',
       'GROUPING SETS' AS 'Grouping Type'
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
WHERE s.Subcategory IN ('Science', 'Non-Fiction', 'Accessories', 'Smartphones')
GROUP BY GROUPING SETS(s.Category, s.Subcategory) -- Specifies individual grouping combinations
ORDER BY s.Category;
GO

-- Sales Analysis - GROUP BY CUBE (Year, Quarter)
-- Aggregates sales data using CUBE for Year and Quarter.
SELECT d.Year,
       d.Quarter,
       FORMAT(SUM(s.SalesAmount), '#,,#,K') AS 'Total Sales',
       'GROUP BY CUBE' AS 'Grouping Type'
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
WHERE d.Year IN (2023, 2024)
GROUP BY CUBE(d.Year, d.Quarter)
ORDER BY d.Year, d.Quarter;
GO

-- Sales Analysis - GROUP BY ROLLUP (Year, Quarter)
-- Aggregates sales data using ROLLUP for Year and Quarter.
SELECT d.Year,
       d.Quarter,
       FORMAT(SUM(s.SalesAmount), '#,,#,K') AS 'Total Sales',
       'GROUP BY ROLLUP' AS 'Grouping Type'
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
WHERE d.Year IN (2023, 2024)
GROUP BY ROLLUP(d.Year, d.Quarter)
ORDER BY d.Year;
GO

-- Sales Analysis - GROUPING SETS (Year, Quarter)
-- Aggregates sales data using GROUPING SETS for specific groupings of Year and Quarter.
SELECT d.Year,
       d.Quarter,
       FORMAT(SUM(s.SalesAmount), '#,,#,K') AS 'Total Sales',
       'GROUPING SETS' AS 'Grouping Type'
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
WHERE d.Year IN (2023, 2024)
GROUP BY GROUPING SETS(d.Year, d.Quarter)
ORDER BY d.Year;
GO

-- Detailed Sales Figures
PRINT '---------------------------------------------------------';
PRINT 'Sales Figures by Product and Date:';
-- Provides a detailed view of sales amounts grouped by date and product.
SELECT
    d.[Date],
    s.Product,
    FORMAT(SUM(s.SalesAmount), '#,,#.00') AS 'Total Sales Amount'
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
GROUP BY d.[Date], s.Product
ORDER BY d.[Date], s.Product;
GO

-- Aggregated Sales by Product Details
-- Shows aggregated sales, price, and quantity for each product, category, and subcategory.
SELECT
    FORMAT(SUM([SalesAmount]), '#,,#')          'Sales v1', -- Sum of pre-calculated SalesAmount
    FORMAT(SUM([Price] * [QuantitySold]), '#,,#') 'Sales v2', -- Recalculated sales (Price * QuantitySold)
    MAX([Price])                                'Price',      -- Maximum price for the product
    FORMAT(SUM([QuantitySold]), '#,,#')         'Quantity',   -- Total quantity sold
    [Category],
    [Subcategory],
    [Product]
FROM
    [dbo].[Sales] -- Assuming the database context is 'Gemini' as per the original script
GROUP BY
    [Category],
    [Subcategory],
    [Product];
