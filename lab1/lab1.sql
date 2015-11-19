
/* 1*/
select 'LAB 1' AS '';
select '1.' AS '';
select name from jbemployee;

/*  2. */
select '2.' AS '';
select name from jbdept order by name;

/* 3. */
select '3.' AS '';
select name,qoh from jbparts where qoh=0;

/* 4. */
/* http://dev.mysql.com/doc/refman/5.5/en/comparison-operators.html#operator_between */
select '4.' AS '';
select name,salary from jbemployee where salary BETWEEN 9000 AND 10000;


/* 5 */
select '5.' AS '';
select name,startyear-birthyear from jbemployee;

/* 6. */
select '6.' AS '';
select name from jbemployee where name like '%son,%';

/* 7 */
select '7.' AS '';
select name from jbitem where supplier = (select id from jbsupplier where name='Fisher-Price');

/* 8 */
select '8.' AS '';
select jbitem.name from jbitem,jbsupplier where jbsupplier.name='Fisher-Price' AND jbitem.supplier=jbsupplier.id;

/* 9 */
select '9.' AS '';
select name from jbcity where id IN (select city from jbsupplier);

/* 10 */
select '10.' AS '';
select name,color from jbparts where weight > (select weight from jbparts where name='card reader');

/* 11 */
select '11.' AS '';
select A.name,A.color from jbparts as A,jbparts as B where A.weight > B.weight AND B.name='card reader';

/* 12 */
select '12.' AS '';
select AVG(weight) from jbparts where color='black';

/* 13 */
select '13.' AS '';
select jbsupplier.name,sum(jbsupply.quan*jbparts.weight) from jbsupply,jbparts,jbsupplier where jbsupply.supplier=jbsupplier.id AND jbsupplier.city in (select id from jbcity where state='Mass') group by jbsupply.supplier;

/* 14 */
select '14.' AS '';
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
select '15.' AS '';
create view jbitem_view as select * from jbitem where price < (select AVG(price) from jbitem);

/* 16 */
select '16.' AS '';
select 'A table is static and a view is dynamic. Static means that we copy content from the original table' AS '';
select 'The more dynamic view updates when the table that the data originates from updates - it is simply a pointer to data in that table.' AS '';


/* 17 */
select '17.' AS '';
create view jbdebit_cost_implicit as select jbdebit.id,SUM(jbitem.price*jbsale.quantity) from jbdebit,jbitem,jbsale where jbsale.debit = jbdebit.id and jbsale.item = jbitem.id group by jbdebit.id;


/* 18 */
select '18.' AS '';
create view jbdebit_cost_explicit as select jbdebit.id,SUM(jbitem.price*jbsale.quantity) from jbdebit inner join jbitem inner join jbsale on jbsale.debit = jbdebit.id and jbsale.item = jbitem.id group by jbdebit.id;

\! echo "We use the inner join since it will only give us matching values from all three tables,and nothing elese. For an example, we do not want items which has never been sold."


/* 19 */
select '19.' AS '';
delete from jbsale where item in (select id from jbitem where supplier = (select id from jbsupplier where city = (select id from jbcity where name='Los Angeles')));
delete from jbitem where supplier = (select id from jbsupplier where city = (select id from jbcity where name='Los Angeles'));
delete from jbitem_copy where supplier = (select id from jbsupplier where city = (select id from jbcity where name='Los Angeles'));
delete from jbsupplier where city = (select id from jbcity where name='Los Angeles');

select 'b) The one supplier based in LA has foreign_keys which refered to items in jbitem, which in turn has foreign keys refering to sales in jbsales. Whe removed the corresponding items from jbsale and jbitem and then we removed the supplier. We also removed a copy of jbitem created earlier in this assignement.' AS '';


/* 20 */
select '20.' AS '';
CREATE VIEW jbsale_supply(supplier,item,quantity) AS SELECT jbsupplier.name,jbitem.name,jbsale.quantity FROM jbsupplier INNER JOIN jbitem LEFT JOIN jbsale ON jbsupplier.id=jbitem.supplier and jbsale.item=jbitem.id;
SELECT supplier,sum(quantity) AS sum FROM jbsale_supply GROUP BY supplier;

/* LAB 2 */
/* -------------------------------- */
select 'LAB2' AS '';


