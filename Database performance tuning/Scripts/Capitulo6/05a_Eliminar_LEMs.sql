-- Consulte a visao V$SYSSTAT  e procure por "table fetch continued row"
select  name, value 
from    v$sysstat  
where   name like '%table%';

-- criar tabela que iremos gerar LEMs
CREATE TABLE TESTE_LEM (COL1 NUMBER, COL2 VARCHAR2(4000), COL3 VARCHAR2(4000), COL4 VARCHAR2(4000)) TABLESPACE USERS;

-- carregar dados na tabela
DECLARE
  v_valor VARCHAR2(4000);
BEGIN
  FOR I IN 1..500
  LOOP
    v_valor := v_valor || to_char(i);
    INSERT INTO TESTE_LEM VALUES (I, v_valor, v_valor, v_valor);
  END LOOP;
  commit;
END;

-- atualizar valores de uma coluna da tabela para gerar LEMs
UPDATE TESTE_LEM SET COL2 = COL2 || COL3;
COMMIT;

-- analisar tabela para preencher coluna CHAIN_CNT na DBA_TABLES
ANALYZE TABLE TESTE_LEM COMPUTE STATISTICS;

-- ver se a tabela agora possui LEMs
SELECT  NVL(SUM(Chain_cnt),0)
FROM    DBA_TABLES
WHERE   owner = USER
AND     table_name = 'TESTE_LEM'
AND     chain_cnt > 0;

-- executar script abaixo para criar tabela auxiliar CHAINED_ROWS (caso ela ainda nao exista)
@?/rdbms/admin/utlchain.sql
 
-- analise a tabela 
analyze table TESTE_LEM list chained rows into CHAINED_ROWS;  

-- veja as linhas encadeadas
select * from CHAINED_ROWS;

-- crie uma tabela auxiliar p/ conter os dados das linhas encadeadas
create table aux_chained TABLESPACE USERS as 
select * from TESTE_LEM
where rowid in (select head_rowid from chained_rows
                where table_name = 'TESTE_LEM'
                and owner_name = user)

-- apague os dados da tabela analisada                
delete from TESTE_LEM
where rowid in (select head_rowid from chained_rows
                where table_name = 'TESTE_LEM'
                and owner_name = user);

-- efetue um shrink na tabela                
ALTER TABLE TESTE_LEM ENABLE ROW MOVEMENT;      
ALTER TABLE TESTE_LEM SHRINK SPACE;                

-- insira os dados da tabela auxiliar na tabela analisada
insert into TESTE_LEM select * from aux_chained;
COMMIT;

-- analise novamente a tabela para verificar se agora as LEMs foram eliminadas
ANALYZE TABLE TESTE_LEM COMPUTE STATISTICS;

-- ver se a tabela as LEMs foram eliminadas
SELECT  NVL(SUM(Chain_cnt),0)
FROM    DBA_TABLES
WHERE   owner = USER
AND     table_name = 'TESTE_LEM'
AND     chain_cnt > 0;

-- atualize estatisticas com dbms_stats
exec dbms_stats.gather_table_stats(user,'TESTE_LEM');