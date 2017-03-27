drop index soe.ORD_ORDER_DATE_IX;

-- crie um indice local   
CREATE INDEX soe.ORD_ORDER_DATE_IX on "SOE"."ORDERS"("ORDER_DATE") local;

-- crie um indice global       
CREATE INDEX soe.ORD_ORDER_DATE_IX on "SOE"."ORDERS"("ORDER_DATE") global;