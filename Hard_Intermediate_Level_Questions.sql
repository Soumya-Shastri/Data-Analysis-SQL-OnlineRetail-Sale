-- Q.1 Assume you're given a table containing information on Facebook user actions. Write a query to obtain number of 
--monthly active users (MAUs) in July 2022, including the month in numerical format "1, 2, 3".
--Hint:
--An active user is defined as a user who has performed actions such as 'sign-in', 'like', or 'comment' in both 
--the current month and the previous month.

--user_actions Table:
--Column Name	Type
--user_id	integer
--event_id	integer
--event_type	string ("sign-in, "like", "comment")
--event_date	datetime

--Example Output for June 2022:
--month	       monthly_active_users
-- 6	           1

CREATE TABLE user_actions (
    user_id INT,
    event_id INT,
    event_type VARCHAR(20),
    event_date DATETIME
);
INSERT INTO user_actions (user_id, event_id, event_type, event_date)
VALUES
-- June Data
(1, 101, 'sign-in', '2022-06-05'),
(2, 102, 'like', '2022-06-10'),
(3, 103, 'comment', '2022-06-12'),
(1, 104, 'like', '2022-06-18'),
(4, 105, 'sign-in', '2022-06-20'),

-- July Data
(1, 201, 'sign-in', '2022-07-02'),
(2, 202, 'like', '2022-07-08'),
(3, 203, 'comment', '2022-07-15'),
(1, 204, 'comment', '2022-07-20'),
(5, 205, 'like', '2022-07-25');

select * from user_actions;

with June_cte as (
select distinct user_id from user_actions
where event_type in ('sign-in','like','comment') and event_date >= '2022-06-01' and event_date < '2022-07-01'), 
July_cte as (
select distinct user_id from user_actions
where event_type in ('sign-in','like','comment') and event_date >= '2022-07-01' and event_date < '2022-08-01')

select 7 as month , count(*) as Monthly_Active_Users
from June_cte Ju 
inner join July_cte JJ
on Ju.user_id = JJ.user_id;


--Q.2) Assume you're given a table containing information about Wayfair user transactions for different products. 
--Write a query to calculate the year-on-year growth rate for the total spend of each product, grouping the results by
--product ID.The output should include the year in ascending order, product ID, current year's spend, previous year's 
--spend and year-on-year growth percentage, rounded to 2 decimal places.
--user_transactions Table:
--Column Name	Type
--transaction_id	integer
--product_id	integer
--spend	decimal
--transaction_date	datetime

CREATE TABLE user_transactions (
    transaction_id INT PRIMARY KEY,
    product_id INT,
    spend DECIMAL(10,2),
    transaction_date DATETIME
);

INSERT INTO user_transactions (transaction_id, product_id, spend, transaction_date)
VALUES
-- Product 1 Data
(1, 101, 500.00, '2021-01-15'),
(2, 101, 600.00, '2021-03-20'),
(3, 101, 700.00, '2022-01-12'),
(4, 101, 800.00, '2022-04-25'),
(5, 101, 900.00, '2023-02-10'),

-- Product 2 Data
(6, 102, 400.00, '2021-02-10'),
(7, 102, 450.00, '2022-02-15'),
(8, 102, 500.00, '2023-03-05'),

-- Product 3 Data
(9, 103, 1000.00, '2022-06-18'),
(10, 103, 1200.00, '2023-07-22');

select * from user_transactions;

with cte as (
SELECT DATEPART(YEAR, transaction_date) as year, product_id,
SPEND AS CURR_YEAR_SPEND,
LAG(SPEND) OVER (partition by product_id ORDER BY transaction_date) AS PREV_YEAR_SPEND
from user_transactions)
select *, 
round((CAST(curr_year_spend - prev_year_spend AS FLOAT )/prev_year_spend)*100.00,2)
as yoy_rate
from cte

