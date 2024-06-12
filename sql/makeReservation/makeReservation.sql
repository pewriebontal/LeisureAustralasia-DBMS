-- Check if the table type 'CustomerTableType' already exists
IF NOT EXISTS (SELECT *
FROM sys.types
WHERE is_table_type = 1 AND name = 'CustomerTableType')
BEGIN
    -- If not, create the table type 'CustomerTableType'
    CREATE TYPE CustomerTableType AS TABLE (
        name VARCHAR(100),
        -- Name of the customer
        address VARCHAR(200),
        -- Address of the customer
        contact_number VARCHAR(20),
        -- Contact number of the customer
        email VARCHAR(100)             -- Email of the customer
    );
END
GO

-- Check if the table type 'ServiceListTableType' already exists
IF NOT EXISTS (SELECT *
FROM sys.types
WHERE is_table_type = 1 AND name = 'ServiceListTableType')
BEGIN
    -- If not, create the table type 'ServiceListTableType'
    CREATE TYPE ServiceListTableType AS TABLE (
        service_id INT,
        -- ID of the service
        quantity INT,
        -- Quantity of the service
        start_date DATE,
        -- Start date of the service
        end_date DATE      -- End date of the service
    );
END
GO

-- Check if the table type 'GuestTableType' already exists
IF NOT EXISTS (SELECT *
FROM sys.types
WHERE is_table_type = 1 AND name = 'GuestTableType')
BEGIN
    -- If not, create the table type 'GuestTableType'
    CREATE TYPE GuestTableType AS TABLE (
        name VARCHAR(100),
        -- Name of the guest
        address VARCHAR(200),
        -- Address of the guest
        contact_number VARCHAR(20),
        -- Contact number of the guest
        email VARCHAR(100)             -- Email of the guest
    );
END
GO

-- Create or alter the stored procedure 'usp_makeReservation'
CREATE OR ALTER PROCEDURE usp_makeReservation
    @customer_details CustomerTableType READONLY,
    -- Table-valued parameter for customer details
    @service_list ServiceListTableType READONLY,
    -- Table-valued parameter for list of services/packages reserved
    @guest_list GuestTableType READONLY,
    -- Table-valued parameter for guest details
    @reservation_id INT OUTPUT
-- Output parameter for the ID of the created reservation
AS
BEGIN
    SET NOCOUNT ON;
    -- Turn off the message that shows the count of rows affected by a SQL statement to improve performance

    BEGIN TRY
        -- Validate input parameters
        IF NOT EXISTS (SELECT 1
    FROM @customer_details)
        BEGIN
        -- Raise an error if customer details are empty
        RAISERROR('Customer details cannot be empty.', 16, 1);
        RETURN;
    END

        IF NOT EXISTS (SELECT 1
    FROM @service_list)
        BEGIN
        -- Raise an error if service list is empty
        RAISERROR('Service list cannot be empty.', 16, 1);
        RETURN;
    END

        IF NOT EXISTS (SELECT 1
    FROM @guest_list)
        BEGIN
        -- Raise an error if guest list is empty
        RAISERROR('Guest list cannot be empty.', 16, 1);
        RETURN;
    END

        -- Check if all services in the list exist
        IF EXISTS (
            SELECT 1
    FROM @service_list SL
    WHERE NOT EXISTS (SELECT 1
    FROM ServiceItem
    WHERE service_id = SL.service_id)
        )
        BEGIN
        -- Raise an error if one or more services in the list do not exist
        RAISERROR('One or more services in the list do not exist.', 16, 1);
        RETURN;
    END

        BEGIN TRANSACTION; -- Start a transaction for atomicity

        DECLARE @total_amount_due DECIMAL(10, 2);  -- Variable to hold total amount due
        DECLARE @deposit_due DECIMAL(10, 2);       -- Variable to hold deposit due

        -- Insert customer details into the Customer table and capture the inserted customer_id
        DECLARE @customer_id_table TABLE (customer_id INT);
        INSERT INTO Customer
        (name, address, contact_number, email)
    OUTPUT INSERTED.customer_id INTO @customer_id_table
    SELECT name, address, contact_number, email
    FROM @customer_details;

        -- Retrieve the inserted customer_id from the table variable
        DECLARE @customer_id INT;
        SELECT @customer_id = customer_id
    FROM @customer_id_table;

        -- Calculate total amount due and deposit due
        SELECT @total_amount_due = SUM(advertised_price * quantity)
    FROM @service_list SL
        JOIN AdvertisedServicePackage ASP ON SL.service_id = ASP.asp_id;

        SET @deposit_due = @total_amount_due * 0.25;  -- Deposit is 25% of total amount due

        -- Insert the reservation into the Reservation table and capture the reservation_id
        DECLARE @reservation_id_table TABLE (reservation_number INT);
        INSERT INTO Reservation
        (customer_id, total_amount_due, deposit_due, payment_information)
    OUTPUT INSERTED.reservation_number INTO @reservation_id_table
    VALUES
        (@customer_id, @total_amount_due, @deposit_due, NULL);

        -- Retrieve the inserted reservation_id from the table variable
        SELECT @reservation_id = reservation_number
    FROM @reservation_id_table;

        -- Insert the bookings into the Booking table and capture booking_ids
        DECLARE @booking_ids TABLE (booking_id INT);
        INSERT INTO Booking
        (asp_id, reservation_number, quantity, start_date, end_date)
    OUTPUT INSERTED.booking_id INTO @booking_ids
    SELECT service_id, @reservation_id, quantity, start_date, end_date
    FROM @service_list;

        -- Insert guest details into the Guest table and capture guest_ids
        DECLARE @guest_ids TABLE (guest_id INT);
        INSERT INTO Guest
        (name, address, contact_number, email)
    OUTPUT INSERTED.guest_id INTO @guest_ids
    SELECT name, address, contact_number, email
    FROM @guest_list;

        -- Insert into BookingGuest table to link bookings with guests
        INSERT INTO BookingGuest
        (booking_id, guest_id)
    SELECT b.booking_id, g.guest_id
    FROM @booking_ids b
        CROSS JOIN @guest_ids g;

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