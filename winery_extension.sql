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

-- Average lifetime spend and order count by tier.
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
    AVG(CONVERT(decimal(19, 2), customers.TotalSales)) AS AverageRevenue,
    AVG(CONVERT(decimal(19, 2), customers.OrderCount)) AS AverageOrderCount
FROM TierList AS tiers
LEFT JOIN Sales.vCustomerTier AS customers
    ON customers.CustomerTier = tiers.CustomerTier
GROUP BY tiers.CustomerTier, tiers.SortOrder
ORDER BY tiers.SortOrder;
GO

-- Annualized lifetime spend by tier. Tenure is measured from each customer's
-- first recorded order through today; same-day first orders have no rate yet.
WITH CustomerTenure AS
(
    SELECT
        CustomerID,
        DATEDIFF(day, MIN(OrderDate), CONVERT(date, GETDATE())) / 365.25 AS TenureYears
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
