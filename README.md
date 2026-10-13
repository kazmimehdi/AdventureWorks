# AdventureWorks SQL exercises

## Purpose

This repository practices the SQL Server, customer segmentation, data-quality,
and client-handover skills needed for a winery project, using Microsoft's
AdventureWorks sample database. Its sales figures and customer records are
sample data, not winery data.

## Install and run

1. Install SQL Server Developer Edition (for learning and non-production use)
   or SQL Server Express from the
   [official SQL Server downloads page](https://www.microsoft.com/en-us/sql-server/sql-server-downloads).
2. Install [SQL Server Management Studio (SSMS)](https://learn.microsoft.com/en-us/ssms/install/install).
3. Connect to the local SQL Server instance in SSMS.
4. Download the AdventureWorks 2022 backup (`AdventureWorks2022.bak`) from
   [SQL Server samples releases](https://github.com/microsoft/sql-server-samples/releases).
5. In SSMS, right-click **Databases** → **Restore Database...** → select
   **Device** → browse to the `.bak` file → **OK**. Confirm the database is
   named `AdventureWorks2022`.
6. Open and execute `AdventureWorks.sql` in SSMS. Then execute
   `winery_extension.sql` to create the customer tier view and run the tier
   analyses. Run `data_quality_checks.sql` to inspect possible data issues.
   Each script selects `AdventureWorks2022` and separates batches with `GO`.

If you are new to SQL, complete the
[Microsoft Learn Transact-SQL tutorial](https://learn.microsoft.com/en-us/sql/t-sql/tutorial-writing-transact-sql-statements).

## Database objects and analyses

- `Person.uspUpdatePerson` updates the supplied first, middle, and/or last name
  for one `BusinessEntityID`.
- `Production.uspUpdateProduct` updates the supplied name, standard cost,
  and/or list price for one `ProductID`.
- `Production.uspUpdateProductDiscontinue` updates either or both end and
  discontinued dates for one `ProductID`.
- `Sales.vCustomerOrderAggregate` returns each customer, total sales, and
  order count. Customers with no orders are included with zero totals.
- `Sales.vCustomerTier` builds on that aggregate: Gold is at least $10,000 in
  lifetime sales, Silver is at least $2,500 and below $10,000, and Bronze is
  below $2,500. These are starter analysis thresholds, not client-approved
  winery segments.
- `winery_extension.sql` reports customer count, average lifetime revenue,
  and average order count by tier. It also reports annualized lifetime
  revenue based on each customer's first recorded order.
- `data_quality_checks.sql` lists likely duplicate names/emails and possible
  missing, blank, oddly capitalized, or extra-space name values. These are
  review candidates, not automatic corrections.
- `email_journeys.md` contains welcome, anniversary, and Gold win-back journey
  drafts for client review.

## Example output

The following values are illustrative only; they are not query results from a
restored database. Run `SELECT CustomerID, CustomerName, TotalSales, OrderCount,
CustomerTier FROM Sales.vCustomerTier` to see the actual rows.

| CustomerID | CustomerName | TotalSales | OrderCount | CustomerTier |
|---:|---|---:|---:|---|
| 1001 | Example Customer A | 12,500.00 | 8 | Gold |
| 1002 | Example Customer B | 4,200.00 | 3 | Silver |
| 1003 | Example Customer C | 850.00 | 1 | Bronze |

## Limitations and next steps

- In the update procedures, `NULL` or omitted optional parameters mean
  “leave this field unchanged”; the procedures cannot use `NULL` to clear a
  nullable field. They raise an error when no fields are supplied or the
  requested row does not exist.
- Order counts and sales use `Sales.SalesOrderHeader.OrderDate` and `TotalDue`.
  The tier analysis uses all recorded orders, not a rolling date window.
- `TotalDue` includes tax and shipping, so it is not a measure of product-only
  or pre-tax revenue.
- The revenue-per-year analysis measures from the first recorded order to
  today. It is an observed-history proxy for tenure, not the customer's true
  signup date or a forecast of future value. Customers whose first order is
  today do not yet have a measurable annualized rate.
- Review the tier cutoffs, quality-check candidates, merge decisions,
  communication consent, and all email copy with the winery client before
  using them operationally.

## Handover

To rerun the work, restore the AdventureWorks 2022 backup using the steps
above, execute `AdventureWorks.sql` first, then execute `winery_extension.sql`.
Run `data_quality_checks.sql` as a read-only review; investigate candidates
before making any data changes. Email journeys in `email_journeys.md` are
drafts only and need client approval. No database backup, customer export, or
credentials are stored in this repository.
