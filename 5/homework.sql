--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Cделайте запрос к таблице payment. 
--Пронумеруйте все продажи от 1 до N по дате продажи.
select *, row_number() over (order by p.payment_date)
from payment p 

--ЗАДАНИЕ №2
--Используя оконную функцию добавьте колонку с порядковым номером
--продажи для каждого покупателя,
--сортировка платежей должна быть по дате платежа.
select 
	*, 
	row_number() over (order by p.payment_date) payment_no,
	row_number() over (partition by p.customer_id order by p.payment_date) customer_payment_no
from payment p;

--ЗАДАНИЕ №3
--Для каждого пользователя посчитайте нарастающим итогом сумму всех его платежей,
--сортировка платежей должна быть по дате платежа.
select 
	*, 
	sum(p.amount) over (partition by p.customer_id order by p.payment_date) payment_sum
from payment p;

--ЗАДАНИЕ №4
--Для каждого покупателя выведите данные о его последней оплате аренде.
select * from payment p2 
where p2.payment_id in (
	select
		last_value(p.payment_id) over (partition by p.customer_id)
	from payment p
	)
order by p2.customer_id;

-- нижеследующие варианты тоже имеют право на жизнь, кмк
with last_payment_cte as (
	select p.customer_id, max(p.payment_date) last_payment_date
	from payment p 
	group by p.customer_id 
)
select p.* from payment p 
inner join last_payment_cte lpc on lpc.customer_id = p.customer_id and lpc.last_payment_date = p.payment_date
order by p.customer_id;

select * from payment p 
where (p.customer_id, p.payment_date) in (select customer_id, max(payment_date) from payment group by customer_id)
order by p.customer_id;



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника магазина
--стоимость продажи из предыдущей строки со значением по умолчанию 0.0
--с сортировкой по дате продажи
select
	* , 
	coalesce(lag(amount) over (partition by p.staff_id order by p.payment_date), 0.00) lag_amount
from 
	payment p
order by p.payment_date, p.staff_id;



--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за март 2007 года
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (дата без учета времени)
--с сортировкой по дате продажи
select distinct
	p.staff_id, 
	date_trunc('day', p.payment_date) dt,
	sum(p.amount) over (partition by p.staff_id order by date_trunc('day', p.payment_date)) 
from payment p 
where date_trunc('month', p.payment_date) = '2007-03-01' 
order by dt;

--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм
with count_rents as(
select distinct 
		c.customer_id,
		c3.country,
		count(r.rental_id) over (partition by (r.customer_id)) rent_count
	from rental r
	inner join customer c using(customer_id)
	inner join address a using(address_id)
	inner join city c2 using(city_id)
	inner join country c3 using(country_id)
),
last_rents as(
select distinct 
		c.customer_id,
		c3.country,
		last_value(r.rental_id) over (order by r.customer_id) as last_rental
	from rental r
	inner join customer c using(customer_id)
	inner join address a using(address_id)
	inner join city c2 using(city_id)
	inner join country c3 using(country_id)
),
sum_payment as(
select distinct 
		c.customer_id,
		c3.country,
		sum(p.amount) over (partition by (p.customer_id)) sum_payment
	from payment p 
	inner join customer c using(customer_id)
	inner join address a using(address_id)
	inner join city c2 using(city_id)
	inner join country c3 using(country_id)
),
max_count as(
	select distinct
		country,
		max(rent_count) max_rc
	from count_rents
	group by country
),
max_sum as(
	select distinct
		country,
		max(sum_payment) max_sum
	from sum_payment
	group by country
),
last_rental as(
	select distinct
		country,
		max(last_rental) max_lr
	from last_rents
	group by country
),
q1 as(select  
	cr.country,
	cr.customer_id max_rental_customer
from max_count mc
join count_rents cr on cr.country = mc.country and cr.rent_count = mc.max_rc
),
q2 as(select 
	sm.country,
	sm.customer_id max_paid_customer
from sum_payment sm
join max_sum ms on sm.country = ms.country and sm.sum_payment = ms.max_sum
),
q3 as(select 
	lr.country,
	lr.customer_id last_rental_customer
from last_rents lr
join last_rental lc on lr.country = lc.country and lr.last_rental = lc.max_lr
)
select * from q1
join q2 using(country)
join q3 using(country);

---УФФФФ!!!!