--Q.3)Amazon wants to maximize the storage capacity of its 500,000 square-foot warehouse by prioritizing a specific batch 
--of prime items. The specific prime product batch detailed in the inventory table must be maintained.
--So, if the prime product batch specified in the item_category column included 1 laptop and 1 side table, that would be 
--the base batch. We could not add another laptop without also adding a side table; they come all together as a batch set.
--After prioritizing the maximum number of prime batches, any remaining square footage will be utilized to stock non-prime 
--batches, which also come in batch sets and cannot be separated into individual items.
--Write a query to find the maximum number of prime and non-prime batches that can be stored in the 500,000 square feet 
--warehouse based on the following criteria:
--Prioritize stocking prime batches
--After accommodating prime items, allocate any remaining space to non-prime batches
--Output the item_type with prime_eligible first followed by not_prime, along with the maximum number of batches that can 
--be stocked.

--Assumptions:

--Again, products must be stocked in batches, so we want to find the largest available quantity of prime batches, and then the largest available quantity of non-prime batches
--Non-prime items must always be available in stock to meet customer demand, so the non-prime item count should never be zero.
--Item count should be whole numbers (integers).
--inventory table:
--Column Name	Type
--item_id	integer
--item_type	string
--item_category	string
--square_footage	decimal

--Example Output:
--item_type	        item_count
--prime_eligible	9285
--not_prime	        6

-- Step 1: Create the Inventory Table
CREATE TABLE inventory (
    item_id INT PRIMARY KEY,
    item_type VARCHAR(20),
    item_category VARCHAR(50),
    square_footage DECIMAL(10,2)
);

-- Step 2: Insert Sample Data

-- Prime Eligible Items (Laptops, Side Tables, TVs, etc.)
INSERT INTO inventory (item_id, item_type, item_category, square_footage)
VALUES
(1, 'prime_eligible', 'laptop', 25.00),
(2, 'prime_eligible', 'side table', 30.00),
(3, 'prime_eligible', 'TV', 40.00),
(4, 'prime_eligible', 'sofa', 80.00),
(5, 'prime_eligible', 'bed', 120.00),
(6, 'prime_eligible', 'chair', 35.00),
(7, 'prime_eligible', 'refrigerator', 150.00),
(8, 'prime_eligible', 'oven', 70.00),
(9, 'prime_eligible', 'washing machine', 200.00),
(10, 'prime_eligible', 'wardrobe', 250.00),
(11, 'prime_eligible', 'microwave', 45.00),
(12, 'prime_eligible', 'desk', 60.00),
(13, 'prime_eligible', 'gaming console', 55.00),
(14, 'prime_eligible', 'AC unit', 180.00),
(15, 'prime_eligible', 'dining table', 150.00);

-- Non-Prime Items (Books, Toys, etc.)
INSERT INTO inventory (item_id, item_type, item_category, square_footage)
VALUES
(16, 'not_prime', 'bookshelf', 50.00),
(17, 'not_prime', 'rug', 20.00),
(18, 'not_prime', 'coffee table', 35.00),
(19, 'not_prime', 'lamp', 15.00),
(20, 'not_prime', 'curtain', 10.00),
(21, 'not_prime', 'shoe rack', 25.00),
(22, 'not_prime', 'wall art', 5.00),
(23, 'not_prime', 'mirror', 40.00),
(24, 'not_prime', 'clock', 8.00),
(25, 'not_prime', 'toy set', 12.00),
(26, 'not_prime', 'pillows', 10.00),
(27, 'not_prime', 'blanket', 30.00),
(28, 'not_prime', 'cushion', 8.00),
(29, 'not_prime', 'side lamp', 12.00),
(30, 'not_prime', 'vase', 7.00),
(31, 'not_prime', 'photo frame', 5.00),
(32, 'not_prime', 'storage box', 22.00),
(33, 'not_prime', 'laundry basket', 18.00),
(34, 'not_prime', 'candles', 6.00),
(35, 'not_prime', 'magazine rack', 14.00),
(36, 'not_prime', 'organizer', 10.00),
(37, 'not_prime', 'kitchen mat', 8.00),
(38, 'not_prime', 'hanger set', 5.00),
(39, 'not_prime', 'placemat', 3.00),
(40, 'not_prime', 'bowl set', 12.00);

