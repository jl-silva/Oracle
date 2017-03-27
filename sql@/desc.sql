set linesize 400;
set pagesize 300;
set verify off;
select	substr(upper(column_name),1,200) Campo,
	decode(nullable,'Y','','NOT NULL') "Nulo?",
	(substr(data_type,1,30) ||
	 to_char(decode(data_precision,null,
			decode(data_type,'DATE','','LONG','','(' || data_length || ')'),
			'(' || data_precision ||
			decode(data_scale,0,'',',' || data_scale) || ')')))  "TIPO/TAMANHO"
from	user_tab_columns
where	upper(table_name) = upper('&1')
order by
	column_name;
set pagesize 10;
set linesize 100;