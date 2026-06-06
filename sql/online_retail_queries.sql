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
-- 2. ORDER STATISTICS
-- ============================================================

SELECT
    COUNT(DISTINCT InvoiceNo)                          AS TotalOrders,
    ROUND(AVG(order_total), 2)                         AS AvgOrderValue,
    ROUND(MIN(order_total), 2)                         AS MinOrderValue,
    ROUND(MAX(order_total), 2)                         AS MaxOrderValue
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
-- ============================================================

SELECT
    StockCode,
    Description,
    SUM(Quantity)                     AS TotalQuantity,
    ROUND(SUM(TotalSales), 2)         AS TotalRevenue,
    ROUND(AVG(UnitPrice), 2)          AS AvgUnitPrice
FROM retail_sales
GROUP BY StockCode, Description
ORDER BY TotalQuantity DESC
LIMIT 10;


-- ============================================================
-- 5. TOP 10 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    StockCode,
    Description,
    ROUND(SUM(TotalSales), 2)         AS TotalRevenue,
    SUM(Quantity)                     AS TotalQuantity,
    ROUND(AVG(UnitPrice), 2)          AS AvgUnitPrice
FROM retail_sales
GROUP BY StockCode, Description
ORDER BY TotalRevenue DESC
LIMIT 10;


-- ============================================================
-- 6. REVENUE BY COUNTRY
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
-- 7. REVENUE SHARE BY COUNTRY
-- ============================================================

SELECT
    Country,
    ROUND(SUM(TotalSales), 2)                             AS TotalRevenue,
    ROUND(SUM(TotalSales) * 100.0 /
          (SELECT SUM(TotalSales) FROM retail_sales), 2)  AS RevenueSharePct
FROM retail_sales
GROUP BY Country
ORDER BY TotalRevenue DESC
LIMIT 10;


-- ============================================================
-- 8. MONTHLY REVENUE TREND
-- ============================================================

SELECT
    STRFTIME('%Y-%m', InvoiceDate)    AS YearMonth,
    COUNT(DISTINCT InvoiceNo)         AS TotalOrders,
    ROUND(SUM(TotalSales), 2)         AS TotalRevenue
FROM retail_sales
GROUP BY YearMonth
ORDER BY YearMonth;


-- ============================================================
-- 9. REVENUE BY DAY OF WEEK
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
ORDER BY CAST(STRFTIME('%w', InvoiceDate) AS INTEGER);


-- ============================================================
-- 10. AVERAGE ORDER VALUE BY COUNTRY (MIN 50 ORDERS)
-- ============================================================

SELECT
    Country,
    COUNT(DISTINCT InvoiceNo)           AS TotalOrders,
    ROUND(SUM(TotalSales) /
          COUNT(DISTINCT InvoiceNo), 2) AS AvgOrderValue
FROM retail_sales
GROUP BY Country
HAVING TotalOrders >= 50
ORDER BY AvgOrderValue DESC
LIMIT 10;


-- ============================================================
-- 11. CUSTOMER PURCHASE FREQUENCY
-- ============================================================

SELECT
    purchase_count                    AS PurchaseCount,
    COUNT(*)                          AS NumberOfCustomers
FROM (
    SELECT CustomerID,
           COUNT(DISTINCT InvoiceNo)  AS purchase_count
    FROM   retail_sales
    WHERE  CustomerID IS NOT NULL
    GROUP  BY CustomerID
)
GROUP BY purchase_count
ORDER BY purchase_count;


-- ============================================================
-- 12. INTERNATIONAL MARKET PERFORMANCE (EXCL. UK)
-- ============================================================

SELECT
    Country,
    COUNT(DISTINCT CustomerID)                  AS Customers,
    COUNT(DISTINCT InvoiceNo)                   AS Orders,
    ROUND(SUM(TotalSales), 2)                   AS Revenue,
    ROUND(SUM(TotalSales) /
          COUNT(DISTINCT InvoiceNo), 2)         AS AvgOrderValue,
    ROUND(SUM(TotalSales) /
          COUNT(DISTINCT CustomerID), 2)        AS RevenuePerCustomer
FROM retail_sales
WHERE CustomerID IS NOT NULL
  AND Country != 'United Kingdom'
GROUP BY Country
HAVING Orders >= 20
ORDER BY Revenue DESC;


-- ============================================================
-- 13. RFM BASE TABLE  (snapshot: 2011-12-10)
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
