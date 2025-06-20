-- Database Setup and Initialization
-- This section prepares the database for our sales data analysis.

-- Connect to the 'Gemini' Database
USE Gemini;
GO

-- Turn Off Row Count Messages
-- This command prevents messages like "(1 row affected)" from appearing after each query,
-- making the output cleaner and easier to read.
SET NOCOUNT ON;
GO

-- Clean Up Existing Sales Data Table (if it exists)
-- This checks if a table named 'Sales' already exists and, if so, removes it.
-- This ensures we start with a clean slate for our new data.
IF OBJECT_ID('dbo.Sales', 'U') IS NOT NULL
    DROP TABLE dbo.Sales;
GO

-- Clean Up Existing Dates Table (if it exists)
-- Similar to the 'Sales' table, this checks for and removes an existing 'Dates' table.
IF OBJECT_ID('dbo.Dates', 'U') IS NOT NULL
    DROP TABLE dbo.Dates;
GO

---
--- Data Table Creation and Population

-- Create the 'Dates' Table
-- This creates a table to store information about dates, which will be used to track sales over time.
-- It includes details like year, quarter, month, and day.
CREATE TABLE dbo.Dates
(
    DateKey INT PRIMARY KEY,              -- A unique number for each date (e.g., 20241231 for December 31, 2024).
    [Date] DATETIME,                      -- The full date and time.
    [Year] INT,                           -- The year of the date.
    [Quarter] INT,                        -- The quarter of the year (1 for Jan-Mar, 2 for Apr-Jun, etc.).
    [Month] INT,                          -- The month of the year (1 for January, 2 for February, etc.).
    [Day] INT,                            -- The day of the month.
    [Week] INT,                           -- The week number of the year.
    MonthName VARCHAR(20),                -- The name of the month (e.g., 'January').
    QuarterName VARCHAR(6)                -- The name of the quarter (e.g., 'Q1').
);
GO

-- Set Up Date Range for Data Population
-- We're defining a period to fill the 'Dates' table.
-- @StartDate is today's date, and @EndDate is 5 years before today.
DECLARE @StartDate DATETIME = GETDATE();
DECLARE @EndDate DATETIME = DATEADD(YEAR, -5, @StartDate);

-- Populate the 'Dates' Table
-- This part of the code fills the 'Dates' table with every day's information for the last 5 years.
WHILE @StartDate >= @EndDate
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
    SELECT CONVERT(INT, CONVERT(VARCHAR(8), @EndDate, 112)), -- Converts the date into a unique number (YYYYMMDD).
           @EndDate,                                         -- The actual date.
           DATEPART(YEAR, @EndDate),                           -- Extracts the year.
           DATEPART(QUARTER, @EndDate),                        -- Extracts the quarter.
           DATEPART(MONTH, @EndDate),                          -- Extracts the month.
           DATEPART(DAY, @EndDate),                            -- Extracts the day.
           DATEPART(WEEK, @EndDate),                           -- Extracts the week number.
           DATENAME(MONTH, @EndDate),                          -- Extracts the month's name.
           'Q' + CAST(DATEPART(QUARTER, @EndDate) AS VARCHAR(1)); -- Creates quarter names like 'Q1'.

    SET @EndDate = DATEADD(DAY, 1, @EndDate); -- Moves to the next day in the loop.
END;
GO

-- Create the 'Sales' Table
-- This creates a table to record individual sales transactions, including what was sold and for how much.
CREATE TABLE dbo.Sales
(
    SalesID INT IDENTITY(1, 1) PRIMARY KEY, -- A unique ID number for each sale, automatically increasing.
    DateKey INT,                          -- A link to the 'Dates' table, connecting the sale to a specific date.
    SalesAmount DECIMAL(10, 2),            -- The amount of money for the sale.
    Category VARCHAR(50),                  -- The main group the product belongs to (e.g., 'Electronics').
    Subcategory VARCHAR(50),               -- A more specific group within the category (e.g., 'Smartphones').
    Product VARCHAR(100),                  -- The name of the specific product sold.
    CONSTRAINT FK_Sales_Dates FOREIGN KEY (DateKey) REFERENCES dbo.Dates (DateKey) -- Ensures sales dates match valid dates in the 'Dates' table.
);
GO

-- Set Up Variables for Sales Data Population
-- These variables will help us generate fake sales data for testing and demonstration.
DECLARE @i INT = 1;                                      -- A counter to keep track of how many sales records we've created.
DECLARE @TotalRecords INT = 10000;                     -- The total number of fake sales records we want to generate.
DECLARE @RandomDateKey INT;                              -- Will store a randomly picked date from our 'Dates' table.
DECLARE @RandomSalesAmount DECIMAL(10, 2);               -- Will store a random sales amount.
DECLARE @RandomCategory VARCHAR(50);                     -- Will store a random product category.
DECLARE @RandomSubcategory VARCHAR(50);                  -- Will store a random product subcategory.
DECLARE @RandomProduct VARCHAR(100);                     -- Will store a random product name.

