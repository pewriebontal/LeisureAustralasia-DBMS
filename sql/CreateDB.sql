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
--Booking Table
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
