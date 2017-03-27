-- ***** PARALELISMO NO NIVEL DA TABELA
-- altere a tabela para nao executar processos paralelos
alter table soe.orders noparallel; -- ou  alter table soe.orders parallel (degree 1);

-- veja o plano de execucao sem paralelismo
explain plan for
    select count(1) from soe.orders where order_total in (1000, 10000, 100000);
select * from table(dbms_xplan.display);

-- altere a tabela para executar 4 processos paralelos
alter table soe.orders parallel (degree 4);

-- veja o plano de execucao com paralelismo
explain plan for
    select count(1) from soe.orders where order_total in (1000, 10000, 100000);
select * from table(dbms_xplan.display);

-- ***** PARALELISMO NO NIVEL DO SQL 
-- altere a tabela para nao executar processos paralelos
alter table soe.orders noparallel; -- ou  alter table soe.orders parallel (degree 1);
explain plan for
    select /* PARALLEL(orders, 8) */ count(1) from soe.orders where order_total in (1000, 10000, 100000);
select * from table(dbms_xplan.display);

