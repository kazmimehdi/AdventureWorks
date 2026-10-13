USE AdventureWorks2022;
GO

CREATE OR ALTER PROCEDURE Person.uspUpdatePerson
    @BusinessEntityID int,
    @FirstName nvarchar(50) = NULL,
    @MiddleName nvarchar(50) = NULL,
    @LastName nvarchar(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @FirstName IS NULL AND @MiddleName IS NULL AND @LastName IS NULL
        THROW 50001, 'Provide at least one person field to update.', 1;

    UPDATE Person.Person
    SET FirstName = COALESCE(@FirstName, FirstName),
        MiddleName = COALESCE(@MiddleName, MiddleName),
        LastName = COALESCE(@LastName, LastName)
    WHERE BusinessEntityID = @BusinessEntityID;

    IF @@ROWCOUNT = 0
        THROW 50002, 'Person record was not found.', 1;
END;
GO

CREATE OR ALTER PROCEDURE Production.uspUpdateProduct
    @ProductID int,
    @Name nvarchar(50) = NULL,
    @StandardCost money = NULL,
    @ListPrice money = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Name IS NULL AND @StandardCost IS NULL AND @ListPrice IS NULL
        THROW 50003, 'Provide at least one product field to update.', 1;

    UPDATE Production.Product
    SET Name = COALESCE(@Name, Name),
        StandardCost = COALESCE(@StandardCost, StandardCost),
        ListPrice = COALESCE(@ListPrice, ListPrice)
    WHERE ProductID = @ProductID;

    IF @@ROWCOUNT = 0
        THROW 50004, 'Product record was not found.', 1;
END;
GO

CREATE OR ALTER PROCEDURE Production.uspUpdateProductDiscontinue
    @ProductID int,
    @SellEndDate datetime = NULL,
    @DiscontinuedDate datetime = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @SellEndDate IS NULL AND @DiscontinuedDate IS NULL
        THROW 50005, 'Provide SellEndDate, DiscontinuedDate, or both.', 1;

    UPDATE Production.Product
    SET SellEndDate = COALESCE(@SellEndDate, SellEndDate),
        DiscontinuedDate = COALESCE(@DiscontinuedDate, DiscontinuedDate)
    WHERE ProductID = @ProductID;

    IF @@ROWCOUNT = 0
        THROW 50006, 'Product record was not found.', 1;
END;
GO

CREATE OR ALTER VIEW Sales.vCustomerOrderAggregate
AS
    SELECT
        c.CustomerID,
        COALESCE(
            s.Name,
            CONCAT(p.FirstName, N' ', COALESCE(p.MiddleName + N' ', N''), p.LastName)
        ) AS CustomerName,
        COALESCE(SUM(soh.TotalDue), CONVERT(money, 0)) AS TotalSales,
        COUNT(soh.SalesOrderID) AS OrderCount
    FROM Sales.Customer AS c
    LEFT JOIN Person.Person AS p
        ON p.BusinessEntityID = c.PersonID
    LEFT JOIN Sales.Store AS s
        ON s.BusinessEntityID = c.StoreID
    LEFT JOIN Sales.SalesOrderHeader AS soh
        ON soh.CustomerID = c.CustomerID
    GROUP BY
        c.CustomerID,
        s.Name,
        p.FirstName,
        p.MiddleName,
        p.LastName;
GO
