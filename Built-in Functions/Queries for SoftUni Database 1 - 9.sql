USE `soft_uni_database`;

-- 1. Find Names of All Employees by First Name 
SELECT `first_name`, `last_name` FROM `employees`
WHERE SUBSTRING(`first_name`, 1, 2) = "Sa"
ORDER BY `employee_id`; 

-- 2. Find Names of All Employees by Last Name
SELECT `first_name`, `last_name` FROM `employees`
WHERE LOCATE("ei", `last_name`)
ORDER BY `employee_id`;

SELECT `first_name`, `last_name` FROM `employees`
WHERE `last_name` LIKE '%ei%'
ORDER BY `employee_id`;

-- 3. Find First Names of All Employess
SELECT `first_name` FROM `employees`
WHERE `department_id` IN (3, 10) 
AND YEAR(`hire_date`) BETWEEN 1995 AND 2005
ORDER BY `employee_id`;

-- 4. Find All Employees Except Engineers
SELECT `first_name`, `last_name` FROM `employees`
WHERE `job_title` NOT LIKE "%engineer%"
ORDER BY `employee_id`;

-- 5. Find Towns with Name Length
SELECT `name` FROM `towns`
WHERE CHAR_LENGTH(`name`) = 5 OR CHAR_LENGTH(`name`) = 6
ORDER BY `name`;

-- 6. Find Towns Starting With
SELECT * FROM `towns`
WHERE LEFT(`name`, 1) REGEXP 'M|B|K|E'
ORDER BY `name`; 

SELECT * FROM `towns`
WHERE `name` LIKE ('M%') OR `name` LIKE ('K%') OR `name` LIKE ('B%') OR `name` LIKE ('E%')
ORDER BY `name`;

-- 7. Find Towns Not Starting With
SELECT * FROM `towns`
WHERE LEFT(`name`, 1) NOT REGEXP 'R|B|D'
ORDER BY `name`;

SELECT * FROM `towns`
WHERE `name` NOT LIKE ('R%') AND `name` NOT LIKE ('B%') AND `name` NOT LIKE ('D%')
ORDER BY `name`;

-- 8. Create View Employees Hired After 2000 Year
CREATE VIEW v_employees_hired_after_2000 AS 
SELECT `first_name`, `last_name` FROM `employees`
WHERE YEAR(`hire_date`) > 2000;
SELECT * FROM v_employees_hired_after_2000;

-- 9. Length of Last Name
SELECT `first_name`, `last_name` FROM `employees`
WHERE CHAR_LENGTH(`last_name`) = 5;
