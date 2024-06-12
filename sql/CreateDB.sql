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
    hotel_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    country VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    description TEXT
);

-- FacilityType Table
CREATE TABLE FacilityType
(
    type_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(50) NOT NULL,
    description TEXT,
    capacity INT
);

-- Facility Table
CREATE TABLE Facility
(
    facility_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) CHECK (status IN ('Available', 'Unavailable', 'Maintenance')),
    hotel_id INT,
    type_id INT,
    FOREIGN KEY (hotel_id) REFERENCES Hotel(hotel_id) ON DELETE CASCADE,
    FOREIGN KEY (type_id) REFERENCES FacilityType(type_id) ON DELETE CASCADE
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
    service_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    restrictions TEXT,
    notes TEXT,
    comments TEXT,
    status VARCHAR(20) CHECK (status IN ('Available', 'Unavailable')),
    available_times VARCHAR(100),
    base_cost DECIMAL(10, 2),
    base_currency VARCHAR(3),
    capacity INT,
    category_code VARCHAR(10) NULL,
    FOREIGN KEY (category_code) REFERENCES ServiceCategory(code) ON DELETE SET NULL
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
    employee_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    position VARCHAR(50)
);

-- AdvertisedServicePackage Table
CREATE TABLE AdvertisedServicePackage
(
    asp_id INT PRIMARY KEY IDENTITY(1,1),
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
    customer_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200),
    contact_number VARCHAR(20),
    email VARCHAR(100)
);

-- Guest Table
CREATE TABLE Guest
(
    guest_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200),
    contact_number VARCHAR(20),
    email VARCHAR(100)
);

-- Reservation Table
CREATE TABLE Reservation
(
    reservation_number INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT,
    total_amount_due DECIMAL(10, 2),
    deposit_due DECIMAL(10, 2),
    payment_information TEXT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE SET NULL
);

-- Booking Table
CREATE TABLE Booking
(
    booking_id INT PRIMARY KEY IDENTITY(1,1),
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
    fr_id INT PRIMARY KEY IDENTITY(1,1),
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
    payment_id INT PRIMARY KEY IDENTITY(1,1),
    reservation_number INT,
    amount DECIMAL(10, 2),
    payment_method VARCHAR(50),
    payment_date DATE,
    FOREIGN KEY (reservation_number) REFERENCES Reservation(reservation_number) ON DELETE CASCADE
);

-- Discount Table
CREATE TABLE Discount
(
    discount_id INT PRIMARY KEY IDENTITY(1,1),
    reservation_number INT,
    amount DECIMAL(10, 2),
    employee_id INT,
    FOREIGN KEY (reservation_number) REFERENCES Reservation(reservation_number) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE SET NULL
);

/* Sample Data */

USE LeisureAustralasiaDB;

-- Insert sample data into each table

-- Sample data for Hotel Table
INSERT INTO Hotel
    (name, address, country, phone_number, description)
VALUES
    ('Brisbane Luxury Hotel', '123 Brisbane St, Brisbane', 'Australia', '1234567890', 'A luxurious hotel in Brisbane.'),
    ('Cairns Beach Resort', '456 Cairns Ave, Cairns', 'Australia', '2345678901', 'A beautiful beach resort in Cairns.'),
    ('Newcastle City Hotel', '789 Newcastle Blvd, Newcastle', 'Australia', '3456789012', 'A modern hotel in Newcastle city center.'),
    ('Broome Sunset Hotel', '101 Broome Rd, Broome', 'Australia', '4567890123', 'A scenic hotel in Broome.'),
    ('Darwin Harbor Hotel', '202 Darwin Ave, Darwin', 'Australia', '5678901234', 'A harbor view hotel in Darwin.'),
    ('Hanoi Elegance Hotel', '303 Hanoi St, Hanoi', 'Vietnam', '6789012345', 'A charming hotel in Hanoi.'),
    ('Singapore Riverside Hotel', '404 Singapore Rd, Singapore', 'Singapore', '7890123456', 'A riverside hotel in Singapore.'),
    ('Bangkok Grand Hotel', '505 Bangkok Ave, Bangkok', 'Thailand', '8901234567', 'A grand hotel in Bangkok.'),
    ('Colombo Beach Resort', '606 Colombo Blvd, Colombo', 'Sri Lanka', '9012345678', 'A beach resort in Colombo.'),
    ('Mumbai City Hotel', '707 Mumbai Rd, Mumbai', 'India', '0123456789', 'A bustling hotel in Mumbai city center.');

