set timing on;
set serveroutput on size unlimited;

declare

l_cont          pls_integer := 0;
l_cont_tabe     pls_integer := 0;
l_sql           varchar2(4000);

cursor c01 is
    SELECT table_name
      FROM all_tables
     WHERE table_name like 'OLI_%'
       AND EXISTS(SELECT 1
                    FROM all_source
                   WHERE type = 'PACKAGE BODY'
                     AND name LIKE 'PKG_MGR%'
                     AND UPPER(text) LIKE UPPER('%' || table_name || ' %'));

begin

for r_c01 in c01 loop

    l_sql := ' SELECT COUNT(1) FROM ' || r_c01.table_name;

    EXECUTE IMMEDIATE l_sql INTO l_cont;

    if  (l_cont = 0) then

        dbms_output.put_line('Tabela ' || r_c01.table_name || ' não possui registros');
        l_cont_tabe := l_cont_tabe + 1;
    end if;
end loop;

dbms_output.put_line('Total de tabelas sem registros: ' || l_cont_tabe);

end;
/