-- Verify the Data
SELECT * FROM inventory;
with cte_item_type as(
select item_type,
       count(*) as item_count,
	   sum(square_footage) as Total_square_footage
	   from inventory
	   group by item_type),
prime_items as (
select item_type,
       (floor(500000/total_square_footage)*item_count) as Total_item_count,
	   (floor(500000/total_square_footage) * Total_square_footage) as total_footage_prime
	   from cte_item_type
	   where item_type = 'prime_eligible')
select item_type , total_item_count
from prime_items
union all
select item_type, 
       floor(500000 - (select total_footage_prime from prime_items)) / total_square_footage *item_count
	   from cte_item_type
	   where item_type = 'not_prime';

--Q.4)Google's marketing team is making a Superbowl commercial and needs a simple statistic to put on their TV ad: 
--the median number of searches a person made last year.However, at Google scale, querying the 2 trillion searches 
--is too costly. Luckily, you have access to the summary table which tells you the number of searches made last year
--and how many Google users fall into that bucket.
--Write a query to report the median of searches made by a user. Round the median to one decimal point.

-- Create the table
CREATE TABLE search_frequency (
    searches INT,
    num_users INT
);

-- Insert data into the table
INSERT INTO search_frequency (searches, num_users)
VALUES
    (1, 2),
    (4, 1),
    (2, 2),
    (3, 3),
    (6, 1),
    (5, 3),
    (7, 2);

Select * from search_frequency;

with cte as(
select *, row_number() over (order by searches) as rn, 
         count(*) over () as cnt
from search_frequency)
select avg(cast(searches as float)) as avg_searches
from cte
where rn in (cnt /2 , (cnt +1)/2);

--Q.5)You're provided with two tables: the advertiser table contains information about advertisers and their respective payment 
--status, and the daily_pay table contains the current payment information for advertisers, and it only includes advertisers 
--who have made payments.
--Write a query to update the payment status of Facebook advertisers based on the information in the daily_pay table. 
--The output should include the user ID and their current payment status, sorted by the user id.
--The payment status of advertisers can be classified into the following categories:
--New: Advertisers who are newly registered and have made their first payment.
--Existing: Advertisers who have made payments in the past and have recently made a current payment.
--Churn: Advertisers who have made payments in the past but have not made any recent payment.
--Resurrect: Advertisers who have not made a recent payment but may have made a previous payment and have made a 
--payment again recently.
--Before proceeding with the question, it is important to understand the possible transitions in the advertiser's status 
--based on the payment status. 
--If an advertiser does not make a payment on day T, regardless of their previous status, their payment status 
--transitions to "CHURN" as the updated status.
--If an advertiser makes a payment on day T, the status is updated to either "EXISTING" or "RESURRECT" based on their 
--previous status. If the previous status was "CHURN," the updated status is "RESURRECT." 
--For any other previous status, the updated status is "EXISTING."

-- Create the advertiser table
CREATE TABLE advertiser (
    user_id VARCHAR(50),
    status VARCHAR(20)
);

-- Insert data into the advertiser table
INSERT INTO advertiser (user_id, status)
VALUES
    ('bing', 'NEW'),
    ('yahoo', 'NEW'),
    ('alibaba', 'EXISTING'),
    ('baidu', 'EXISTING'),
    ('target', 'CHURN'),
    ('tesla', 'CHURN'),
    ('morgan', 'RESURRECT'),
    ('chase', 'RESURRECT');

-- Create the daily_pay table
CREATE TABLE daily_pay (
    user_id VARCHAR(50),
    paid DECIMAL(10, 2)
);

-- Insert data into the daily_pay table
INSERT INTO daily_pay (user_id, paid)
VALUES
    ('yahoo', 45.00),
    ('alibaba', 100.00),
    ('target', 13.00),
    ('morgan', 600.00),
    ('fitdata', 25.00);

select * from advertiser;
select * from daily_pay;


