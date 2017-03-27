-- cria tablespace com blocos de 32k
create tablespace soe_32 datafile '/tmp/soe_32.dbf' size 100M AUTOEXTEND ON NEXT 1G  MAXSIZE UNLIMITED BLOCKSIZE 32768
    extent management local segment space management auto;

-- cria indice em tablespace com bloco de 8k
create index soe.ix_orders2_orderid on soe.orders2(order_id) TABLESPACE SOE;

-- analise o nivel do indice e qtde de folhas
select BLEVEL, LEAF_BLOCKS from dba_indexes where index_name = 'IX_ORDERS2_ORDERID';

-- apague o indice e recrie-o com blocos de 32k
DROP INDEX soe.ix_orders2_orderid;
create index soe.ix_orders2_orderid on soe.orders2(order_id) TABLESPACE SOE_32;

-- analise o nivel do indice e qtde de folhas e compare-os com os valores obtidos em blocos em 8k
select BLEVEL, LEAF_BLOCKS from dba_indexes where index_name = 'IX_ORDERS2_ORDERID';