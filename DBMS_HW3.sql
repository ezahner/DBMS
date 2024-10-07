/*
DB Assignment 3
Erin Zahner
8 October 2024
*/

create database hw3;
use hw3;

-- Add constraints to the products table
alter table products
add constraint chk_product_name check (name in ('Printer', 'Ethernet Adapter', 'Desktop', 'Hard Drive', 'Laptop', 'Router', 'Network Card', 'Super Drive', 'Monitor')),
add constraint chk_product_category check (category in ('Peripheral', 'Networking', 'Computer'));

-- Add constraints to the sell table
alter table sell
add constraint chk_sell_price check (price between 0 and 100000),
add constraint chk_quantity_available check (quantity_available between 0 and 1000);

-- Add constraints to the orders table
alter table orders
add constraint chk_shipping_method check (shipping_method in ('UPS', 'FedEx', 'USPS')),
add constraint chk_shipping_cost check (shipping_cost between 0 and 500);

-- Add a valid date constraint to the place table
alter table place
add constraint chk_order_date check (order_date >= '1900-01-01' and order_date <= '2024-12-31');





-- List names and sellers of products that are no longer available (quantity=0)
select products.name as product_name, 
	merchants.name as seller_name
from products
join sell on products.pid = sell.pid
join merchants on sell.mid = merchants.mid
where sell.quantity_available = 0;


-- List names and descriptions of products that are not sold.
select products.name, products.description
from products
left join sell on products.pid = sell.pid
where sell.pid is null;



-- How many customers bought SATA drives but not any routers?
select count(distinct place.cid) as num_customers
from place
join contain on place.oid = contain.oid
join products on contain.pid = products.pid
where products.name like '%SATA%'
	and place.cid not in (
		select place.cid
        from place
        join contain on place.oid = contain.oid
        join products on contain.pid = products.pid
        where products.description like '%Router%'
    );
    
    
    
    
    
-- HP has a 20% sale on all its Networking products.
select sell.pid, (sell.price * 0.80) as discount_price
from sell 
join merchants on sell.mid = merchants.mid
where merchants.name = 'HP'
  and sell.pid in (
      select products.pid 
      from products   
      where products.category = 'Networking'
  );
  

-- What did Uriel Whitney order from Acer? (make sure to at least retrieve product names and prices).
select products.name as product_name, sell.price
from customers 
join place on customers.cid = place.cid
join contain on place.oid = contain.oid
join products on contain.pid = products.pid
join sell  on products.pid = sell.pid
join merchants on sell.mid = merchants.mid
where customers.fullname = 'Uriel Whitney'
and merchants.name = 'Acer';


-- List the annual total sales for each company (sort the results along the company and the year attributes).
select merchants.name as company_name, year(place.order_date) as year, sum(sell.price * sell.quantity_available) as total_sales
from merchants
join sell on merchants.mid = sell.mid
join contain on sell.pid = contain.pid
join place on contain.oid = place.oid
group by merchants.name, year(place.order_date)
order by merchants.name, year;


-- Which company had the highest annual revenue and in what year?
select merchants.name as company_name, year(place.order_date) as year, sum(sell.price * sell.quantity_available) as total_sales
from merchants
join sell on merchants.mid = sell.mid
join contain on sell.pid = contain.pid
join place on contain.oid = place.oid
group by merchants.name, year(place.order_date)
order by total_sales desc
limit 1;


-- On average, what was the cheapest shipping method used ever?
select shipping_method, avg(shipping_cost) as average_cost
from orders
group by shipping_method
order by average_cost
limit 1;


-- What is the best sold ($) category for each company?
select company_name, category, total_sales
from (
    select merchants.name as company_name, products.category, sum(sell.price * sell.quantity_available) as total_sales
    from merchants
    join sell on merchants.mid = sell.mid
    join contain on sell.pid = contain.pid
    join products on sell.pid = products.pid
    group by merchants.name, products.category
) as category_sales
where (company_name, total_sales) in (
    select company_name, max(total_sales)
    from (
        select merchants.name as company_name, products.category, sum(sell.price * sell.quantity_available) as total_sales
        from merchants
        join sell on merchants.mid = sell.mid
        join contain on sell.pid = contain.pid
        join products on sell.pid = products.pid
        group by merchants.name, products.category
    ) as grouped_sales
    group by company_name
)
order by company_name;




-- For each company find out which customers have spent the most and the least amounts.
select company_name, customer_name, total_spent
from (
    select merchants.name as company_name, customers.fullname as customer_name, sum(sell.price * sell.quantity_available) as total_spent
    from merchants
    join sell on merchants.mid = sell.mid
    join contain on sell.pid = contain.pid
    join orders on contain.oid = orders.oid
    join place on orders.oid = place.oid
    join customers on place.cid = customers.cid
    group by merchants.name, customers.fullname
) as customer_spending
where (company_name, total_spent) in (
    select company_name, max(total_spent)
    from (
        select merchants.name as company_name, customers.fullname as customer_name, sum(sell.price * sell.quantity_available) as total_spent
        from merchants
        join sell on merchants.mid = sell.mid
        join contain on sell.pid = contain.pid
        join orders on contain.oid = orders.oid
        join place on orders.oid = place.oid
        join customers on place.cid = customers.cid
        group by merchants.name, customers.fullname
    ) as spending_per_customer
    group by company_name
)
or (company_name, total_spent) in (
    select company_name, min(total_spent)
    from (
        select merchants.name as company_name, customers.fullname as customer_name, sum(sell.price * sell.quantity_available) as total_spent
        from merchants
        join sell on merchants.mid = sell.mid
        join contain on sell.pid = contain.pid
        join orders on contain.oid = orders.oid
        join place on orders.oid = place.oid
        join customers on place.cid = customers.cid
        group by merchants.name, customers.fullname
    ) as spending_per_customer
    group by company_name
)
order by company_name, total_spent desc;