WITH CTE AS (
    SELECT 
        COALESCE(a.user_id, dp.user_id) AS user_id,  -- Ensure all user_ids are included
        a.status,
        dp.paid
    FROM advertiser a
    FULL OUTER JOIN daily_pay dp 
    ON a.user_id = dp.user_id
)
SELECT user_id,
       CASE
           WHEN status IS NULL THEN 'NEW'            -- Exists only in daily_pay
           WHEN paid IS NULL THEN 'CHURN'            -- Exists in advertiser but hasn't paid
           WHEN status = 'CHURN' THEN 'RESURRECT'    -- Was CHURN but made a payment
           ELSE 'EXISTING'                           -- All other cases
       END AS new_status
FROM CTE
ORDER BY user_id;

--Q.6)You’re a consultant for a major pizza chain that will be running a promotion where all 3-topping pizzas will be 
--sold for a fixed price, and are trying to understand the costs involved. Given a list of pizza toppings, consider 
--all the possible 3-topping pizzas, and print out the total cost of those 3 toppings. Sort the results with the highest 
--total cost on the top followed by pizza toppings in ascending order.
--Break ties by listing the ingredients in alphabetical order, starting from the first ingredient, followed by the 
--second and third.
--Do not display pizzas where a topping is repeated. For example, ‘Pepperoni,Pepperoni,Onion Pizza’.
--Ingredients must be listed in alphabetical order. For example, 'Chicken,Onions,Sausage'. 'Onion,Sausage,Chicken' is not 
--acceptable.
CREATE TABLE PizzaToppings (
    ingredient_cost DECIMAL(4,2),
    topping_name VARCHAR(50)
);

INSERT INTO PizzaToppings (ingredient_cost, topping_name)
VALUES
(0.50, 'Pepperoni'),
(0.70, 'Sausage'),
(0.55, 'Chicken'),
(0.40, 'Extra Cheese'),
(0.25, 'Mushrooms'),
(0.20, 'Green Peppers'),
(0.15, 'Onions'),
(0.25, 'Pineapple'),
(0.30, 'Spinach'),
(0.20, 'Jalapenos');

Select * from PizzaToppings;
--Solution 1 ( using inner join)
select concat(p1.topping_name , ',', p2.topping_name , ',', p3.topping_name) as toppings,
(p1.ingredient_cost + p2.ingredient_cost + p3.ingredient_cost) as total_cost

FROM PizzaToppings AS p1
INNER JOIN PizzaToppings AS p2
  ON p1.topping_name < p2.topping_name 
INNER JOIN PizzaToppings AS p3
  ON p2.topping_name < p3.topping_name
order by total_cost desc , toppings;

--Solution 2 (using cross join)
select concat(p1.topping_name , ',', p2.topping_name , ',', p3.topping_name) as toppings,
(p1.ingredient_cost + p2.ingredient_cost + p3.ingredient_cost) as total_cost
 from PizzaToppings p1
cross join PizzaToppings p2
cross join PizzaToppings p3
where p1.topping_name < p2.topping_name
and p2.topping_name < p3.topping_name
order by total_cost desc , toppings;


--Q.7)You work as a data analyst for a FAANG company that tracks employee salaries over time. The company wants to 
--understand how the average salary in each department compares to the company's overall average salary each month.
--Write a query to compare the average salary of employees in each department to the company's average salary for March 2024. 
--Return the comparison result as 'higher', 'lower', or 'same' for each department. Display the department ID, 
--payment month (in MM-YYYY format), and the comparison result.

-- Create the Employee table
DROP TABLE EMPLOYEE;
CREATE TABLE Employee (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    salary INT,
    department_id INT,
    manager_id INT
);

-- Insert data into the Employee table
INSERT INTO Employee (employee_id, name, salary, department_id, manager_id)
VALUES
(1, 'Emma Thompson', 3800, 1, 6),
(2, 'Daniel Rodriguez', 2230, 1, 7),
(3, 'Olivia Smith', 7000, 1, 8),
(4, 'Noah Johnson', 6800, 2, 9),
(5, 'Sophia Martinez', 1750, 1, 11),
(6, 'Liam Brown', 13000, 3, NULL),
(7, 'Ava Garcia', 12500, 3, NULL),
(8, 'William Davis', 6800, 2, NULL),
(9, 'Isabella Wilson', 11000, 3, NULL),
(10, 'James Anderson', 4000, 1, 11),
(11, 'Mia Taylor', 10800, 3, NULL),
(12, 'Benjamin Hernandez', 9500, 3, 8),
(13, 'Charlotte Miller', 7000, 2, 6),
(14, 'Logan Moore', 8000, 2, 6),
(15, 'Amelia Lee', 4000, 1, 7);

