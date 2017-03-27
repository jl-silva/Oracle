-- criando a tabela SOE.OI
CREATE TABLE SOE.OI AS SELECT * FROM SOE.ORDER_ITEMS;

-- coletando estatisticas na tabela (necessario ate 11g apos CTAS)
EXEC DBMS_STATS.GATHER_TABLE_STATS('SOE','OI');

-- verificar qtde linhas por bloco
SELECT num_rows / blocks FROM DBA_TABLES WHERE OWNER = 'SOE' and table_name = 'OI';

-- configurar PCTFREE = 70 e INITRANS = 5
ALTER TABLE SOE.ORDER_ITEMS PCTFREE 70 PCTUSED 30 INITRANS 5;

-- REORGANIZE A TABELA
ALTER TABLE SOE.OI MOVE;

-- coletando estatisticas na tabela (necessario ate 11g apos CTAS)
EXEC DBMS_STATS.GATHER_TABLE_STATS('SOE','OI');

-- verifique a qtde linhas por bloco DIMINUIU:
SELECT num_rows / blocks FROM DBA_TABLES WHERE OWNER = 'SOE' and table_name = 'OI';

