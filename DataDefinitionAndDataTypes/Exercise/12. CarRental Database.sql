CREATE DATABASE `car_rental`;
USE `car_rental`;

CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`category` VARCHAR(30),
`daily_rate` DOUBLE,
`weekly_rate` DOUBLE,
`monthly_rate` DOUBLE,
`weekend_rate` DOUBLE
);

CREATE TABLE `cars` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`plate_number` VARCHAR(10),
`make` VARCHAR(25),
`model` VARCHAR(30),
`car_year` YEAR,
`category_id` INT,
`doors` INT NOT NULL,
`picture` BLOB,
`car_condirion` VARCHAR(30),
`available` BOOLEAN
);

CREATE TABLE `employees` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(25) NOT NULL,
`last_name` VARCHAR(25) NOT NULL,
`title` VARCHAR(25),
`notes` TEXT
);

CREATE TABLE `customers` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`driver_licence_number` VARCHAR(30) NOT NULL,
`full_name` VARCHAR(100) NOT NULL,
`address` VARCHAR(100),
`city` VARCHAR(25),
`zip_code` VARCHAR(25),
`notes` TEXT
);

CREATE TABLE `rental_orders` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`employee_id` INT,
`customer_id` INT,
`car_id` INT,
`car_condition` VARCHAR(30),
`tank_level` VARCHAR(25),
`kilometrage_start` INT NOT NULL,
`kilometrage_end` INT NOT NULL,
`total_kilometrage` INT,
`start_date` DATE NOT NULL,
`end_date` DATE NOT NULL,
`total_days` INT NOT NULL,
`rate_applied` DOUBLE NOT NULL,
`tax_rate` INT,
`order_status` VARCHAR(30),
`notes` TEXT
);

INSERT INTO `categories` (`category`)
VALUES ("Economy"), ("SUV"), ("Luxury");

INSERT INTO `cars` (`plate_number`, `make`, `model`, `doors`)
VALUES ("CB1234AB", "Kia", "Sportage", 5),
("CB1155TM", "Audi", "A6", 4),
("CB8543EH", "VW", "Passat", 5);

INSERT INTO `employees` (`first_name`, `last_name`)
VALUES ("Bozhidar", "Bozhkov"),
("Nikol", "Dimitrova"),
("Emil", "Kopchev");

INSERT INTO `customers` (`driver_licence_number`, `full_name`, `city`)
VALUES ("280532845", "Ivan Petrov", "Sofia"),
("E-25483A", "Juan Martinez", "Madrid"),
("JK25A5863", "John Smith", "New York");

INSERT INTO `rental_orders` (`kilometrage_start`, `kilometrage_end`, `start_date`, `end_date`, `total_days`, `rate_applied`)
VALUES (1000, 1958, '2022-09-01', '2022-09-06', 5, 45.23),
(12358, 15870, '2022-08-15', '2022-08-25', 10, 1523.12),
(45300, 46215, '2022-05-14', '2022-06-01', 17, 986.00);