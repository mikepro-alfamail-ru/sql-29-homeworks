--=============== МОДУЛЬ 2. РАБОТА С БАЗАМИ ДАННЫХ =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия регионов из таблицы адресов

select 
	distinct district 
from 
	address
where 
	district != ''
order by 
	district;



--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те регионы, 
--названия которых начинаются на "K" и заканчиваются на "a", и названия не содержат пробелов

select 
	distinct district 
from 
	address
where 
	district like 'K%a' and district not like '% %'
order by 
	district;
	

--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 марта 2007 года по 19 марта 2007 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.

select 
	payment_id, payment_date, amount 
from 
	payment
where 
	payment_date between '2007-03-17 0:0:0' and '2007-03-19 23:59:59'
and
	amount >= 1
order by 
	payment_date;



--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.

select
	payment_id, payment_date, amount 
from 
	payment
order by 
	payment_id desc
/* 
 * Можно сортировать по payment_date, но в таблице очень много записей
 * с одинаковым значением в этом поле, так что на мой взгляд сортировать
 * по payment_id правильней
 */	
limit 10;


--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.

select 
	first_name||' '||last_name as "Фамилия и имя",
	email as "Электронная почта",
	char_length(email) as "Длина Email",
	last_update::date as "Дата"
from 
	customer;


--ЗАДАНИЕ №6
--Выведите одним запросом активных покупателей, имена которых Kelly или Willie.
--Все буквы в фамилии и имени из нижнего регистра должны быть переведены в высокий регистр.


select 
	upper(last_name) as last_name, 
	upper(first_name) as first_name
from 
	customer
where 
	upper(first_name) = 'KELLY' or upper(first_name) = 'WILLIE';
	

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите одним запросом информацию о фильмах, у которых рейтинг "R" 
--и стоимость аренды указана от 0.00 до 3.00 включительно, 
--а также фильмы c рейтингом "PG-13" и стоимостью аренды больше или равной 4.00.

select 
	title, description, rating, rental_rate 
from 
	film
where 
	(rating = 'R' and rental_rate between 0 and 3) or 
	(rating = 'PG-13' and rental_rate >= 4);



--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.

select 
	title, description, rating, rental_rate 
from 
	film
order by 
	char_length(description) desc
limit 3;



--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.

select 
	split_part(email, '@', 1) as email1,
	split_part(email, '@', 2) as email2
from 
	customer


--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква должна быть заглавной, остальные строчными.

select 
/* 	Так не совсем верно работает, т.к. '.' - тоже разделитель для initcap
	initcap(split_part(email, '@', 1)) as email1,
	initcap(split_part(email, '@', 2)) as email2
*/
	upper(substring(split_part(email, '@', 1) from 1 for 1))||substring(split_part(email, '@', 1) from 2) as email1,
	upper(substring(split_part(email, '@', 2) from 1 for 1))||substring(split_part(email, '@', 2) from 2) as email2
from 
	customer;

