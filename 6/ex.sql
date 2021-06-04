--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc

/*
Unique  (cost=1089.36..1089.40 rows=5 width=44) (actual time=63.089..64.324 rows=600 loops=1)
  ->  Sort  (cost=1089.36..1089.38 rows=5 width=44) (actual time=63.088..63.548 rows=8632 loops=1)
        Sort Key: (count(r.inventory_id) OVER (?)) DESC, ((((cu.first_name)::text || ' '::text) || (cu.last_name)::text))
        Sort Method: quicksort  Memory: 1058kB
        ->  WindowAgg  (cost=1089.19..1089.30 rows=5 width=44) (actual time=53.701..58.385 rows=8632 loops=1)
              ->  Sort  (cost=1089.19..1089.20 rows=5 width=21) (actual time=53.684..54.277 rows=8632 loops=1)
                    Sort Key: cu.customer_id
                    Sort Method: quicksort  Memory: 1057kB
                    ->  Nested Loop Left Join  (cost=81.09..1089.13 rows=5 width=21) (actual time=0.637..49.803 rows=8632 loops=1)
                    Джойн вложенным циклом, очень дорого, сравнивает каждое значение из одной таблицы с каждым из другой
                    
                          ->  Nested Loop Left Join  (cost=80.82..1087.66 rows=5 width=6) (actual time=0.626..34.217 rows=8632 loops=1)
                                ->  Subquery Scan on inv  (cost=76.50..995.42 rows=5 width=4) (actual time=0.593..8.754 rows=2494 loops=1)
                                      Filter: (inv.sf_string ~~ '%Behind the Scenes%'::text)
                                      Rows Removed by Filter: 7274
                                      !!!!!
!!!!                                  !!!!!  Затратное сравнение строки
                                      !!!!!
                                      ->  ProjectSet  (cost=76.50..422.80 rows=45810 width=710) (actual time=0.590..6.922 rows=9768 loops=1)
                                            ->  Hash Full Join  (cost=76.50..159.39 rows=4581 width=63) (actual time=0.584..3.033 rows=4623 loops=1)
                                                  Hash Cond: (i.film_id = f.film_id)
                                                  ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.011..0.703 rows=4581 loops=1)
                                                  ->  Hash  (cost=64.00..64.00 rows=1000 width=63) (actual time=0.553..0.554 rows=1000 loops=1)
                                                        Buckets: 1024  Batches: 1  Memory Usage: 104kB
                                                        ->  Seq Scan on film f  (cost=0.00..64.00 rows=1000 width=63) (actual time=0.016..0.396 rows=1000 loops=1)
                                ->  Bitmap Heap Scan on rental r  (cost=4.32..18.41 rows=4 width=6) (actual time=0.005..0.007 rows=3 loops=2494)
                                      Recheck Cond: (inventory_id = inv.inventory_id)
                                      Heap Blocks: exact=8602
                                      ->  Bitmap Index Scan on idx_fk_inventory_id  (cost=0.00..4.32 rows=4 width=0) (actual time=0.003..0.003 rows=3 loops=2494)
                                            Index Cond: (inventory_id = inv.inventory_id)
                          ->  Index Scan using customer_pkey on customer cu  (cost=0.28..0.30 rows=1 width=17) (actual time=0.001..0.001 rows=1 loops=8632)
                                Index Cond: (customer_id = r.customer_id)
Planning Time: 0.733 ms
Execution Time: 64.532 ms
*/

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


