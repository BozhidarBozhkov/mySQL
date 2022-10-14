-- 1. Table Design
CREATE TABLE `pictures` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`url` VARCHAR(100) NOT NULL,
`added_on` DATETIME NOT NULL
);

CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `products`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE,
`best_before` DATE,
`price` DECIMAL(10,2) NOT NULL,
`description` TEXT,
`category_id` INT NOT NULL,
`picture_id` INT NOT NULL,
CONSTRAINT fk_products_categories
FOREIGN KEY(`category_id`) REFERENCES `categories`(`id`),
CONSTRAINT fk_products_pictures
FOREIGN KEY(`picture_id`) REFERENCES `pictures`(`id`)
);

CREATE TABLE `towns`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE `addresses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL UNIQUE,
`town_id` INT NOT NULL,
CONSTRAINT fk_addresses_towns
FOREIGN KEY(`town_id`) REFERENCES `towns`(`id`)
);

CREATE TABLE `stores`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL UNIQUE,
`rating` FLOAT NOT NULL,
`has_parking` TINYINT(1) DEFAULT(FALSE),
`address_id` INT NOT NULL,
CONSTRAINT fk_stores_addresses
FOREIGN KEY(`address_id`) REFERENCES `addresses`(`id`)
);

CREATE TABLE `products_stores`(
`product_id` INT NOT NULL,
`store_id` INT NOT NULL,
CONSTRAINT pk_products_stores
PRIMARY KEY(`product_id`, `store_id`),
CONSTRAINT fk_products_stores_products
FOREIGN KEY(`product_id`) REFERENCES `products`(`id`),
CONSTRAINT fk_products_stores_stores
FOREIGN KEY(`store_id`) REFERENCES `stores`(`id`)
);

CREATE TABLE `employees`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(15) NOT NULL,
`middle_name` CHAR(1),
`last_name` VARCHAR(20) NOT NULL,
`salary` DECIMAL(19,2) DEFAULT(0),
`hire_date` DATE NOT NULL,
`manager_id` INT,
`store_id` INT NOT NULL,
CONSTRAINT fk_employees_stores
FOREIGN KEY(`store_id`) REFERENCES `stores`(`id`),
CONSTRAINT fk_employees_manager
FOREIGN KEY(`manager_id`) REFERENCES `employees`(`id`)
);

-- 2. Insert
INSERT INTO `products_stores`(`product_id`, `store_id`)
SELECT p.`id`, 1 FROM `products` AS p
LEFT JOIN `products_stores` AS ps ON ps.`product_id` = p.`id`
LEFT JOIN `stores` AS s ON s.`id` = ps.`store_id`
WHERE s.`id` IS NULL;

-- 3. Update
UPDATE `employees`
SET `salary` = `salary` - 500, `manager_id` = 3
WHERE YEAR(`hire_date`) > '2003' AND `store_id` NOT IN(5,14);

-- 4. Delete
DELETE e FROM `employees` AS e
WHERE `manager_id` IS NOT NULL AND `salary` >= 6000;

-- 5. Employees 
SELECT `first_name`, `middle_name`, `last_name`, `salary`, `hire_date` FROM `employees`
ORDER BY `hire_date` DESC;

-- 6. Products with old pictures
SELECT p.`name`, p.`price`, p.`best_before`, CONCAT(SUBSTRING(p.`description`, 1, 10), '...') AS 'short_description', pic.`url` FROM `products` AS p
JOIN `pictures` AS pic ON pic.`id` = p.`picture_id`
WHERE CHAR_LENGTH(p.`description`) > 100 AND YEAR(pic.`added_on`) < 2019 AND p.`price` > 20
ORDER BY p.`price` DESC;

-- 7. Counts of products in stores and their average
SELECT s.`name`, COUNT(ps.`product_id`) AS 'product_count', ROUND(AVG(p.`price`), 2) AS 'avg' FROM `stores` AS s
LEFT JOIN `products_stores` AS ps ON ps.`store_id` = s.`id`
LEFT JOIN `products` AS p ON p.`id` = ps.`product_id`
GROUP BY s.`name`
ORDER BY `product_count` DESC, `avg` DESC, s.`id`;

-- 8. Specific employee
SELECT CONCAT_WS(' ', e.`first_name`, e.`last_name`) AS 'Full_name', s.`name` AS 'Store_name',
a.`name` AS 'address', e.`salary` FROM `employees` AS e
JOIN `stores` AS s ON s.`id` = e.`store_id`
JOIN `addresses` AS a ON a.`id` = s.`address_id`
WHERE e.`salary` < 4000 AND a.`name` LIKE '%5%' AND CHAR_LENGTH(s.`name`) > 8 AND e.`last_name` LIKE '%n';

-- 9. Find all information of stores
SELECT REVERSE(s.`name`) AS 'reversed_name', 
CONCAT(UPPER(t.`name`), '-', a.`name`) AS 'full_address', 
COUNT(e.`id`) AS 'employees_count' 
FROM `stores` AS s
JOIN `addresses` AS a ON a.`id` = s.`address_id`
JOIN `towns` AS t ON t.`id` = a.`town_id`
JOIN `employees` AS e ON e.`store_id` = s.`id`
GROUP BY s.`id`
HAVING `employees_count` >= 1
ORDER BY `full_address`;

-- 10. Find full name of top paid employee by store name
DELIMITER $$
CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
	DECLARE full_info VARCHAR(255);
    SET full_info := (SELECT CONCAT(e.`first_name`, ' ', e.`middle_name`, '. ', e.`last_name`, ' ',
    'works in store for ', FLOOR(DATEDIFF('2020-10-18', `hire_date`) / 365.25), ' years') FROM `employees` AS e
    JOIN `stores` AS s ON s.`id` = e.`store_id`
	WHERE  s.`name` = store_name AND e.`salary` = (SELECT MAX(e.`salary`) FROM `employees`)
    ORDER BY e.`salary` DESC
	LIMIT 1);
    RETURN full_info;
END$$

-- 11. Update product price by address
CREATE PROCEDURE udp_update_product_price (address_name VARCHAR (50))
BEGIN
UPDATE `products` AS p
JOIN `products_stores` AS ps ON ps.`product_id` = p.`id`
JOIN `stores` AS s ON s.`id` = ps.`store_id`
JOIN `addresses` AS a ON a.`id` = s.`address_id`
SET p.`price` = IF(a.`name` LIKE '0%', p.`price` + 100, p.`price` + 200)
WHERE a.`name` = address_name;
END$$
DELIMITER ;