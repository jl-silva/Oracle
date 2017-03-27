-- apague indice na tabela SALES
DROP INDEX SH.SALES_CUST_BIX;

-- ver plano de execucao da consulta abaixo na tabela particionada SALES
explain plan for
  select * from sh.sales where cust_id in (2380, 531, 6612, 8881);
select * from table(dbms_xplan.display);

-- criar tabela heap clone
create table sh.sales2 as select * from sh.sales;
exec dbms_stats.gather_table_stats('SH','SALES2');

-- ver plano de execucao na tabela HEAP clone e comparar com a consulta anterior
explain plan for
  select * from sh.sales2 where cust_id in (2380, 531, 6612, 8881);
select * from table(dbms_xplan.display);

-- A CONSULTA NA TABELA PARTICIONADA EH MELHOR? PQ?

-- apague a tabela sales2:
DROP TABLE sh.sales2 