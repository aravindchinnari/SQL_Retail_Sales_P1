# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  
**Database**: `SQL_project_p1`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `SQL_project_p1`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
create  DATABASE SQL_project_p1;

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
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

#### Checking Null values
##### Method 1
```sql
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
```
##### Method 2
```sql
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

```
#### Removing Null values

```sql

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
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
SELECT *
FROM retail_sales
WHERE category = 'clothing'
  AND quantiy > 10
  AND sale_date >= '2022-11-01'
  AND sale_date < '2022-12-01';
```

3. **Write a SQL query to calculate the total sales (total_sale) for each category.**:
```sql
select category, sum(total_sale) as Total_Sales_each_category, count(*) as Total_orders
from 
retail_sales
group by category;
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
select round(avg(age), 2) as Average_Age 
from retail_sales
where category = 'Beauty';
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
select * from 
retail_sales
where total_sale > 1000;
```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
select gender,category,count(*) as Total_Transactions_Gender_Category
from retail_sales
group by gender,category;
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
##### Method 1
```sql
with aravind as(
select  extract (month from sale_date) as Month, extract( year from sale_date) as Year, avg(total_sale)  as Avg_sale
from retail_sales
group by Month, Year
)

select year, max(Avg_sale)
from aravind
group by year;
```

##### Method 2
```sql
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
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales.**:
```sql
select customer_id, sum(total_Sale) as Total_sales_customer 
from retail_sales
group by customer_id
order by Total_sales_customer desc
limit 5;
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
select category, count(distinct customer_id ) as TotalUniqueCustomersByCategory
from retail_sales
group by category;
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
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

```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `analysis_queries.sql` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Aravind Chinnari - Data Analyst/Engineer

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated and Join the Community

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on social media and join our community:


- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/chinnari-aravind/)


Thank you for your support, and I look forward to connecting with you!
