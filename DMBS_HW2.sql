-- Erin Zahner 
-- Homework 2

use hw2;

-- Average Price of Food at Each Restaurant
select restaurants.name,
avg(foods.price) as avg_price
from serves
join restaurants on serves.restID = restaurants.restID
join foods on serves.foodID = foods.foodID
group by restaurants.restID, restaurants.name;


-- Maximum Food Price at Each Restaurant
select restaurants.name,
max(foods.price) as max_price
from serves
join restaurants on serves.restID = restaurants.restID
join foods on serves.foodID = foods.foodID
group by restaurants.restID, restaurants.name;


-- Count of Different Food Types Served at Each Restaurant
select restaurants.name,
count(distinct foods.type) as count_type
from serves
join restaurants on serves.restID = restaurants.restID
join foods on serves.foodID = foods.foodID
group by restaurants.restID, restaurants.name;


-- Average Price of Foods Served by Each Chef
select chefs.name,
avg(foods.price) as avg_price
from works
join chefs on works.chefID = chefs.chefID
join restaurants on works.restID = restaurants.restID
join serves on restaurants.restID = serves.restID
join foods on serves.foodID = foods.foodID
group by chefs.name;


-- Find the Restaurant with the Highest Average Food Price 
select restaurants.name,
avg(foods.price) as avg_price
from serves
join restaurants on serves.restID = restaurants.restID
join foods on serves.foodID = foods.foodID
group by restaurants.restID, restaurants.name
order by avg_price desc;


/* Determine which chef has the highest average price of the foods served at 
   the restaurants where they work. Include the chef’s name, the average food price, 
   and the names of the restaurants where the chef works. Sort the  results by the 
   average food price in descending order.
*/

select chefs.name,
group_concat(distinct restaurants.name order by restaurants.name),
avg(foods.price) as avg_price
from works
join chefs on works.chefID = chefs.chefID
join restaurants on works.restID = restaurants.restID
join serves on restaurants.restID = serves.restID
join foods on serves.foodID = foods.foodID
group by chefs.chefID, chefs.name
order by avg_price desc;

