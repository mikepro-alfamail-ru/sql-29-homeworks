--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
explain analyze
select * from film f 
where f.special_features @> array['Behind the Scenes']
--Seq Scan on film f  (cost=0.00..66.50 rows=538 width=384) (actual time=0.024..0.680 rows=538 loops=1)

--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
explain analyze
select * from film f 
where (select array_position(f.special_features, 'Behind the Scenes')) is not null;
--Seq Scan on film f  (cost=0.00..76.50 rows=995 width=384) (actual time=0.027..0.692 rows=538 loops=1)

explain analyze
select * from film f 
where 'Behind the Scenes' = any(f.special_features);
-- Seq Scan on film f  (cost=0.00..76.50 rows=538 width=384) (actual time=0.015..0.371 rows=538 loops=1)




--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.
explain analyze
with bts_films as (
	select * from film f 
	where f.special_features @> array['Behind the Scenes']
	)
select
	c.customer_id,
	count(r.rental_id) rent_count
from customer c 
join rental r using(customer_id)
join inventory i using(inventory_id)
join bts_films bf using(film_id)
group by c.customer_id;
--- HashAggregate  (cost=684.64..690.63 rows=599 width=12) (actual time=14.933..15.029 rows=599 loops=1)

--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

explain analyze 
select
	c.customer_id,
	count(r.rental_id) rent_count
from customer c 
join rental r using(customer_id)
join inventory i using(inventory_id)
join (select * from film f 
	where f.special_features @> array['Behind the Scenes']) bf using(film_id)
group by c.customer_id;
--- HashAggregate  (cost=684.64..690.63 rows=599 width=12) (actual time=14.519..14.595 rows=599 loops=1)

--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления
create materialized view bts_rent_count_by_customer as
select
	c.customer_id,
	count(r.rental_id) rent_count
from customer c 
join rental r using(customer_id)
join inventory i using(inventory_id)
join (select * from film f 
	where f.special_features @> array['Behind the Scenes']) bf using(film_id)
group by c.customer_id;

refresh materialized view bts_rent_count_by_customer;

--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
Оператор '@>' имеет наименьший cost 

--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса
Выходит одинаково. 
В случае использования оконных функций оба варианта замедляются

