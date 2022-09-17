CREATE DATABASE `movies`;
USE `movies`;

CREATE TABLE `directors` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`director_name` VARCHAR(30) NOT NULL,
`notes` TEXT
);

CREATE TABLE `genres` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`genre_name` VARCHAR(30) NOT NULL,
`notes` TEXT
);

CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`category_name` VARCHAR(50) NOT NULL,
`notes` TEXT
);

CREATE TABLE `movies` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`title` VARCHAR(50) NOT NULL,
`director_id` INT,
`copyright_year` YEAR,
`length` TIME,
`genre_id` INT,
`category_id` INT,
`rating` DOUBLE,
`notes` TEXT
);

INSERT INTO `directors` (`director_name`) 
VALUES ("Bozhkov"),
("Simeonsky"),
("Ivanchev"),
("Rashkov"),
("Stoyanov");

INSERT INTO `genres` (`genre_name`, `notes`)
VALUES ("Car rental", "n/a"),
("Automotive", "n/a"),
("Automotive", "n/a"),
("Financial", "n/a"),
("Leasing", "n/a");

INSERT INTO `categories` (`category_name`, `notes`)
VALUES ("Car rental", "n/a"),
("Automotive", "n/a"),
("Automotive", "n/a"),
("Financial", "n/a"),
("Leasing", "n/a");

INSERT INTO `movies` (`title`, `copyright_year`)
VALUES ("Gladiator", 1997),
("The Godfather", 1972),
("Top Gun", 1995),
("Scarface", 1980),
("Fast and Furious", 2000);