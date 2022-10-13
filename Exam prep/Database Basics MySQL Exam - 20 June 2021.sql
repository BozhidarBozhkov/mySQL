-- 1. Table Design
CREATE TABLE `addresses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(100) NOT NULL
);

CREATE TABLE `categories`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(10) NOT NULL	
);

CREATE TABLE `clients`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`full_name` VARCHAR(50) NOT NULL,
`phone_number` VARCHAR(20) NOT NULL
);

CREATE TABLE `drivers`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(30) NOT NULL,
`last_name` VARCHAR(30) NOT NULL,
`age` INT NOT NULL,
`rating` FLOAT DEFAULT(5.5)
);

CREATE TABLE `cars`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`make` VARCHAR(20) NOT NULL,
`model` VARCHAR(20),
`year` INT NOT NULL DEFAULT(0),
`mileage` INT DEFAULT(0),
`condition` CHAR(1) NOT NULL,
`category_id` INT NOT NULL,
CONSTRAINT fk_cars_categories
FOREIGN KEY(`category_id`) REFERENCES `categories`(`id`)
);

CREATE TABLE `courses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`from_address_id` INT NOT NULL,
`start` DATETIME NOT NULL,
`bill` DECIMAL(10,2) DEFAULT(10),
`car_id` INT NOT NULL,
`client_id` INT NOT NULL,
CONSTRAINT fk_courses_addresses
FOREIGN KEY(`from_address_id`) REFERENCES `addresses`(`id`),
CONSTRAINT fk_courses_cars
FOREIGN KEY(`car_id`) REFERENCES `cars`(`id`),
CONSTRAINT fk_courses_clients
FOREIGN KEY(`client_id`) REFERENCES `clients`(`id`)
);

CREATE TABLE `cars_drivers`(
`car_id` INT NOT NULL,
`driver_id` INT NOT NULL,
CONSTRAINT pk_cars_drivers
PRIMARY KEY(`car_id`, `driver_id`),
CONSTRAINT fk_cars_drivers_cars
FOREIGN KEY(`car_id`) REFERENCES `cars`(`id`),
CONSTRAINT fk_cars_drivers_drivers
FOREIGN KEY(`driver_id`) REFERENCES `drivers`(`id`)
);

-- 2. Insert
INSERT INTO `clients` (`full_name`, `phone_number`)
SELECT concat_ws(' ', `first_name`, `last_name`),
	CONCAT('(088) 9999', `id` * 2)
    FROM `drivers`
    WHERE `id` BETWEEN 10 AND 20;

-- 3. Update
UPDATE `cars` 
SET `condition` = 'C'
WHERE (`mileage` >= 800000 OR `mileage` IS NULL) AND `year` <= 2010 AND `model` NOT IN ('Mercedes-Benz');

-- 4. Delete
DELETE c FROM `clients` AS c
LEFT JOIN `courses` AS cs ON cs.`client_id` = c.`id`
WHERE cs.`client_id` IS NULL AND CHAR_LENGTH(c.`full_name`) > 3;

-- 5. Cars
SELECT `make`, `model`, `condition` FROM `cars`
ORDER BY `id`;

-- 6. Drivers and Cars
SELECT d.`first_name`, d.`last_name`, c.`make`, c.`model`, c.`mileage` FROM `drivers` AS d
JOIN `cars_drivers` AS cd ON cd.`driver_id` = d.`id`
JOIN `cars` AS c ON c.`id` = cd.`car_id`
WHERE c.`mileage` IS NOT NULL
ORDER BY c.`mileage` DESC, d.`first_name`;

-- 7. Number of courses for each car
SELECT c1.`id`, c1.`make`, c1.`mileage`, COUNT(c2.`id`) AS 'count_of_courses', ROUND(AVG(c2.`bill`), 2) AS 'avg_bill' FROM `cars` AS c1
LEFT JOIN `courses` AS c2 ON c2.`car_id` = c1.`id`
GROUP BY c1.`id`
HAVING `count_of_courses` <> 2
ORDER BY `count_of_courses` DESC, c1.`id`;

-- 8. Regular clients
SELECT cl.`full_name`, COUNT(c.`id`) AS 'count_of_cars', SUM(co.`bill`) AS 'total_sum' FROM `clients` AS cl
JOIN `courses` AS co ON co.`client_id` = cl.`id`
JOIN `cars` AS c ON c.`id` = co.`car_id`
GROUP BY cl.`full_name`
HAVING cl.`full_name` LIKE '_a%' AND `count_of_cars` > 1
ORDER BY cl.`full_name`;

-- 9. Full information of courses
SELECT a.`name`,
 IF (HOUR(c.`start`) BETWEEN 6 AND 20, 'Day', 'Night') AS 'day_time',
 c.`bill`, cl.`full_name`, cr.`make`, cr.`model`, ca.`name` AS 'category_name' FROM `courses` AS c
JOIN `addresses` AS a ON a.`id` = c.`from_address_id`
JOIN `clients` AS cl ON cl.`id` = c.`client_id`
JOIN `cars` AS cr ON cr.`id` = c.`car_id`
JOIN `categories` AS ca ON ca.`id` = cr.`category_id`
ORDER BY c.`id`;

-- 10. Find all courses by client’s phone number
DELIMITER $$
CREATE FUNCTION udf_courses_by_client(phone_num VARCHAR (20))
RETURNS INT 
DETERMINISTIC 
BEGIN
DECLARE count_courses INT;
SET count_courses :=
	(SELECT COUNT(co.id) FROM clients AS cl
	JOIN courses AS co ON co.client_id = cl.id
    WHERE cl.phone_number = phone_num
	GROUP BY cl.full_name);
RETURN count_courses;
END$$

-- 11. Full info for address
CREATE PROCEDURE udp_courses_by_address(address_name VARCHAR(100))
BEGIN
SELECT a.`name`,
cli.`full_name` AS 'full_names',
CASE 
WHEN co.`bill` <= 20 THEN 'Low'
WHEN co.`bill` <= 30 THEN 'Medium'
ELSE 'High'
END AS 'level_of_bill',
cr.`make`,
cr.`condition`,
cat.`name`
 FROM `addresses` AS a
JOIN `courses` AS co ON co.`from_address_id` = a.`id`
LEFT JOIN `clients` AS cli ON cli.`id` = co.`client_id`
LEFt JOIN `cars` AS cr ON cr.`id` = co.`car_id`
LEFT JOIN `categories` AS cat ON cat.`id` = cr.`category_id`
WHERE a.`name` = address_name
ORDER BY cr.`make`, cli.`full_name`;
END$$
DELIMITER ;