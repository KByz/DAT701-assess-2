-- FinanceDW DDL
USE master;
GO

DROP DATABASE IF EXISTS FinanceDW;
GO

CREATE DATABASE FinanceDW;
GO

USE FinanceDW;


CREATE TABLE DimDate 
([Date] datetime NOT NULL, 
[Month] int NOT NULL,
[Year] int NOT NULL, 
PRIMARY KEY ([Date]));

CREATE TABLE DimProduct 
(ID int IDENTITY NOT NULL, 
ProductName varchar(50) 
NOT NULL, 
PRIMARY KEY (ID));

CREATE TABLE DimSalesPerson 
(ID int IDENTITY NOT NULL, 
FirstName varchar(100) NOT NULL, 
LastName varchar(100) NOT NULL, 
HireDate date NOT NULL, 
PRIMARY KEY (ID));

CREATE TABLE DimSalesRegion 
(ID int IDENTITY NOT NULL, 
Region varchar(100) NOT NULL, 
Country varchar(100) NOT NULL, 
Segment varchar(50) NOT NULL, 
PRIMARY KEY (ID));

CREATE TABLE FactKPI 
(KPI int NOT NULL, 
DimSalesPersonID int NOT NULL, 
[Year] datetime NOT NULL);

CREATE TABLE FactSalesOrder 
(SalesOrderLineItemID int NOT NULL, 
SalesOrderID int NOT NULL, 
SaleDate datetime NOT NULL, 
ProductID int NOT NULL, 
SalesRegionID int NOT NULL, 
SalesPersonID int NOT NULL, 
UnitsSold int NULL, 
SalesPrice int NOT NULL, 
PromotionDiscount float NULL);

DROP TABLE FactSalesOrder
GO

ALTER TABLE FactSalesOrder ADD CONSTRAINT FKFactSalesOr993022 FOREIGN KEY (SalesRegionID) REFERENCES DimSalesRegion (ID);
ALTER TABLE FactKPI ADD CONSTRAINT FKFactKPI803050 FOREIGN KEY (Year) REFERENCES DimDate ([Date]);
ALTER TABLE FactKPI ADD CONSTRAINT FKFactKPI921544 FOREIGN KEY (DimSalesPersonID) REFERENCES DimSalesPerson (ID);
ALTER TABLE FactSalesOrder ADD CONSTRAINT FKFactSalesOr273504 FOREIGN KEY (SaleDate) REFERENCES DimDate ([Date]);
ALTER TABLE FactSalesOrder ADD CONSTRAINT FKFactSalesOr410440 FOREIGN KEY (SalesPersonID) REFERENCES DimSalesPerson (ID);
ALTER TABLE FactSalesOrder ADD CONSTRAINT FKFactSalesOr564491 FOREIGN KEY (ProductID) REFERENCES DimProduct (ID);



