-- verificar o status da instalação do APEX
SELECT  STATUS 
FROM    DBA_REGISTRY
WHERE   COMP_ID = 'APEX';

-- verificar a versão do APEX
SELECT * FROM apex_release;

-- verificar todas as versões do APEX instaladas
SELECT  VERSION 
FROM    DBA_REGISTRY 
WHERE   COMP_NAME = 'Oracle Application Express';