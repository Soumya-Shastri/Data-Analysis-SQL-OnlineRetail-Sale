CREATE TABLE CAR_RENTAL
(ID INT PRIMARY KEY,
NAME VARCHAR(30),
ORDER_DATE DATE ,
PRICE DECIMAL(10,2));

INSERT INTO CAR_RENTAL
VALUES
('12', 'ABC', '2025-05-29', 12.5),
('10', 'ADD', '2025-01-31', 10.23);

insert into car_rental
values('11', 'zzz', '2025-10-22', NULL),
('23', 'XXX', '2025-06-01',NULL);

--DATA VALIDATION
--1)DATA COMPLETENESS 
--CHECKING FOR ANY MISSING DATA

SELECT * FROM CAR_RENTAL WHERE PRICE IS NULL;

--ALTERING TABLE STRUCTURE AFTER IT HAS BEEN CREATED
ALTER TABLE CAR_RENTAL
ALTER COLUMN PRICE DECIMAL(10,2) NOT NULL;
--the above query was giving error as we were already having the 3rd row with null
--value, need to update that row

UPDATE CAR_RENTAL --this is an example of updating a row in a Table
SET PRICE = 20.0
WHERE ID in ('11','22');

select * from car_rental;

--2) DATA ACCURACY 
--Checking if the data is accurate or not like if price is not in -ve values

SELECT * FROM CAR_RENTAL 
WHERE PRICE < 0;

ALTER TABLE CAR_RENTAL
ADD CONSTRAINT PRC_CHK CHECK (PRICE BETWEEN 10 AND 20);

--3) DATA DUPLICATION
insert into car_rental
values('19', 'zzz', '2025-10-22', 10.25),
('24', 'XXX', '2025-06-01',10.25);

SELECT * FROM CAR_RENTAL;
insert into car_rental
values('32', 'zzz', '2025-10-22', 10.25),
('33', 'XXX', '2025-06-01',10.25);

--Removing Duplicates
--1) by creating a copy of that table
SELECT * INTO CAR_RENTAL_COPY
FROM (
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY NAME , ORDER_DATE, PRICE ORDER BY PRICE) AS RN
FROM CAR_RENTAL) AS CTE
WHERE RN = 1;

--2) by creating a view
CREATE VIEW TT 
AS 
select * from
(SELECT *, 
ROW_NUMBER() OVER (PARTITION BY NAME, ORDER_DATE, PRICE ORDER BY PRICE) AS RN
FROM CAR_RENTAL ) AS CTE
WHERE RN > 1;

SELECT * FROM CAR_RENTAL
select * from TT;

with cte as (
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY NAME , ORDER_DATE, PRICE ORDER BY PRICE) AS RN
FROM CAR_RENTAl)

delete from cte
where rn = 2;

--Difference b/w Truncate and Delete command
--Truncate delete all the rows in the Table 
--Delete removes selective rows using where clause

select * from car_rental;

USE RENTAL_DATA;

SELECT * FROM dbo.employees;

--4)Checking unique values for the unique columns
select employee_id , count(*) as cn
from dbo.employees
group by employee_id
having count(*) >1;

--5)Checking range of salary
select * from dbo.employees
where salary < 1;

alter table dbo.employees
add constraint mngr_id
default '124' for manager_id;

--6)Phone number validation
select * from dbo.employees
where phone_number like ('%.%.%');
--as phone numbers consist of dots we can replace it with -

UPDATE DBO.EMPLOYEES
SET PHONE_NUMBER = REPLACE(PHONE_NUMBER,'.','-')
WHERE PHONE_NUMBER LIKE '%.%.%';

select * from dbo.employees

--ALL CONSTRAINTS
--BEFORE CREATION OF TABLE
CREATE TABLE CON
( ID INT PRIMARY KEY,
NAME VARCHAR(20) NOT NULL,
EMAIL_ID VARCHAR (30) UNIQUE default 'name@gmail.com',
salary int check (salary < 0));

CREATE TABLE CON_2
( ID INT,
NAME VARCHAR(20),
EMAIL_ID VARCHAR (30),
salary int check (salary < 0)
primary key (ID , NAME));



CREATE TABLE CONSTRAINTS
( ID INT PRIMARY KEY,
NAME VARCHAR(20) NOT NULL,
EMAIL_ID VARCHAR (30) UNIQUE);

INSERT INTO CONSTRAINTS --PARENT TABLE
VALUES
(1 , 'SUNIL', 'sunil@gmail.com'),
(2, 'DILIP', 'dilip@gmail.com'),
(3, 'ANUBHAV', 'anubhav@gmail.com');

CREATE TABLE DEPARTMENT --CHILD TABLE 
(ID INT ,
DEPARTMENT_NAME VARCHAR (20),
DEPT_ID INT
FOREIGN KEY (DEPT_ID) REFERENCES CONSTRAINTS(ID));

INSERT INTO DEPARTMENT
VALUES
(11 , 'ADMIN', 3),
(12 , 'HR', 1),
(13, 'OPERATIONS', 2);

DROP TABLE CONSTRAINTS;
DROP TABLE DEPARTMENT;


--AFTER CREATION OF TABLE
CREATE TABLE CON_3
( ID INT,
NAME VARCHAR(20),
EMAIL_ID VARCHAR (30),
salary int);

ALTER TABLE CON_3
ADD CONSTRAINT PK PRIMARY KEY(ID); -- FOR PRIMARY KEY

ALTER TABLE CON_3
ADD CONSTRAINT CK CHECK (SALARY < 0); -- FOR CHECK CONSTRAINT

ALTER TABLE CON_3
ALTER COLUMN EMAIL_ID VARCHAR (30) NOT NULL; --FOR NOT NULL CONSTRAINT

ALTER TABLE CON_3
ADD CONSTRAINT NN UNIQUE(NAME); --FOR UNIQUE CONSTRAINT

ALTER TABLE  DEPARTMENT_3 --CHILD TABLE 
add constraint FK
FOREIGN KEY (DEPT_ID) 
REFERENCES CONSTRAINTS(ID);








