SET search_path TO public;

-- Задание 1
select 
	distinct district 
from 
	address
where 
	district != ''
order by 
	district;

-- Задание 2
select 
	distinct district 
from 
	address
where 
	district like 'K%a' and district not like '% %'
order by 
	district;
	
-- Задание 3
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

-- Задание 4
select
	payment_id, payment_date, amount 
from 
	payment
limit 10;

-- Задание 5
select 
	first_name||' '||last_name as "Фамилия и имя",
	email as "Электронная почта",
	char_length(email) as "Длина Email",
	last_update::date as "Дата"
from 
	customer;

-- Задание 6
select 
	upper(last_name) as last_name, 
	upper(first_name) as first_name
from 
	customer
where 
	upper(first_name) = 'KELLY' or upper(first_name) = 'WILLIE';
