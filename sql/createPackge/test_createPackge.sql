-- Test Script for usp_createPackage

-- Declare a variable to hold the output package ID
DECLARE @advertisedPackageID INT;

-- Declare a table-valued variable to hold the list of service items and their quantities
DECLARE @serviceItemList ServiceItemList;

-- Insert test data into the table-valued variable
INSERT INTO @serviceItemList (serviceItemID, quantity)
VALUES (1, 2),  -- Example service item ID and quantity
       (2, 3);  -- Example service item ID and quantity

-- Execute the stored procedure with test data
EXEC usp_createPackage
    @packageName = 'This is a packge name',        -- Example package name
    @serviceItemList = @serviceItemList,     -- Example service item list
    @description = 'Bon is a child', -- Example description
    @validPeriodStartDate = '2024-06-01',    -- Example start date
    @validPeriodEndDate = '2024-06-30',      -- Example end date
    @advertisedPrice = 999.99,               -- Example advertised price
    @advertisedCurrency = 'SGD',             -- Example currency
    @employeeID = 101,                       -- Example employee ID
    @advertisedPackageID = @advertisedPackageID OUTPUT;  -- Output parameter

-- Check the output to verify the new package ID
SELECT @advertisedPackageID AS 'Advertised Package ID';
GO
