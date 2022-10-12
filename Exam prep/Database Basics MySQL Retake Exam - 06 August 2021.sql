-- 1. Table Design
CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(10) NOT NULL
);

CREATE TABLE `addresses` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL
);

CREATE TABLE `offices` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`workspace_capacity` INT NOT NULL,
`website` VARCHAR(50),
`address_id` INT NOT NULL,
CONSTRAINT fk_offices_addresses
FOREIGN KEY(`address_id`) REFERENCES `addresses`(`id`)
);

CREATE TABLE `employees` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(30) NOT NULL,
`last_name` VARCHAR(30) NOT NULL,
`age` INT NOT NULL,
`salary` DECIMAL(10,2) NOT NULL,
`job_title` VARCHAR(20) NOT NULL,
`happiness_level` CHAR(1)
);

CREATE TABLE `teams` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL,
`office_id` INT NOT NULL,
`leader_id` INT NOT NULL UNIQUE,
CONSTRAINT fk_teams_offices
FOREIGN KEY(`office_id`) REFERENCES `offices`(`id`),
CONSTRAINT fk_teams_employees
FOREIGN KEY(`leader_id`) REFERENCES `employees`(`id`)
);

CREATE TABLE `games` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL UNIQUE,
`description` TEXT,
`rating` FLOAT NOT NULL DEFAULT(5.5),
`budget` DECIMAL(10,2) NOT NULL,
`release_date` DATE,
`team_id` INT NOT NULL,
CONSTRAINT fk_games_teams
FOREIGN KEY(`team_id`) REFERENCES `teams`(`id`)
);

CREATE TABLE `games_categories` (
`game_id` INT NOT NULL,
`category_id` INT NOT NULL,
CONSTRAINT pk_games_categories
PRIMARY KEY(`game_id`, `category_id`),
CONSTRAINT fk_games_categories_games
FOREIGN KEY(game_id) REFERENCES `games`(`id`),
CONSTRAINT fk_games_categories_categories
FOREIGN KEY(category_id) REFERENCES `categories`(`id`)
);

-- 2. Insert
INSERT INTO `games`(`name`, `rating`, `budget`, `team_id`)
SELECT
LOWER(REVERSE(SUBSTRING(`name` FROM 2))),
`id`,
`leader_id` * 1000,
`id`
FROM `teams` AS t
WHERE t.`id` BETWEEN 1 AND 9;

-- 3. Update
UPDATE `employees` AS e
JOIN `teams` AS t ON t.`leader_id` = e.`id` 
SET e.`salary` = e.`salary` + 1000
WHERE e.`age` < 40 AND e.`salary` <= 5000;

-- 4. Delete
DELETE g FROM `games` AS g
LEFT JOIN `games_categories` AS gc ON gc.`game_id` = g.`id`
WHERE `release_date` IS NULL AND gc.`game_id` IS NULL;

-- 5. Employees
SELECT `first_name`, `last_name`, `age`, `salary`, `happiness_level` FROM `employees`
ORDER BY `salary`, `id`;

-- 6. Addresses of the teams
SELECT t.`name` AS 'team_name', a.`name` AS 'address_name', CHAR_LENGTH(a.`name`) AS 'count_of_characters' FROM `teams` AS t
JOIN `offices` AS o ON o.`id` = t.`office_id`
JOIN `addresses` AS a ON a.`id` = o.`address_id`
WHERE o.`website` IS NOT NULL
ORDER BY t.`name`, a.`name`;

-- 7. Categories Info
SELECT c.`name`, COUNT(gc.`game_id`) AS 'games_count', ROUND(AVG(g.`budget`), 2) AS 'avg_budget', MAX(g.`rating`) AS 'max_rating' 
FROM `categories` AS c
JOIN `games_categories` AS gc ON gc.`category_id` = c.`id`
JOIN `games` AS g ON g.`id` = gc.`game_id`
GROUP BY c.`name`
HAVING `max_rating` >= 9.5
ORDER BY `games_count` DESC, c.`name`;