-- Insert sample data into FacilityType Table
INSERT INTO FacilityType
    (name, description, capacity)
VALUES
    ('Standard Room', 'A room with a queen bed', 2),
    ('Family Room', 'A room with a queen bed and two single beds', 4),
    ('Conference Hall', 'Large hall for events', 100),
    ('Swimming Pool', 'Outdoor pool with sun loungers', 50),
    ('Gym', 'Fully equipped gym', 20),
    ('Spa', 'Relaxing spa with massage services', 10),
    ('Restaurant', 'On-site dining options', 50),
    ('Bar', 'Bar with a selection of drinks', 30),
    ('Lobby', 'Elegant lobby with seating area', 50),
    ('Meeting Room', 'Room for business meetings', 20),
    ('Rooftop Terrace', 'Terrace with city views', 40),
    ('Kids Play Area', 'Indoor play area for children', 30),
    ('Laundry Room', 'Self-service laundry facilities', 10),
    ('Library', 'Quiet library with books', 15),
    ('Sauna', 'Traditional Finnish sauna', 8),
    ('Cinema Room', 'Private cinema room with comfortable seating', 25),
    ('Garden', 'Outdoor garden with walking paths', 60),
    ('Game Room', 'Room with arcade machines and board games', 20),
    ('Pet Care Center', 'Facility for pet care and grooming', 10),
    ('Parking Garage', 'Secure underground parking', 100);


-- Insert sample data into Facility Table
INSERT INTO Facility
    (name, description, status, hotel_id, type_id)
VALUES
    ('Swimming Pool', 'Outdoor pool with sun loungers', 'Available', 1, 4),
    ('Gym', 'Fully equipped gym', 'Available', 1, 5),
    ('Conference Room', 'Spacious conference room', 'Maintenance', 2, 3),
    ('Hotel Lobby', 'Elegant lobby with seating area', 'Available', 3, 9),
    ('Spa', 'Relaxing spa with massage services', 'Available', 2, 6),
    ('Restaurant', 'Gourmet restaurant with diverse menu', 'Available', 1, 7),
    ('Bar', 'Cocktail bar with a wide selection of drinks', 'Available', 1, 8),
    ('Business Center', 'Business center with computers and printers', 'Available', 3, 9),
    ('Parking Garage', 'Secure underground parking', 'Available', 2, 20),
    ('Tennis Court', 'Outdoor tennis court', 'Maintenance', 1, 4);

-- Insert sample data into ServiceCategory Table
INSERT INTO ServiceCategory
    (code, name, description, type)
VALUES
    ('FOOD', 'Food & Meals', 'Meals provided to guests', 'Service'),
    ('ACCM', 'Accommodation', 'Lodging for guests', 'Service'),
    ('EVENT', 'Event Venues', 'Venues for events', 'Service'),
    ('GYM', 'Gym', 'Fitness center', 'Service'),
    ('LAUN', 'Laundry', 'Laundry services', 'Service'),
    ('ENTR', 'Entertainment', 'Entertainment options', 'Service'),
    ('TOUR', 'Site-Seeing Tours', 'Tours for guests', 'Service'),
    ('TAXI', 'Taxis', 'Taxi services', 'Service'),
    ('SPA', 'Spa Services', 'Spa and wellness services', 'Service'),
    ('TRANS', 'Transportation', 'Transportation services', 'Service');

