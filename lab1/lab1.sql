
/* Initiate script with "clean" DB */
SET FOREIGN_KEY_CHECKS = 0; 
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

/* 1*/
\! echo ""
\! echo "1"
select name from jbemployee;

/*  2. */
\! echo ""
\! echo "2"
select name from jbdept order by name;

/* 3. */
\! echo ""
\! echo "3"
select name,qoh from jbparts where qoh=0;

/* 4. */
/* http://dev.mysql.com/doc/refman/5.5/en/comparison-operators.html#operator_between */
\! echo ""
\! echo "4."
select name,salary from jbemployee where salary BETWEEN 9000 AND 10000;


\! echo ""
\! echo "5"
/* 5 */
select name,startyear-birthyear from jbemployee;

/* 6. */
\! echo ""
\! echo "6. "
select name from jbemployee where name like '%son,%';

/* 7 */
\! echo ""
\! echo "7. "
select name from jbitem where supplier = (select id from jbsupplier where name='Fisher-Price');

/* 8 */
\! echo ""
\! echo "8. "
select jbitem.name from jbitem,jbsupplier where jbsupplier.name='Fisher-Price' AND jbitem.supplier=jbsupplier.id;

/* 9 */
\! echo ""
\! echo "9. "
select name from jbcity where id IN (select city from jbsupplier);

/* 10 */
\! echo ""
\! echo "10."
select name,color from jbparts where weight > (select weight from jbparts where name='card reader');

/* 11 */
\! echo ""
\! echo "11."
select A.name,A.color from jbparts as A,jbparts as B where A.weight > B.weight AND B.name='card reader';

/* 12 */
\! echo ""
\! echo "12."
select AVG(weight) from jbparts where color='black';

/* 13 */
\! echo ""
\! echo "13."
select jbsupplier.name,sum(jbsupply.quan*jbparts.weight) from jbsupply,jbparts,jbsupplier where jbsupply.supplier=jbsupplier.id AND jbsupplier.city in (select id from jbcity where state='Mass') group by jbsupply.supplier;

/* 14 */
\! echo ""
\! echo "14."
create table jbitem_copy (id int NOT NULL DEFAULT 0,
 name varchar(20),
 dept int NOT NULL,
 price int,
 qoh int unsigned,
 supplier int NOT NULL,
 PRIMARY KEY (id),
 KEY fk_item_copy_dept (dept),
 KEY fk_item_copy_supplier (supplier),
 CONSTRAINT fk_item_copy_dept FOREIGN KEY(dept) REFERENCES jbdept(id),
 CONSTRAINT fk_item_copy_supplier FOREIGN KEY(supplier) REFERENCES jbsupplier(id));


/* 15 */
\! echo ""
\! echo "15."


