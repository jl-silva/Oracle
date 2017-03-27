set pages 3000;
set lines 300;
select	substr(b.table_name,1,40) tabela_pk,
	substr(rpad(d.column_name,30,'-'),1,29) || '>' campo_pk,
	substr(c.column_name,1,30) campo_fk,
	substr(a.table_name,1,40) tabela_fk
from	user_constraints a,
	user_constraints b,
	user_cons_columns c,
	user_cons_columns d
where	a.table_name = upper('&table_name')
and	a.r_constraint_name	= b.constraint_name
and	a.constraint_name	= c.constraint_name
and	b.constraint_name	= d.constraint_name
order by	b.table_name, a.constraint_name
/