-- Insert sample data into ServiceItem Table
INSERT INTO ServiceItem
    (name, description, restrictions, notes, comments, status, available_times, base_cost, base_currency, capacity, category_code)
VALUES
    ('Breakfast Buffet', 'All you can eat breakfast buffet', 'None', 'Served from 7-10 AM', 'Popular with guests', 'Available', '7:00-10:00', 20.00, 'AUD', 100, 'FOOD'),
    ('Room Cleaning', 'Daily room cleaning service', 'None', 'Available daily', 'Contact housekeeping for more details', 'Available', '9:00-17:00', 15.00, 'AUD', 1, 'LAUN'),
    ('Wi-Fi', 'High-speed internet access', 'None', 'Available in all rooms', 'Complimentary for guests', 'Available', '24 hours', 0.00, 'AUD', 1, 'ENTR'),
    ('Standard Room Night Stay', 'One night stay in a standard room', 'No restrictions', 'Standard amenities included', 'Comfortable and spacious', 'Available', '24/7', 100.00, 'AUD', 2, 'ACCM'),
    ('Conference Booking', 'Booking for a conference hall', 'Pre-booking required', 'Includes basic audio-visual equipment', 'Ideal for business meetings', 'Unavailable', '9:00 AM - 5:00 PM', 500.00, 'AUD', 100, 'EVENT'),
    ('Gym Access', 'Access to the gym', 'Guests only', 'Bring your own towel', 'State-of-the-art equipment', 'Unavailable', '6:00 AM - 10:00 PM', 10.00, 'AUD', 20, 'GYM'),
    ('Dinner Buffet', 'A buffet dinner', 'None', 'Wide variety of dishes available', 'Includes dessert options', 'Available', '6:00 PM - 9:00 PM', 30.00, 'AUD', 50, 'FOOD'),
    ('Spa Treatment', 'Full body spa treatment', 'Pre-booking required', 'Includes complimentary drinks', 'Relaxing and rejuvenating', 'Available', '9:00 AM - 8:00 PM', 150.00, 'AUD', 5, 'SPA'),
    ('Airport Shuttle', 'Shuttle service to and from the airport', 'Book 24 hours in advance', 'Operates every hour', 'Convenient for guests', 'Available', '5:00 AM - 11:00 PM', 25.00, 'AUD', 15, 'TRANS'),
    ('Laundry Service', 'Full laundry service', 'None', 'Same day service available', 'Contact housekeeping for details', 'Available', '9:00 AM - 5:00 PM', 10.00, 'AUD', 10, 'LAUN');

-- Insert sample data into FacilityServiceItem Table
INSERT INTO FacilityServiceItem
    (facility_id, service_id)
VALUES
    (1, 1),
    (2, 2),
    (3, 5),
    (4, 3),
    (5, 8),
    (6, 7),
    (7, 10);

-- Insert sample data into Employee Table
INSERT INTO Employee
    (name, position)
VALUES
    ('John Doe', 'Manager'),
    ('Jane Smith', 'Receptionist'),
    ('Robert Johnson', 'Chef'),
    ('Emily Davis', 'Housekeeping Supervisor'),
    ('Michael Wilson', 'Concierge'),
    ('Sarah Brown', 'Event Coordinator'),
    ('David Miller', 'Maintenance Manager'),
    ('Jessica Moore', 'Sales Manager'),
    ('Daniel Taylor', 'IT Support Specialist'),
    ('Laura Anderson', 'Marketing Manager');

-- Insert sample data into AdvertisedServicePackage Table
INSERT INTO AdvertisedServicePackage
    (name, description, start_date, end_date, advertised_price, advertised_currency, inclusions, exclusions, status, grace_period, employee_id)
