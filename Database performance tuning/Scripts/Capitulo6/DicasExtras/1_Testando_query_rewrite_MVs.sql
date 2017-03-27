/*
Visões materializadas (MV´s) são objetos que podem ser criados no BD para armazenar resultados de uma query (tabela(s) master) e que podem ser atualizados em modo completo ou incremental;

MV´s podem ser utilizadas para reduzir o tempo de resposta de muitos tipos de queries, entre elas: queries remotas e queries complexas ou pesadas;

Crie MV´s que podem ser utilizadas transparentemente (sem intervenção do usuário final) através de queries reescritas (rewrite queries).
*/


-- Altere os parametros de sessao query_rewrite_enabled e query_rewrite_integrity:
alter session set query_rewrite_enabled=true;
alter session set query_rewrite_integrity=trusted; -- valor default "enforced" pode ignorar MVs qdo elas estao desatualizadas

-- veja o tempo de execucao da query
set timing on
SELECT    to_char(order_date, 'mm/yyyy') mes_ano,
          order_mode,
          SUM(order_total) total
FROM      soe.orders
group by  to_char(order_date, 'mm/yyyy'), order_mode;
set timing off

-- Crie a visao materializada soe.mv_orders_total_mensal:
create materialized view soe.mv_orders_total_mensal BUILD IMMEDIATE enable query rewrite
AS
SELECT    to_char(order_date, 'mm/yyyy') mes_ano,
          order_mode,
          SUM(order_total) total
FROM      soe.orders
group by  to_char(order_date, 'mm/yyyy'), order_mode;

-- veja novamente o tempo de execucao da query e compare com o tempo anterior?
set timing on
SELECT    to_char(order_date, 'mm/yyyy') mes_ano,
          order_mode,
          SUM(order_total) total
FROM      soe.orders
group by  to_char(order_date, 'mm/yyyy'), order_mode;
set timing off


-- Analise o plano de execucao da query para verificar se ela foi reescrita pelo otimizador para utilizar a visao materializada:
EXPLAIN PLAN FOR
  SELECT    to_char(order_date, 'mm/yyyy') mes_ano,
            order_mode,
            SUM(order_total) total
  FROM      soe.orders
  group by  to_char(order_date, 'mm/yyyy'), order_mode;
select * from table(DBMS_XPLAN.DISPLAY);

-- desabilite query rewrite e veja o plano de execucao novamente
alter session set query_rewrite_enabled=false;
EXPLAIN PLAN FOR
  SELECT    to_char(order_date, 'mm/yyyy') mes_ano,
            order_mode,
            SUM(order_total) total
  FROM      soe.orders
  group by  to_char(order_date, 'mm/yyyy'), order_mode;
select * from table(DBMS_XPLAN.DISPLAY);



-- Obs.: Execute o script abaixo para atualizar  uma visao materializada:
BEGIN
    -- SE METODO = 'C' entao faz atualizacao completa. Se METODO = 'F' entao faz atualizacao incremental (precisa criar logs de mv's)
    DBMS_MVIEW.REFRESH('&SCHEMA..&MV_NAME','&METODO'); 
END;

-- Execute o script abaixo para atualizar varias visoes materializada:
BEGIN
    -- SE METODO = 'C' entao faz atualizacao completa. Se METODO = 'F' entao faz atualizacao incremental (neste caso, eh necessario ter logs de mv´s)
    DBMS_MVIEW.REFRESH(list => 'SCHEMA.MV1, SCHEMA.MV2', method => 'METODO'); 
END;