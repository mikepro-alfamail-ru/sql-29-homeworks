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
with finally as (
	with max_by_customer as(
		select distinct
			r.customer_id,
			c2.country_id,
			count(r.rental_id) over (partition by (r.customer_id)) max_rents,
			sum(p.amount) over (partition by (p.customer_id)) pay_amount,
			last_value(r.rental_id)  over (partition by (r.customer_id)) last_rent
		from customer c 
		inner join address a using(address_id)
		inner join city c2 using(city_id)
		inner join rental r on c.customer_id = r.customer_id 
		right join payment p on p.customer_id = c.customer_id 
	),
	max_by_country as (
		select
			mrc.country_id,
			max(mrc.max_rents) max_rent_count,
			max(mrc.pay_amount) max_pay_amount,
			max(mrc.last_rent) max_last_rent
		from max_by_customer mrc
		group by mrc.country_id
	)
	select distinct
		c3.country cnt,
		array_agg(mc1.customer_id) ma, 
		array_agg(mc2.customer_id) mp, 
		array_agg(mc3.customer_id) la
	from country c3 
	join max_by_country mc0 on c3.country_id = mc0.country_id
	join max_by_customer mc1 on mc0.country_id = mc1.country_id and mc0.max_rent_count = mc1.max_rents
	join max_by_customer mc2 on mc0.country_id = mc1.country_id and mc0.max_pay_amount = mc2.pay_amount
	join max_by_customer mc3 on mc0.country_id = mc1.country_id and mc0.max_last_rent = mc3.last_rent
	group by c3.country
)
select 
	cnt "Страна",
	array(select distinct * from unnest(ma)) "Макс аренд",
	array(select distinct * from unnest(mp)) "Макс платеж",
	array(select distinct * from unnest(la)) "Последняя аренда"
from finally;

---УФФФФ!!!!
