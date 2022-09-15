CREATE DATABASE `exercise`;

USE `exercise`;

CREATE TABLE `people` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(200) NOT NULL,
`picture` BLOB,
`height` DOUBLE(10, 2),
`weight` DOUBLE (10, 2),
`gender` CHAR(1) NOT NULL,
`birthdate` DATE NOT NULL,
`biography` TEXT
);

INSERT INTO `people` (`name`, `gender`, `birthdate`)
VALUES ("Boris", 'm', DATE(NOW())),
("Alex", 'm', DATE(NOW())),
("Michaela", 'f', DATE(NOW())),
("Borislava", 'f', DATE(NOW())),
("Peter", 'm', DATE(NOW()));

CREATE TABLE `users` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`username` VARCHAR(30) NOT NULL,
`password` VARCHAR(26) NOT NULL,
`profile_picture` BLOB,
`last_login_time` TIME,
`is_deleted` BOOLEAN
);

INSERT INTO `users` (`username`, `password`)
VALUES ("admin", "1234"),
("test", "abc1"),
("ivan", "567"),
("bozhidar", "121212"),
("petya", "adc12");

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD PRIMARY KEY pk_users (`id`, `username`);

ALTER TABLE `users`
/*ALTER COLUMN -- set or remove dafult value
CHANGE COLUMN -- change type, rename, move, resize
MODIFY COLUMN -- like change, but no rename */
MODIFY COLUMN `last_login_time` DATETIME DEFAULT NOW();

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT pk_users
PRIMARY KEY `users` (`id`),
MODIFY COLUMN `username` VARCHAR(30) UNIQUE;