-- Create the Salary table
DROP TABLE SALARY;
CREATE TABLE Salary (
    salary_id INT PRIMARY KEY,
    employee_id INT,
    amount INT,
    payment_date DATETIME,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
);

-- Insert data into the Salary table
-- Create the Salary table
DROP TABLE SALARY;
CREATE TABLE Salary (
    salary_id INT PRIMARY KEY,
    employee_id INT,
    amount INT,
    payment_date DATETIME,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
);

-- Insert data into the Salary table
INSERT INTO Salary (salary_id, employee_id, amount, payment_date)
VALUES
(1, 1, 3800, '2024-01-31 00:00:00'),
(2, 2, 2230, '2024-01-31 00:00:00'),
(3, 3, 7000, '2024-01-31 00:00:00'),
(4, 4, 6800, '2024-01-31 00:00:00'),
(5, 5, 1750, '2024-01-31 00:00:00'),
(6, 6, 13000, '2024-01-31 00:00:00'),
(7, 7, 12500, '2024-01-31 00:00:00'),
(8, 8, 6800, '2024-01-31 00:00:00'),
(9, 9, 11000, '2024-01-31 00:00:00'),
(10, 10, 4000, '2024-01-31 00:00:00'),
(11, 11, 10800, '2024-01-31 00:00:00'),
(12, 12, 9500, '2024-01-31 00:00:00'),
(13, 13, 7000, '2024-01-31 00:00:00'),
(14, 14, 8000, '2024-01-31 00:00:00'),
(15, 15, 4000, '2024-01-31 00:00:00'),
(16, 1, 3800, '2024-02-28 00:00:00'),
(17, 2, 2230, '2024-02-28 00:00:00'),
(18, 3, 7000, '2024-02-28 00:00:00'),
(19, 4, 6800, '2024-02-28 00:00:00'),
(20, 5, 1750, '2024-02-28 00:00:00'),
(21, 6, 13000, '2024-02-28 00:00:00'),
(22, 7, 12500, '2024-02-28 00:00:00'),
(23, 8, 6800, '2024-02-28 00:00:00'),
(24, 9, 11000, '2024-02-28 00:00:00'),
(25, 10, 4000, '2024-02-28 00:00:00'),
(26, 11, 10800, '2024-02-28 00:00:00'),
(27, 12, 9500, '2024-02-28 00:00:00'),
(28, 13, 7000, '2024-02-28 00:00:00'),
(29, 14, 8000, '2024-02-28 00:00:00'),
(30, 15, 4000, '2024-02-28 00:00:00'),
(31, 1, 3800, '2024-03-31 00:00:00'),
(32, 2, 2230, '2024-03-31 00:00:00'),
(33, 3, 7000, '2024-03-31 00:00:00'),
(34, 4, 6800, '2024-03-31 00:00:00'),
(35, 5, 1750, '2024-03-31 00:00:00'),
(36, 6, 13000, '2024-03-31 00:00:00'),
(37, 7, 12500, '2024-03-31 00:00:00'),
(38, 8, 6800, '2024-03-31 00:00:00'),
(39, 9, 11000, '2024-03-31 00:00:00'),
(40, 10, 4000, '2024-03-31 00:00:00'),
(41, 11, 10800, '2024-03-31 00:00:00'),
(42, 12, 9500, '2024-03-31 00:00:00'),
(43, 13, 7000, '2024-03-31 00:00:00'),
(44, 14, 8000, '2024-03-31 00:00:00'),
(45, 15, 4000, '2024-03-31 00:00:00');


