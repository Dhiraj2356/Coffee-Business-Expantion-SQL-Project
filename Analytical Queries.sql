---GoodLuck Coffee Data Analysis & Reports


---Q.1 What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select city_name, 
		sum(revenue) as revenue, 	
		sum(orders_count) as total_orders  
		from 
		(
select  ct.city_name,
		sum(s.total) as revenue,
		count(s.sale_id) as orders_count,
		extract(month from s.sale_date) as months,
		extract(year from s.sale_date) as year
		from sales as s
left join customers as c
on s.customer_id = c.customer_id
full join city as ct
on ct.city_id = c.city_id
group by ct.city_name, months, year
) 
where months > 9 and year = 2023
group by  city_name
order by revenue desc;


 
/* Q.2  How many units of each coffee product have been sold ? and
        find out top 5 most sold product with total revenue.
*/

Select  p.product_name,
		count(s.sale_id) total_orders,
		sum(s.total) total_revenue
		from sales as s
left join products as p 
on s.product_id = p.product_id 
group by p.product_name
order by 2 desc
limit 5 ;


--- Q.3 How many people in each city are estimated to consume coffee, given that 25% of the population does.

select 	city_name, 
		round(population * 0.25 / 1000000, 2) as estimated_coffee_consumers
		from city
order by population desc

   
---- Q.4  What is the average sales amount per customer in each city?


select city_name, avg_sales_per_cust from (
select  ct.city_name, 
		sum(s.total)  as total_sales,
		count(distinct c.customer_id) as total_cust,
		Round(sum(s.total) / count(distinct c.customer_name),2) as avg_sales_per_cust
		from city as ct
full join customers as c
on ct.city_id = c.city_id
left join sales as s
on s.customer_id = c.customer_id 
group by ct.city_name
order by total_sales desc)


---Q.5 Provide a list of cities along with their estimated populations and coffee consumers.

select ct.city_name,
		count(customer_id) customers,
		round(ct.population * 0.25 / 1000000, 2) as estimated_coffee_consumers
		from customers as c
join city as ct
on c.city_id = ct.city_id
group by ct.city_name, ct.population
order by customers desc;

---Q.6 What are the top 3 selling products in each city based on sales volume?

 
select * from (
select  ct.city_name,
		p.product_name,
		count(s.sale_id ) as total_orders,
		dense_rank()over(partition by ct.city_name order by count(s.sale_id) desc)  as rank
		from products as p 
left join sales as s
on s.product_id = p.product_id
full join customers as c
on c.customer_id = s.customer_id
full join city as ct
on ct.city_id = c.city_id
group by 1,2)
where rank <= 3 


---Q.7 How many unique customers are there in each city who have purchased only coffee products?

select city_name,
		count(distinct s.customer_id) total_customers			
		from customers as c
full join city as ct
on c.city_id = ct.city_id
left join sales as s
on s.customer_id = c.customer_id
full join products as p
on p.product_id = s.product_id
where s.product_id  between 1 and 14
group by city_name
order by 2 desc


---Q.8 Find each city and their average sale per customer and avg rent per customer

select  ct.city_name,  
		round(ct.estimated_rent / count(distinct s.customer_id),2) as rent_per_cust,
		round(sum(s.total) / count(distinct s.customer_id),2) as average_sale_per_cust
		from customers as c
full join city as ct
on c.city_id = ct.city_id
left join sales as s
on s.customer_id = c.customer_id
group by ct.city_name, ct.estimated_rent
order by  3 desc


---Q.9 Calculate the percentage growth (or decline) in sales over different time periods (monthly) for each city.

select city_name, 
		year, 
		months, 
		monthly_sale, 
		wf,
		round((monthly_sale-wf)::Numeric/wf::Numeric * 100,2) as growth_ratio
		from 
				
		(		
select  ct.city_name as city_name,
		extract(year from sale_date) as year,
		extract(month from sale_date) as months,
		sum(s.total) as monthly_sale,
		Lag(sum(s.total), 1) over(partition by ct.city_name ) as wf
				 
		from sales as s
		left join customers as c
		on s.customer_id = c.customer_id
		join city as ct
		on c.city_id = ct.city_id
		group by 1,2,3
		order by 1,2,3 asc 
		) as t
where wf is not null and city_name = 'Pune'	
group by 1,2,3,4,5
order by city_name, year, months asc


---Q.10 Identify top 3 city based on highest sales with lower estimated rent
--- city name, total sale, total rent, total customers, estimated coffee consumer

select ct.city_name,
		sum(s.total) as total_sale ,
		ct.estimated_rent, 
		count(distinct c.customer_id) as total_customers,
		round(ct.population * 0.25 / 1000000.0 ,2) as est_coffee_consumer,
		round(ct.estimated_rent / count(distinct c.customer_id),2) as rent_per_cust
		from sales as s
left join customers as c
on s.customer_id = c.customer_id
join city as ct
on c.city_id = ct.city_id
group by 1, 3 , ct.population
order by total_sale desc;