/* 3 */
select '3.' AS '';
/* Create table and insert managers*/
CREATE TABLE jbmanager ( id int(11) NOT NULL DEFAULT 0, bonus int(11) NOT NULL DEFAULT 0, UNIQUE KEY fk_manager_id (id), CONSTRAINT fk_manager_id FOREIGN KEY (id) REFERENCES jbemployee (id) ON DELETE CASCADE);
INSERT INTO jbmanager(id) SELECT manager FROM jbemployee WHERE NOT manager='NULL' group by manager;

/* Alter jbemployee to use new table */
ALTER TABLE jbemployee DROP FOREIGN KEY fk_emp_mgr;
ALTER TABLE jbemployee ADD CONSTRAINT fk_emp_mgr FOREIGN KEY (manager) REFERENCES jbmanager(id);
/* Same with jbdept */
ALTER TABLE jbdept DROP FOREIGN KEY fk_dept_mgr;
INSERT INTO jbmanager(id) SELECT manager FROM jbdept WHERE manager NOT IN (select id from jbmanager) group by manager;
ALTER TABLE jbdept ADD CONSTRAINT fk_dept_mgr FOREIGN KEY (manager) REFERENCES jbmanager(id);

/* 4 */
select '4.' AS '';
UPDATE jbmanager SET bonus=bonus+10000 WHERE id IN (SELECT manager FROM jbdept);


/* 5 */
select '5.' AS '';

select 'Decouple jbsale from jbdebit so we can alter it' AS '';
alter table jbsale drop foreign key fk_sale_debit;
select 'Primary id will be in main table for class, jbtransaction - remove' AS '';
ALTER TABLE jbdebit DROP PRIMARY KEY;
select 'Will be in transaction' AS '';
ALTER TABLE jbdebit DROP FOREIGN KEY fk_debit_employee;

select 'Create jbcustomer' AS '';
CREATE TABLE jbcustomer ( pnr varchar(20) NOT NULL, name varchar(20) NOT NULL, streetaddress varchar(20), city int(11) NOT NULL DEFAULT 0, PRIMARY KEY (pnr), KEY fk_customer_city (city), CONSTRAINT fk_customer_city FOREIGN KEY (city) REFERENCES jbcity(id));

select 'Create jbaccount' AS '';
CREATE TABLE jbaccount ( id int(11) NOT NULL DEFAULT 0,  customer varchar(20) NOT NULL, PRIMARY KEY (id), KEY fk_account_customer (customer), CONSTRAINT fk_account_customer FOREIGN KEY (customer) REFERENCES jbcustomer(pnr));

select 'Create transaction' AS '';
CREATE TABLE jbtransaction ( id int(11) NOT NULL DEFAULT 0, sdate timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, employee int(11) NOT NULL, account int(11) NOT NULL, PRIMARY KEY (id), KEY fk_transaction_employee (employee), KEY fk_transaction_account (account), CONSTRAINT fk_transaction_employee FOREIGN KEY (employee) REFERENCES jbemployee(id), CONSTRAINT fk_transaction_account FOREIGN KEY (account) REFERENCES jbaccount(id));

select 'Need data to fill up our responsibilities for FK' AS '';
INSERT INTO jbcustomer(pnr,name,streetaddress,city) VALUES ('990909-1337','Li Sam','Azure road 1',537);
INSERT INTO jbaccount(id,customer) SELECT DISTINCT jbdebit.account,jbcustomer.pnr FROM jbdebit,jbcustomer;
INSERT INTO jbtransaction(id,sdate,employee,account) SELECT * FROM jbdebit;

select 'Alter jbdebit to fit new structure' AS '';
ALTER TABLE jbdebit DROP COLUMN sdate;
ALTER TABLE jbdebit DROP COLUMN employee;
ALTER TABLE jbdebit DROP COLUMN account;
ALTER TABLE jbdebit ADD CONSTRAINT fk_debit_transaction FOREIGN KEY (id) REFERENCES jbtransaction(id);

select 'Create last subclasses to transaction' AS '';
CREATE TABLE jbdeposit ( id int(11) NOT NULL DEFAULT 0, ammount int(11) NOT NULL DEFAULT 0, KEY fk_deposit_transaction (id), CONSTRAINT fk_deposit_transaction FOREIGN KEY (id) REFERENCES jbtransaction(id));
CREATE TABLE jbwithdrawal ( id int(11) NOT NULL DEFAULT 0, ammount int(11) NOT NULL DEFAULT 0, KEY fk_withdrawal_transaction (id), CONSTRAINT fk_withdrawal_transaction FOREIGN KEY (id) REFERENCES jbtransaction(id));


