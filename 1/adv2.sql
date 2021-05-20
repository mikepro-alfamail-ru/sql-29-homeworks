select 
	tc.constraint_name 
	from 
		information_schema.table_constraints tc 
	where 
		tc.constraint_type = 'PRIMARY KEY';
