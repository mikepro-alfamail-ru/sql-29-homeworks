--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.
with first_rent_by_staff as (
select distinct 
	s.staff_id,
	first_value(r.rental_id) over (partition by (s.staff_id)) first_rent
from rental r 
join staff s on s.staff_id = r.staff_id
)
select r2.* from rental r2 
join first_rent_by_staff fr on fr.first_rent = r2.rental_id;

--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день
select distinct
	s2.store_id,
	date_trunc('day', r.rental_date) "day",
	count(r.rental_id) over (partition by date_trunc('day', r.rental_date), s2.store_id) rents_count,
	count(f.film_id) over (partition by date_trunc('day', r.rental_date), s2.store_id) films_count,
	sum(p.amount) over (partition by date_trunc('day', r.rental_date), s2.store_id) sell_sum
from rental r 
join staff s using(staff_id)
join store s2 using(store_id)
join inventory i on r.inventory_id = i.inventory_id 
join film f using(film_id)
join payment p on p.rental_id = r.rental_id 
