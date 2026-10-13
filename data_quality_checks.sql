USE AdventureWorks2022;
GO

-- Duplicate person-name candidates (case- and surrounding-space-insensitive).
SELECT
    UPPER(LTRIM(RTRIM(FirstName))) AS NormalizedFirstName,
    UPPER(LTRIM(RTRIM(LastName))) AS NormalizedLastName,
    COUNT(*) AS MatchingPeople
FROM Person.Person
WHERE NULLIF(LTRIM(RTRIM(FirstName)), N'') IS NOT NULL
  AND NULLIF(LTRIM(RTRIM(LastName)), N'') IS NOT NULL
GROUP BY
    UPPER(LTRIM(RTRIM(FirstName))),
    UPPER(LTRIM(RTRIM(LastName)))
HAVING COUNT(*) > 1
ORDER BY MatchingPeople DESC, NormalizedLastName, NormalizedFirstName;
GO

-- Duplicate email candidates after trimming and case normalization.
SELECT
    LOWER(LTRIM(RTRIM(EmailAddress))) AS NormalizedEmailAddress,
    COUNT(*) AS MatchingPeople
FROM Person.EmailAddress
WHERE NULLIF(LTRIM(RTRIM(EmailAddress)), N'') IS NOT NULL
GROUP BY LOWER(LTRIM(RTRIM(EmailAddress)))
HAVING COUNT(*) > 1
ORDER BY MatchingPeople DESC, NormalizedEmailAddress;
GO

-- Missing names, blank optional middle names, leading/trailing or repeated
-- spaces, and names stored entirely in upper- or lower-case.
SELECT
    BusinessEntityID,
    FirstName,
    MiddleName,
    LastName
FROM Person.Person
WHERE FirstName IS NULL
   OR NULLIF(LTRIM(RTRIM(FirstName)), N'') IS NULL
   OR LastName IS NULL
   OR NULLIF(LTRIM(RTRIM(LastName)), N'') IS NULL
   OR (MiddleName IS NOT NULL AND LTRIM(RTRIM(MiddleName)) = N'')
   OR (FirstName IS NOT NULL AND
       (LTRIM(RTRIM(FirstName)) <> FirstName OR FirstName LIKE N'%  %'))
   OR (MiddleName IS NOT NULL AND
       (LTRIM(RTRIM(MiddleName)) <> MiddleName OR MiddleName LIKE N'%  %'))
   OR (LastName IS NOT NULL AND
       (LTRIM(RTRIM(LastName)) <> LastName OR LastName LIKE N'%  %'))
   OR (LEN(FirstName) > 1 AND
       (FirstName COLLATE Latin1_General_100_BIN2 = UPPER(FirstName) COLLATE Latin1_General_100_BIN2
        OR FirstName COLLATE Latin1_General_100_BIN2 = LOWER(FirstName) COLLATE Latin1_General_100_BIN2))
   OR (LEN(LastName) > 1 AND
       (LastName COLLATE Latin1_General_100_BIN2 = UPPER(LastName) COLLATE Latin1_General_100_BIN2
        OR LastName COLLATE Latin1_General_100_BIN2 = LOWER(LastName) COLLATE Latin1_General_100_BIN2))
ORDER BY BusinessEntityID;
GO

-- Merge candidates require review; do not merge records from these checks
-- automatically. Prefer the record with verified/current contact details,
-- preserve its stable business key and related history, and retain an audit
-- mapping from every retired key to the surviving key.