SELECT TOP 5 * FROM EMPLOYEE;
SELECT TOP 5 * FROM SALARY;
--When format function is working
with cte as(
select a.department_id ,a.salary,
format(b.payment_date,'mm-yyyy') as pay_date -- format function is not working here as date is in 'yyyy-mm-dd' format
from employee a 
inner join salary b 
on a.employee_id = b.employee_id)
select distinct department_id , 
pay_date, 
CASE 
    WHEN 
	avg(salary) over (partition by department_id) < avg(salary) over () THEN 'LOWER' ELSE 'HIGHER' END AS COMPARISON
from cte
where pay_date > '02-2024' and pay_date < '04-2024'; --this script will give empty output

--when format function for date is not working

with cte as(
select a.department_id ,a.salary,
right( '0' + cast(MONTH(b.payment_date) as varchar(2)) ,2) + '-' + cast(year(b.payment_date) as varchar(4)) as pay_date
from employee a 
inner join salary b 
on a.employee_id = b.employee_id)
select distinct department_id , 
pay_date, 
CASE 
    WHEN 
	avg(salary) over (partition by department_id) < avg(salary) over () THEN 'LOWER' ELSE 'HIGHER' END AS COMPARISON
from cte
where pay_date > '02-2024' and pay_date < '04-2024';


--Q.8)Sometimes, payment transactions are repeated by accident; it could be due to user error, API failure or a 
--retry error that causes a credit card to be charged twice.Using the transactions table, identify any payments made 
--at the same merchant with the same credit card for the same amount within 10 minutes of each other. Count such 
--repeated payments. Assumptions: The first transaction of such payments should not be counted as a repeated payment. 
--This means, if there are two transactions performed by a merchant with the same credit card and for the same amount 
--within 10 minutes, there will only be 1 repeated payment.

-- Create the Transactions table
DROP TABLE TRANSACTIONS;
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY,
    merchant_id INT,
    credit_card_id INT,
    transaction_timestamp DATETIME,
    amount INT
);

-- Insert data into the Transactions table
INSERT INTO Transactions (transaction_id, merchant_id, credit_card_id, transaction_timestamp, amount)
VALUES
(1, 101, 1, '2022-09-25 12:00:00', 100),
(2, 101, 1, '2022-09-25 12:08:00', 100),
(3, 101, 1, '2022-09-25 12:28:00', 100),
(5, 101, 1, '2022-09-25 13:37:00', 100),
(4, 101, 2, '2022-09-25 12:20:00', 300),
(6, 102, 2, '2022-09-25 14:00:00', 400),
(7, 102, 3, '2022-09-26 10:00:00', 300),
(8, 102, 3, '2022-09-26 10:10:00', 300),
(9, 102, 3, '2022-09-26 10:14:00', 300),
(10, 103, 4, '2022-09-27 12:00:00', 50),
(11, 103, 4, '2022-09-27 12:09:00', 50),
(12, 103, 4, '2022-09-27 22:00:00', 50),
(14, 105, 6, '2022-09-27 12:10:00', 100),
(13, 105, 6, '2022-09-27 12:00:00', 200);

SELECT * FROM TRANSACTIONS;

WITH RankedTransactions AS (
  SELECT 
    t1.transaction_id AS t1_transaction_id,
    t2.transaction_id AS t2_transaction_id,
	DATEDIFF(MINUTE, t1.transaction_timestamp, t2.transaction_timestamp) as diff
  FROM transactions AS t1
  JOIN transactions AS t2
  ON t1.merchant_id = t2.merchant_id
    AND t1.credit_card_id = t2.credit_card_id
    AND t1.amount = t2.amount
    AND t1.transaction_timestamp < t2.transaction_timestamp
    AND DATEDIFF(MINUTE, t1.transaction_timestamp, t2.transaction_timestamp) <= 10
)
SELECT COUNT(*) AS payment_count
FROM RankedTransactions;

--Q.10)Amazon Web Services (AWS) is powered by fleets of servers. Senior management has requested data-driven solutions 
--to optimize server usage.Write a query that calculates the total time that the fleet of servers was running. 
--The output should be in units of full days.
--Assumptions:
--Each server might start and stop several times.
--The total time in which the server fleet is running can be calculated as the sum of each server's uptime.
-- Create the table
CREATE TABLE server_utilization (
    server_id INT,
    session_status VARCHAR(10),
    status_time DATETIME
);