VALUES
    ('Weekend Getaway', 'Two-night stay with breakfast included', '2024-06-01', '2024-06-30', 299.99, 'AUD', 'Breakfast, Free Wi-Fi', 'No pets allowed', 'Active', 7, 1),
    ('Family Fun Package', 'Three-night stay with tickets to local attractions', '2024-07-01', '2024-07-31', 499.99, 'AUD', 'Tickets to zoo, Breakfast', 'No pets allowed', 'Active', 7, 2),
    ('Romantic Escape', 'One-night stay with a candlelight dinner', '2024-08-01', '2024-08-31', 199.99, 'AUD', 'Dinner, Champagne, Free Wi-Fi', 'No children allowed', 'Active', 5, 3),
    ('Adventure Package', 'Four-night stay with adventure sports', '2024-09-01', '2024-09-30', 799.99, 'AUD', 'Adventure sports, Breakfast', 'No pets allowed', 'Active', 10, 4),
    ('Luxury Retreat', 'Five-night stay with spa access', '2024-10-01', '2024-10-31', 999.99, 'AUD', 'Spa access, Breakfast, Dinner', 'No pets allowed', 'Active', 7, 5);

-- Insert sample data into PackageServiceItem Table
INSERT INTO PackageServiceItem
    (asp_id, service_id, quantity)
VALUES
    (1, 1, 2),
    -- Weekend Getaway - Breakfast Buffet
    (1, 4, 2),
    -- Weekend Getaway - Standard Room Night Stay
    (2, 1, 3),
    -- Family Fun Package - Breakfast Buffet
    (2, 4, 3),
    -- Family Fun Package - Standard Room Night Stay
    (3, 4, 1),
    -- Romantic Escape - Standard Room Night Stay
    (3, 7, 1),
    -- Romantic Escape - Dinner Buffet
    (4, 4, 4),
    -- Adventure Package - Standard Room Night Stay
    (4, 9, 4),
    -- Adventure Package - Airport Shuttle
    (5, 4, 5),
    -- Luxury Retreat - Standard Room Night Stay
    (5, 8, 5);
-- Luxury Retreat - Spa Treatment

-- Insert sample data into Customer Table
INSERT INTO Customer
    (name, address, contact_number, email)
VALUES
    ('Alice Brown', '789 Market St, Melbourne', '555123456', 'alice.brown@example.com'),
    ('Bob Green', '321 Pine Rd, Brisbane', '555654321', 'bob.green@example.com'),
    ('Charlie White', '456 Oak St, Sydney', '555789012', 'charlie.white@example.com'),
    ('David Black', '123 Elm St, Perth', '555345678', 'david.black@example.com'),
    ('Emily Gray', '987 Willow St, Adelaide', '555456789', 'emily.gray@example.com'),
    ('Pewrie Bontal', '760111 Pine Rd, Brisbane', '555654321', 'pewrie@bontal.net'),
    ('Min Thu Khaing', '760809 Yishun Ring Road', '87476403', '0x@bontal.net'),
    ('Thet Paing Hmue', '310145 Block 145 Lorong 2 Toapayoh 36-302', '82845157', 'lnvlps11@gmail.com'),
    ('Emily Johnson', '987 Willow St, Adelaide', '555456789', 'emily.johnson@example.com'),
    ('Frank Williams', '654 Maple Ave, Hobart', '555567890', 'frank.williams@example.com'),
    ('Grace Taylor', '321 Cedar Rd, Darwin', '555678901', 'grace.taylor@example.com'),
    ('Henry Brown', '789 Birch St, Canberra', '555789123', 'henry.brown@example.com'),
    ('Isla Wilson', '123 Spruce St, Newcastle', '555890234', 'isla.wilson@example.com'),
    ('Jack Martin', '456 Ash St, Gold Coast', '555901345', 'jack.martin@example.com');

-- Insert sample data into Guest Table
INSERT INTO Guest
    (name, address, contact_number, email)
