REM @Consultar_StatusGeral_Advanced_BDs.sql

PROMPT
PROMPT
PROMPT
PROMPT ************ 2: LISTAGEM DE SQLs ATIVOS C/ TEMPO MEDIO DE EXECUCAO MAIOR QUE DESEJADO  **************
SELECT * FROM TABLE(PKG_ESTATISTICAS.FC_RETORNA_TOP_SQL);
PROMPT *****************************************************************************************************
          
PROMPT
PROMPT
PROMPT
PROMPT ********************* 3: LISTAGEM DE SQLs BLOQUEADOS (LOCKS DE LINHA OU TABELA)  ********************
select sid, wait_event, blocker_sid from v$session_blockers
PROMPT *****************************************************************************************************
PROMPT
PROMPT
PROMPT
ACCEPT pswd CHAR PROMPT '******** Pressione ENTER p/ continuar ********' HIDE


PROMPT
PROMPT
PROMPT
PROMPT ******************** 4: LISTAGEM DE OBJETOS NOVOS NO BD (criados em menos de 48h) ********************
SELECT    SUBSTR(o.OWNER,1,12) owner, o.object_type, o.OBJECT_NAME, TO_CHAR(o.CREATED,'dd/mm/yyyy hh24:mi:ss') created, o.STATUS
FROM      DBA_OBJECTS o
WHERE     o.CREATED > SYSDATE - 2
AND       o.OWNER NOT IN ('SYS') 
PROMPT *****************************************************************************************************
PROMPT
PROMPT
PROMPT
ACCEPT pswd CHAR PROMPT '******** Pressione ENTER p/ continuar ********' HIDE


PROMPT
PROMPT
PROMPT
PROMPT ********************** 5: LISTAGEM DE OBJETOS ALTERADOS NO BD (em menos de 48h) *********************
SELECT    SUBSTR(o.OWNER,1,12) owner, O.object_type, O.OBJECT_NAME, TO_CHAR(TO_DATE(TIMESTAMP, 'yyyy-mm-dd:hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss') changed, O.STATUS
FROM      DBA_OBJECTS o 
WHERE     TO_DATE(TIMESTAMP, 'yyyy-mm-dd:hh24:mi:ss') > (SYSDATE - 2)
AND       o.OWNER NOT IN ('SYS') 
AND       o.object_type not in ('JOB')
ORDER BY  1, 2, 3;
PROMPT *****************************************************************************************************

PROMPT
PROMPT
PROMPT
PROMPT *** Aguarde, a listagem de parametros esta sendo gerada... ******************************************
PROMPT
PROMPT ******************* 6: LISTAGEM DE PARAMETROS ALTERADOS NO BD (nos ultimos 2 dias) ******************
select 	* 
from 	sys.vw_changed_parameters 
where 	data > (SYSDATE - 2);
PROMPT *****************************************************************************************************


SPOOL OFF

PROMPT
PROMPT
PROMPT
PROMPT
PROMPT * Foi gerado na sua estacao o arquivo "&v_spool_filename".
PROMPT

SET FEEDBACK ON
SET LINESIZE 80
SET VERIFY OFF
SET TERMOUT OFF
