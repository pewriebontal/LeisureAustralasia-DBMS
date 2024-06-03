-- This is the store procedure to create a service package
CREATE PROCEDURE usp_createPackage
    @package_name VARCHAR(100),                            -- Name of the package
    @service_item_list dbo.ServiceItem READONLY,           -- Table-valued parameter for list of service items and quantities
    @description VARCHAR(255),                             -- Description of the package
    @valid_start_date DATE,                                -- Start date of the package validity period
    @valid_end_date DATE,                                  -- End date of the package validity period
    @advertised_price DECIMAL(10, 2),                      -- Advertised price of the package
    @advertised_currency VARCHAR(10),                      -- Currency for the advertised price
    @employee INT,                                         -- Employee ID authorizing the package
    @advertised_package_id INT OUTPUT                      -- Output parameter for the ID of the newly created package
AS 
BEGIN
    -- ERROR HANDLING
    BEGIN TRY
        -- Start transaction
        BEGIN TRANSACTION

    END TRY
    BEGIN CATCH
        -- TODO
    END CATCH
END;

