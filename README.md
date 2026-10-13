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
   analyses. Run `data_quality_checks.sql` as a read-only review. Each script
   selects `AdventureWorks2022` and separates batches with `GO`.

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
  below $2,500. These spend-based thresholds demonstrate a method; they are
  not winery membership levels.
- `winery_extension.sql` reports the tier distribution, average lifetime
  revenue and order count among customers with orders, and annualized
  revenue using the sample's latest order date as its as-of date.
- `data_quality_checks.sql` checks Sales.Customer people for duplicate names
  with a matching email or address, duplicate customer emails, and possible
  missing, blank, oddly capitalized, or extra-space names. It also includes
  a commented crosswalk table template. These are review candidates, not
  automatic corrections.
- `email_journeys.md` contains four draft winery journeys, including club
  signup welcome, club anniversary, Gold win-back, and a club-join nudge.
  Journeys require client review and winery membership/consent data.

## Findings

The SQL analysis reports all customers per spend-based tier, separately
counts those with orders, and calculates average revenue/order count using
only customers with at least one order. Zero-order customers remain in the
view and in tier distribution counts; they are excluded from those averages.
Because they have zero spend, they are classified Bronze.

The restored AdventureWorks database is not available in this environment, so
the data query could not be run here and actual tier counts/averages are not
reported rather than guessed. Restore the sample and execute
`winery_extension.sql`; its first result set provides the real distribution
and averages for that backup.

This is a **method demo**, not a conclusion that higher spend defines better
membership. The winery should group customers by their actual membership
level and compare revenue, order frequency, and retention across levels.

## Example output

The following values are illustrative only; they are not query results from a
restored database. Run `SELECT CustomerID, CustomerName, TotalSales, OrderCount,
CustomerTier FROM Sales.vCustomerTier` to see actual rows.

| CustomerID | CustomerName | TotalSales | OrderCount | CustomerTier |
|---:|---|---:|---:|---|
| 1001 | Example Customer A | 12,500.00 | 8 | Gold |
| 1002 | Example Customer B | 4,200.00 | 3 | Silver |
| 1003 | Example Customer C | 850.00 | 1 | Bronze |

## Winery deliverable map

| File | Winery-project deliverable |
|---|---|
| `AdventureWorks.sql` | Reusable SQL procedures and baseline customer-sales aggregate |
| `winery_extension.sql` | Tiering method demo, distribution, revenue/order analysis, and tenure-rate analysis |
| `data_quality_checks.sql` | Customer-list quality review, duplicate candidates, and crosswalk design |
| `email_journeys.md` | Client-review lifecycle and club-growth email journey drafts |
| `README.md` | Setup, limitations, findings status, and rerun handover |

## Limitations and next steps

- In the update procedures, `NULL` or omitted optional parameters mean
  “leave this field unchanged”; the procedures cannot use `NULL` to clear a
  nullable field. They raise an error when no fields are supplied or the
  requested row does not exist.
- Order counts and sales use `Sales.SalesOrderHeader.OrderDate` and `TotalDue`.
  `TotalDue` includes tax and shipping, so it is not product-only or pre-tax
  revenue.
- `Sales.vCustomerOrderAggregate` includes customers with no orders.
  `Sales.vCustomerTier` classifies their zero spend as Bronze. The tier
  distribution counts them, but the average revenue/order metrics exclude
  them.
- `Sales.vCustomerOrderAggregate.CustomerName` prefers `Sales.Store.Name`
  when the customer is a store (which has no `PersonID`); otherwise it uses
  the related person's first, middle, and last name.
- The sample's annualized revenue uses `MAX(OrderDate)` as the as-of date
  because AdventureWorks is historical. The as-of date is a parameter in the
  script; for live winery analysis, set it to today. Customers with zero
  measured tenure have no annualized rate.
- Spend tiers make average spend differences partly circular. For the winery,
  use actual membership tiers and compare revenue, order frequency, and
  retention; membership join date and club-status data are not in this sample.
- Review tier definitions, quality-check candidates, merge decisions,
  consent, age eligibility, and all email copy with the winery client before
  operational use.

## Handover

To rerun the work, restore the AdventureWorks 2022 backup using the steps
above, execute `AdventureWorks.sql` first, then execute `winery_extension.sql`
and `data_quality_checks.sql`. The latter is read-only; investigate candidates
before making data changes. The crosswalk DDL is a commented template for an
integration/staging database, not part of the read-only checks. Email journeys
in `email_journeys.md` are drafts only and need client approval. No database
backup, customer export, or credentials are stored in this repository.
