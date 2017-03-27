begin
declare
ds_sql_w 		varchar2(1000);
qt_registro_w 		pls_integer;
nm_tablespace_index_w	varchar2(100);
begin
	select	Obter_Tablespace_Index(null) 
	into	nm_tablespace_index_w
	from 	dual;
	
	select	count(1)
	into	qt_registro_w
	from	user_tab_columns
	where	table_name = 'PLS_GRAU_CLASSIF_ITEM'
	and	column_name = 'VL_PORTE';	

	if	(qt_registro_w > 0) then	
		exec_sql_dinamico('Tasy','alter table PLS_GRAU_CLASSIF_ITEM drop column VL_PORTE');
	end if;	
exception
when others then
	null;
end;
commit;
end;
/

begin
declare
qt_registro_w 		pls_integer;
tipo_dado_w		varchar2(106);
begin
	select 	count(1)
	into 	qt_registro_w
	from 	user_tab_columns
	where 	table_name = 'PLS_CONVERSAO_MAT'
	and	column_name = 'IE_TIPO_TABELA';

	if	(qt_registro_w > 0) then
		select	data_type
		into	tipo_dado_w
		from	user_tab_columns
		where	table_name = 'PLS_CONVERSAO_MAT'
		and	column_name = 'IE_TIPO_TABELA';
		
		if 	(upper(tipo_dado_w) <> upper('varchar2')) then
			exec_sql_dinamico('Tasy','alter table PLS_CONVERSAO_MAT modify IE_TIPO_TABELA VARCHAR2(10)');
		end if;
	elsif 	(qt_registro_w = 0) then
		exec_sql_dinamico('Tasy','alter table PLS_CONVERSAO_MAT add IE_TIPO_TABELA VARCHAR2(10)');
	end if;
exception
when others then
	null;
end;
commit;
end;