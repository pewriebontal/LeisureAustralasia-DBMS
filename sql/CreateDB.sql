--  This is a SQL script to create a database named LeisureAustralasiaDB.
--  And then create tables named Hotel, Facility, FacilityType, and so on.

--  We are just programmers, we are not database administrators.
--  So let us document all with anoying comments. 
--  so that we can understand what we are doing.

--  Create Database named LeisureAustralasiaDB
CREATE DATABASE LeisureAustralasiaDB;
GO
--  GO is a batch separator. It is used to group SQL commands into batches which are sent to the server together.


--  USE statement is used to select a database whose name is specified as the database_name.
USE LeisureAustralasiaDB;
GO


-- Create Tables

-- Hotel Table
CREATE TABLE Hotel
(
    hotel_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    country VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    description TEXT
);

-- Facility Table
CREATE TABLE Facility
(
    facility_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) CHECK (status IN ('Available', 'Unavailable', 'Maintenance')),
    hotel_id INT,
    FOREIGN KEY (hotel_id) REFERENCES Hotel(hotel_id) ON DELETE CASCADE
);

-- FacilityType Table
CREATE TABLE FacilityType
(
    type_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    capacity INT
);

-- ServiceCategory Table
CREATE TABLE ServiceCategory
(
    code VARCHAR(10) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    type VARCHAR(50)
);

-- ServiceItem Table
CREATE TABLE ServiceItem
(
    service_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    restrictions TEXT,
    notes TEXT,
    comments TEXT,
    status VARCHAR(20) CHECK (status IN ('Available', 'Unavailable')),
    available_times VARCHAR(100),
    base_cost DECIMAL(10, 2),
    base_currency VARCHAR(3),
    capacity INT
);

-- FacilityServiceItem Table (Associative Entity)
CREATE TABLE FacilityServiceItem
(
    facility_id INT,
    service_id INT,
    PRIMARY KEY (facility_id, service_id),
    FOREIGN KEY (facility_id) REFERENCES Facility(facility_id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES ServiceItem(service_id) ON DELETE CASCADE
);

-- Employee Table
CREATE TABLE Employee
(
    employee_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    position VARCHAR(50)
);

-- AdvertisedServicePackage Table
CREATE TABLE AdvertisedServicePackage
(
    asp_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    advertised_price DECIMAL(10, 2),
    advertised_currency VARCHAR(3),
    inclusions TEXT,
    exclusions TEXT,
    status VARCHAR(20) CHECK (status IN ('Active', 'Inactive')),
    grace_period INT,
    employee_id INT,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE SET NULL
);

-- PackageServiceItem Table (Associative Entity)
CREATE TABLE PackageServiceItem
(
    asp_id INT,
    service_id INT,
    quantity INT,
    PRIMARY KEY (asp_id, service_id),
    FOREIGN KEY (asp_id) REFERENCES AdvertisedServicePackage(asp_id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES ServiceItem(service_id) ON DELETE CASCADE
);

-- Customer Table
CREATE TABLE Customer
(
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200),
    contact_number VARCHAR(20),
    email VARCHAR(100)
);

-- Guest Table
CREATE TABLE Guest
(
    guest_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200),
    contact_number VARCHAR(20),
    email VARCHAR(100)
);

-- Reservation Table
CREATE TABLE Reservation
(
    reservation_number INT PRIMARY KEY,
    customer_id INT,
    total_amount_due DECIMAL(10, 2),
    deposit_due DECIMAL(10, 2),
    payment_information TEXT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE SET NULL
);

-- Booking Table
CREATE TABLE Booking
(
    booking_id INT PRIMARY KEY,
    asp_id INT,
    reservation_number INT,
    quantity INT,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (asp_id) REFERENCES AdvertisedServicePackage(asp_id) ON DELETE SET NULL,
    FOREIGN KEY (reservation_number) REFERENCES Reservation(reservation_number) ON DELETE CASCADE
);

-- FacilityReservation Table
CREATE TABLE FacilityReservation
(
    fr_id INT PRIMARY KEY,
    booking_id INT,
    facility_id INT,
    start_date_time DATETIME,
    end_date_time DATETIME,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (facility_id) REFERENCES Facility(facility_id) ON DELETE CASCADE
);

-- BookingGuest Table (Associative Entity)
CREATE TABLE BookingGuest
(
    booking_id INT,
    guest_id INT,
    PRIMARY KEY (booking_id, guest_id),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (guest_id) REFERENCES Guest(guest_id) ON DELETE CASCADE
);

-- Payment Table
CREATE TABLE Payment
(
    payment_id INT PRIMARY KEY,
    reservation_number INT,
    amount DECIMAL(10, 2),
    payment_method VARCHAR(50),
    payment_date DATE,
    FOREIGN KEY (reservation_number) REFERENCES Reservation(reservation_number) ON DELETE CASCADE
);

-- Discount Table
CREATE TABLE Discount
(
    discount_id INT PRIMARY KEY,
    reservation_number INT,
    amount DECIMAL(10, 2),
    employee_id INT,
    FOREIGN KEY (reservation_number) REFERENCES Reservation(reservation_number) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE SET NULL
);

-- Insert sample data into each table

-- Sample data for Hotel Table
INSERT INTO Hotel
    (name, address, country, phone_number, description)
VALUES
    ('Hotel Sunshine', '123 Sunny St, Sydney', 'Australia', '123456789', 'A beautiful hotel in Sydney'),
    ('Hotel Rainforest', '456 Rainy Ave, Cairns', 'Australia', '987654321', 'A serene retreat in the rainforest');

