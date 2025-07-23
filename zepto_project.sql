create table zepto (
	sku_id serial primary key,
	category varchar(150),
	name varchar(150) not null,
	mrp numeric(8,2),
	discountpercent numeric(5,2),
	availablequantity int,
	discountedsp numeric(8,2),
	weight int,
	outofstock boolean,
	quantity int
);

select * from zepto;

-- Check whether all rows have been imported

select count(*) as number_of_rows
from zepto;


-- Data Cleaning

-- Check for zero mrp

select *
from zepto
where
	mrp = 0
	or
	discountedsp = 0
;

delete from zepto
where 
	mrp = 0;  -- Product with zero mrp shall be removed

-- Converting mrp from paise to rupees by dividing by 100

Update zepto
set
	mrp = mrp/100,
	discountedsp = discountedsp/100
;


-- Exploratory Data Analysis

-- Check for null values

select *
from zepto
where
	row(name, category, mrp, discountpercent, availablequantity, discountedsp, weight, outofstock, quantity)
	is null
;

-- Check for different categories

select 
	distinct category
from zepto
order by
	category;

-- No. of products in stock

select
	count(sku_id) as in_stock_items
from zepto
where
	outofstock = 'false';  -- 3279

-- No. of products out of stock

select
	count(sku_id) as out_of_stock_items
from zepto
where
	outofstock = 'true';   -- 453

-- No of items in stock v/s out of stock

select
	outofstock as items_out_of_stock,
	count(sku_id)
from zepto
group by 
	outofstock;

-- Number of different Products in stock

select
	name,
	count(sku_id) as number_of_items_in_stock
from zepto
where 
	outofstock = 'false'
group by
	name;


-- Answering Business Questions

-- Q1. Find top 10 best value products based on discount percentage.

select
	distinct name,
	mrp,
	discountpercent,
	discountedsp
from zepto
order by
	discountpercent desc
limit 10;

-- Max discount offered on food items which might be to avoid wastage


-- Q2. What are the products with high mrp and are out of stock?

select
	distinct name,
	mrp,
	outofstock
from zepto
where
	outofstock = 'true'
	and
	mrp > 200
order by mrp desc;

-- Zepto should restock these items, since despite having high mrp they have high demands, thus, may lead to higher profit


-- Q3. Calculate revenue for each category.

select 
	distinct category,
	sum(discountedsp * availablequantity) as total_revenue
from zepto
group by 
	category
order by
	total_revenue desc;

-- Categories related to food, like cooking essentials, have the highest revenue since they are used regularly on daily basis


-- Q4. Find all products with mrp greater than 500 and discountpercent less than 10%.

select
	distinct name,
	mrp,
	discountpercent
from zepto
where
	mrp > 500
	and
	discountpercent < 10
order by 
	discountpercent desc,
	mrp desc;

-- It is observed that the daily essential products offer least discount with high mrp since their demand is unaffected by price. People buy them due to their daily requirements.


-- Q5. Find top 5 categories offering highest average discount percentage.

select
	distinct category,
	round(avg(discountpercent),2) as avg_discount_offered
from zepto
group by
	category
order by
	avg_discount_offered desc;

-- It is observed that the categories related to food items offer highest average discount to avoid wastage of product and loss to Zepto


-- Q6. Group the products into categories - low, medium, bulk

select
	distinct category,
	case
		when weight <= 500 then 'low'
		when weight < 1000 then 'medium'
		when weight >= 1000 then 'bulk'
	end as weight_category
from zepto
order by
	weight_category;