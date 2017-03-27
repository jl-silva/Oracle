-- verificar objetos candidatos a pinagem (objetos mais executados ver coluna Kept?)
SELECT      SUBSTR(owner,1,10) Owner,
            SUBSTR(type,1,12) Type,
            SUBSTR(name,1,20) Name,
            executions,
            sharable_mem Mem_used,
            SUBSTR(kept||' ',1,4) "Kept?"
FROM        v$db_object_cache 
WHERE       TYPE IN ('TRIGGER','PROCEDURE','PACKAGE BODY','PACKAGE','FUNCTION')
ORDER BY    EXECUTIONS DESC;

-- pinar uma procedure, function ou package
DBMS_SHARED_POOL.KEEP('SYS.STANDARD');

-- pinar uma sequence que tenha CACHE(selecionar somente aquelas que o risco de ter "furos" deve ser o menor possivel)
DBMS_SHARED_POOL.KEEP('SCHEMA_NAME.SEQUENCE_NAME','Q');

