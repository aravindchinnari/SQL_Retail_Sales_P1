--SQl Retail Sales Analysis  - P1

create  DATABASE SQL_project_p1;

USE database SQL_project_p1;

--create Table
drop table if exists retail_sales;

create table retail_sales(
           transactions_id INT,
		   sale_date DATE,
		   sale_time TIME,
		   customer_id INT,
		   gender VARCHAR(15),
		   age INT,
		   category VARCHAR(15),
		   quantiy INT,
		   price_per_unit FLOAT,
		   cogs FLOAT,
		   total_sale FLOAT
);


select * from retail_sales;

select count(*) as total_records from retail_sales;

--checking null values

DO
$$
DECLARE
    r RECORD;
    col_name TEXT;
    qry TEXT;
    has_null BOOLEAN;
BEGIN
    FOR r IN 
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'retail_sales'
    LOOP
        col_name := quote_ident(r.column_name);
        qry := format('SELECT EXISTS (SELECT 1 FROM retail_sales WHERE %I IS NULL)', col_name);
        EXECUTE qry INTO has_null;

        IF has_null THEN
            RAISE NOTICE 'Column "%" has NULLs', r.column_name;
        END IF;
    END LOOP;
END
$$ LANGUAGE plpgsql;


select * from retail_sales
where transactions_id isnull or
		   sale_date isnull or
		   sale_time isnull or
		   customer_id isnull or
		   gender isnull or
		   age isnull or
		   category isnull or
		   quantiy isnull or
		   price_per_unit isnull or
		   cogs isnull or
		   total_sale isnull;


--delete rows in the retail_sales table which having null vales ( Data Cleaning)
delete from retail_sales
where transactions_id isnull or
		   sale_date isnull or
		   sale_time isnull or
		   customer_id isnull or
		   gender isnull or
		   age isnull or
		   category isnull or
		   quantiy isnull or
		   price_per_unit isnull or
		   cogs isnull or
		   total_sale isnull;

-- Data Exploration	

--total sales
select count(*) as Total_sales from retail_sales;

--How many  unique customers we have

select count(distinct(customer_id)) from retail_sales;

--How Many Categories we have in the data

select distinct category from retail_sales;

-- Data Analysis & Business Key Problems

--Q.1 Write a SQL query to  retrieve all columns for sale made on '2022-11-05'.
select * 
from 
retail_sales 
where sale_date = '2022-11-05';

--Q.2 Write a SQL query to retrieve all transacations where the category is 'clothing' and quantity sold is more than 10 in the month of Nov-2022.

SELECT *
FROM retail_sales
WHERE category = 'clothing'
  AND quantiy > 10
  AND sale_date >= '2022-11-01'
  AND sale_date < '2022-12-01';

--Q.3 Write a SQL query to calculate the total sales (total sales for each category)

select category, sum(total_sale) as Total_Sales_each_category, count(*) as Total_orders
from 
retail_sales
group by category;

--Q.4 Write a SQl query to find the average age of customers  who purchased items from the 'Beauty' category

select round(avg(age), 2) as Average_Age 
from retail_sales
where category = 'Beauty';

--Q.5 Write a SQL query to find  all transactions  where the total_sale is greater than 1000.

select * from 
retail_sales
where total_sale > 1000;

--Q.6 Write  a SQL query  to find  the total number of transactions (transaction_id) made by each gender in each category.

select gender,category,count(*) as Total_Transactions_Gender_Category
from retail_sales
group by gender,category;

--Q.7 Write a SQL queryto calculate the average sale for each month , find out best selling month in each year
-- Method 1

with aravind as(
select  extract (month from sale_date) as Month, extract( year from sale_date) as Year, avg(total_sale)  as Avg_sale
from retail_sales
group by Month, Year
)

select year, max(Avg_sale)
from aravind
group by year;

--Method 2
select year, 
month,
Avg_sale
from 
(

select extract(month from sale_date) as Month,
extract(year from sale_date) as Year,
avg(total_sale) as Avg_sale,
rank() over(partition by extract(year from sale_date) order by avg(total_sale) desc ) as rank
from retail_sales
group by Month, Year

)
where rank =1;

--Q.8 Write SQL query to find the  top 5 customers  based on the highest total_sales.

select customer_id, sum(total_Sale) as Total_sales_customer 
from retail_sales
group by customer_id
order by Total_sales_customer desc
limit 5;

--Q.9 Write SQL query to find the number of unique customers who purchased items from each category.

select category, count(distinct customer_id ) as TotalUniqueCustomersByCategory
from retail_sales
group by category;

--Q.10 Write a SQl query to create each shift and number of orders (Example Morning <=12, Afternoon between 12 & 17 , Evening > 17).

with aravind as 
(
select *,
case
   when extract(hour from sale_time)< 12 then 'Morning'
   when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
   else 'Evening'
end as shift   
from retail_sales
)

select shift, count(transactions_id)
from aravind
group by shift;

--End of Data Analysis