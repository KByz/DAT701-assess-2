-- FinanceDW View Creation Statements

-- Total Profit against KPI View per sales person

USE FinanceDW;
GO

DROP VIEW IF EXISTS KPIvProfits;
GO
CREATE VIEW KPIvProfits AS

SELECT  
		sp.ID,
		SUM(kpi.KPI) AS KPI,
		SUM (fso.SalesPrice) * SUM(fso.UnitsSold) AS TotalProfits
FROM DimSalesPerson sp
	RIGHT JOIN FactKPI kpi ON
	kpi.DimSalesPersonID = sp.ID
	LEFT JOIN FactSalesOrder fso ON
	fso.SalesPersonID = sp.ID
GROUP BY sp.ID;

GO

-- Total Profit per month

DROP VIEW IF EXISTS TotalProfitPerMonth;
GO
CREATE VIEW TotalProfitPerMonth AS

SELECT 
		SUM(fso.SalesPrice) * SUM(fso.UnitsSold) AS TotalProfit,
		dimdate.Month
FROM FactSalesOrder fso
	JOIN DimDate dimdate ON
	dimdate.date = fso.SaleDate
GROUP BY dimdate.Month;

GO