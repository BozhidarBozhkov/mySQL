-- 1. Employees with Salary Above 35000
DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN
	SELECT `first_name`, `last_name` FROM `employees`
    WHERE `salary` > 35000
    ORDER BY `first_name`, `last_name`, `employee_id`;
END$$

CALL usp_get_employees_salary_above_35000()$$

-- 2. Employees with Salary Above Number

CREATE PROCEDURE usp_get_employees_salary_above(salary_above DECIMAL(19,4))
BEGIN
	SELECT `first_name`, `last_name` FROM `employees`
    WHERE `salary` >= salary_above
    ORDER BY `first_name`, `last_name`, `employee_id`;
END$$

CALL usp_get_employees_salary_above(45000)$$

-- 3. Town Names Starting With
CREATE PROCEDURE usp_get_towns_starting_with(town_start_with VARCHAR(50))
BEGIN
	SELECT `name` AS `town_name` FROM `towns`
	WHERE `name` LIKE CONCAT(town_start_with, '%')
	-- WHERE `name` LIKE 'town_start_with%'
    ORDER BY `name`;
END$$

CALL usp_get_towns_starting_with('b')$$

-- 4. Employees from Town
CREATE PROCEDURE usp_get_employees_from_town(town_name VARCHAR(50))
BEGIN
	SELECT e.`first_name`, e.`last_name` FROM `employees` AS e
	JOIN `addresses` AS a ON a.`address_id` = e.`address_id`
	JOIN `towns` AS t ON t.`town_id` = a.`town_id`
	WHERE t.`name` = town_name
	ORDER BY e.`first_name`, e.`last_name`, e.`employee_id`;
END$$

CALL usp_get_employees_from_town('Sofia')$$

-- 5. Salary Level Function
CREATE FUNCTION ufn_get_salary_level(salary DECIMAL(19,4))
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
	DECLARE salary_level VARCHAR(10);
		IF salary < 30000 THEN SET salary_level := "Low";
        ELSEIF salary BETWEEN 30000 AND 50000 THEN SET salary_level := "Average";
        ELSEIF salary > 50000 THEN SET salary_level := "High";
	END IF;
    RETURN salary_level;
END$$

-- 6. Employees by Salary Level
CREATE PROCEDURE usp_get_employees_by_salary_level(salary_level VARCHAR(10))
BEGIN
		SELECT e.`first_name`, e.`last_name` FROM `employees` AS e
        WHERE salary_level = (SELECT ufn_get_salary_level(e.`salary`))
		ORDER BY e.`first_name` DESC, e.`last_name` DESC;
END$$

CALL usp_get_employees_by_salary_level("High")$$

-- 7. Define Function
CREATE FUNCTION ufn_is_word_comprised(set_of_letters VARCHAR(50), word VARCHAR(50))
RETURNS BIT
DETERMINISTIC
BEGIN
	RETURN (SELECT word REGEXP(CONCAT('^[', set_of_letters, ']+$')));
END$$

SELECT ufn_is_word_comprised('oistmiahf', 'Sofia')$$