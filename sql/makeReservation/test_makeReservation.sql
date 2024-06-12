-- Test Script for usp_makeReservation

-- Declare a variable to hold the output reservation ID
DECLARE @reservation_id INT;

-- Declare table-valued variables to hold the customer details, service list, and guest list
DECLARE @customer_details CustomerTableType;
DECLARE @service_list ServiceListTableType;
DECLARE @guest_list GuestTableType;

-- Insert test data into the customer details table-valued variable
INSERT INTO @customer_details
    (name, address, contact_number, email)
VALUES
    ('Bon Gae', '4 Lor Long St', '555-1234', 'bonsgae@uon.edu.sg');

-- Insert test data into the service list table-valued variable
INSERT INTO @service_list
    (service_id, quantity, start_date, end_date)
VALUES
    (1, 1, '2024-07-01', '2024-07-07'),
    -- Example service item ID and quantity
    (2, 1, '2024-07-01', '2024-07-07');
-- Example service item ID and quantity

-- Insert test data into the guest list table-valued variable
INSERT INTO @guest_list
    (name, address, contact_number, email)
VALUES
    ('Bon Gae', '4 Lor Long St', '555-1234', 'bonsgae@uon.edu.sg');

-- Execute the stored procedure with test data
EXEC usp_makeReservation
    @customer_details = @customer_details,  -- Example customer details
    @service_list = @service_list,          -- Example service list
    @guest_list = @guest_list,              -- Example guest list
    @reservation_id = @reservation_id OUTPUT;
-- Output parameter

-- Check the output to verify the new reservation ID
SELECT @reservation_id AS 'Reservation ID';
GO

-------------------------------------------------------------------------------


-------------------------------------------------------------------------------

-- Test Script for usp_cancelReservation

-- Step 1: Verify the Reservation Exists before cancellation
-- Declare a variable to hold the reservation ID to be canceled
DECLARE @reservation_id_to_cancel INT;
SET @reservation_id_to_cancel = 69;
-- Example reservation ID to be canceled, change as necessary

-- Verify the reservation exists before attempting to cancel
PRINT 'Verifying the Reservation Exists before cancellation...';
SELECT *
FROM Reservation
WHERE reservation_number = @reservation_id_to_cancel;
SELECT *
FROM Booking
WHERE reservation_number = @reservation_id_to_cancel;
SELECT *
FROM Guest
WHERE guest_id IN (SELECT guest_id
FROM BookingGuest
WHERE booking_id IN (SELECT booking_id
FROM Booking
WHERE reservation_number = @reservation_id_to_cancel));
SELECT *
FROM BookingGuest
WHERE booking_id IN (SELECT booking_id
FROM Booking
WHERE reservation_number = @reservation_id_to_cancel);

-- Step 2: Cancel the Reservation
PRINT 'Attempting to Cancel the Reservation...';
EXEC usp_cancelReservation
    @reservation_id = @reservation_id_to_cancel;

-- Step 3: Verify that the reservation has been canceled
PRINT 'Verifying the Reservation has been Canceled...';
-- Check if the reservation still exists
IF NOT EXISTS (SELECT 1
FROM Reservation
WHERE reservation_number = @reservation_id_to_cancel)
BEGIN
    PRINT 'Reservation successfully canceled.';
END
ELSE
BEGIN
    PRINT 'Failed to cancel the reservation.';
END

-- Additional checks for related tables
PRINT 'Checking related tables for data...';
SELECT *
FROM Booking
WHERE reservation_number = @reservation_id_to_cancel;
SELECT *
FROM Guest
WHERE guest_id IN (SELECT guest_id
FROM BookingGuest
WHERE booking_id IN (SELECT booking_id
FROM Booking
WHERE reservation_number = @reservation_id_to_cancel));
SELECT *
FROM BookingGuest
WHERE booking_id IN (SELECT booking_id
FROM Booking
WHERE reservation_number = @reservation_id_to_cancel);
GO
