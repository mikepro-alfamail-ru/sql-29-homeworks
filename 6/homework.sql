--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
select * from film f 
where f.special_features @> array['Behind the Scenes']




--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
select * from film f 
where (select array_position(f.special_features, 'Behind the Scenes')) is not null;

select * from film f 
where 'Behind the Scenes' = any(f.special_features);





--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.
with bts_films as (
	select * from film f 
	where f.special_features @> array['Behind the Scenes']
	)
select distinct
	c.customer_id,
	count(r.rental_id) over (partition by c.customer_id) rent_count
from customer c 
join rental r using(customer_id)
join inventory i using(inventory_id)
join bts_films bf using(film_id)




--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

select distinct
	c.customer_id,
	count(r.rental_id) over (partition by c.customer_id) rent_count
from customer c 
join rental r using(customer_id)
join inventory i using(inventory_id)
join (select * from film f 
	where f.special_features @> array['Behind the Scenes']) bf using(film_id);



--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления
create materialized view bts_rent_count_by_customer as
select distinct
	c.customer_id,
	count(r.rental_id) over (partition by c.customer_id) rent_count
from customer c 
join rental r using(customer_id)
join inventory i using(inventory_id)
join (select * from film f 
	where f.special_features @> array['Behind the Scenes']) bf using(film_id);

refresh materialized view bts_rent_count_by_customer;

