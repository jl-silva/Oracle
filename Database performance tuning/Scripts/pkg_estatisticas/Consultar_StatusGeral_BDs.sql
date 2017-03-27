REM @Consultar_StatusGeral_BDs.sql

SET ECHO OFF
SET FEEDBACK OFF
SET LINESIZE 150
set pagesize 500000
SET TERMOUT ON
SET VERIFY ON
set colsep   "    "
set columns 1000
set long 1000

CLEAR SCREEN
PROMPT *--------------------------------------------------------------------------------------------------*
PROMPT |                                                                                                  |
PROMPT |   * * *                 RELATORIO DE STATUS RAPIDO DO BANCO DE DADOS                      * * *  |
PROMPT |                                                                                                  |
PROMPT *-[@Consultar_StatusGeral_BDs.sql]-----------------------------------------------------------------*
PROMPT
ACCEPT v_Usu_DBA CHAR FORMAT A30 PROMPT      "Nome do usuario ............................................: "
ACCEPT v_Snh_DBA CHAR FORMAT A30 HIDE PROMPT "SENHA do usuario ...........................................: "
ACCEPT v_BD CHAR FORMAT A8 PROMPT            "Nome da instancia de BD.....................................: "
SET TERMOUT OFF
CONNECT &v_Usu_DBA/&v_Snh_DBA@&v_BD

CLEAR COLUMNS
CLEAR BREAKS
BREAK ON BD SKIP 1
COLUMN A_SA HEADING "Qtde. atual SA" FORMAT 999999 JUSTIFY center
COLUMN MO_SA HEADING "Media SA ontem" FORMAT 999999.99 JUSTIFY center
COLUMN METRICA HEADING "Nome da metrica" FORMAT A30 WORD_WRAPPED JUSTIFY left
COLUMN VALOR HEADING "Valor" FORMAT 99999.99 JUSTIFY left
COLUMN VALOR_REFERENCIA HEADING "Valor ref." FORMAT 99999.99
COLUMN STATUS HEADING "Status" FORMAT 5 JUSTIFY left
COLUMN UNIDADE_METRICA HEADING "Unidade da metrica" FORMAT A30 WORD_WRAPPED JUSTIFY left
COLUMN OWNER HEADING "Owner" FORMAT A30 WORD_WRAPPED JUSTIFY left
COLUMN object_type HEADING "Object type" FORMAT A12 WORD_WRAPPED JUSTIFY left
COLUMN OBJECT_NAME HEADING "Object name" FORMAT A30 WORD_WRAPPED JUSTIFY left
COLUMN CREATED HEADING "Created"
COLUMN STATUS HEADING "Status" FORMAT A10
COLUMN OWNER HEADING "Owner" FORMAT A12
COLUMN script_name NEW_VALUE v_script_name
COLUMN spool_filename NEW_VALUE v_spool_filename

SET TERMOUT OFF
SELECT 'relat_status_rapido_bd-' || TO_CHAR(SYSDATE,'yyyymmddhh24miss') || '.log' spool_filename FROM DUAL;

SET TERMOUT ON
SPOOL &v_spool_filename
PROMPT
PROMPT
PROMPT
PROMPT **** 1: METRICAS PRINCIPAIS DOS ULTIMOS 60 SEGUNDOS DO BD: CARGA DE CPU, BUFFER CACHE, PGA etc.  ***
PROMPT *-------------------        Verificar principalmente "Current OS Load"        ---------------------*
SELECT * FROM TABLE(PKG_ESTATISTICAS.FC_RETORNA_METRICAS_PRINCIPAIS);
PROMPT *****************************************************************************************************
PROMPT
PROMPT
PROMPT
ACCEPT v_continua CHAR FORMAT A1 HIDE PROMPT '******** Pressione "ENTER" p/ continuar ou digite "N" e pressione "ENTER" p/ sair: ' 

SET termout OFF
SELECT  decode(lower('&v_continua'),'n','Consultar_StatusGeral_BDs_saida.sql','Consultar_StatusGeral_Advanced_BDs.sql') script_name
FROM    dual;
SET termout ON

@&v_script_name
