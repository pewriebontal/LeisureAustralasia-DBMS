-- Define the table type for ServiceItemList
CREATE TYPE ServiceItemList AS TABLE (
    serviceItemID INT,
    quantity INT
);
GO

-- Create the stored procedure (usp_createPackage)
CREATE PROCEDURE usp_createPackage
    @packageName VARCHAR(255),                  -- Name of the package
    @serviceItemList ServiceItemList READONLY,  -- Table-valued parameter for list of service items and quantities
    @description TEXT = NULL,                   -- Description of the package (Allow NULL description)
    @validPeriodStartDate DATE,                 -- Start date of the package validity period
    @validPeriodEndDate DATE,                   -- End date of the package validity period
    @advertisedPrice DECIMAL(10, 2),            -- Advertised price of the package
    @advertisedCurrency VARCHAR(3),             -- Currency for the advertised price
    @employeeID INT,                            -- Employee ID authorizing the package
    @advertisedPackageID INT OUTPUT             -- Output parameter for the ID of the newly created package
AS
BEGIN
    SET NOCOUNT ON;
    -- Improve performance

    BEGIN TRY
        -- Input validation
        IF (@packageName IS NULL OR @validPeriodStartDate IS NULL OR @validPeriodEndDate IS NULL OR @advertisedPrice IS NULL OR @advertisedCurrency IS NULL OR @employeeID IS NULL)
        BEGIN
        ;THROW 50001, 'Invalid input parameters. All parameters except description are mandatory.', 1;
    END

        IF (@validPeriodStartDate > @validPeriodEndDate)
        BEGIN
        ;THROW 50002, 'Invalid date range. Start date cannot be after end date.', 1;
    END

        IF (@advertisedPrice <= 0)
        BEGIN
        ;THROW 50003, 'Invalid price. Price must be greater than zero.', 1;
    END

        IF NOT EXISTS (SELECT 1
    FROM Employee
    WHERE employeeID = @employeeID)
        BEGIN
        ;THROW 50004, 'Employee not found.', 1;
    END

        IF NOT EXISTS (SELECT 1
    FROM @serviceItemList)
        BEGIN
        ;THROW 50005, 'Service item list cannot be empty.', 1;
    END

        -- Check for duplicate package names within the valid period
        IF EXISTS (
            SELECT 1
    FROM AdvertisedServicePackage
    WHERE name = @packageName
        AND (
                    (@validPeriodStartDate BETWEEN startDate AND endDate)
        OR (@validPeriodEndDate BETWEEN startDate AND endDate)
        OR (startDate BETWEEN @validPeriodStartDate AND @validPeriodEndDate)
        OR (endDate BETWEEN @validPeriodStartDate AND @validPeriodEndDate)
                )
        )
        BEGIN
        ;THROW 50006, 'A package with the same name already exists within the specified date range.', 1;
    END

        -- Check if all service items in the list exist
        IF EXISTS (
            SELECT 1
    FROM @serviceItemList
    WHERE NOT EXISTS (SELECT 1
    FROM ServiceItem
    WHERE serviceItemID = serviceItemID)
        )
        BEGIN
        ;THROW 50007, 'One or more service items in the list do not exist.', 1;
    END

        BEGIN TRANSACTION; -- Start transaction for atomicity

        -- Insert into AdvertisedServicePackage
        INSERT INTO AdvertisedServicePackage
        (name, description, startDate, endDate, advertisedPrice, advertisedCurrency, status, gracePeriod, employeeID)
    VALUES
        (@packageName, @description, @validPeriodStartDate, @validPeriodEndDate, @advertisedPrice, @advertisedCurrency, 'Active', 7, @employeeID);

        -- Get the newly created package ID
        SET @advertisedPackageID = SCOPE_IDENTITY();

        -- Insert into AdvertisedServicePackageServiceItem
        INSERT INTO AdvertisedServicePackageServiceItem
        (advertisedServicePackageID, serviceItemID, quantity)
    SELECT @advertisedPackageID, serviceItemID, quantity
    FROM @serviceItemList;

        COMMIT TRANSACTION; -- Commit the transaction
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION; -- Rollback in case of error

        ;THROW; -- Re-throw the error to be handled by the caller
    END CATCH
END;