/*
HashAggregate  (cost=684.64..690.63 rows=599 width=12) (actual time=15.018..15.091 rows=599 loops=1)
Группировка с использованием временной хэш-таблицы

  Group Key: c.customer_id
  Batches: 1  Memory Usage: 105kB
  ->  Hash Join  (cost=223.78..641.48 rows=8632 width=8) (actual time=2.278..13.470 rows=8608 loops=1)
  Хеш-соединение загружает записи-кандидаты с одной стороны соединения в хеш-таблицу, которая затем проверяется для 
  каждой строки с другой стороны соединения. Операция используется всегда, когда невозможно применить другие виды 
  соединения: если соединяемые наборы данных достаточно велики и/или наборы данных не упорядочены по столбцам соединения.
        
      Hash Cond: (r.customer_id = c.customer_id)
        ->  Hash Join  (cost=201.30..596.19 rows=8632 width=6) (actual time=2.053..11.657 rows=8608 loops=1)
              Hash Cond: (i.film_id = f.film_id)
              ->  Hash Join  (cost=128.07..480.67 rows=16044 width=8) (actual time=1.261..8.717 rows=16044 loops=1)
                    Hash Cond: (r.inventory_id = i.inventory_id)
                    ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=10) (actual time=0.018..1.845 rows=16044 loops=1)
Операция сканирует всю таблицу в порядке, в котором она хранится на диске. 

                    ->  Hash  (cost=70.81..70.81 rows=4581 width=6) (actual time=1.219..1.220 rows=4581 loops=1)
Хэширует inventory если я правильно понял

                          Buckets: 8192  Batches: 1  Memory Usage: 234kB
                          ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.012..0.716 rows=4581 loops=1)
              ->  Hash  (cost=66.50..66.50 rows=538 width=4) (actual time=0.779..0.779 rows=538 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 27kB
                    ->  Seq Scan on film f  (cost=0.00..66.50 rows=538 width=4) (actual time=0.018..0.718 rows=538 loops=1)
                          Filter: (special_features @> '{"Behind the Scenes"}'::text[])
                          Rows Removed by Filter: 462
        ->  Hash  (cost=14.99..14.99 rows=599 width=4) (actual time=0.200..0.200 rows=599 loops=1)
              Buckets: 1024  Batches: 1  Memory Usage: 30kB
              ->  Seq Scan on customer c  (cost=0.00..14.99 rows=599 width=4) (actual time=0.016..0.135 rows=599 loops=1)
Planning Time: 1.081 ms
Execution Time: 15.231 ms
 * 
 */



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

with q1 as(
with max_films_rented as 
(
	with rents_by_date as 
	(
		select r2.rental_id, r2.staff_id, r2.rental_date::date r_date
		from rental r2
	)
	select 
		s.store_id,
		r.r_date, 
		count(r.rental_id) r_count
	from 
		store s
	join staff s2 on s2.store_id = s.store_id 
	join rents_by_date r on r.staff_id = s2.staff_id 
	group by s.store_id, r.r_date
)
select mfr.store_id, mfr.r_count, mfr.r_date
from max_films_rented mfr 
where (mfr.store_id, mfr.r_count) in (
	select
		mfr2.store_id, 
		max(mfr2.r_count)
	from max_films_rented mfr2
	group by mfr2.store_id
	)
),
q2 as(
with max_films_rented as 
(
	with rents_by_date as 
	(
		select r2.rental_id, r2.staff_id, r2.rental_date::date r_date1
		from rental r2
	)
	select 
		s.store_id,
		r.r_date1, 
		sum(p.amount) p_amount
	from 
		store s
	join staff s2 on s2.store_id = s.store_id 
	join rents_by_date r on r.staff_id = s2.staff_id 
	join payment p on p.rental_id = r.rental_id 
	group by s.store_id, r.r_date1
)
select mfr.store_id, mfr.p_amount, mfr.r_date1
from max_films_rented mfr 
where (mfr.store_id, mfr.p_amount) in (
	select
		mfr2.store_id, 
		min(mfr2.p_amount)
	from max_films_rented mfr2
	group by mfr2.store_id
	)
)
select 
	q1.store_id "Магазин", 
	q1.r_count "Максимально аренд", 
	q1.r_date "Дата макс.аренд",
	q2.p_amount "Минимально выручки", 
	q2.r_date1 "Дата аренд по мин. выручке"
from q1
join q2 on q1.store_id = q2.store_id
order by q1.store_id;