-- Populate the 'Sales' Table with Random Data
-- This loop generates and inserts 10,000 fake sales records into the 'Sales' table.
-- Each record will have a random date, sales amount, category, subcategory, and product.
WHILE @i <= @TotalRecords
BEGIN
    -- Pick a random date from the 'Dates' table.
    SELECT TOP 1 @RandomDateKey = DateKey FROM dbo.Dates ORDER BY NEWID();

    -- Generate a random sales amount between $10.00 and $5000.00.
    SET @RandomSalesAmount = ROUND((RAND() * (5000 - 10) + 10), 2);

    -- Assign a random main product category.
    SELECT @RandomCategory = CASE (ABS(CHECKSUM(NEWID())) % 4)
                                 WHEN 0 THEN 'Electronics'
                                 WHEN 1 THEN 'Clothing'
                                 WHEN 2 THEN 'Home & Garden'
                                 ELSE 'Books'
                             END;

    -- Assign a random subcategory based on the main category.
    SELECT @RandomSubcategory = CASE @RandomCategory
                                     WHEN 'Electronics' THEN
                                         CASE (ABS(CHECKSUM(NEWID())) % 3)
                                             WHEN 0 THEN 'Smartphones'
                                             WHEN 1 THEN 'Laptops'
                                             ELSE 'Accessories'
                                         END
                                     WHEN 'Clothing' THEN
                                         CASE (ABS(CHECKSUM(NEWID())) % 3)
                                             WHEN 0 THEN 'Men''s'
                                             WHEN 1 THEN 'Women''s'
                                             ELSE 'Children''s'
                                         END
                                     WHEN 'Home & Garden' THEN
                                         CASE (ABS(CHECKSUM(NEWID())) % 3)
                                             WHEN 0 THEN 'Kitchen'
                                             WHEN 1 THEN 'Furniture'
                                             ELSE 'Gardening'
                                         END
                                     WHEN 'Books' THEN
                                         CASE (ABS(CHECKSUM(NEWID())) % 3)
                                             WHEN 0 THEN 'Fiction'
                                             WHEN 1 THEN 'Non-Fiction'
                                             ELSE 'Science'
                                         END
                                 END;

    -- Create a random product name using the subcategory.
    SELECT @RandomProduct = @RandomSubcategory + ' Product ' + CHAR(65 + (ABS(CHECKSUM(NEWID())) % 26)) + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR(4));

    -- Insert the new random sales record into the 'Sales' table.
    INSERT INTO dbo.Sales (DateKey, SalesAmount, Category, Subcategory, Product)
    VALUES (@RandomDateKey, @RandomSalesAmount, @RandomCategory, @RandomSubcategory, @RandomProduct);

    SET @i = @i + 1; -- Increase the counter to create the next record.
END;
GO

---
--- Data Verification and Reporting

-- Display Status Messages
-- These messages confirm that the tables have been created and filled with data.
PRINT 'Successfully generated 10,000 random sales records.';
PRINT 'The Sales and Dates tables have been created and populated.';
PRINT '---------------------------------------------------------';
PRINT 'Sample of 10 records from the Sales table:';

-- Show a Sample of Sales Data
-- This query displays the first 10 sales records, along with their related date information,
-- to give a quick overview of the generated data.
SELECT TOP 10
    s.SalesID,             -- The unique ID for each sale.
    d.[Date],              -- The full date of the sale.
    s.SalesAmount,         -- The amount of the sale.
    s.Category,            -- The main category of the product.
    s.Subcategory,         -- The specific subcategory of the product.
    s.Product,             -- The name of the product.
    d.[Year],              -- The year of the sale.
    d.QuarterName,         -- The quarter of the year (e.g., 'Q1').
    d.MonthName,           -- The name of the month (e.g., 'January').
    d.[Week]               -- The week number of the year.
FROM dbo.Sales s           -- From the 'Sales' table (aliased as 's').
JOIN dbo.Dates d ON s.DateKey = d.DateKey -- Connects sales records to their corresponding dates.
ORDER BY d.[Date];         -- Orders the results by date, showing the oldest sales first.
GO

---
--- Advanced Sales Analysis Queries