VALUES
    ('Charlie Brown', '789 Market St, Melbourne', '555123457', 'charlie.brown@example.com'),
    ('Daisy Green', '321 Pine Rd, Brisbane', '555654322', 'daisy.green@example.com'),
    ('Wolfgang Mozart', '789 Amadeus St, Vienna', '555123457', 'wolfgang.mozart@example.com'),
    ('Sigmund Freud', '321 Berggasse, Vienna', '555654322', 'sigmund.freud@example.com'),
    ('Maria Theresia', '456 Habsburg St, Vienna', '555789012', 'maria.theresia@example.com'),
    ('Franz Schubert', '123 Schubert St, Vienna', '555345678', 'franz.schubert@example.com'),
    ('Arnold Schwarzenegger', '987 Hollywood Blvd, Los Angeles', '555456789', 'arnold.schwarzenegger@example.com'),
    ('Friedensreich Hundertwasser', '654 Kunst Haus, Vienna', '555567890', 'friedensreich.hundertwasser@example.com'),
    ('Gustav Klimt', '321 Art Nouveau Rd, Vienna', '555678901', 'gustav.klimt@example.com'),
    ('Ludwig Wittgenstein', '789 Philosophy Ln, Vienna', '555789123', 'ludwig.wittgenstein@example.com'),
    ('Gregor Mendel', '123 Genetics St, Brno', '555890234', 'gregor.mendel@example.com'),
    ('Niki Lauda', '456 Formula 1 St, Vienna', '555901345', 'niki.lauda@example.com');

-- Insert sample data into Reservation Table
INSERT INTO Reservation
    (customer_id, total_amount_due, deposit_due, payment_information)
VALUES
    (1, 299.99, 74.99, 'Paid via Credit Card'),
    (2, 499.99, 124.99, 'Paid via Debit Card'),
    (3, 199.99, 49.99, 'Paid via PayPal'),
    (4, 399.99, 99.99, 'Paid via Bank Transfer'),
    (5, 599.99, 149.99, 'Paid via Credit Card'),
    (6, 150.00, 37.50, 'Paid via Cash'),
    (7, 350.00, 87.50, 'Paid via Debit Card'),
    (8, 450.00, 112.50, 'Paid via Credit Card'),
    (9, 250.00, 62.50, 'Paid via PayPal'),
    (10, 550.00, 137.50, 'Paid via Bank Transfer');

-- Insert sample data into Booking Table
INSERT INTO Booking
    (asp_id, reservation_number, quantity, start_date, end_date)
VALUES
    (1, 1, 1, '2024-06-10', '2024-06-12'),
    -- Weekend Getaway - Reservation 1
    (2, 2, 1, '2024-07-15', '2024-07-18'),
    -- Family Vacation - Reservation 2
    (3, 3, 1, '2024-08-01', '2024-08-03'),
    -- Romantic Escape - Reservation 3
    (4, 4, 1, '2024-09-05', '2024-09-12'),
    -- Adventure Trip - Reservation 4
    (1, 5, 1, '2024-10-10', '2024-10-15'),
    -- Weekend Getaway - Reservation 5
    (2, 6, 1, '2024-11-15', '2024-11-20'),
    -- Family Vacation - Reservation 6
    (3, 7, 1, '2024-12-01', '2024-12-05'),
    -- Romantic Escape - Reservation 7
    (4, 8, 1, '2025-01-10', '2025-01-17'),
    -- Adventure Trip - Reservation 8
    (1, 9, 1, '2025-02-15', '2025-02-20'),
    -- Weekend Getaway - Reservation 9
    (2, 10, 1, '2025-03-05', '2025-03-10');
-- Family Vacation - Reservation 10


-- Insert sample data into FacilityReservation Table
INSERT INTO FacilityReservation
    (booking_id, facility_id, start_date_time, end_date_time)
