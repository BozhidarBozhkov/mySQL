/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- USE soft_uni;

-- Dumping structure for table bank.accounts
DROP TABLE IF EXISTS `accounts`;
CREATE TABLE IF NOT EXISTS `accounts` (
  `id` int(11) NOT NULL,
  `account_holder_id` int(11) NOT NULL,
  `balance` decimal(19,4) DEFAULT '0.0000',
  PRIMARY KEY (`id`),
  KEY `fk_accounts_account_holders` (`account_holder_id`),
  CONSTRAINT `fk_accounts_account_holders` FOREIGN KEY (`account_holder_id`) REFERENCES `account_holders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table bank.accounts: ~18 rows (approximately)
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` (`id`, `account_holder_id`, `balance`) VALUES
	(1, 1, 123.1200),
	(2, 3, 4354.2300),
	(3, 12, 6546543.2300),
	(4, 9, 15345.6400),
	(5, 11, 36521.2000),
	(6, 8, 5436.3400),
	(7, 10, 565649.2000),
	(8, 11, 999453.5000),
	(9, 1, 5349758.2300),
	(10, 2, 543.3000),
	(11, 3, 10.2000),
	(12, 7, 245656.2300),
	(13, 5, 5435.3200),
	(14, 4, 1.2300),
	(15, 6, 0.1900),
	(16, 2, 5345.3400),
	(17, 11, 76653.2000),
	(18, 1, 235469.8900);
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;


-- Dumping structure for table bank.account_holders
DROP TABLE IF EXISTS `account_holders`;
CREATE TABLE IF NOT EXISTS `account_holders` (
  `id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `ssn` char(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table bank.account_holders: ~12 rows (approximately)
/*!40000 ALTER TABLE `account_holders` DISABLE KEYS */;
INSERT INTO `account_holders` (`id`, `first_name`, `last_name`, `ssn`) VALUES
	(1, 'Susan', 'Cane', '1234567890'),
	(2, 'Kim', 'Novac', '1234567890'),
	(3, 'Jimmy', 'Henderson', '1234567890'),
	(4, 'Steve', 'Stevenson', '1234567890'),
	(5, 'Bjorn', 'Sweden', '1234567890'),
	(6, 'Kiril', 'Petrov', '1234567890'),
	(7, 'Petar', 'Kirilov', '1234567890'),
	(8, 'Michka', 'Tsekova', '1234567890'),
	(9, 'Zlatina', 'Pateva', '1234567890'),
	(10, 'Monika', 'Miteva', '1234567890'),
	(11, 'Zlatko', 'Zlatyov', '1234567890'),
	(12, 'Petko', 'Petkov Junior', '1234567890');
/*!40000 ALTER TABLE `account_holders` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;

-- 8. Find Full Name
DELIMITER $$
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
	SELECT CONCAT_WS(' ', `first_name`, `last_name`) AS 'full_name' FROM `account_holders`
	ORDER BY `first_name`, `id`;
END$$

CALL usp_get_holders_full_name()$$

-- 9. People with Balance Higher Than
CREATE PROCEDURE usp_get_holders_with_balance_higher_than(num INT)
BEGIN
	SELECT `first_name`, `last_name` FROM `account_holders` AS a1
	JOIN `accounts` AS a2 ON a2.`account_holder_id` = a1.`id`
	GROUP BY `account_holder_id`
	HAVING SUM(`balance`) > num
	ORDER BY `account_holder_id`;
END$$

CALL usp_get_holders_with_balance_higher_than(7000)$$

-- 10. Future Value Function
CREATE FUNCTION ufn_calculate_future_value(initial_sum DECIMAL(19,4), yearly_interest_rate DOUBLE, years INT)
RETURNS DECIMAL(19,4)
DETERMINISTIC
BEGIN
	DECLARE future_value DECIMAL(19,4);
    SET future_value := initial_sum * POW((1 + yearly_interest_rate), years);
    RETURN future_value;
END$$

-- 11. Calculating Interest
CREATE PROCEDURE usp_calculate_future_value_for_account(account_id INT, interest_rate DECIMAL(19,4))
BEGIN
	SELECT a.`id` AS 'account_id', ah.`first_name`, ah.`last_name`, a.`balance` AS 'current_balance', 
    ufn_calculate_future_value(a.`balance`, interest_rate, 5) AS 'balance_in_5_years' 
    FROM `accounts` AS a
    JOIN `account_holders` AS ah ON ah.`id` = a.`account_holder_id`
    WHERE a.`id` = account_id;
END$$

-- 12. Deposit Money
CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(19,4))
BEGIN
	START TRANSACTION;
    IF(money_amount <= 0) THEN ROLLBACK;
    ELSE UPDATE `accounts` SET `balance` = `balance` + money_amount
    WHERE `id` = account_id;
    COMMIT;
    END IF;
END$$


-- 13. Withdraw Money
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19,4))
BEGIN
	START TRANSACTION;
    IF(money_amount <= 0 OR (SELECT `balance` FROM `accounts` WHERE `id` = account_id) < money_amount) THEN ROLLBACK;
    ELSE UPDATE `accounts` SET `balance` = `balance` - money_amount
    WHERE `id` = account_id;
    COMMIT;
    END IF;
END$$ 

-- 14. Money Transfer
DELIMITER $$
CREATE PROCEDURE usp_transfer_money(from_account_id INT, to_account_id INT, amount DECIMAL(19, 4))
BEGIN
	START TRANSACTION;
    IF amount < 0 OR (SELECT `balance` FROM `accounts` WHERE `id` = from_account_id) < amount
    OR (SELECT COUNT(`id`) FROM `accounts` WHERE `id` = from_account_id) <> 1 
    OR (SELECT COUNT(`id`) FROM `accounts` WHERE `id` = to_account_id) <> 1
    OR from_account_id = to_account_id THEN ROLLBACK;
    ELSE UPDATE `accounts` SET `balance` = `balance` - amount
    WHERE `id` = from_account_id;
    UPDATE `accounts` SET `balance` = `balance` + amount
    WHERE `id` = to_account_id;
      COMMIT;
      END IF;
END$$
DELIMITER ;

-- 15. Log Accounts Trigger

CREATE TABLE `logs` (
log_id INT PRIMARY KEY AUTO_INCREMENT,
account_id INT NOT NULL,
old_sum DECIMAL(19,4) NOT NULL,
new_sum DECIMAL(19,4) NOT NULL
);

DELIMITER $$
CREATE TRIGGER tr_account_balance_change
AFTER UPDATE
ON `accounts`
FOR EACH ROW
BEGIN
	INSERT INTO `logs` (account_id, old_sum, new_sum)
    VALUES(OLD.id, OLD.balance, NEW.balance);
END$$

-- 16. Emails Trigger
CREATE TABLE `notification_emails` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`recipient` INT NOT NULL,
`subject` VARCHAR(100),
`body` TEXT
);

DELIMITER $$
CREATE TRIGGER tr_new_record_inserted
AFTER INSERT ON `logs`
FOR EACH ROW
BEGIN
    INSERT INTO `notification_emails` (`recipient`, `subject`, `body`)
    VALUES (
        NEW.account_id, 
        CONCAT('Balance change for account: ', NEW.account_id), 
        CONCAT('On ', DATE_FORMAT(NOW(), '%b %d %Y at %r'), ' your balance was changed from ', ROUND(NEW.old_sum, 2), ' to ', ROUND(NEW.new_sum, 2), '.'));
END$$

DELIMITER ;