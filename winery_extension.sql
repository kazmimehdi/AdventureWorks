USE AdventureWorks2022;
GO

CREATE OR ALTER VIEW Sales.vCustomerTier
AS
    SELECT
        CustomerID,
        CustomerName,
        TotalSales,
        OrderCount,
        CASE
            WHEN TotalSales >= 10000 THEN N'Gold'
            WHEN TotalSales >= 2500 THEN N'Silver'
            ELSE N'Bronze'
        END AS CustomerTier
    FROM Sales.vCustomerOrderAggregate;
GO

-- Counts include every customer in the view. Averages exclude customers
-- without orders so zero-order Bronze customers do not depress the metrics.
DECLARE @AsOfDate date =
(
    SELECT CONVERT(date, MAX(OrderDate))
    FROM Sales.SalesOrderHeader
);

WITH TierList AS
(
    SELECT CustomerTier, SortOrder
    FROM (VALUES
        (N'Gold', 1),
        (N'Silver', 2),
        (N'Bronze', 3)
    ) AS tiers(CustomerTier, SortOrder)
)
SELECT
    tiers.CustomerTier,
    COUNT(customers.CustomerID) AS CustomerCount,
    COUNT(CASE WHEN customers.OrderCount > 0 THEN 1 END) AS PurchasingCustomerCount,
    AVG(CASE WHEN customers.OrderCount > 0
        THEN CONVERT(decimal(19, 2), customers.TotalSales)
    END) AS AverageRevenuePerPurchasingCustomer,
    AVG(CASE WHEN customers.OrderCount > 0
        THEN CONVERT(decimal(19, 2), customers.OrderCount)
    END) AS AverageOrderCountPerPurchasingCustomer
FROM TierList AS tiers
LEFT JOIN Sales.vCustomerTier AS customers
    ON customers.CustomerTier = tiers.CustomerTier
GROUP BY tiers.CustomerTier, tiers.SortOrder
ORDER BY tiers.SortOrder;

-- Use the dataset's latest order as its as-of date to avoid aging this static
-- sample beyond its last observed transaction. For live winery data, set
-- @AsOfDate to the current date instead.
WITH CustomerTenure AS
(
    SELECT
        CustomerID,
        DATEDIFF(day, MIN(OrderDate), @AsOfDate) / 365.25 AS TenureYears
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
),
AnnualizedRevenue AS
(
    SELECT
        tier.CustomerTier,
        CONVERT(decimal(19, 4), tier.TotalSales)
            / NULLIF(tenure.TenureYears, 0.0) AS RevenuePerYear
    FROM Sales.vCustomerTier AS tier
    INNER JOIN CustomerTenure AS tenure
        ON tenure.CustomerID = tier.CustomerID
    WHERE tier.OrderCount > 0
)
SELECT
    CustomerTier,
    COUNT(RevenuePerYear) AS CustomersWithMeasurableTenure,
    AVG(RevenuePerYear) AS AverageRevenuePerYear
FROM AnnualizedRevenue
GROUP BY CustomerTier
ORDER BY
    CASE CustomerTier
        WHEN N'Gold' THEN 1
        WHEN N'Silver' THEN 2
        ELSE 3
    END;
GO
