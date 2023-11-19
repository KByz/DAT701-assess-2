-- ETL to transfer data from FinanceDB to FinanceDW

-- FinanceDB Read Only Login Creation

CREATE LOGIN financeDBA 
WITH PASSWORD = 'password1',
DEFAULT_DATABASE = FinanceDB,
CHECK_EXPIRATION = OFF,
CHECK_POLICY = OFF

USE FinanceDW;
GO
-- DimSalesPerson
BEGIN TRANSACTION

SET IDENTITY_INSERT DimSalesPerson ON
GO
MERGE INTO DimSalesPerson AS tgt
USING 
	(SELECT
			SalesPersonID,
			FirstName,
			LastName,
			HireDate
	FROM FinanceDB.dbo.SalesPerson
	)AS src (NewID,
			NewFirstName,
			NewLastName,
			NewHireDate)
	ON (tgt.ID = src.NewID)
	WHEN NOT MATCHED
	THEN
		INSERT (ID, FirstName, LastName, HireDate)
		VALUES (NewID, NewFirstName, NewLastName, NewHireDate);

SET IDENTITY_INSERT DimSalesPerson OFF

COMMIT
GO

-- DimSalesRegion
BEGIN TRANSACTION
GO
SET IDENTITY_INSERT DimSalesRegion ON
GO

MERGE INTO DimSalesRegion AS tgt
USING 
	(SELECT
		sr.SalesRegionID,
		r.RegionID,
		c.CountryName,
		s.SegmentID
		FROM FinanceDB.dbo.SalesRegion AS sr
		INNER JOIN FinanceDB.dbo.Region AS r ON
		sr.RegionID = r.RegionID
		INNER JOIN FinanceDB.dbo.Segment AS s ON
		r.SegmentID = s.SegmentID
		INNER JOIN FinanceDB.dbo.Country AS c ON
		r.CountryID = c.CountryID
		)AS src 
			(NewID,
			NewRegion,
			NewCountry,
			NewSegment)
		ON (tgt.ID = src.NewID)
		WHEN NOT MATCHED 
		THEN
			INSERT (ID, Region, Country, Segment)
			VALUES (NewID, NewRegion, NewCountry, NewSegment);

SET IDENTITY_INSERT DimSalesRegion OFF

COMMIT
GO


-- Product

BEGIN TRANSACTION 
GO
SET IDENTITY_INSERT DimProduct ON

MERGE INTO DimProduct AS tgt
USING
	(SELECT
		ProductID,
		ProductName
		FROM FinanceDB.dbo.Product
		) AS src
			(NewProductID,
			NewProductName)
			ON (tgt.ID = src.NewProductID)
			WHEN NOT MATCHED 
			THEN
			INSERT (ID, ProductName)
			VALUES (NewProductID, NewProductName);

SET IDENTITY_INSERT DimProduct OFF

COMMIT
GO

-- DimDate
BEGIN TRANSACTION
GO

MERGE INTO DimDate AS tgt
USING (
		SELECT
			DISTINCT 
				so.SalesOrderDate,
				MONTH(so.SalesOrderDate),
				YEAR(so.SalesOrderDate)
		FROM FinanceDB.dbo.SalesOrder so
		 UNION 
			SELECT 
				DISTINCT
					DATEFROMPARTS(kpi.SalesYear, 1, 1),
					MONTH(DATEFROMPARTS(kpi.SalesYear, 1, 1)),
					YEAR(DATEFROMPARTS(kpi.SalesYear, 1, 1))
			FROM FinanceDB.dbo.SalesKPI kpi
		) AS src
				(NewDate,
				NewMonth,
				NewYear)
		ON (tgt.Date = src.NewDate)
		WHEN NOT MATCHED 
		THEN
		INSERT 
		VALUES (NewDate, NewMonth, NewYear);

COMMIT
GO

/* DATE TEST to verify dates are correct
USE FinanceDB;
GO
SELECT *
FROM
(SELECT 
		DISTINCT 
			so.SalesOrderDate,
			MONTH(so.SalesOrderDate) AS Month,
			YEAR(so.SalesOrderDate) AS Year
		FROM FinanceDB.dbo.SalesOrder so
		 UNION 
			SELECT 
				DISTINCT
					DATEFROMPARTS(kpi.SalesYear, 1, 1),
					MONTH(DATEFROMPARTS(kpi.SalesYear, 1, 1)) AS Month,
					YEAR(DATEFROMPARTS(kpi.SalesYear, 1, 1)) AS Year
			FROM FinanceDB.dbo.SalesKPI kpi) AS DateTable
			JOIN FinanceDb.dbo.SalesKPI ogkpi
				ON ogkpi.SalesYear = DateTable.Year;
*/

--FactKPI
USE FinanceDW;

BEGIN TRANSACTION
GO
SET IDENTITY_INSERT FactKPI ON

MERGE INTO FactKPI AS tgt
USING (SELECT
			DISTINCT
				kpi.KPIID,
				kpi.KPI,
				kpi.SalesPersonID,
				DimDate.Date
		FROM FinanceDB.dbo.SalesKPI AS kpi
		CROSS JOIN DimDate
		) AS src (NewKPIID,
					NewKPI,
					NewDimSalesPersonID,
					NewYear)
		ON (tgt.KPIID = src.NewKPIID)
		WHEN NOT MATCHED 
		THEN
		INSERT (KPIID, KPI, DimSalesPersonID, Year)
		VALUES (NewKPIID,
				NewKPI,
				NewDimSalesPersonID,
				NewYear);
COMMIT
GO

-- FactSaleOrder 
USE FinanceDW

BEGIN TRANSACTION
GO

MERGE INTO FactSalesOrder as tgt
USING (SELECT
		sol.SalesOrderLineItemID,
		so.SalesOrderID,
		so.SalesOrderDate,
		sol.ProductID,
		so.SalesRegionID,
		so.SalesPersonID,
		sol.UnitsSold,
		sol.SalePrice,
		prm.Discount
	FROM FinanceDB.dbo.SalesOrderLineItem AS sol
		JOIN FinanceDB.dbo.SalesOrder AS so
		ON so.SalesOrderID = sol.SalesOrderID
		JOIN FinanceDB.dbo.Promotion AS prm 
		ON prm.ProductID = sol.ProductID
		) AS src
			(NewSalesOrderLineItemID,
			NewSalesOrderID,
			NewDate,
			NewProductID,
			NewSalesRegionID,
			NewSalesPersonID,
			NewUnitsSold,
			NewSalesPrice,
			NewDiscount)
		ON (tgt.SalesOrderLineItemID = src.NewSalesOrderLineItemID)
		WHEN NOT MATCHED 
		THEN
		INSERT 
		VALUES(NewSalesOrderLineItemID,
						NewSalesOrderID,
						NewDate,
						NewProductID,
						NewSalesRegionID,
						NewSalesPersonID,
						NewUnitsSold,
						NewSalesPrice,
						NewDiscount);
COMMIT
GO
