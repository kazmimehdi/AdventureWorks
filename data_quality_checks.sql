USE AdventureWorks2022;
GO

-- Duplicate candidates are Sales.Customer people only. A name match is
-- reported only when a normalized email or normalized address also matches.
WITH CustomerPeople AS
(
    SELECT
        c.CustomerID,
        p.BusinessEntityID,
        p.FirstName,
        p.LastName
    FROM Sales.Customer AS c
    INNER JOIN Person.Person AS p
        ON p.BusinessEntityID = c.PersonID
    WHERE NULLIF(LTRIM(RTRIM(p.FirstName)), N'') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(p.LastName)), N'') IS NOT NULL
),
DuplicateEmailCandidates AS
(
    SELECT
        N'Name + email' AS MatchBasis,
        UPPER(LTRIM(RTRIM(cp.FirstName))) AS NormalizedFirstName,
        UPPER(LTRIM(RTRIM(cp.LastName))) AS NormalizedLastName,
        CONVERT(nvarchar(4000), LOWER(LTRIM(RTRIM(ea.EmailAddress)))) AS ContactValue,
        COUNT(DISTINCT cp.CustomerID) AS MatchingCustomers
    FROM CustomerPeople AS cp
    INNER JOIN Person.EmailAddress AS ea
        ON ea.BusinessEntityID = cp.BusinessEntityID
    WHERE NULLIF(LTRIM(RTRIM(ea.EmailAddress)), N'') IS NOT NULL
    GROUP BY
        UPPER(LTRIM(RTRIM(cp.FirstName))),
        UPPER(LTRIM(RTRIM(cp.LastName))),
        LOWER(LTRIM(RTRIM(ea.EmailAddress)))
    HAVING COUNT(DISTINCT cp.CustomerID) > 1
),
DuplicateAddressCandidates AS
(
    SELECT
        N'Name + address' AS MatchBasis,
        UPPER(LTRIM(RTRIM(cp.FirstName))) AS NormalizedFirstName,
        UPPER(LTRIM(RTRIM(cp.LastName))) AS NormalizedLastName,
        CONVERT(nvarchar(4000), CONCAT(
            UPPER(LTRIM(RTRIM(a.AddressLine1))), N'|',
            UPPER(LTRIM(RTRIM(a.AddressLine2))), N'|',
            UPPER(LTRIM(RTRIM(a.City))), N'|',
            UPPER(LTRIM(RTRIM(a.PostalCode)))
        )) AS ContactValue,
        COUNT(DISTINCT cp.CustomerID) AS MatchingCustomers
    FROM CustomerPeople AS cp
    INNER JOIN Person.BusinessEntityAddress AS bea
        ON bea.BusinessEntityID = cp.BusinessEntityID
    INNER JOIN Person.Address AS a
        ON a.AddressID = bea.AddressID
    WHERE NULLIF(LTRIM(RTRIM(a.AddressLine1)), N'') IS NOT NULL
    GROUP BY
        UPPER(LTRIM(RTRIM(cp.FirstName))),
        UPPER(LTRIM(RTRIM(cp.LastName))),
        UPPER(LTRIM(RTRIM(a.AddressLine1))),
        UPPER(LTRIM(RTRIM(a.AddressLine2))),
        UPPER(LTRIM(RTRIM(a.City))),
        UPPER(LTRIM(RTRIM(a.PostalCode)))
    HAVING COUNT(DISTINCT cp.CustomerID) > 1
)
SELECT MatchBasis, NormalizedFirstName, NormalizedLastName, ContactValue, MatchingCustomers
FROM DuplicateEmailCandidates
UNION ALL
SELECT MatchBasis, NormalizedFirstName, NormalizedLastName, ContactValue, MatchingCustomers
FROM DuplicateAddressCandidates
ORDER BY MatchingCustomers DESC, NormalizedLastName, NormalizedFirstName, MatchBasis;
GO

-- Duplicate email candidates after trimming and case normalization.
SELECT
    LOWER(LTRIM(RTRIM(EmailAddress))) AS NormalizedEmailAddress,
    COUNT(DISTINCT ea.BusinessEntityID) AS MatchingPeople
FROM Person.EmailAddress AS ea
INNER JOIN Sales.Customer AS c
    ON c.PersonID = ea.BusinessEntityID
WHERE NULLIF(LTRIM(RTRIM(ea.EmailAddress)), N'') IS NOT NULL
GROUP BY LOWER(LTRIM(RTRIM(ea.EmailAddress)))
HAVING COUNT(DISTINCT ea.BusinessEntityID) > 1
ORDER BY MatchingPeople DESC, NormalizedEmailAddress;
GO

-- Missing names, blank optional middle names, leading/trailing or repeated
-- spaces, and names stored entirely in upper- or lower-case.
SELECT
    BusinessEntityID,
    CustomerID,
    FirstName,
    MiddleName,
    LastName
FROM Sales.Customer AS c
INNER JOIN Person.Person AS p
    ON p.BusinessEntityID = c.PersonID
WHERE p.FirstName IS NULL
   OR NULLIF(LTRIM(RTRIM(p.FirstName)), N'') IS NULL
   OR p.LastName IS NULL
   OR NULLIF(LTRIM(RTRIM(p.LastName)), N'') IS NULL
   OR (p.MiddleName IS NOT NULL AND LTRIM(RTRIM(p.MiddleName)) = N'')
   OR (p.FirstName IS NOT NULL AND
       (DATALENGTH(LTRIM(RTRIM(p.FirstName))) <> DATALENGTH(p.FirstName)
        OR p.FirstName LIKE N'%  %'))
   OR (p.MiddleName IS NOT NULL AND
       (DATALENGTH(LTRIM(RTRIM(p.MiddleName))) <> DATALENGTH(p.MiddleName)
        OR p.MiddleName LIKE N'%  %'))
   OR (p.LastName IS NOT NULL AND
       (DATALENGTH(LTRIM(RTRIM(p.LastName))) <> DATALENGTH(p.LastName)
        OR p.LastName LIKE N'%  %'))
   OR (LEN(p.FirstName) > 1 AND
       (p.FirstName COLLATE Latin1_General_100_BIN2 = UPPER(p.FirstName) COLLATE Latin1_General_100_BIN2
        OR p.FirstName COLLATE Latin1_General_100_BIN2 = LOWER(p.FirstName) COLLATE Latin1_General_100_BIN2))
   OR (LEN(p.LastName) > 1 AND
       (p.LastName COLLATE Latin1_General_100_BIN2 = UPPER(p.LastName) COLLATE Latin1_General_100_BIN2
        OR p.LastName COLLATE Latin1_General_100_BIN2 = LOWER(p.LastName) COLLATE Latin1_General_100_BIN2))
ORDER BY BusinessEntityID;
GO

-- Crosswalk template for integrating client source systems. Create and load
-- this in an integration/staging database after reviewing merge decisions.
-- CREATE TABLE dbo.CustomerCrosswalk
-- (
--     SourceSystem nvarchar(100) NOT NULL,
--     SourceID nvarchar(100) NOT NULL,
--     MasterCustomerID int NOT NULL,
--     CONSTRAINT PK_CustomerCrosswalk PRIMARY KEY (SourceSystem, SourceID)
-- );
--
-- Illustrative mappings only:
-- INSERT dbo.CustomerCrosswalk (SourceSystem, SourceID, MasterCustomerID)
-- VALUES (N'WineryCRM', N'C-1042', 1001),
--        (N'StorePOS', N'P-773', 1001);
--
-- Keep the record with verified/current contact details, preserve its stable
-- master key and related history, and retain one crosswalk row per source ID.
