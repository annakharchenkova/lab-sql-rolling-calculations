/*
Lab | SQL Rolling calculations

In this lab, you will be using the Sakila database of movie rentals.

Instructions

1. Get number of monthly active customers.
2. Active users in the previous month.
3. Percentage change in the number of active customers.
4. Retained customers every month.
*/

use sakila;

#1. Get number of monthly active customers.
select year(rental_date) as year_active, month(rental_date) as month_active, count(distinct(customer_id))as active_customers
	 from rental
group by month_active, year_active
order by year_active, month_active; 

#2. Active users in the previous month.
with activity as 
(
select year(rental_date) as year_active, month(rental_date) as month_active, count(distinct(customer_id))as active_customers
	 from rental
group by month_active, year_active
order by year_active, month_active
)

select *, lag(active_customers, 1, 'NA') over(partition by year_active) as active_prev  
		from activity
group by month_active, year_active
order by year_active, month_active;


#3. Percentage change in the number of active customers.
with activity_2 as
(
with activity as 
(
select year(rental_date) as year_active, month(rental_date) as month_active, count(distinct(customer_id))as active_customers
	 from rental
group by month_active, year_active
order by year_active, month_active
)

select *, lag(active_customers, 1, 'NA') over(partition by year_active) as active_prev  
		from activity
group by month_active, year_active
order by year_active, month_active
)

select *, if(active_prev <> 'NA', round((active_customers-active_prev)/active_prev*100, 2), 'NA') as difference from activity_2;

#4. Retained customers every month.
SET sql_mode=(SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));


with customers as
(
select distinct year(rental_date) as year_active, month(rental_date) as month_active, customer_id 
	 from rental
group by month_active, year_active, customer_id
order by year_active, month_active, customer_id
)

select c1.year_active, c1.month_active, c2.customer_id 
		-- ,count(c2.customer_id) -- for checking purposes - returns amount of customers retained 
		from customers as c1
join customers as c2 on 
	c1.year_active = c2.year_active and 
	c1.month_active = c2.month_active -1 and
	c1.customer_id = c2.customer_id

-- group by year_active, month_active -- for checking purposes - returns amount of customers retained
-- order by year_active, month_active, customer_id

;

