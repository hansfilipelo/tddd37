
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

insert into jbitem_copy select * from jbitem where price < (select AVG(price) from jbitem);

/* 15 */
\! echo ""
\! echo "15."
create view jbitem_view as select * from jbitem where price < (select AVG(price) from jbitem);

/* 16 */
\! echo ""
\! echo "16."
\! echo "A table is static and a view is dynamic. Static means that we copy content from the original table"
\! echo "The more dynamic view updates when the table that the data originates from updates - it's simply pointer to data in that table."


/* 17 */
\! echo ""
\! echo "17."
create view jbdebit_cost_implicit as select jbdebit.id,SUM(jbitem.price*jbsale.quantity) from jbdebit,jbitem,jbsale where jbsale.debit = jbdebit.id and jbsale.item = jbitem.id group by jbdebit.id;


/* 18 */
\! echo ""
\! echo "18."
create view jbdebit_cost_explicit as select jbdebit.id,SUM(jbitem.price*jbsale.quantity) from jbdebit inner join jbitem inner join jbsale on jbsale.debit = jbdebit.id and jbsale.item = jbitem.id group by jbdebit.id;

\! echo "We use the inner join since it will only give us matching values from all three tables,and nothing elese. For an example, we do not want items which has never been sold."


/* 19 */
\! echo ""
\! echo "19."

delete from jbsale where item in (select id from jbitem where supplier = (select id from jbsupplier where city = (select id from jbcity where name='Los Angeles')));
delete from jbitem where supplier = (select id from jbsupplier where city = (select id from jbcity where name='Los Angeles'));
delete from jbitem_copy where supplier = (select id from jbsupplier where city = (select id from jbcity where name='Los Angeles'));
delete from jbsupplier where city = (select id from jbcity where name='Los Angeles');

\! echo "b) The one supplier based in LA has foreign_keys which refered to items in jbitem, which in turn has foreign keys refering to sales in jbsales. Whe removed the corresponding items from jbsale and jbitem and then we removed the supplier. We also removed a copy of jbitem created earlier in this assignement."


/* 20 */
\! echo ""
\! echo "20."

CREATE VIEW jbsale_supply(supplier,item,quantity) AS SELECT jbsupplier.name,jbitem.name,jbsale.quantity FROM jbsupplier INNER JOIN jbitem LEFT JOIN jbsale ON jbsupplier.id=jbitem.supplier and jbsale.item=jbitem.id;
SELECT supplier,sum(quantity) AS sum FROM jbsale_supply GROUP BY supplier;