-- Analyze Sales by Category and Subcategory (CUBE)
-- This query summarizes sales by different combinations of Category and Subcategory,
-- including totals for each category and a grand total for all sales.
SELECT s.Category,
       s.Subcategory,
       FORMAT(SUM(s.SalesAmount), '#,,#,K') AS 'Total Sales', -- Shows total sales, formatted for thousands (e.g., 1,234K).
       'GROUP BY CUBE' AS 'Grouping Type'                       -- Labels this analysis as a 'CUBE' grouping.
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
WHERE s.Subcategory IN ('Science', 'Non-Fiction', 'Accessories', 'Smartphones') -- Focuses on specific subcategories.
GROUP BY CUBE(s.Category, s.Subcategory) -- Creates all possible grouping combinations for Category and Subcategory.
ORDER BY s.Category;
GO

-- Analyze Sales by Category and Subcategory (ROLLUP)
-- This query provides a hierarchical summary of sales, first by subcategory within each category,
-- then by category totals, and finally a grand total.
SELECT s.Category,
       s.Subcategory,
       FORMAT(SUM(s.SalesAmount), '#,,#,K') AS 'Total Sales', -- Shows total sales, formatted for thousands.
       'GROUP BY ROLLUP' AS 'Grouping Type'                    -- Labels this analysis as a 'ROLLUP' grouping.
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
WHERE s.Subcategory IN ('Science', 'Non-Fiction', 'Accessories', 'Smartphones') -- Focuses on specific subcategories.
GROUP BY ROLLUP(s.Category, s.Subcategory) -- Creates hierarchical totals for Category and Subcategory.
ORDER BY s.Category;
GO

-- Analyze Sales by Category and Subcategory (GROUPING SETS)
-- This query allows us to define specific ways to group our sales data.
-- Here, it shows totals by individual categories and individual subcategories, but not all combinations.
SELECT s.Category,
       s.Subcategory,
       FORMAT(SUM(s.SalesAmount), '#,,#,K') AS 'Total Sales', -- Shows total sales, formatted for thousands.
       'GROUPING SETS' AS 'Grouping Type'                      -- Labels this analysis as 'GROUPING SETS'.
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
WHERE s.Subcategory IN ('Science', 'Non-Fiction', 'Accessories', 'Smartphones') -- Focuses on specific subcategories.
GROUP BY GROUPING SETS(s.Category, s.Subcategory) -- Groups by Category and separately by Subcategory.
ORDER BY s.Category;
GO

-- Analyze Sales by Year and Quarter (CUBE)
-- This query summarizes sales by different combinations of Year and Quarter,
-- including totals for each year and a grand total for all sales within the specified years.
SELECT d.Year,
       d.Quarter,
       FORMAT(SUM(s.SalesAmount), '#,,#,K') AS 'Total Sales', -- Shows total sales, formatted for thousands.
       'GROUP BY CUBE' AS 'Grouping Type'                       -- Labels this analysis as a 'CUBE' grouping.
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
WHERE d.Year IN (2023, 2024)                                   -- Focuses on sales data from 2023 and 2024.
GROUP BY CUBE(d.Year, d.Quarter) -- Creates all possible grouping combinations for Year and Quarter.
ORDER BY d.Year, d.Quarter;
GO

-- Analyze Sales by Year and Quarter (ROLLUP)
-- This query provides a hierarchical summary of sales by year, then by quarter within each year,
-- and finally a grand total for the selected years.
SELECT d.Year,
       d.Quarter,
       FORMAT(SUM(s.SalesAmount), '#,,#,K') AS 'Total Sales', -- Shows total sales, formatted for thousands.
       'GROUP BY ROLLUP' AS 'Grouping Type'                    -- Labels this analysis as a 'ROLLUP' grouping.
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
WHERE d.Year IN (2023, 2024)                                   -- Focuses on sales data from 2023 and 2024.
GROUP BY ROLLUP(d.Year, d.Quarter) -- Creates hierarchical totals for Year and Quarter.
ORDER BY d.Year;
GO

-- Analyze Sales by Year and Quarter (GROUPING SETS)
-- This query allows us to define specific ways to group our sales data by year and quarter.
-- Here, it shows totals by individual years and individual quarters, but not all combinations.
SELECT d.Year,
       d.Quarter,
       FORMAT(SUM(s.SalesAmount), '#,,#,K') AS 'Total Sales', -- Shows total sales, formatted for thousands.
       'GROUPING SETS' AS 'Grouping Type'                      -- Labels this analysis as 'GROUPING SETS'.
FROM dbo.Sales s
JOIN dbo.Dates d ON s.DateKey = d.DateKey
WHERE d.Year IN (2023, 2024)                                   -- Focuses on sales data from 2023 and 2024.
GROUP BY GROUPING SETS(d.Year, d.Quarter) -- Groups by Year and separately by Quarter.
ORDER BY d.Year;
GO
