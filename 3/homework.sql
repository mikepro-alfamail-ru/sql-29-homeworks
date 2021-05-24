--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

-- inner join, т.к. у всех покупателей заполнены города, у всех городов - страны. Соответствующие поля Not Null
-- Если будут заполнены не у всех, то, думаю, нужен left join, чтоб не потерять покупателей беза адреса
select 
	c.first_name || ' ' || c.last_name "customer",
	a.address, 
	city.city, 
	country.country
from 
	customer c
inner join 
	address a using(address_id)
inner join 
	city using(city_id)
inner join 
	country using(country_id);


--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.


select 
	s.store_id, 
	count(c.customer_id) "customer_count"
from 
	customer c
inner join 
	store s using(store_id)
group by 
	s.store_id ;

	
--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.


select 
	s.store_id, 
	count(c.customer_id)  "customer_count"
from 
	customer c
inner join 
	store s using(store_id)
group by 
	s.store_id 
having 
	count(c.customer_id) >300;


-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

select 
	s.store_id, 
	c2.city,
	s2.first_name || ' ' || s2.last_name "manager",
	count(customer_id)
from 
	customer c
inner join 
	store s using(store_id)
inner join 
	address a on a.address_id = s.address_id 
inner join 
	city c2 on c2.city_id = a.city_id
inner join 
	staff s2 on s.manager_staff_id = s2.staff_id 
group by 
	1, 2, 3
having 
	count(c.customer_id) >300;



--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

select 
	count(r.rental_id), 
	c.first_name ||' ' || c.last_name "customer"
from 
	rental r 
inner join 
	customer c using(customer_id)
group by 
	r.customer_id, 2
order by 
	count(r.rental_id) desc
limit 5



--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

select 
	c.first_name || ' ' || c.last_name "customer_name",
	count(r.rental_id),
	sum(p.amount),
	min(p.amount),
	max(p.amount)
from 
	customer c 
left join 
	rental r using(customer_id)
left join 
	payment p using(customer_id)
group by
	c.customer_id;



--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.

select 
	c.city, 
	c2.city 
from 
	city c 
cross join city c2
where 
	c.city_id != c2.city_id;



--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 
select 
	c.first_name || ' ' || c.last_name customer_name,
	avg(r.return_date::date - r.rental_date::date) avg_days
from 
	rental r 
inner join customer c using(customer_id)
group by
	c.customer_id 
order by customer_name;


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.

select 
	f.title,
	count(r.rental_id),
	sum(p.amount) 
from 
	rental r 
inner join inventory i using(inventory_id)
inner join film f on i.film_id = f.film_id
inner join payment p on p.rental_id = r.rental_id 
group by f.film_id;

	


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.


select 
	f.title,
	count(r.rental_id),
	sum(p.amount) 
from 
	rental r 
inner join inventory i using(inventory_id)
right join film f on i.film_id = f.film_id
left join payment p on p.rental_id = r.rental_id 
group by f.film_id
having count(r.rental_id) = 0;



--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".

select 
	s.first_name || ' ' || s.last_name manager,
	sum(p.amount),
	case 
		when sum(p.amount) > 7300
		then 'Да'
		else 'Нет'
	end "Премия"
from 
	payment p 
inner join staff s using(staff_id)
group by 1, p.staff_id;





