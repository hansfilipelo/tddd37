
/* 1*/

\! echo "1"
select name from jbemployee;

/*  2. */
\! echo "2"
select name from jbdept order by name;

/* 3. */
\! echo "3"
select name,qoh from jbparts where qoh=0;

/* 4. */
/* http://dev.mysql.com/doc/refman/5.5/en/comparison-operators.html#operator_between */
\! echo "4."
select name,salary from jbemployee where salary BETWEEN 9000 AND 10000;


\! echo "5"
/* 5 */
select name,startyear-birthyear from jbemployee;

/* 6. */
\! echo "6. "
select name from jbemployee where name like '%son,%';

/* 7 */
\! echo "7. "
select name from jbitem where supplier = (select id from jbsupplier where name='Fisher-Price');

/* 8 */
\! echo "8. "
select name from jbitem where supplier=89;

/* 9 */
\! echo "9. "
select name from jbcity where id IN (select city from jbsupplier);

/* 10 */
\! echo "10."
select name,color from jbparts where weight > (select weight from jbparts where name='card reader');

/* 11 */



