-- cria indice 
create index soe.ix_orders2_orderid on soe.orders2(order_id) TABLESPACE SOE;

-- testa performance de consulta com indice
EXPLAIN PLAN FOR
  SELECT * FROM SOE.ORDERS2 WHERE ORDER_ID = 101;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- apague o indice 
DROP INDEX soe.ix_orders2_orderid;

-- teste a performance de consulta sem indice e compare com o valor anterior
EXPLAIN PLAN FOR
  SELECT * FROM SOE.ORDERS2 WHERE ORDER_ID = 101;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- testando atualizacoes com e sem indices
-- testando atualizacoes com e sem indices
SET SERVEROUTPUT ON
DECLARE 
  L_START         NUMBER;    
BEGIN
  L_START := DBMS_UTILITY.GET_TIME;
  -- executa insert sem indices 
  INSERT  INTO SOE.ORDERS2 
  SELECT  soe.orders_seq.nextval, order_date, order_mode, 
          customer_id, order_status, order_total, sales_rep_id, promotion_id, warehouse_id
  FROM    soe.orders WHERE ROWNUM < 999999;
  DBMS_OUTPUT.PUT_LINE('INSERT SEM indices : ' || ROUND((DBMS_UTILITY.GET_TIME - L_START)/100,2) || 's');    
  -- desfaz insercao dos dados
  ROLLBACK;

  EXECUTE IMMEDIATE 'create index soe.ix_orders2_orderid on soe.orders2(order_id) TABLESPACE SOE';
  
  L_START := DBMS_UTILITY.GET_TIME;
  -- executa insert c/ constraints FKs desabilitadas
  INSERT  INTO SOE.ORDERS2 
  SELECT  soe.orders_seq.nextval, order_date, order_mode, 
          customer_id, order_status, order_total, sales_rep_id, promotion_id, warehouse_id
  FROM    soe.orders WHERE ROWNUM < 999999;
  DBMS_OUTPUT.PUT_LINE('INSERT COM indices: ' || ROUND((DBMS_UTILITY.GET_TIME - L_START)/100,2) || 's');    
  -- desfaz insercao dos dados
  ROLLBACK;    
END;