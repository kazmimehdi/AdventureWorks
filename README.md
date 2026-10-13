# AdventureWorks SQL exercises

This folder contains SQL Server objects for the AdventureWorks sample database. The script targets the `AdventureWorks2022` database and can be rerun to create or update the procedures and view.

## Install SQL Server and SSMS

1. Install SQL Server Developer Edition (for learning and non-production use) or SQL Server Express from the [official SQL Server downloads page](https://www.microsoft.com/en-us/sql-server/sql-server-downloads).
2. Install [SQL Server Management Studio (SSMS)](https://learn.microsoft.com/en-us/ssms/install/install).
3. In SSMS, connect to the local SQL Server instance.
4. Download the AdventureWorks 2022 backup (`AdventureWorks2022.bak`) from the [SQL Server samples releases](https://github.com/microsoft/sql-server-samples/releases).
5. Restore the backup in SSMS: right-click **Databases** → **Restore Database...** → select **Device** → browse to the `.bak` file → **OK**. Confirm the restored database is named `AdventureWorks2022`.
6. Open `AdventureWorks.sql` in SSMS and execute it.

## Objects in the script

- `Person.uspUpdatePerson` updates the supplied first, middle, and/or last name for one `BusinessEntityID`.
- `Production.uspUpdateProduct` updates the supplied name, standard cost, and/or list price for one `ProductID`.
- `Production.uspUpdateProductDiscontinue` updates either or both end/discontinued dates for one `ProductID`.
- `Sales.vCustomerOrderAggregate` returns each customer, total sales (`SalesOrderHeader.TotalDue`), and order count. Customers with no orders are included with zero totals.

For any procedure, pass `NULL` or omit optional parameters to leave those fields unchanged. An error is raised if no fields are supplied or the requested row does not exist. These procedures do not provide a way to clear a nullable field to `NULL`.

If you are new to SQL, complete the [Microsoft Learn Transact-SQL tutorial](https://learn.microsoft.com/en-us/sql/t-sql/tutorial-writing-transact-sql-statements) before running the script.