-- 8. Games of 2022
SELECT g.`name`, g.`release_date`, CONCAT(substring(g.`description`, 1, 10), '...') AS 'summary', 
CASE 
WHEN MONTHNAME(g.`release_date`) = 'January' THEN 'Q1'
WHEN MONTHNAME(g.`release_date`) = 'February' THEN 'Q1'
WHEN MONTHNAME(g.`release_date`) = 'March' THEN 'Q1'
WHEN MONTHNAME(g.`release_date`) = 'April' THEN 'Q2'
WHEN MONTHNAME(g.`release_date`) = 'May' THEN 'Q2'
WHEN MONTHNAME(g.`release_date`) = 'June' THEN 'Q2'
WHEN MONTHNAME(g.`release_date`) = 'July' THEN 'Q3'
WHEN MONTHNAME(g.`release_date`) = 'August' THEN 'Q3'
WHEN MONTHNAME(g.`release_date`) = 'September' THEN 'Q3'
WHEN MONTHNAME(g.`release_date`) = 'October' THEN 'Q4'
WHEN MONTHNAME(g.`release_date`) = 'November' THEN 'Q4'
WHEN MONTHNAME(g.`release_date`) = 'December' THEN 'Q4'
END AS 'quarter',
t.`name` 
FROM `games` AS g
JOIN `teams` AS t ON t.`id` = g.`team_id`
WHERE YEAR(g.`release_date`) = '2022' AND g.`name` LIKE '%2' AND MONTH(g.`release_date`) IN ('02', '04', '06', '08', '10', '12')
ORDER BY `quarter`;

-- 9. Full info for games
SELECT g.`name`,
 CASE WHEN g.`budget` < 50000 THEN 'Normal budget'
 ELSE 'Insufficient budget' 
 END AS 'budget_level', 
 t.`name` AS 'team_name', 
 a.`name` AS 'address_name'
 FROM `games` AS g
LEFT JOIN `games_categories` AS gc ON gc.`game_id` = g.`id`
JOIN `teams` AS t ON t.`id` = g.`team_id`
JOIN `offices` AS o ON o.`id` = t.`office_id`
JOIN `addresses` AS a ON a.`id` = o.`address_id`
WHERE g.`release_date` IS NULL AND gc.`category_id` IS NULL
ORDER BY g.`name`;

-- 10. Find all basic information for a game
DELIMITER $$
CREATE FUNCTION udf_game_info_by_name (game_name VARCHAR (20))
RETURNS VARCHAR(750)
DETERMINISTIC
BEGIN
DECLARE game_info VARCHAR(750);
DECLARE team_name VARCHAR(40);
DECLARE address_text VARCHAR(50);
SET team_name := (SELECT t.`name` FROM `teams` AS t 
JOIN `games` AS g ON g.`team_id` = t.`id`
WHERE g.`name` = game_name);
SET address_text := (SELECT a.`name` FROM `addresses` AS a
JOIN `offices` AS o ON o.`address_id` = a.`id`
JOIN `teams` AS t ON t.`office_id` = o.`id`
WHERE t.`name` = team_name);
SET game_info := CONCAT('The ', game_name, ' is developed by a ', team_name, ' in an office with an address ', address_text);
RETURN game_info;
END$$

-- 11. Update budget of the games
CREATE PROCEDURE udp_update_budget(min_game_rating FLOAT)
BEGIN
	UPDATE `games` AS g
LEFT JOIN `games_categories` AS gc ON gc.`game_id` = g.`id`
SET g.`budget` = g.`budget` + 100000, g.`release_date` = ADDDATE(g.`release_date`, INTERVAL 1 YEAR)
WHERE gc.`category_id` IS NULL AND g.`rating` > 5 AND g.`release_date` IS NOT NULL;
END$$
DELIMITER ;
