-- 1. Managers

SELECT e1.`employee_id`, 
CONCAT(`first_name`, ' ', `last_name`) AS `full_name`,
d.`department_id`, d.`name` AS `department_name`  FROM `employees` AS e1
JOIN `departments` AS d 
ON d.manager_id = e1.employee_id
ORDER BY `employee_id`
LIMIT 5;


-- 2. Towns Addresses

SELECT t.`town_id`, t.`name`, a.`address_text` FROM `addresses` AS a
JOIN `towns` AS t ON t.`town_id` = a.`town_id`
WHERE t.`name` IN ('San Francisco', 'Sofia', 'Carnation')
ORDER BY t.`town_id`, a.`address_id`;

-- 3. Employees Without Managers

SELECT e.`employee_id`, e.`first_name`, e.`last_name`, e.`department_id`, e.`salary` FROM `employees` AS e
RIGHT JOIN `departments` AS d ON e.`department_id` = d.`department_id`
WHERE e.`manager_id` IS NULL
ORDER BY `employee_id`;

-- 4. Higher Salary
SELECT COUNT(*) FROM `employees` AS e
WHERE e.salary > (
SELECT AVG(e1.`salary`) FROM `employees` AS e1);