-- Sample data for Facility Table
INSERT INTO Facility
    (name, description, status, hotel_id)
VALUES
    ('Swimming Pool', 'Outdoor pool with sun loungers', 'Available', 1),
    ('Gym', 'Fully equipped gym', 'Available', 1),
    ('Conference Room', 'Spacious conference room', 'Maintenance', 2);

-- Sample data for FacilityType Table
INSERT INTO FacilityType
    (name, description, capacity)
VALUES
    ('Standard Room', 'A room with a queen bed', 2),
    ('Family Room', 'A room with a queen bed and two single beds', 4),
    ('Conference Hall', 'Large hall for events', 100);

-- Sample data for ServiceCategory Table
INSERT INTO ServiceCategory
    (code, name, description, type)
VALUES
    ('F&B', 'Food & Beverage', 'Meals and drinks', 'Catering'),
    ('ACC', 'Accommodation', 'Room stays', 'Lodging'),
    ('ENT', 'Entertainment', 'Entertainment services', 'Leisure');

-- Sample data for ServiceItem Table
INSERT INTO ServiceItem
    (name, description, restrictions, notes, comments, status, available_times, base_cost, base_currency, capacity)
VALUES
    ('Breakfast Buffet', 'All you can eat breakfast buffet', 'None', 'Served from 7-10 AM', 'Popular with guests', 'Available', '7:00-10:00', 20.00, 'AUD', 100),
    ('Room Cleaning', 'Daily room cleaning service', 'None', 'Available daily', 'Contact housekeeping for more details', 'Available', '9:00-17:00', 15.00, 'AUD', 1);

-- Sample data for FacilityServiceItem Table
INSERT INTO FacilityServiceItem
    (facility_id, service_id)
VALUES
    (1, 1),
    -- Swimming Pool - Breakfast Buffet (example, though logically might not be correct)
    (2, 2);
-- Gym - Room Cleaning (example, though logically might not be correct)

-- Sample data for Employee Table
INSERT INTO Employee
    (name, position)
VALUES
    ('John Doe', 'Manager'),
    ('Jane Smith', 'Receptionist');

-- Sample data for AdvertisedServicePackage Table
INSERT INTO AdvertisedServicePackage
    (name, description, start_date, end_date, advertised_price, advertised_currency, inclusions, exclusions, status, grace_period, employee_id)
VALUES
    ('Weekend Getaway', 'Two-night stay with breakfast included', '2024-06-01', '2024-06-30', 299.99, 'AUD', 'Breakfast, Free Wi-Fi', 'No pets allowed', 'Active', 7, 1),
    ('Family Fun Package', 'Three-night stay with tickets to local attractions', '2024-07-01', '2024-07-31', 499.99, 'AUD', 'Tickets to zoo, Breakfast', 'No pets allowed', 'Active', 7, 1);

-- Sample data for PackageServiceItem Table
INSERT INTO PackageServiceItem
    (asp_id, service_id, quantity)
VALUES
    (1, 1, 1),
    -- Weekend Getaway - Breakfast Buffet
    (2, 2, 1);
-- Family Fun Package - Room Cleaning

-- Sample data for Customer Table
INSERT INTO Customer
    (name, address, contact_number, email)
VALUES
    ('Alice Brown', '789 Market St, Melbourne', '555123456', 'alice.brown@example.com'),
    ('Bob Green', '321 Pine Rd, Brisbane', '555654321', 'bob.green@example.com');

-- Sample data for Guest Table
INSERT INTO Guest
    (name, address, contact_number, email)
VALUES
    ('Charlie Brown', '789 Market St, Melbourne', '555123457', 'charlie.brown@example.com'),
    ('Daisy Green', '321 Pine Rd, Brisbane', '555654322', 'daisy.green@example.com');

-- Sample data for Reservation Table
INSERT INTO Reservation
    (customer_id, total_amount_due, deposit_due, payment_information)
VALUES
    (1, 299.99, 74.99, 'Paid via Credit Card'),
    (2, 499.99, 124.99, 'Paid via Debit Card');

-- Sample data for Booking Table
INSERT INTO Booking
    (asp_id, reservation_number, quantity, start_date, end_date)
VALUES
    (1, 1, 1, '2024-06-10', '2024-06-12'),
    -- Weekend Getaway - Reservation 1
    (2, 2, 1, '2024-07-15', '2024-07-18');
-- Family Fun Package - Reservation 2

-- Sample data for FacilityReservation Table
INSERT INTO FacilityReservation
    (booking_id, facility_id, start_date_time, end_date_time)
VALUES
    (1, 1, '2024-06-10 15:00', '2024-06-12 11:00'),
    -- Reservation for Swimming Pool
    (2, 2, '2024-07-15 15:00', '2024-07-18 11:00');
-- Reservation for Gym

-- Sample data for BookingGuest Table
INSERT INTO BookingGuest
    (booking_id, guest_id)
VALUES
    (1, 1),
    -- Booking 1 - Guest 1
    (2, 2);
-- Booking 2 - Guest 2

-- Sample data for Payment Table
INSERT INTO Payment
    (reservation_number, amount, payment_method, payment_date)
VALUES
    (1, 299.99, 'Credit Card', '2024-06-01'),
    (2, 499.99, 'Debit Card', '2024-07-01');

-- Sample data for Discount Table
INSERT INTO Discount
    (reservation_number, amount, employee_id)
VALUES
    (1, 10.00, 1),
    -- Discount for Reservation 1 by Employee 1
    (2, 20.00, 2);  -- Discount for Reservation 2 by Employee 2
