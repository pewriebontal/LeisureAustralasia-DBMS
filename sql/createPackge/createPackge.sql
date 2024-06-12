-- Check if the table type 'ServiceItemList' already exists
IF NOT EXISTS (SELECT *
FROM sys.types
WHERE is_table_type = 1 AND name = 'ServiceItemList')
BEGIN
    -- If not, create the table type 'ServiceItemList'
    CREATE TYPE ServiceItemList AS TABLE (
        serviceItemID INT,
        -- ID of the service item
        quantity INT        -- Quantity of the service item
    );
END
GO

-- Create or alter the stored procedure 'usp_createPackage'
CREATE OR ALTER PROCEDURE usp_createPackage
    @packageName VARCHAR(255),
    -- Name of the package
    @serviceItemList ServiceItemList READONLY,
    -- Table-valued parameter for list of service items and quantities
    @description TEXT = NULL,
    -- Description of the package (Allow NULL description)
    @validPeriodStartDate DATE,
    -- Start date of the package validity period
    @validPeriodEndDate DATE,
    -- End date of the package validity period
    @advertisedPrice DECIMAL(10, 2),
    -- Advertised price of the package
    @advertisedCurrency VARCHAR(3),
    -- Currency for the advertised price
    @employeeID INT,
    -- Employee ID authorizing the package
    @advertisedPackageID INT OUTPUT
-- Output parameter for the ID of the newly created package
AS
BEGIN
    SET NOCOUNT ON;
    -- Turn off the message that shows the count of rows affected by a SQL statement to improve performance

    BEGIN TRY
        -- Validate input parameters
        IF (@packageName IS NULL OR @validPeriodStartDate IS NULL OR @validPeriodEndDate IS NULL OR @advertisedPrice IS NULL OR @advertisedCurrency IS NULL OR @employeeID IS NULL)
        BEGIN
        -- Raise an error if any mandatory parameter is NULL
        RAISERROR('Invalid input parameters. All parameters except description are mandatory.', 16, 1);
        RETURN;
    END

        -- Validate the date range
        IF (@validPeriodStartDate > @validPeriodEndDate)
        BEGIN
        -- Raise an error if the start date is after the end date
        RAISERROR('Invalid date range. Start date cannot be after end date.', 16, 1);
        RETURN;
    END

        -- Validate the price
        IF (@advertisedPrice <= 0)
        BEGIN
        -- Raise an error if the price is less than or equal to zero
        RAISERROR('Invalid price. Price must be greater than zero.', 16, 1);
        RETURN;
    END

        -- Check if the employee exists
        IF NOT EXISTS (SELECT 1
    FROM Employee
    WHERE employee_id = @employeeID)
        BEGIN
        -- Raise an error if the employee does not exist
        RAISERROR('Employee not found.', 16, 1);
        RETURN;
    END

        -- Check if the service item list is empty
        IF NOT EXISTS (SELECT 1
    FROM @serviceItemList)
        BEGIN
        -- Raise an error if the service item list is empty
        RAISERROR('Service item list cannot be empty.', 16, 1);
        RETURN;
    END

        -- Check for duplicate package names within the valid period
        IF EXISTS (
            SELECT 1
    FROM AdvertisedServicePackage
    WHERE name = @packageName
        AND (
                    (@validPeriodStartDate BETWEEN start_date AND end_date)
        OR (@validPeriodEndDate BETWEEN start_date AND end_date)
        OR (start_date BETWEEN @validPeriodStartDate AND @validPeriodEndDate)
        OR (end_date BETWEEN @validPeriodStartDate AND @validPeriodEndDate)
                )
        )
        BEGIN
        -- Raise an error if a package with the same name already exists within the specified date range
        RAISERROR('A package with the same name already exists within the specified date range.', 16, 1);
        RETURN;
    END

        -- Check if all service items in the list exist
        IF EXISTS (
            SELECT 1
    FROM @serviceItemList SL
    WHERE NOT EXISTS (SELECT 1
    FROM ServiceItem
    WHERE service_id = SL.serviceItemID)
        )
        BEGIN
        -- Raise an error if one or more service items in the list do not exist
        RAISERROR('One or more service items in the list do not exist.', 16, 1);
        RETURN;
    END

        BEGIN TRANSACTION; -- Start a transaction for atomicity

        -- Insert a new record into the 'AdvertisedServicePackage' table
        INSERT INTO AdvertisedServicePackage
        (name, description, start_date, end_date, advertised_price, advertised_currency, status, grace_period, employee_id)
    VALUES
        (@packageName, @description, @validPeriodStartDate, @validPeriodEndDate, @advertisedPrice, @advertisedCurrency, 'Active', 7, @employeeID);

        -- Get the ID of the newly created package
        SET @advertisedPackageID = SCOPE_IDENTITY();

        -- Insert records into the 'PackageServiceItem' table for each service item in the list
        INSERT INTO PackageServiceItem
        (asp_id, service_id, quantity)
    SELECT @advertisedPackageID, serviceItemID, quantity
    FROM @serviceItemList;

        COMMIT TRANSACTION; -- Commit the transaction
    END TRY
    BEGIN CATCH
        -- If an error occurs and a transaction is in progress, rollback the transaction
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        -- Get the error message, severity, and state
        SELECT
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

        -- Raise the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO