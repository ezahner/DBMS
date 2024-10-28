/*
DB Assignment 4
Erin Zahner
31 October 2024
*/

-- make composite unique for rental
alter table rental
add constraint unique_combination 
unique (rental_date(20), inventory_id, customer_id);

-- ----------------------------------------------------------------------------------------------------------------------------
-- add all constraints
-- ----------------------------------------------------------------------------------------------------------------------------


-- check category names 
alter table category
add constraint chk_category_name
check (name in ('animation', 'comedy', 'family', 'foreign', 'sci-fi', 'travel', 'children', 'drama', 'horror', 'action', 'classics', 'games', 'new', 'documentary', 'sports', 'music'));

-- check special features, duration, rate, length, rating, and replacement cost
alter table film
add constraint chk_special_features
check (special_features in ('behind the scenes', 'commentaries', 'deleted scenes', 'trailers')),
add constraint chk_rental_duration
check (rental_duration between 2 and 8),
add constraint chk_rental_rate
check (rental_rate between 0.99 and 6.99),
add constraint chk_length
check (length between 30 and 200),
add constraint chk_rating
check (rating in ('pg', 'g', 'nc-17', 'pg-13', 'r')),
add constraint chk_replacement_cost
check (replacement_cost between 5.00 and 100.00);

-- active constraints for customer and staff
alter table customer
add constraint chk_active
check (active in (0, 1));

alter table staff
add constraint chk_staff_active
check (active in (0, 1));

-- make sure payment amount is greater than 0
alter table payment
add constraint chk_amount
check (amount >= 0);

-- ----------------------------------------------------------------------------------------------------------------------------
-- Homework Questions 
-- ----------------------------------------------------------------------------------------------------------------------------


-- What is the average length of films in each category? List the results in alphabetic order of categories.
select c.name as category, avg(f.length) as average_length
from film f
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id
group by c.name
order by c.name;


-- Which categories have the longest and shortest average film lengths?
(select c.name as category, avg(f.length) as average_length
from film f
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id
group by c.name
order by average_length asc
limit 1)
union all
(select c.name as category, avg(f.length) as average_length
from film f
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id
group by c.name
order by average_length desc
limit 1);


-- Which customers have rented action but not comedy or classic movies?
select distinct c.customer_id, c.first_name, c.last_name
from customer c
join rental r on c.customer_id = r.customer_id
join inventory i on r.inventory_id = i.inventory_id
join film_category fc on i.film_id = fc.film_id
join category cat on fc.category_id = cat.category_id
where cat.name = 'Action'
and c.customer_id not in (
    select r.customer_id
    from rental r
    join inventory i on r.inventory_id = i.inventory_id
    join film_category fc on i.film_id = fc.film_id
    join category cat on fc.category_id = cat.category_id
    where cat.name in ('Comedy', 'Classics')
);


-- Which actor has appeared in the most English-language movies?
select a.actor_id, a.first_name, a.last_name, count(f.film_id) as film_count
from actor a
join film_actor fa on a.actor_id = fa.actor_id
join film f on fa.film_id = f.film_id
join language l on f.language_id = l.language_id
where l.name = 'English'
group by a.actor_id, a.first_name, a.last_name
order by film_count desc
limit 1;


-- How many distinct movies were rented for exactly 10 days from the store where Mike works?
select count(distinct f.film_id) as distinct_movies_rented
from rental r
join inventory i on r.inventory_id = i.inventory_id
join film f on i.film_id = f.film_id
join staff s on i.store_id = s.store_id
where s.first_name = 'Mike'
and datediff(r.return_date, r.rental_date) = 10;



-- Alphabetically list actors who appeared in the movie with the largest cast of actors.
with film_cast_count as (
    select fa.film_id, count(fa.actor_id) as actor_count
    from film_actor fa
    group by fa.film_id
),
max_cast_film as (
    select film_id
    from film_cast_count
    where actor_count = (select max(actor_count) from film_cast_count)
)
select a.first_name, a.last_name
from actor a
join film_actor fa on a.actor_id = fa.actor_id
join max_cast_film mcf on fa.film_id = mcf.film_id
order by a.last_name, a.first_name;