-- Insert the data
INSERT INTO server_utilization (server_id, session_status, status_time)
VALUES
(1, 'start', '2022-08-02 10:00:00'),
(1, 'stop', '2022-08-04 10:00:00'),
(1, 'stop', '2022-08-13 19:00:00'),
(1, 'start', '2022-08-13 10:00:00'),
(3, 'stop', '2022-08-19 10:00:00'),
(3, 'start', '2022-08-18 10:00:00'),
(5, 'stop', '2022-08-19 10:00:00'),
(4, 'stop', '2022-08-19 14:00:00'),
(4, 'start', '2022-08-16 10:00:00'),
(3, 'stop', '2022-08-14 10:00:00'),
(3, 'start', '2022-08-06 10:00:00'),
(2, 'stop', '2022-08-24 10:00:00'),
(2, 'start', '2022-08-17 10:00:00'),
(5, 'start', '2022-08-14 21:00:00');

Select * from server_utilization;

with cte as(
select server_id , session_status , status_time as start_time , 
lead(status_time) over (partition by server_id order by status_time) as stop_time --here we are taking lead time as we are 
--ordering the status_time in asc order, start_time will be less than stop_time stop time will be after the start time
from server_utilization)

select 
sum(datediff(hour, start_time , stop_time)) /24 as diff_in_hours --taking difference b/w the 2 times, now we need to take out 
--cumulative days so doing the sum and then to convert it to days dividing the hours by 24
from cte
where session_status = 'start' and stop_time is not null;

--Q.10)Assume you're given tables with information on Snapchat users, including their ages and time spent sending and opening 
-- snaps.Write a query to obtain a breakdown of the time spent sending vs. opening snaps as a percentage of total time spent on 
--these activities grouped by age group. Round the percentage to 2 decimal places in the output.
--Notes:
--Calculate the following percentages:
--time spent sending / (Time spent sending + Time spent opening)
--Time spent opening / (Time spent sending + Time spent opening)
--To avoid integer division in percentages, multiply by 100.0 and not 100.

-- Create the table
CREATE TABLE activity_log (
    activity_id INT,
    user_id INT,
    activity_type VARCHAR(10),
    time_spent FLOAT,
    activity_date DATETIME
);

-- Insert data into the table
INSERT INTO activity_log (activity_id, user_id, activity_type, time_spent, activity_date)
VALUES
(7274, 123, 'open', 4.50, '2022-06-22 12:00:00'),
(2425, 123, 'send', 3.50, '2022-06-22 12:00:00'),
(1413, 456, 'send', 5.67, '2022-06-23 12:00:00'),
(2536, 456, 'open', 3.00, '2022-06-25 12:00:00'),
(8564, 456, 'send', 8.24, '2022-06-26 12:00:00'),
(5235, 789, 'send', 6.24, '2022-06-28 12:00:00'),
(4251, 123, 'open', 1.25, '2022-07-01 12:00:00'),
(1414, 789, 'chat', 11.00, '2022-06-25 12:00:00'),
(1314, 123, 'chat', 3.15, '2022-06-26 12:00:00'),
(1435, 789, 'open', 5.25, '2022-07-02 12:00:00');

-- Create the table
CREATE TABLE snapchat_users (
    user_id INT,
    age_bucket VARCHAR(10)
);

-- Insert data into the table
INSERT INTO snapchat_users (user_id, age_bucket)
VALUES
(123, '31-35'),
(456, '26-30'),
(789, '21-25');

select * from activity_log;
select * from snapchat_users;

with cte as(
select a.activity_type , a.time_spent , b.age_bucket
from activity_log a 
join snapchat_users b 
on a.user_id = b.user_id),
cte_2 as (
select age_bucket , 
sum(case when activity_type = 'open' then time_spent end) as open_time_spent,
sum(case when activity_type = 'send' then time_spent end) as send_time_sent
from cte
group by age_bucket)

select age_bucket , round((open_time_spent /(open_time_spent + send_time_sent))*100.00,2) as open_perc,
round((send_time_sent /(open_time_spent + send_time_sent))*100.00,2) as send_perc
from cte_2;







