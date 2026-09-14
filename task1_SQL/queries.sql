/* 1.
Вывести количество фильмов в каждой категории, отсортированное по убыванию.
*/
select
	category.name,
	count(film_category.film_id)
from
	category
inner join film_category on
	film_category.category_id = category.category_id
group by
	category.category_id,
	category.name
order by
	2 desc;


/* 2.
Вывести 10 актеров, чьи фильмы арендовали больше всего раз, отсортированных по убыванию.
*/
select
	a.first_name,
	a.last_name,
	count(*) as count_of_rents
from
	actor a
inner join film_actor fa 
on
	fa.actor_id = a.actor_id
inner join inventory i
on
	i.film_id = fa.film_id
inner join rental r
on
	i.inventory_id = r.inventory_id
group by
	a.actor_id,
	a.first_name,
	a.last_name
order by
	count_of_rents desc
limit 10;



/* 3.
Вывести категорию фильмов, на которую было потрачено больше всего денег.
*/
select
	c.name
from
	category c
join film_category fc on
	fc.category_id = c.category_id
join film f on
	f.film_id = fc.film_id
group by
	c.category_id,
	c.name
order by
	sum(f.replacement_cost) desc
limit 1;


/* 4.
Вывести названия фильмов, которых нет в инвентаре (таблице inventory). 
Напишите запрос без использования оператора IN.
*/
select
	f.title
from
	film f
where
	not exists(
	select 1 
	from inventory i 
	where f.film_id = i.film_id);

/* 5.
Вывести топ-3 актеров, которые чаще всего появлялись в фильмах категории «Children». 
Если у нескольких актеров одинаковое количество фильмов, вывести их всех.
*/
/* 5.
Вывести топ-3 актеров, которые чаще всего появлялись в фильмах категории «Children». 
Если у нескольких актеров одинаковое количество фильмов, вывести их всех.
*/
with t as (
select
	a.first_name,
	a.last_name,
	dense_rank() over (
order by
	count(fa.film_id) desc) as ranked_actors,
	count(fa.film_id) as films_count
from
	actor a
join film_actor fa on
	fa.actor_id = a.actor_id
join film_category fc on
	fc.film_id = fa.film_id
join category ca on
	ca.category_id = fc.category_id
where
	ca.name = 'Children'
group by
	a.actor_id,
	a.first_name,
	a.last_name
order by
	ranked_actors asc)
select
	*
from
	t
where
	t.ranked_actors <= 3;


/* 6.
Вывести города с количеством активных и неактивных клиентов 
(активный клиент — customer.active = 1). 
Отсортировать по количеству неактивных клиентов по убыванию.
*/
select
	c2.city ,
	count(*) filter (where c.active = 1) as activ,
	count(*) filter (where c.active = 0) as pas
from
	customer c
join address a on
	a.address_id = c.address_id
join city c2 on
	a.city_id = c2.city_id
group by
	c2.city_id,
	c2.city
order by
	pas desc;


/* 7.
Вывести категорию фильмов, которая имеет наибольшее количество 
общих часов аренды в городе (где customer.address_id привязан к 
этому городу) и название которого начинается на букву «A». Сделать то же 
самое для городов, в названии которых есть дефис («-»). Написать всё в одном запросе.
*/

with city_A as(
select ci.city, address.address_id from city ci
join address on address.city_id = ci.city_id 
where ci.city like 'A%' or ci.city like '%-%'
),
t1 as (
select
	city_A.city as A_city,
	c.name,
	sum(extract(epoch from (r.return_date - r.rental_date)) / 3600) as hours_rent
from
	category c
join film_category fc on
	fc.category_id = c.category_id
join inventory i on
	i.film_id = fc.film_id
join rental r on
	r.inventory_id = i.inventory_id
join customer cu on
	cu.customer_id = r.customer_id
join city_A on
	city_A.address_id = cu.address_id
group by
	c.name,
	city_A.city
)

select
	distinct on
	(t1.A_city) *
from
	t1
order by
	t1.A_city,
	t1.hours_rent desc nulls last;



