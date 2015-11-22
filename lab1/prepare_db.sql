
/* Initiate script with "clean" DB */
/* Delete views */
SET FOREIGN_KEY_CHECKS = 0;
SET GROUP_CONCAT_MAX_LEN=32768;
SET @views = NULL;
SELECT GROUP_CONCAT('`', TABLE_NAME, '`') INTO @views
  FROM information_schema.views
  WHERE table_schema = (SELECT DATABASE());
SELECT IFNULL(@views,'dummy') INTO @views;

SET @views = CONCAT('DROP VIEW IF EXISTS ', @views);
PREPARE stmt FROM @views;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

/* Delete tables */
SET @tables = NULL;
SELECT GROUP_CONCAT(table_schema, '.', table_name) INTO @tables
  FROM information_schema.tables 
  WHERE table_schema = 'tddd37'; -- specify DB name here.

SET @tables = CONCAT('DROP TABLE ', @tables);
PREPARE stmt FROM @tables;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET FOREIGN_KEY_CHECKS = 1;

/* Set up DB-env */
source ../company_schema.sql
source ../company_data.sql

