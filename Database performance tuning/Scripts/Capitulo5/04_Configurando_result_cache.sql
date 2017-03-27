-- Result cache pode ser habilitado via 3 caminhos: alter session, alter system e hint em sql. Para habilita-lo vc pode usar os parametros:
--    result_cache_mode: MANUAL (default) ou FORCE
--    result_cache_max_size:  valor em bytes do tamanho da result cache
--    result_cache_max_result: valor percentual q um unico resultset pode armazenar (default = 5%) -> para grandes resultados pode ser necessario aumentar este valor
--    result_cache_remote_expiration: tempo em minutos para objetos remotos expirarem (valor default expira sempre objetos remotos)

-- configurando area para result cache
alter system set result_cache_max_size = 10M;

-- testando result cache
SET SERVEROUTPUT ON
DECLARE
  V_START NUMBER;
  TYPE cust_type IS TABLE OF SOE.CUSTOMERS%ROWTYPE;
  CUST_RECORD cust_type;
BEGIN
  dbms_result_cache.flush;
  execute immediate 'alter system flush shared_pool';
  execute immediate 'alter system flush buffer_cache';

  V_START := DBMS_UTILITY.GET_TIME;
  
  for i in 1..9999
  loop
    SELECT    /*+ result_cache */ * BULK COLLECT INTO CUST_RECORD
    FROM      SOE.CUSTOMERS
    WHERE     rownum = 1;
  end loop; 
    
  DBMS_OUTPUT.PUT_LINE('Tempo de execucao SQL com result cache: ' || (DBMS_UTILITY.GET_TIME - V_START) || 'cs');
  dbms_result_cache.flush;
  execute immediate 'alter system flush shared_pool';
  execute immediate 'alter system flush buffer_cache';

  V_START := DBMS_UTILITY.GET_TIME;
 
  for i in 1..9999
  loop
    SELECT    * BULK COLLECT INTO CUST_RECORD
    FROM      SOE.CUSTOMERS
    WHERE     rownum = 1;
  end loop;
  
  DBMS_OUTPUT.PUT_LINE('Tempo de execucao SQL sem result cache: ' || (DBMS_UTILITY.GET_TIME - V_START) || 'cs');   
END;

-- visualizar objetos no result cache
select * from v$result_cache_objects;

select BLOCKS * 8 /1024 from dba_tables where owner = 'SOE' AND TABLE_NAME = 'CUSTOMERS';

-- ver estatisticas do result cache
select * from v$result_cache_statistics;
 
-- verificar parametros result_cache
SHOW PARAMETER result_cache

-- limpar result cache
begin
    dbms_result_cache.flush;
end;   

-- configurar para nao usar o result cache
begin
    dbms_result_cache.bypass(true);
end;    

-- configurar para voltar a usar o result cache
BEGIN
    DBMS_RESULT_CACHE.BYPASS(false);
end;    

-- visualizar relatorio com visao geral sobre a result cache
set serveroutput on
exec DBMS_RESULT_CACHE.MEMORY_REPORT;

-- Retorna o total de memória da result cache
SELECT a.block_count * b.block_size max_mem_bytes
  FROM 
(SELECT value block_count
  FROM v$result_cache_statistics
 WHERE name = 'Block Count Maximum') a,
(SELECT (value / 1024) block_size
  FROM v$result_cache_statistics
 WHERE name = 'Block Size (Bytes)') b;

-- Retorna a quantidade de memória utilizada
SELECT a.block_count * b.block_size max_mem_bytes
  FROM 
(SELECT value block_count
  FROM v$result_cache_statistics
 WHERE name = 'Block Count Current') a,
(SELECT (value / 1024) block_size
  FROM v$result_cache_statistics
 WHERE name = 'Block Size (Bytes)') b;
 
-- Retorna a quantidade de falhas
 SELECT value falhas
  FROM v$result_cache_statistics
 WHERE name = 'Create Count Failure';
 
-- hit ratio qtde_suce e qtde_falh foram as quantidades de vezes em que o Oracle
-- precisou gravar ou tentou gravar algo na memória, qtde_find foi o número de vezes
-- que ele não precisou gravar, a informação já estava lá
SELECT 100 * ( 1 - (b.qtde_suce + c.qtde_falh)/(a.qtde_find)) hit_ratio
  FROM 
(SELECT value qtde_find
  FROM v$result_cache_statistics
 WHERE name = 'Find Count') a,
(SELECT value qtde_suce
  FROM v$result_cache_statistics
 WHERE name = 'Create Count Success') b,
(SELECT value qtde_falh
  FROM v$result_cache_statistics
 WHERE name = 'Create Count Failure') c;