VALUES
    (1, 1, '2024-06-10 15:00', '2024-06-12 11:00'),
    -- Reservation for Facility 1 (Standard Room) in Booking 1
    (2, 2, '2024-07-15 15:00', '2024-07-18 11:00'),
    -- Reservation for Facility 2 (Family Room) in Booking 2
    (3, 3, '2024-08-01 09:00', '2024-08-01 17:00'),
    -- Reservation for Facility 3 (Conference Hall) in Booking 3
    (4, 4, '2024-09-05 06:00', '2024-09-12 10:00'),
    -- Reservation for Facility 4 (Swimming Pool) in Booking 4
    (5, 5, '2024-10-10 07:00', '2024-10-10 09:00'),
    -- Reservation for Facility 5 (Gym) in Booking 5
    (6, 1, '2024-11-15 14:00', '2024-11-20 11:00'),
    -- Reservation for Facility 1 (Standard Room) in Booking 6
    (7, 2, '2024-12-01 15:00', '2024-12-05 11:00'),
    -- Reservation for Facility 2 (Family Room) in Booking 7
    (8, 3, '2025-01-10 09:00', '2025-01-10 17:00'),
    -- Reservation for Facility 3 (Conference Hall) in Booking 8
    (9, 4, '2025-02-15 06:00', '2025-02-20 10:00'),
    -- Reservation for Facility 4 (Swimming Pool) in Booking 9
    (10, 5, '2025-03-05 07:00', '2025-03-05 09:00');
-- Reservation for Facility 5 (Gym) in Booking 10

-- Insert sample data into BookingGuest Table
INSERT INTO BookingGuest
    (booking_id, guest_id)
VALUES
    (1, 1),
    -- Booking 1 - Guest 1
    (2, 2),
    -- Booking 2 - Guest 2
    (3, 3),
    -- Booking 3 - Guest 3
    (4, 4),
    -- Booking 4 - Guest 4
    (5, 5),
    -- Booking 5 - Guest 5
    (6, 6),
    -- Booking 6 - Guest 6
    (7, 7),
    -- Booking 7 - Guest 7
    (8, 8),
    -- Booking 8 - Guest 8
    (9, 9),
    -- Booking 9 - Guest 9
    (10, 10);
-- Booking 10 - Guest 10

-- Insert sample data into Payment Table
INSERT INTO Payment
    (reservation_number, amount, payment_method, payment_date)
VALUES
    (1, 299.99, 'Credit Card', '2024-06-01'),
    (2, 499.99, 'Debit Card', '2024-07-01'),
    (3, 199.99, 'PayPal', '2024-08-01'),
    (4, 799.99, 'Bank Transfer', '2024-09-01'),
    (5, 999.99, 'Credit Card', '2024-10-01'),
    (6, 250.00, 'Credit Card', '2024-06-05'),
    (7, 350.00, 'Bank Transfer', '2024-06-06'),
    (8, 400.00, 'Credit Card', '2024-06-07'),
    (9, 450.00, 'Debit Card', '2024-06-08'),
    (10, 500.00, 'Credit Card', '2024-06-09');

-- Insert sample data into Discount Table
INSERT INTO Discount
    (reservation_number, amount, employee_id)
VALUES
    (1, 10.00, 1),
    -- Discount for Reservation 1 by Employee 1
    (2, 20.00, 2),
    -- Discount for Reservation 2 by Employee 2
    (3, 15.00, 3),
    -- Discount for Reservation 3 by Employee 3
    (4, 25.00, 4),
    -- Discount for Reservation 4 by Employee 4
    (5, 30.00, 5),
    -- Discount for Reservation 5 by Employee 5
    (6, 5.00, 6),
    -- Discount for Reservation 6 by Employee 6
    (7, 12.50, 7),
    -- Discount for Reservation 7 by Employee 7
    (8, 20.00, 8),
    -- Discount for Reservation 8 by Employee 8
    (9, 10.00, 9),
    -- Discount for Reservation 9 by Employee 9
    (10, 22.50, 10);
-- Discount for Reservation 10 by Employee 10
