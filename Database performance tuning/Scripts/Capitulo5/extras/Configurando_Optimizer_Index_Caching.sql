-- Valores mais altos favorecem uso de indices e operacoes de nested loop joins e interacoes em operadores IN
-- Valor mais baixos favorecem operacoes de hash joins ou sort merge joins. 

-- consultar indices em cache se blocos tem 32k
SELECT      S.TABLESPACE_NAME, 
            ROUND((SUM(S.BLOCKS) / (SELECT VALUE FROM V$PARAMETER WHERE NAME = 'db_32k_cache_size')) * 100,2) OPTIMIZER_INDEX_CACHING 
FROM        DBA_SEGMENTS S 
INNER JOIN  DBA_TABLESPACES T
    ON      S.TABLESPACE_NAME = T.TABLESPACE_NAME
WHERE       T.BLOCK_SIZE = 32768
GROUP BY    S.TABLESPACE_NAME;

-- Altere o valor de OPTIMIZER_INDEX_CACHING para o valor retornado na consulta anterior
ALTER SYSTEM SET OPTIMIZER_INDEX_CACHING = X; -- substitua X pelo valor desejado