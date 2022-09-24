-- 12. Employees Minimum Salaries
SELECT `department_id`, MIN(`salary`) AS 'minimum_salary' FROM `employees`
WHERE `department_id` IN(2, 5, 7) AND `hire_date` > '2000-01-01'
GROUP BY `department_id`
ORDER BY `department_id`;

-- 13. Employees Average Salaries
CREATE TABLE `high_paid_employees`
SELECT * FROM `employees`
WHERE `salary` > 30000;

DELETE FROM `high_paid_employees`
WHERE `manager_id` = 42;

UPDATE `high_paid_employees`
SET `salary` = `salary` + 5000
WHERE `department_id` = 1;

SELECT `department_id`, AVG(`salary`) AS 'avg_salary' FROM `high_paid_employees`
GROUP BY `department_id`
ORDER BY `department_id`;

-- 14. Employees Maximum Salaries
SELECT `department_id`, MAX(`salary`) AS `max_salary` FROM `employees`
GROUP BY `department_id`
HAVING `max_salary` NOT BETWEEN 30000 AND 70000
ORDER BY `department_id`;

-- 15. Employees Count Salaries
SELECT COUNT(`salary`) FROM `employees`
WHERE `manager_id` IS NULL;