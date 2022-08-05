-- Get number of monthly active customers.
-- step 1: first i'll create a view with all the data i'm going to need:
create or replace view sakila.user_activity as
select customer_id, convert(payment_date, date) as Activity_date,
date_format(convert(payment_date,date), '%m') as Activity_Month,
date_format(convert(payment_date,date), '%Y') as Activity_year
from sakila.payment;

select * from sakila.user_activity;

-- step 2: getting the total number of active user per month and year
create or replace view sakila.monthly_active_users as
select Activity_year, Activity_Month, count(distinct customer_id) as Active_users
from sakila.user_activity
group by Activity_year, Activity_Month
order by Activity_year asc, Activity_Month asc;

select * from sakila.monthly_active_users;

-- Active users in the previous month.
-- step 3: using LAG() to get the users from previous month
select 
   Activity_year, 
   Activity_month,
   Active_users, 
   lag(Active_users) over () as Last_month 
from sakila.monthly_active_users;

-- Percentage change in the number of active customers.
create or replace view sakila.diff_monthly_active_users as
with cte_view as 
(
	select 
	Activity_year, 
	Activity_month,
	Active_users, 
	lag(Active_users) over (order by Activity_year, Activity_Month) as Last_month
	from sakila.monthly_active_users
)
select 
   Activity_year, 
   Activity_month, 
   Active_users, 
   Last_month, 
    (Active_users-last_month)/Active_users*100 as Percentage 
from cte_view;

select * from sakila.diff_monthly_active_users;