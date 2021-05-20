select 
	tc.table_name, tc.constraint_name, kcu.column_name, c.data_type 
	from 
		information_schema.table_constraints tc
	join 
		information_schema.key_column_usage kcu 
		on tc.constraint_name = kcu.constraint_name
	join 
		information_schema."columns" c
		on c.column_name = kcu.column_name 
	where 
		tc.constraint_type = 'PRIMARY KEY'
	order by 
		tc.table_name;
