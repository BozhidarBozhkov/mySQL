-- 01. Table Design

CREATE TABLE `genres` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE `countries` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL UNIQUE,
`continent` VARCHAR(30) NOT NULL,
`currency` VARCHAR(5) NOT NULL
);

CREATE TABLE `actors` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(50) NOT NULL,
`last_name` VARCHAR(50) NOT NULL,
`birthdate` DATE NOT NULL,
`height` INT,
`awards` INT,
`country_id` INT NOT NULL,
CONSTRAINT fk_actors_countires
FOREIGN KEY(`country_id`) REFERENCES `countries`(`id`)
);

CREATE TABLE `movies_additional_info` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`rating` DECIMAL(10, 2) NOT NULL,
`runtime` INT NOT NULL,
`picture_url` VARCHAR(80) NOT NULL,
`budget` DECIMAL(10, 2),
`release_date` DATE NOT NULL,
`has_subtitles` TINYINT(1),
`description` TEXT
);

CREATE TABLE `movies` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`title` VARCHAR(70) NOT NULL UNIQUE,
`country_id` INT NOT NULL,
`movie_info_id` INT NOT NULL UNIQUE,
CONSTRAINT fk_movies_countires
FOREIGN KEY(`country_id`) REFERENCES `countries`(`id`),
CONSTRAINT fk_movies_movie_additional_info
FOREIGN KEY(`movie_info_id`) REFERENCES `movies_additional_info`(`id`)
);

CREATE TABLE `movies_actors` (
`movie_id` INT, 
`actor_id` INT,
CONSTRAINT fk_movies_actors_movies
FOREIGN KEY(`movie_id`) REFERENCES `movies`(`id`),
CONSTRAINT fk_movies_actors_actors
FOREIGN KEY(`actor_id`) REFERENCES `actors`(`id`)
);

CREATE TABLE `genres_movies` (
`genre_id` INT, 
`movie_id` INT,
CONSTRAINT fk_genres_movies_genres
FOREIGN KEY(`genre_id`) REFERENCES `genres`(`id`),
CONSTRAINT fk_genres_movies_movies
FOREIGN KEY(`movie_id`) REFERENCES `movies`(`id`)
);

-- 02. Insert

INSERT INTO `actors` (`first_name`, `last_name`, `birthdate`, `height`, `awards`, `country_id`)
SELECT 
REVERSE(`first_name`),
REVERSE(`last_name`),
DATE_SUB(`birthdate`, INTERVAL 2 DAY),
`height` + 10,
`country_id`,
(SELECT `id` FROM `countries` WHERE `name` LIKE 'Armenia')
FROM `actors`
WHERE `id` <= 10;

-- 03. Update
UPDATE `movies_additional_info`
SET `runtime` = `runtime` - 10
WHERE `id` BETWEEN 15 AND 25;

-- 04. Delete
DELETE c FROM countries AS c
LEFT JOIN movies as m ON c.id = m.country_id
WHERE `movie_info_id` IS NULL;

-- 05. Countries
SELECT * FROM `countries`
ORDER BY `currency` DESC, `id`;

-- 06. Old movies
SELECT m.`id`, m.`title`, ma.`runtime`, ma.`budget`, ma.`release_date` FROM `movies_additional_info` AS ma
JOIN `movies` AS m ON m.`movie_info_id` = ma.`id`
WHERE YEAR(ma.`release_date`) BETWEEN 1996 AND 1999
ORDER BY ma.`runtime`, ma.`id`
LIMIT 20;

-- 07. Movie casting
SELECT CONCAT_WS(' ', a.`first_name`, a.`last_name`) AS 'full_name', 
CONCAT(REVERSE(a.`last_name`), CHAR_LENGTH(a.`last_name`), '@cast.com') AS 'email',
2022 - YEAR(a.`birthdate`) AS 'age',
a.`height`
FROM `actors` AS a
LEFT JOIN `movies_actors` as m ON a.`id` = m.`actor_id`
WHERE m.`movie_id` IS NULL
GROUP BY a.`id`
ORDER BY a.`height`;

-- 08. International festival
SELECT c.`name`, COUNT(m.`id`) AS 'movies_count' FROM `countries` AS c
LEFT JOIN `movies` AS m ON c.`id` = m.`country_id`
GROUP BY `name`
HAVING COUNT(m.`country_id`) >= 7
ORDER BY c.`name` DESC;

-- 09. Rating system
SELECT m.`title`,
CASE 
WHEN i.`rating` <= 4 THEN 'poor'
WHEN i.`rating` <= 7 THEN 'good'
ELSE 'excellent' END AS 'rating',
IF(i.`has_subtitles`, 'english', '-') AS 'subtitles',
i.`budget`
FROM `movies` as m
LEFT JOIN `movies_additional_info` AS i ON i.`id` = m.`movie_info_id`
ORDER BY `budget` DESC;

-- 10. History movies
DELIMITER $$
CREATE FUNCTION udf_actor_history_movies_count(full_name VARCHAR(50))
RETURNS INT 
DETERMINISTIC
BEGIN
DECLARE history_movies INT;
	SET history_movies := (SELECT COUNT(ma.movie_id) FROM actors AS a
JOIN movies_actors AS ma ON ma.actor_id = a.id
JOIN genres_movies AS gm ON gm.movie_id = ma.movie_id
JOIN genres AS g ON g.id = gm.genre_id
WHERE CONCAT_WS(' ', a.first_name, a.last_name) = full_name AND g.id = 12
GROUP BY ma.actor_id);
RETURN history_movies;
END$$

-- 11. Movie awards
CREATE PROCEDURE udp_award_movie(movie_title VARCHAR(50))
BEGIN
UPDATE actors AS a
JOIN movies_actors AS ma ON ma.actor_id = a.id
JOIN movies AS m ON m.id = ma.movie_id
SET awards = awards + 1
WHERE m.title = movie_title;
END$$

DELIMITER ;