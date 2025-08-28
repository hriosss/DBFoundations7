--*************************************************************************--
-- Title: Assignment07
-- Author: HRios
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,HRios,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_HRios')
	 Begin 
	  Alter Database [Assignment07DB_HRios] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_HRios;
	 End
	Create Database Assignment07DB_HRios;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_HRios;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --
--select * 
--from vProducts
--
select productname
, Format(unitprice, 'C','en-US') AS 'UnitPriceUSD'
from vProducts
order by ProductName

go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --
select c.categoryname
, p.productname
, Format(p.unitprice, 'C','en-US') AS 'UnitPriceUSD'
from vProducts p
join vCategories c
	on p.CategoryID = c.categoryID
order by c.CategoryName
, p.ProductName;
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
/*
select *
from vProducts
select *
from vInventories
--
select ProductName
, InventoryDate
, [Count] AS 'InventoryCount'
from vInventories i
join vProducts p
	on i.ProductID = p.ProductID
order by ProductName
, InventoryDate;
go
*/
--
select ProductName
, Format (InventoryDate, 'MMMM, yyyy') AS 'InventoryDate'
, [Count] AS 'InventoryCount'
from vInventories i
join vProducts p
	on i.ProductID = p.ProductID
order by ProductName
, Year(InventoryDate)
, Month(InventoryDate);
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
create or alter view vProductInventories
as 
	select top 100000 ProductName
	, Format (InventoryDate, 'MMMM, yyyy') AS 'InventoryDate'
	, [Count] AS 'InventoryCount'
	from vInventories i
	join vProducts p
		on i.ProductID = p.ProductID
	order by ProductName
	, Year(InventoryDate)
	, Month(InventoryDate);
go

-- Check that it works: 
Select * From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
/*
select * from vCategories
select * from vInventories
select * from vProducts
--
create or alter view vCategoryInventories
as 
	select top 100000 CategoryName
	, Format (InventoryDate, 'MMMM, yyyy') AS 'InventoryDate'
	, [Count] AS 'InventoryCount'
	from vInventories i
	join vProducts p
		on i.ProductID = p.ProductID
	join vCategories v
		on v.CategoryID = p.CategoryID;
go
*/
-- <Put Your Code Here> --
create or alter view vCategoryInventories
as 
	select top 100000 
	CategoryName
	, Format (InventoryDate, 'MMMM, yyyy') AS 'InventoryDate'
	, SUM([Count]) AS 'InventoryCount'
	from vInventories i
	join vProducts p
		on i.ProductID = p.ProductID
	join vCategories v
		on v.CategoryID = p.CategoryID
	group by CategoryName
	, InventoryDate
	order by CategoryName
	, Year(InventoryDate)
	, Month(InventoryDate);
go
-- Check that it works: 
Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.
/*
Select * From vProductInventories;
--
select productname
, inventorydate
, inventorycount
from vProductInventories
--
go
create or alter view vProductInventoriesWithPreviousMonthCounts
as 
	select productname
	, inventorydate
	, inventorycount
	, lag(inventorycount) Over (
		partition by productname
		order by inventorydate) AS 'PreviousMonthCount'
	from vProductInventories
	order by ProductName
	, Year(InventoryDate)
	, Month(InventoryDate);
go
---
go
create or alter view vProductInventoriesWithPreviousMonthCounts
as 
	select productname
	, inventorydate
	, inventorycount
	, CASE
		When Month(InventoryDate) = 1 AND
		lag(inventorycount) Over (
		partition by productname
		order by inventorydate) IS NULL
		Then 0
		Else ISNULL (Lag(inventorycount) Over (
		partition by productname
		order by inventorydate),0)
	END
		AS 'PreviousMonthCount'
	from vProductInventories
go
*/
-- <Put Your Code Here> --
select * from vProductInventories
--
go
create or alter view vProductInventoriesWithPreviousMonthCounts
as 
	select top 100000 productname
	, InventoryDate
	, InventoryCount
	, IIF(InventoryDate Like ('January%'), 0, IsNull (Lag(InventoryCount) Over (Order By ProductName, Month(InventoryDate)), 0)) AS PreviousMonthCount
from vProductInventories
order by ProductName
	, year(InventoryDate)
	, Month(InventoryDate);
go
Select * From vProductInventoriesWithPreviousMonthCounts;
go
-- works
/*
CREATE OR ALTER VIEW vProductInventoriesWithPreviousMonthCounts AS
SELECT top 10000
    p.ProductName,
    i.InventoryDate,
    i.Count AS InventoryCount,
    -- Use LAG() to get the previous month's count
    CASE 
        WHEN MONTH(i.InventoryDate) = 1 AND 
             LAG(i.Count) OVER (PARTITION BY p.ProductID ORDER BY i.InventoryDate) IS NULL
        THEN 0
        ELSE ISNULL(LAG(i.Count) OVER (PARTITION BY p.ProductID ORDER BY i.InventoryDate), 0)
    END AS PreviousMonthCount
FROM 
    vInventories i
JOIN 
    vProducts p ON i.ProductID = p.ProductID
ORDER BY 
    p.ProductName, 
    YEAR(i.InventoryDate), 
    MONTH(i.InventoryDate);
GO
*/
-- Check that it works: 


-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Verify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
go
create or alter view vProductInventoriesWithPreviousMonthCountsWithKPIs
as
	select
	productname
	, inventorydate
	, inventorycount
	, PreviousMonthCount
	, IsNull (Case
		when InventoryCount > PreviousMonthCount Then 1
		when InventoryCount = PreviousMonthCount Then 0
		when InventoryCount < PreviousMonthCount Then -1
		end, 0) as CountVsPreviousCountKPI
	from vProductInventoriesWithPreviousMonthCounts;
go
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
go
create or alter function fProductInventoriesWithPreviousMonthCountsWithKPIs
(@KPIValue int)
returns table
	as
			Return
				select
				productname
				, inventorydate
				, inventorycount
				, PreviousMonthCount
				, CountVsPreviousCountKPI
				from vProductInventoriesWithPreviousMonthCountsWithKPIs
				where CountVsPreviousCountKPI = @KPIValue;
go
--Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
go

/***************************************************************************************/