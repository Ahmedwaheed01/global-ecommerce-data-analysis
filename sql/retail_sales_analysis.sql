-- ============================================================
-- Online Retail — Business Analysis
-- Run against: online_retail.db
-- ============================================================


-- ============================================================
-- TABLE SCHEMA
-- ============================================================

CREATE TABLE IF NOT EXISTS retail_sales (
    InvoiceNo   TEXT    NOT NULL,
    StockCode   TEXT    NOT NULL,
    Description TEXT,
    Quantity    INTEGER NOT NULL,
    InvoiceDate TEXT    NOT NULL,
    UnitPrice   REAL    NOT NULL,
    CustomerID  INTEGER,
    Country     TEXT,
    TotalSales  REAL
);


-- ============================================================
-- 1. KPI OVERVIEW
-- ============================================================

SELECT
    ROUND(SUM(TotalSales), 2)         AS TotalRevenue,
    COUNT(DISTINCT InvoiceNo)         AS TotalOrders,
    COUNT(DISTINCT CustomerID)        AS TotalCustomers,
    COUNT(DISTINCT StockCode)         AS UniqueProducts,
    COUNT(DISTINCT Country)           AS CountriesServed
FROM retail_sales;


-- ============================================================
-- 2. AVERAGE ORDER VALUE
--    (average revenue per unique invoice, not AVG(TotalSales))
-- ============================================================

SELECT
    COUNT(DISTINCT InvoiceNo)                          AS TotalOrders,
    ROUND(AVG(order_total), 2)                         AS AvgOrderValue
FROM (
    SELECT InvoiceNo,
           SUM(TotalSales) AS order_total
    FROM   retail_sales
    GROUP  BY InvoiceNo
);


-- ============================================================
-- 3. TOP 10 CUSTOMERS BY REVENUE
-- ============================================================

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo)         AS TotalOrders,
    SUM(Quantity)                     AS TotalItemsBought,
    ROUND(SUM(TotalSales), 2)         AS TotalRevenue
FROM retail_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY TotalRevenue DESC
LIMIT 10;


-- ============================================================
-- 4. TOP 10 PRODUCTS BY QUANTITY SOLD
--    (excludes non-product/service lines: postage & manual entries)
-- ============================================================

SELECT
    StockCode,
    Description,
    SUM(Quantity)                     AS TotalQuantity,
    ROUND(SUM(TotalSales), 2)         AS TotalRevenue,
    ROUND(AVG(UnitPrice), 2)          AS AvgUnitPrice
FROM retail_sales
WHERE Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
GROUP BY StockCode, Description
ORDER BY TotalQuantity DESC
LIMIT 10;


-- ============================================================
-- 5. TOP 10 PRODUCTS BY REVENUE
--    (excludes non-product/service lines: postage & manual entries)
-- ============================================================

SELECT
    StockCode,
    Description,
    ROUND(SUM(TotalSales), 2)         AS TotalRevenue,
    SUM(Quantity)                     AS TotalQuantity,
    ROUND(AVG(UnitPrice), 2)          AS AvgUnitPrice
FROM retail_sales
WHERE Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
GROUP BY StockCode, Description
ORDER BY TotalRevenue DESC
LIMIT 10;


-- ============================================================
-- 6. REVENUE BY COUNTRY
--    (includes all countries, e.g. United Kingdom)
-- ============================================================

SELECT
    Country,
    COUNT(DISTINCT InvoiceNo)         AS TotalOrders,
    COUNT(DISTINCT CustomerID)        AS TotalCustomers,
    ROUND(SUM(TotalSales), 2)         AS TotalRevenue
FROM retail_sales
GROUP BY Country
ORDER BY TotalRevenue DESC;


-- ============================================================
-- 7. MONTHLY REVENUE TREND
-- ============================================================

SELECT
    CAST(STRFTIME('%Y', InvoiceDate) AS INTEGER)      AS Year,
    CAST(STRFTIME('%m', InvoiceDate) AS INTEGER)      AS Month,
    CASE CAST(STRFTIME('%m', InvoiceDate) AS INTEGER)
        WHEN 1  THEN 'Jan'
        WHEN 2  THEN 'Feb'
        WHEN 3  THEN 'Mar'
        WHEN 4  THEN 'Apr'
        WHEN 5  THEN 'May'
        WHEN 6  THEN 'Jun'
        WHEN 7  THEN 'Jul'
        WHEN 8  THEN 'Aug'
        WHEN 9  THEN 'Sep'
        WHEN 10 THEN 'Oct'
        WHEN 11 THEN 'Nov'
        WHEN 12 THEN 'Dec'
    END                                                AS MonthName,
    COUNT(DISTINCT InvoiceNo)                          AS TotalOrders,
    ROUND(SUM(TotalSales), 2)                          AS TotalRevenue
FROM retail_sales
GROUP BY Year, Month, MonthName
ORDER BY Year, Month;


-- ============================================================
-- 8. REVENUE BY DAY OF WEEK
--    (ordered Monday → Sunday to match the notebook / Power BI)
-- ============================================================

SELECT
    CASE CAST(STRFTIME('%w', InvoiceDate) AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END                               AS DayOfWeek,
    COUNT(DISTINCT InvoiceNo)         AS TotalOrders,
    ROUND(SUM(TotalSales), 2)         AS TotalRevenue
FROM retail_sales
GROUP BY DayOfWeek
ORDER BY CASE CAST(STRFTIME('%w', InvoiceDate) AS INTEGER)
             WHEN 1 THEN 1   -- Monday
             WHEN 2 THEN 2
             WHEN 3 THEN 3
             WHEN 4 THEN 4
             WHEN 5 THEN 5
             WHEN 6 THEN 6
             WHEN 0 THEN 7   -- Sunday
         END;


-- ============================================================
-- 9. RFM PREPARATION  (snapshot: 2011-12-10)
--    CustomerID, Recency, Frequency, Monetary
-- ============================================================

SELECT
    CustomerID,
    CAST(
        JULIANDAY('2011-12-10') - JULIANDAY(MAX(InvoiceDate))
    AS INTEGER)                       AS Recency,
    COUNT(DISTINCT InvoiceNo)         AS Frequency,
    ROUND(SUM(TotalSales), 2)         AS Monetary
FROM retail_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY Monetary DESC;
