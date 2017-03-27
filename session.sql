----------- Tempo PL/SQL -----------------

0.00695 -- 10 minutos pl/sql
0.00347 -- 5 min

------------------------------------------

------------------ VERIFICANDO USO DO SERVIDOR LINUX ----------------

iostat - pode ser necess�rio instalar (apt-get install iostat), monitoramento dos recursos de leitura e escrita
top - existem outros como htop, mostra os recursos que est�o sendo utilizados no servidor, tais como mem�ria, uso de CPU e os processos que est�o em execu��o
oratop / as sysdba - top para oracle, similar ao top por�m monitora os recursos dispon�veis do oracle, com algumas op��es a mais para o banco, como verificar qual SQL est� executando, os wait events etc..

-----------------------------------------------------------

------------------- SQL sessão --------------------

select a.*, b.*
from v$sesstat a,
     v$statname b
where sid = 1146
and   b.statistic# = a.statistic#;

SELECT	s.sid,
	s.serial#,
	(select max(x.sql_text) from v$sql x where x.sql_id = s.SQL_ID) sql_text,
	(select max(DBMS_LOB.SUBSTR(x.SQL_FULLTEXT, 4000,1)) from v$sql x where x.sql_id = s.SQL_ID) sql_full_text,
    s.osuser
FROM	gv$session s
INNER JOIN v$process p 
	ON s.paddr = p.addr
WHERE	s.status = 'ACTIVE'
--AND	s.osuser = 'jlsilva';

SELECT s.sid,
     s.serial#,
     (select max(x.sql_text) from v$sql x where x.sql_id = s.SQL_ID) sql_text,
     s.osuser
   FROM gv$session s
  inner join v$process p
     on s.paddr = p.addr
  where s.status = 'ACTIVE'
  --and	s.osuser = 'wheb';
  
SELECT s.username,
     s.osuser,
     s.sid,
     s.serial#,
     p.spid,
     s.status,
     s.machine,
     (select max(x.sql_text) from v$sql x where x.sql_id = s.SQL_ID) sql_text,
     s.program,
     TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
   FROM gv$session s
  inner join v$process p
     on s.paddr = p.addr
  where s.status = 'ACTIVE' 
  and	s.osuser = 'wheb06';

SELECT sid
     , serial#
  FROM gv$session
 WHERE audsid = USERENV('SESSIONID');

SELECT sid,
	   serial#
FROM   gv$session
WHERE  sid = 3297;
  
select a.OSUSER
     , a.SQL_ID 
  from v$session a 
 where sid = 2030;
  
select a.SID, a.SERIAL#, a.seq#, a.EVENT, b.SQL_ID, b.SQL_FULLTEXT 
from gv$session a, 
     v$sql b 
where lower(a.OSUSER) = 'valdenir'
and b.SQL_ID = a.SQL_ID; 
  
select * from v$sql where sql_id = '6mzh703g1n3zm';
  
-- Executar comando abaixo p/ coletar valor ultima variavel bind a cada 10s. (somente p/ teste). Valor padr�o � de 15 minutos.
-- ALTER system SET "_cursor_bind_capture_interval" = 10;
select        a.sql_id,
              u.username,
              sc.username as schemaname,
              a.executions,
              a.cpu_time/(1000000) "cpu_time (s)",
              a.disk_reads,
              a.elapsed_time/(1000000) "elapsed_time (s)",
              (a.sharable_mem + a.persistent_mem + a.runtime_mem) /1024/1024 "used_memory (mb)",
              a.first_load_time,
              TO_CHAR(a.last_load_time,'dd/mm/yy HH24:mi:ss') last_load_time,
              a.buffer_gets,
              a.sorts,
              a.loads,
              a.application_wait_time/(1000000) "application_wait_time (s)",
              a.concurrency_wait_time/(1000000) "concurrency_wait_time (s)",
              a.user_io_wait_time/(1000000) "user_io_wait_time (s)",
              a.plsql_exec_time/(1000000) "plsql_exec_time (s)",
              a.rows_processed,
              a.optimizer_mode,
              a.optimizer_cost,
              --a.sql_text,
              DBMS_LOB.SUBSTR(a.SQL_FULLTEXT, 4000,1) sql_text,
              b.value_string
from          v$sqlarea a
INNER JOIN    dba_users u
      ON      a.parsing_user_id = u.user_id
INNER JOIN    dba_users sc
      ON      A.PARSING_SCHEMA_ID = SC.USER_ID
LEFT JOIN     v$sql_bind_capture b
      ON      a.address = b.address
      AND     a.hash_value = b.hash_value
where         U.username = '&USER';


-- Executar comando abaixo p/ coletar valor ultima variavel bind a cada 10s. (somente p/ teste). Valor padr�o � de 15 minutos.
-- ALTER system SET "_cursor_bind_capture_interval" = 10;
select a.sql_id,
       u.username,
       a.executions,
       a.cpu_time/(1000000) "cpu_time (s)",
       a.disk_reads,
       a.elapsed_time/(1000000) "elapsed_time (s)",
       (a.sharable_mem + a.persistent_mem + a.runtime_mem) /1024/1024 "used_memory (mb)",
       a.first_load_time,
       TO_CHAR(a.last_load_time,'dd/mm/yy HH24:mi:ss') last_load_time,
       a.buffer_gets,
       a.sorts,
       a.loads,
       a.application_wait_time/(1000000) "application_wait_time (s)",
       a.concurrency_wait_time/(1000000) "concurrency_wait_time (s)",
       a.user_io_wait_time/(1000000) "user_io_wait_time (s)",
       a.plsql_exec_time/(1000000) "plsql_exec_time (s)",
       a.rows_processed,
       a.optimizer_mode,
       a.optimizer_cost,
       --a.sql_text,
       DBMS_LOB.SUBSTR(a.SQL_FULLTEXT, 4000,1) sql_text,
       b.NAME
     , b.value_string
     , (a.elapsed_time / DECODE(a.executions, 0, 1, a.executions)) / 1000000 elap_per_exec
  from v$session s
     , v$sqlarea a
     , dba_users u
     , v$sql_bind_capture b
 where s.status = 'ACTIVE'
   and s.sql_hash_value > 0
   and s.sql_address != '00'
   AND a.address = s.sql_address
   AND a.hash_value = s.sql_hash_value
   and b.address = a.address
   AND b.hash_value = a.hash_value
   and u.user_id = a.parsing_user_id
 UNION ALL
-- Executar comando abaixo p/ coletar valor ultima variavel bind a cada 10s. (somente p/ teste). Valor padr�o � de 15 minutos.
-- ALTER system SET "_cursor_bind_capture_interval" = 10;
select a.sql_id,
       u.username,
       a.executions,
       a.cpu_time/(1000000) "cpu_time (s)",
       a.disk_reads,
       a.elapsed_time/(1000000) "elapsed_time (s)",
       (a.sharable_mem + a.persistent_mem + a.runtime_mem) /1024/1024 "used_memory (mb)",
       a.first_load_time,
       TO_CHAR(a.last_load_time,'dd/mm/yy HH24:mi:ss') last_load_time,
       a.buffer_gets,
       a.sorts,
       a.loads,
       a.application_wait_time/(1000000) "application_wait_time (s)",
       a.concurrency_wait_time/(1000000) "concurrency_wait_time (s)",
       a.user_io_wait_time/(1000000) "user_io_wait_time (s)",
       a.plsql_exec_time/(1000000) "plsql_exec_time (s)",
       a.rows_processed,
       a.optimizer_mode,
       a.optimizer_cost,
       --a.sql_text,
       DBMS_LOB.SUBSTR(a.SQL_FULLTEXT, 4000,1) sql_text,
       b.NAME
     , b.value_string
     , (a.elapsed_time / DECODE(a.executions, 0, 1, a.executions)) / 1000000 elap_per_exec
  from v$session s
     , v$sqlarea a
     , dba_users u
     , v$sql_bind_capture b
 where s.status = 'ACTIVE'
   and s.sql_hash_value = 0
   and s.sql_address = '00'
   AND a.address = s.prev_sql_addr
   AND a.hash_value = s.prev_hash_value
   and b.address = a.address
   AND b.hash_value = a.hash_value
   and u.user_id = a.parsing_user_id
 UNION ALL
select a.sql_id,
       u.username,
       a.executions,
       a.cpu_time/(1000000) "cpu_time (s)",
       a.disk_reads,
       a.elapsed_time/(1000000) "elapsed_time (s)",
       (a.sharable_mem + a.persistent_mem + a.runtime_mem) /1024/1024 "used_memory (mb)",
       a.first_load_time,
       TO_CHAR(a.last_load_time,'dd/mm/yy HH24:mi:ss') last_load_time,
       a.buffer_gets,
       a.sorts,
       a.loads,
       a.application_wait_time/(1000000) "application_wait_time (s)",
       a.concurrency_wait_time/(1000000) "concurrency_wait_time (s)",
       a.user_io_wait_time/(1000000) "user_io_wait_time (s)",
       a.plsql_exec_time/(1000000) "plsql_exec_time (s)",
       a.rows_processed,
       a.optimizer_mode,
       a.optimizer_cost,
       --a.sql_text,
       DBMS_LOB.SUBSTR(a.SQL_FULLTEXT, 4000,1) sql_text,
       null
     , null
     , (a.elapsed_time / DECODE(a.executions, 0, 1, a.executions)) / 1000000 elap_per_exec
  from v$session s
     , v$sqlarea a
     , dba_users u
 where s.status = 'ACTIVE'
   and s.sql_hash_value = 0
   and s.sql_address = '00'
   AND a.address = s.prev_sql_addr
   AND a.hash_value = s.prev_hash_value
   and u.user_id = a.parsing_user_id
   AND NOT EXISTS( SELECT 1 
                     FROM v$sql_bind_capture b
                    WHERE b.address = a.address
                      AND b.hash_value = a.hash_value)
 UNION ALL
select a.sql_id,
       u.username,
       a.executions,
       a.cpu_time/(1000000) "cpu_time (s)",
       a.disk_reads,
       a.elapsed_time/(1000000) "elapsed_time (s)",
       (a.sharable_mem + a.persistent_mem + a.runtime_mem) /1024/1024 "used_memory (mb)",
       a.first_load_time,
       TO_CHAR(a.last_load_time,'dd/mm/yy HH24:mi:ss') last_load_time,
       a.buffer_gets,
       a.sorts,
       a.loads,
       a.application_wait_time/(1000000) "application_wait_time (s)",
       a.concurrency_wait_time/(1000000) "concurrency_wait_time (s)",
       a.user_io_wait_time/(1000000) "user_io_wait_time (s)",
       a.plsql_exec_time/(1000000) "plsql_exec_time (s)",
       a.rows_processed,
       a.optimizer_mode,
       a.optimizer_cost,
       --a.sql_text,
       DBMS_LOB.SUBSTR(a.SQL_FULLTEXT, 4000,1) sql_text,
       null
     , null
     , (a.elapsed_time / DECODE(a.executions, 0, 1, a.executions)) / 1000000 elap_per_exec
  from v$session s
     , v$sqlarea a
     , dba_users u
 where s.status = 'ACTIVE'
   and s.sql_hash_value > 0
   and s.sql_address != '00'
   AND a.address = s.sql_address
   AND a.hash_value = s.sql_hash_value
   and u.user_id = a.parsing_user_id
   AND NOT EXISTS( SELECT 1 
                     FROM v$sql_bind_capture b
                    WHERE b.address = a.address
                      AND b.hash_value = a.hash_value)
 ORDER BY elap_per_exec desc;

------------------- SQL sess�o FIM --------------------

------------------- Wait no banco ---------------------

-- pegar os waits no banco, no momento de execu��o
select sid
     , event
     , seconds_in_wait 
  from v$session_wait 
 order by seconds_in_wait desc;

-- pegar o sql causador do wait, base colocar a sid retornada no select acima
select a.sql_text
  from v$sqltext a
     , v$session b
 where a.address = b.sql_address
   and a.hash_value = b.sql_hash_value
   and b.sid = &sid 
 order by piece;

-------------------------------------------------------

------------------ Matar sess�o bloqueadoras ---------------------------

SELECT 'alter system kill session ''' || s.blocking_session || ',' || a.SERIAL# || ''';'
 FROM gv$session s
    , gv$session a
    , v$lock l
 WHERE s.blocking_session IS NOT NULL 
   and a.SID = s.BLOCKING_SESSION
   and l.BLOCK is not null
   and l.sid = s.SID;

-------------------------------------------------------------------------

----------------- Matar sess�o --------------------
  
ALTER SYSTEM KILL SESSION '2091,22045' IMMEDIATE;
ALTER SYSTEM KILL SESSION '1896,30966' IMMEDIATE;

---------------------------------------------------

---------------- Alterar formato data na sess�o --------------------

alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
   
--------------------------------------------------------------------

--------------------------------- TASY ------------------------------
    
exec tasy_eliminar_processo_lock(1656, 34975, 1);


1 - Excluir indices;
2 - Provocar altera��o no dicion�rio de objetos na tabela onde os indices foram excluidos. Ex: alterar um tamanho de campo salvar e voltar ao valor que estava salvando novamente.
3 - Sincronizar a base. isto far� com que os indices sejam recriados no table space correto;
4 - Rodar os Status da tabela; (comando abaixo)

EXEC DBMS_STATS.GATHER_TABLE_STATS('TASY', 'PLS_CTA_LOTE_PROC_CONTA', cascade=>TRUE);

select a.nr_seq_ocorrencia,
       a.nr_seq_regra,
       a.dt_inicio_processo,
       a.dt_fim_processo,
       substr(pls_manipulacao_datas_pck.obter_tempo_execucao_format(a.dt_inicio_processo, nvl(a.dt_fim_processo, sysdate)),1,20) tempo,
       a.nr_id_transacao,
       a.nr_sequencia,
       a.nm_usuario
  from pls_oc_cta_log_ocor a
  where a.nr_id_transacao = (select max(b.nr_id_transacao)
                             from   pls_oc_cta_log_ocor b
                             where  1 = 1
			     and    nm_usuario = &usuario)
 order by a.nr_sequencia

-- Colocar para sincronizar uma tabela (quando tem problemas de inconsist�ncias) 
exec wheb_usuario_pck.set_nm_usuario('cetrentin');
update tabela_sistema set ie_sincronizar_wheb = 'S' where nm_tabela IN ('PLS_PP_IT_PREST_EVENT_VAL');

commit;

select ds_senha from pls_usuario_web where nm_usuario_web = 'dgkorz';


exec tasy_trace(0, 'rotina_antiga_1');
exec tasy_trace(1, 'rotina_antiga_1');

----------------------------------------------------------------------------

------------------ Pegar as binds variables de um SQL ----------------------

select a.*
from V$SQL_BIND_CAPTURE a
where a.sql_id = 'gj3bm8njubpxd';

select ss.osuser,
       ss.sid, 
       ss.SERIAL#,
       ss.seq#,
	   ss.event#,
       ss.PLSQL_OBJECT_ID,
	   ss.event,
       ss.SECONDS_IN_WAIT,
       ss.STATE,
       sq.sql_text,
       sq.SQL_FULLTEXT,
       sq.sql_id,
       ss.program
  from v$session ss,
	   v$sql sq
 where ss.sql_id = '6bsb1g4hhhuuu'
   and sq.sql_id = ss.sql_id;

select name
     , value_string
  from v$sql_bind_capture
 where sql_id = 'dnw3p6h8zg58d';


----------------------------------------------------------------------------

--------------- Quem est� bloqueando ------------------

SELECT s.blocking_session || ',' || a.SERIAL# || ' ' || a.OSUSER ||' est� bloqueando ' || s.sid || ',' || s.serial# || ' ' || s.osuser ||
       ' por ' || decode(l.TYPE, 'TX', 'Transa��o', 'TM', 'Comando DML', l.TYPE) block_status
 FROM gv$session s
    , gv$session a
    , v$lock l
 WHERE s.blocking_session IS NOT NULL 
   and a.SID = s.BLOCKING_SESSION
   and l.BLOCK is not null
   and l.sid = s.SID;

-- encontrando sess�es bloqueadoras em um ambiente RAC
select	dl.inst_id, 
	s.sid, 
	p.spid, 
	dl.resource_name1, 
	decode(substr(dl.grant_level,1,8),'KJUSERNL','Null','KJUSERCR','Row-S (SS)','KJUSERCW','Row-X (SX)','KJUSERPR','Share','KJUSERPW','S/Row-X (SSX)','KJUSEREX','Exclusive',request_level) as grant_level,
	decode(substr(dl.request_level,1,8),'KJUSERNL','Null','KJUSERCR','Row-S (SS)','KJUSERCW','Row-X (SX)','KJUSERPR','Share','KJUSERPW','S/Row-X (SSX)','KJUSEREX','Exclusive',request_level) as request_level, 
	decode(substr(dl.lockstate,1,8),'KJUSERGR','Granted','KJUSEROP','Opening','KJUSERCA','Canceling','KJUSERCV','Converting') as lockstate,
	s.sid, 
	sw.event, 
	sw.seconds_in_wait sec
from	gv$dlm_locks dl, 
	gv$process p, 
	gv$session s, 
	gv$session_wait sw
where	blocker = 1
and (dl.inst_id = p.inst_id and dl.pid = p.spid)
and (p.inst_id = s.inst_id and p.addr = s.paddr)
and (s.inst_id = sw.inst_id and s.sid = sw.sid)
order by sw.seconds_in_wait desc;
   
------------------------------------------------------

--------------- LISTA QUEM EST� USANDO A TABELA TEMPOR�RIA QUE PRECISA SER ALTERADA --------------

select a.*
  from v$lock a
     , user_objects b
 where b.object_name = 'PLS_PP_PRESTADOR_TMP'
   and a.id1 = b.object_id;

ALTER SYSTEM KILL SESSION '1466,20137' IMMEDIATE;

---------------------------------------------------------------------------------------

---------------- Buscar por FKs ----------------

select r.owner, r.table_name, r.constraint_name
  from user_constraints r, user_constraints o
 where r.r_owner = o.owner
   and r.r_constraint_name = o.constraint_name
   and o.constraint_type in ('P', 'U')
   and r.constraint_type = 'R'
   and o.table_name = 'PLS_MONITOR_TISS_INC';

------------------------------------------------

--------------- uso de CPU -------------------

SELECT se.username, ss.sid, se.serial#, se.osuser, ROUND (value/100) "CPU Usage seconds"
FROM v$session se, v$sesstat ss, v$statname st
WHERE ss.statistic# = st.statistic#
   AND name LIKE  '%CPU used by this session%'
   AND se.sid = ss.SID 
   AND se.username IS NOT NULL
   and se.status = 'ACTIVE'
  ORDER BY value DESC

------------------------------------------------

-- lista as estat�stica tendenciosas para �ndices de uma determinada tabela ---------
SELECT CS.COLUMN_NAME,
       CS.NUM_DISTINCT,
       CS.NUM_NULLS,
       (SELECT NUM_ROWS
          FROM DBA_TABLES T
         WHERE T.TABLE_NAME = CS.table_name
           AND T.OWNER = CS.owner) AS TOT_LINHAS,
       ((CS.NUM_DISTINCT * 100) /
       (SELECT NUM_ROWS
           FROM DBA_TABLES T
          WHERE T.TABLE_NAME = CS.table_name
            AND T.OWNER = CS.owner)) as "% total"
  FROM DBA_TAB_COL_STATISTICS CS
 WHERE CS.TABLE_NAME = 'PLS_GUIA_PLANO_MAT'
 AND	CS.COLUMN_NAME IN ('NR_SEQ_CBO_SAUDE', 'IE_VERSAO', 'CD_PESSOA_FISICA', 'CD_ESPECIALIDADE')
 ORDER BY CS.COLUMN_NAME

ANALYZE INDEX PLSCOME_I21 VALIDATE STRUCTURE;
 
SELECT HEIGHT, DEL_LF_ROWS, LF_ROWS, LF_BLKS, (DEL_LF_ROWS/LF_ROWS) FROM INDEX_STATS;

OBS1: Caso o valor de DEL_LF_ROWS/LF_ROWS seja maior que 2, ou LF_ROWS seja menor que LF_BLKS, ou HEIGHT seja 4, ent�o o 
�ndice deveria ser reconstru�do.
OBS2: Recomenda-se realizar o rebuild e computar as estat�sticas na mesma opera��o. Ex:

ALTER INDEX PLSCOCOP_PLSCOMAT_FK_I REBUILD COMPUTE STATISTICS;
 
---------------------------------------------------------------------------------------

--------------------- An�lise das est�tisticas -----------------------------

SELECT   STAT.TABLE_NAME AS "Nome do objeto",
         STAT.OBJECT_TYPE AS "Tipo do objeto",
         STAT.NUM_ROWS AS "Quant. de linhas estat�stica",
         STAT.LAST_ANALYZED AS "�ltima coleta das estat�sticas",
         GET_QT_REG_TAB(STAT.TABLE_NAME) "Quant. de linhas tabela"
    FROM USER_TAB_STATISTICS STAT
WHERE STAT.TABLE_NAME IN ('PLS_PROTOCOLO_CONTA', 'PLS_CONTA', 'PLS_CONTA_PROC', 'PLS_CONTA_MAT', 
                          'PLS_LOTE_PROTOCOLO_CONTA', 'PLS_OCORRENCIA_BENEF', 'PLS_CONTA_GLOSA', 'PLS_XML_ARQUIVO',
                          'PLS_XML_LOTE', 'PLS_PRESTADOR', 'PLS_SEGURADO', 'PLS_CONTESTACAO_DISCUSSAO',
                          'PLS_CONTESTACAO', 'PLS_ANALISE_CONTA')
ORDER BY LAST_ANALYZED


SELECT   STAT.TABLE_NAME AS "Nome do objeto",
         STAT.OBJECT_TYPE AS "Tipo do objeto",
         STAT.NUM_ROWS AS "Quant. de Linhas",
         STAT.LAST_ANALYZED AS "�ltima coleta das estat�sticas"
    FROM USER_IND_STATISTICS STAT
WHERE STAT.TABLE_NAME = 'PLS_CONTA_PROC'
ORDER BY LAST_ANALYZED

ANALYZE TABLE TABELA COMPUTE STATISTICS;


EXEC DBMS_STATS.GATHER_TABLE_STATS('TASY', 'PLS_PROTOCOLO_CONTA', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('TASY', 'PLS_CONTA', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('TASY', 'PLS_CONTA_PROC', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('TASY', 'PLS_CONTA_MAT', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('TASY', 'PLS_PROC_PARTICIPANTE', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('TASY', 'PLS_CTA_LOTE_PROC_CONTA', cascade=>TRUE);

EXEC DBMS_STATS.GATHER_TABLE_STATS('DBAASS', 'OLI_ALUNDISC', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('DBAASS', 'OLI_DISCMINI', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('DBAASS', 'OLI_PERILETI_UNI', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('DBAASS', 'MGR_ALUNO', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('DBAASS', 'MGR_ALUNO_TURMA', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('DBAASS', 'MGR_CURSO', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('DBAASS', 'MGR_TURMA_SEMESTRE', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('DBAASS', 'MGR_SEMESTRE', cascade=>TRUE);


----------------------------------------------------------------------------


------------------ verificar quantidade de cursores abertos ----------------

create or replace procedure pls_cursor_aberto(ds_p varchar2) is

qt_cursor_aberto_w          pls_integer;
begin

select sum(a.value) qt_cursor
  into qt_cursor_aberto_w
  from v$sesstat a,
       v$statname b,
       v$session s
 where a.statistic# = b.statistic#
   and s.sid = a.sid
   and b.name = 'opened cursors current'
   and s.program not like 'ORACLE%'
   and s.program not like 'OMS'
   and s.audsid = userenv('SESSIONID');

insert into decbuh_cursor_open(ds, qt_cursor, data, nr_sequencia) values ( ds_p, qt_cursor_aberto_w, sysdate, decbuh_cursor_open_seq.nextval);
commit;

end pls_cursor_aberto;

----------------------------------------------------------------------------

---------------------- Config sql plus formata��o -----------------------

col objname format a60 -- define um tamanho para a coluna
col type FOR a15
col LOCK_SUM FOR 99999999999
col PIN_SUM FOR 99999999999
col EXEC FOR 99999999999
col NAMESPACE FOR 999
set linesize 1000
set sqlprompt 'SQL> '

-------------------------------------------------------------------------

----------------- An�lise de eventos de Wait no banco -------------------
-- verifica os wait em Library cache: mutex X, evento de wait em mem�ria feito pelo Oracle para melhorar a performance fazendo com que
-- os registros fiquem em lock exclusivo, desta forma gerando uma fila para acessar as informa��es
select * from (
   select kglhdadr ADDR,
          kglobt09,
          substr(kglnaobj,1,80) objname,
          kglnahsh hashvalue,
          kglobtyd type,
          kglobt23 LOCK_SUM,
          kglobt24 PIN_SUM,
          kglhdexc EXEC,
          kglhdnsp NAMESPACE
       from x$kglob
  order by kglobt24 desc)
where rownum <= 100;

-- encontrando waiting sessions em um ambiente RAC
SELECT dl.inst_id,
       s.sid,
       p.spid,
       dl.resource_name1,
       DECODE(SUBSTR(dl.grant_level, 1, 8),
              'KJUSERNL',
              'Null',
              'KJUSERCR',
              'Row-S (SS)',
              'KJUSERCW',
              'Row-X (SX)',
              'KJUSERPR',
              'Share',
              'KJUSERPW',
              'S/Row-X (SSX)',
              'KJUSEREX',
              'Exclusive',
              request_level) as grant_level,
       DECODE(SUBSTR(dl.request_level, 1, 8),
              'KJUSERNL',
              'Null',
              'KJUSERCR',
              'Row-S (SS)',
              'KJUSERCW',
              'Row-X (SX)',
              'KJUSERPR',
              'Share',
              'KJUSERPW',
              'S/Row-X (SSX)',
              'KJUSEREX',
              'Exclusive',
              request_level) as request_level,
       DECODE(SUBSTR(dl.lockstate, 1, 8),
              'KJUSERGR',
              'Granted',
              'KJUSEROP',
              'Opening',
              'KJUSERCA',
              'Cancelling',
              'KJUSERCV',
              'Converting') as lockstate,
	s.sid,
	sw.event,
	sw.seconds_in_wait sec
from	gv$dlm_locks dl, 
		gv$process p, 
		gv$session s, 
		gv$session_wait sw
 where blocked = 1
   and (dl.inst_id = p.inst_id and dl.pid = p.spid)
   and (p.inst_id = s.inst_id and p.addr = s.paddr)
   and (s.inst_id = sw.inst_id and s.sid = sw.sid)
 order by sw.seconds_in_wait desc;

-- busca o hist�rico recente da session
SELECT to_char(sample_time,'hh24:mi:ss') sample_time,
 session_id,
 sql_id,
 event,
 p1 IDN,
 FLOOR(p2/POWER(2,4 * 8)) blocking_sid,
 FLOOR (p3/POWER (2,4 * 8)) location_id,
 CASE WHEN (event LIKE 'library cache:%' AND p1 <= power(2,17)) THEN  'library cache bucket: '||p1
 ELSE  (SELECT substr(kglnaobj,1,60) FROM x$kglob WHERE kglnahsh=p1 AND (kglhdadr = kglhdpar) and rownum=1) END mutexobject
 from v$active_session_history
 WHERE p1text='idn' AND session_state='WAITING'
 ORDER BY sample_time;
 
 -- listar os waits das sess�es que estejam em uma classe diferente de Idle
select	se.sid,
		se.event,
		sum(se.total_waits),
		sum(se.total_timeouts),
		sum(se.time_waited/100) time_waited
from	v$session_event se,
		v$session sess
where	sess.sid = se.sid
and		sess.wait_class != 'Idle'
group by se.sid,
		se.event
order by 1,3 desc;

-------------------------------------------------------------------------

------------------- Library cache perdidos ------------------------------ 
 -- You can see library cache misses from invalidations with this script:
select
   child_number,
   executions,
   loads,
   invalidations,
   parse_calls
from
   v$sql
where
   hash_value = nnn; 

-- objetos em cache mais utilizados
select	OWNER, 
		NAMESPACE, 
		TYPE,
		ROUND(SHARABLE_MEM /1024/1024,5) as "SHARABLE_MEM (MB)", 
		LOADS,
		EXECUTIONS,
		LOCKS,
		KEPT,
		NAME
from	v$db_object_cache
where	type not in ( 'NOT LOADED','NON-EXISTENT','VIEW','TABLE','SEQUENCE')
and		executions>0 and loads>1 and kept='NO'
order by executions desc, owner, namespace, type;
   
-------------------------------------------------------------------------

-------------------- Leituras fisicas estatisticas ----------------------
-- pegando o hit ratio de leituras fisicas de uma sess�o (quanto mais pr�ximo a 100 melhor, 100 seria 1 unica leitura em disco para todo o processo)
 SELECT (P1.value + P2.value - P3.value) / (P1.value + P2.value)
 FROM   v$sesstat P1, v$statname N1, v$sesstat P2, v$statname N2,
        v$sesstat P3, v$statname N3
 WHERE  N1.name = 'db block gets'
 AND    P1.statistic# = N1.statistic#
 AND    P1.sid = 1146
 AND    N2.name = 'consistent gets'
 AND    P2.statistic# = N2.statistic#
 AND    P2.sid = 1146
 AND    N3.name = 'physical reads'
 AND    P3.statistic# = N3.statistic#
 AND    P3.sid = 1146;

 -- fazer uma an�lise da quantidade de leituras em disco e total de leituras, quanto mais pr�ximo de 1 melhor abaixo de 0.93 podemos melhorar
SELECT	(P1.value + P2.value - P3.value) / (P1.value + P2.value)
FROM	v$sysstat P1, v$sysstat P2, v$sysstat P3
WHERE	P1.name = 'db block gets'
AND		P2.name = 'consistent gets'
AND		P3.name = 'physical reads';
 
-------------------------------------------------------------------------

---------------------- listar permiss�es de um usu�rio  -----------------
SELECT privilege
  FROM sys.dba_sys_privs
 WHERE grantee = 'TASY'
UNION
SELECT privilege 
  FROM dba_role_privs rp JOIN role_sys_privs rsp ON (rp.granted_role = rsp.role)
 WHERE rp.grantee = 'TASY'
 ORDER BY 1;

-------------------------------------------------------------------------

-- retorna a instru��o DDL para cria��o da tabela 
select dbms_metadata.get_ddl(object_type => 'TABLE', name => 'OLI_ALUNOS') from dual;

-- retorna um XML com a estrutura da tabela
select dbms_metadata.get_xml(object_type => 'TABLE', name => 'OLI_ALUNOS') from dual;
 
----------------------- SGA e PGA -----------------------------------
-- Algumas verifica��es quanta ao tamanho da SGA e PGA
--1- Verifique os advisors de mem�ria no AWR ou consulte diretamente as vis�es de performance din�micas relacionadas, como no exemplo abaixo:
-- verificar se aumentando  mem�ria teria melhora de desempenho (estd_db_time)

Select * 
  from v$memory_target_advice 
 order by memory_size;

--2- Verifique se est�o ocorrendo muitas opera��es de redimensionamento de mem�ria autom�ticas. Se sim, considere aumentar a mem�ria da SGA:

select component,
       oper_type,
       oper_mode,
       parameter,
       initial_size,
       final_size,
       to_char(start_time, 'dd/mm/yyyy  hh24:mi:ss') start_time,
       to_char(end_time, 'dd/mm/yyyy  hh24:mi:ss') end_time
  from v$memory_resize_ops;

--3- Para tunar a PGA, na consulta abaixo verifique se "ESTD_OVERALLOC_COUNT" > 0. Se sim, considere aument�-la:

select round(pga_target_for_estimate / 1024 / 1024) target_mb,
       estd_pga_cache_hit_percentage cache_hit_perc,
       estd_overalloc_count
  from v$pga_target_advice;


-------------------------------------------------------------------------

------------ retornando FKs (integridades) de uma tabela ----------------
SELECT a.table_name, a.constraint_name, c.column_name, c.position, a.r_constraint_name, b.constraint_name
  FROM user_constraints a
     , user_constraints b
     , user_cons_columns c
 WHERE b.table_name = 'PESSOA'
   AND a.r_constraint_name = b.constraint_name
   AND a.constraint_type = 'R'
   AND c.constraint_name = a.constraint_name
 ORDER BY a.table_name, a.constraint_name, c.position;

SELECT a.index_name, a.index_type, a.tablespace_name, b.column_name, b.column_position, b.descend
  FROM user_indexes a
     , user_ind_columns b
 WHERE b.index_name = a.index_name
   AND a.table_name = 'REPASSE_POS_ALUNO'
 ORDER BY a.index_name, b.column_position ;
 
SELECT a.constraint_name, c.column_name, c.position, a.r_constraint_name, b.table_name, b.constraint_name
  FROM user_constraints a
     , user_constraints b
     , user_cons_columns c
 WHERE a.table_name = 'ALUNO'
   AND a.constraint_type = 'R'
   AND b.constraint_name = a.r_constraint_name
   AND c.constraint_name = a.constraint_name
 ORDER BY  a.constraint_name, c.position;
   
SELECT a.index_name, a.index_type, a.tablespace_name, b.column_name, b.column_position, b.descend
  FROM user_indexes a
     , user_ind_columns b
 WHERE a.table_name = 'ALUNO'
   AND b.index_name = a.INDEX_NAME
 ORDER BY a.INDEX_NAME, b.column_position ;
 
-- ENCONTRAR INDICES QUE DEVERIAM EXISTIR NAS TABELAS MGR_ PELO CAMPO QUE DEVERIA CONTER O INDICES
SELECT distinct a.table_name
  FROM user_indexes  a
 WHERE a.table_name like 'MGR_%'
   AND NOT EXISTS(SELECT 1
                    FROM user_ind_columns x 
                   WHERE x.table_name = a.table_name
                     AND x.COLUMN_NAME like '%_CHAV')
   AND EXISTS( SELECT 1
                 FROM user_tab_columns y
                WHERE y.TABLE_NAME = a.table_name
                  AND y.COLUMN_NAME like '%_CHAV'); 

------------------------------ ORA-54032 --------------------------------------
                  
--ORA-54032: a coluna a ser renomeada � usada em uma express�o de coluna virtual
-- fazer o select abaixo para mostrar todas as colunas da tabela, pode ser que o Extended Statistics esteja habilitado
-- com isso o Oracle cria algumas colunas virtuais que podem estar sendo utilizadas
SELECT COLUMN_NAME, DATA_DEFAULT, HIDDEN_COLUMN 
  FROM USER_TAB_COLS
 WHERE TABLE_NAME = 'MGR_MENSALIDADE_CONV';

-- para excluir estas colunas � necess�rio utilizar o comando abaixo
-- owner, table_name, campos que retornaram no select anterior para a coluna virtual a ser dropada
EXEC DBMS_STATS.DROP_EXTENDED_STATS(ownname=>'DBAASS', tabname=>'MGR_MENSALIDADE_CONV', extension=>'("MMCO_MALU","MMCO_MSEM","MMCO_DREF")');

------------------------------ ORA-54032 FIM --------------------------------------

------------ tratamento de exce��o para forall ---------------------

dml_errors EXCEPTION;

    BEGIN
    forall i in bla..bla SAVE EXCEPTIONS ---------
    EXCEPTION
      WHEN dml_errors THEN -- Now we figure out what failed and why.

      l_index := SQL%BULK_EXCEPTIONS.COUNT;
       FOR i IN 1..l_index LOOP

            l_index := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;

            INSERT INTO JLS (DS, NUM, DS_CLOB) VALUES (
                    SUBSTR(' Erro na posi��o ' || l_index || ' t_alun_curs=' || t_alun_curs(i) ||
                    ' t_alun_codi=' || t_alun_codi(i) || ' t_alun_asig=' || t_alun_asig(i) ||  ' t_alun_form=' || t_alun_form(i) || 
                    ' t_alun_curs=' || t_alun_curs(i) || ' t_alun_pess=' || t_alun_pess(i) || ' t_alun_stat=' || NVL(t_alun_stat(i), '10') ||
                    ' t_alun_senh=' || t_alun_senh(i) || ' t_alun_diis=' || t_alun_diis(i) || ' t_alun_fing=' || t_alun_fing(i) ||
                    ' t_alun_ding=' || t_alun_ding(i), 1, 4000)
                , i, SQLERRM(BULK_EXCEPTIONS(i).ERROR_CODE));
       END LOOP;
       raise_application_error(-20011, 'Erros inseridos na tabela jls');
    END;
    
--------------------------------------------------------------------

----------------------- ENABLE/DISABLE DAS CONSTRAINTS QUE EST�O DESABILITADAS NA DEV ------------------------
declare

cursor c01 is
    SELECT ' ALTER TABLE ' || table_name || ' DISABLED CONSTRAINT ' || constraint_name sql_w 
      FROM USER_CONSTRAINTS
     WHERE TABLE_NAME LIKE 'OLI_%'
       AND CONSTRAINT_TYPE = 'R'
       AND STATUS = 'DISABLED';

begin

for r_c01 in c01 loop

    EXECUTE IMMEDIATE r_c01.sql_w;
end loop;

end;
/

--------------------------------------------------------------------

----------------------- ATUALIZAR ESTATISTICAS DAS TABELAS ------------------------
declare

cursor c01 is
   SELECT object_name
     FROM user_objects
    WHERE object_type = 'TABLE'
      AND object_name LIKE 'MGR_%';

begin

for r_c01 in c01 loop

    DBMS_STATS.GATHER_TABLE_STATS('DBAASS', r_c01.object_name, cascade=>TRUE);
end loop;

end;
/

--------------------------------------------------------------------


SELECT	DS_DANO
FROM	MAN_ORDEM_SERVICO AS OF TIMESTAMP TO_TIMESTAMP('08/12/2014 12:00:00','DD/MM/YYYY HH24:MI:SS')
WHERE	(Restri��es do select...)


----------------- CLAUSULA WITH PARA FUN��ES EM PL/SQL -------------------------
-- EXEMPLO E SCRIPT PARA TESTE

create or replace
function f_retorna_cpf_aluno( p_alucod oli_alunos.alucod%type
                            , p_alucpf oli_alunos.alucpf%type
                            , p_so_cpf varchar2 default 'N') return varchar2 is

PRAGMA UDF;

begin

if  (p_alucod = 815399) then
    return '09805309975';
elsif (p_so_cpf = 'S') then
    return pkg_mgr_imp_producao_aux.mgr_compara_string(p_alucpf);
else
    return pkg_mgr_imp_producao_aux.mgr_compara_string(NVL(p_alucpf, TO_CHAR(p_alucod)));
end if;

end f_retorna_cpf_aluno;
/

SET SERVEROUTPUT ON
DECLARE
  l_time    PLS_INTEGER;
  l_cpu     PLS_INTEGER;
  
  l_sql     VARCHAR2(32767);
  l_cursor  SYS_REFCURSOR;
  
  TYPE t_tab IS TABLE OF VARCHAR2(500);
  l_tab t_tab;
BEGIN
  l_time := DBMS_UTILITY.get_time;
  l_cpu  := DBMS_UTILITY.get_cpu_time;

  l_sql := 'WITH
              function my_retorna_cpf_aluno( p_alucod IN oli_alunos.alucod%type
                            , p_alucpf IN oli_alunos.alucpf%type
                            , p_so_cpf IN varchar2 default ''N'') return varchar2 is

                begin

                if  (p_alucod = 815399) then
                    return ''09805309975'';
                elsif (p_so_cpf = ''S'') then
                    return pkg_mgr_imp_producao_aux.mgr_compara_string(p_alucpf);
                else
                    return pkg_mgr_imp_producao_aux.mgr_compara_string(NVL(p_alucpf, TO_CHAR(p_alucod)));
                end if;

                end my_retorna_cpf_aluno;
            SELECT my_retorna_cpf_aluno(a.alucod, a.alucpf)
              FROM oli_alunos a';
            
  OPEN l_cursor FOR l_sql;
  FETCH l_cursor
  BULK COLLECT INTO l_tab;
  CLOSE l_cursor;
  
  DBMS_OUTPUT.put_line('WITH_FUNCTION  : ' ||
                       'Time=' || TO_CHAR(DBMS_UTILITY.get_time - l_time) || ' hsecs ' ||
                       'CPU Time=' || (DBMS_UTILITY.get_cpu_time - l_cpu) || ' hsecs ');

  l_time := DBMS_UTILITY.get_time;
  l_cpu  := DBMS_UTILITY.get_cpu_time;

  l_sql := 'SELECT f_retorna_cpf_aluno(a.alucod, a.alucpf)
            FROM oli_alunos a';
            
  OPEN l_cursor FOR l_sql;
  FETCH l_cursor
  BULK COLLECT INTO l_tab;
  CLOSE l_cursor;
  
  DBMS_OUTPUT.put_line('NORMAL_FUNCTION: ' ||
                       'Time=' || TO_CHAR(DBMS_UTILITY.get_time - l_time) || ' hsecs ' ||
                       'CPU Time=' || (DBMS_UTILITY.get_cpu_time - l_cpu) || ' hsecs ');
 
END;
/


-----------------------------------------------------------------------------------------



-- VIEWS QUE GUARDAM OS TEMPOS DE PROCESSAMENTO, CPU, FOREGROUND ETC...
SELECT * 
  FROM V$SESS_TIME_MODEL;

SELECT * 
  FROM V$SYS_TIME_MODEL;

SELECT * 
  FROM V$DB_CACHE_ADVICE

SELECT * 
  FROM V$parameter;

SELECT * 
  FROM dba_hist_active_sess_history;

SELECT *
  FROM V$UNDOSTAT;
  
SELECT * 
  FROM V$SQL X
 WHERE X.SQL_ID = '9ad33pcv8cyu9';

SELECT *
  FROM V$ROLLSTAT;
  
select *
  from V$INSTANCE_RECOVERY;
  
select * 
  from v$tablespace;

--------------------------------- SELECT DE DADOS EM TABLES ----------------------------

--create table jls_teste1 as select * from aluno where 1 = 2;

declare

t_alun_codi     pkg_util.tb_number;
t_ds            pkg_util.tb_varchar2_4000;
l_count         pls_integer;

begin

SELECT COUNT(1)
  INTO l_count
  FROM aluno;

l_count := l_count/2;
  
SELECT alun_codi
  BULK COLLECT INTO t_alun_codi
  FROM aluno
 WHERE rownum <= l_count;
 
SELECT COUNT(1)
  INTO l_count
  FROM aluno a
     , TABLE(t_alun_codi) b
 WHERE a.alun_codi = b.column_value;
  
SELECT TO_CHAR(a.alun_codi) || TO_CHAR(a.alun_pess)
  BULK COLLECT INTO t_ds
  FROM aluno a
     , TABLE(t_alun_codi) b
 WHERE a.alun_codi = b.column_value;
  
forall i in t_ds.first..t_ds.last
    INSERT INTO jls (ds) VALUES (t_ds(i));

COMMIT;
end;
/
-----------------------------------------------------------------------------------------

PRAGMA UDF
result_cache
WITH Function em PL/SQL

----------------- PEGAR O PLANO DE EXECU��O QUE O ORACLE UTILIZOU EM UM SQL ---------------

select * from table(dbms_xplan.display_cursor('ID_DO_SQL'));

-------------------------------------------------------------------------------------------

---------------- PARAMETRO DA KEEP POOL -------------------------
select *
  from v$parameter
 where upper(name) = 'DB_KEEP_CACHE_SIZE';
 ----------------------------------------------------------------
 
--------------- Teste com a function F_DESC_VCOL ------------------------------------
 
create or replace 
function F_DESC_VCOL(   pTabe valor_coluna.vcol_tabe%TYPE
                      , pColu valor_coluna.vcol_colu%TYPE
				      , pCodi valor_coluna.vcol_codi%TYPE ) return varchar2 DETERMINISTIC is 

PRAGMA UDF;

result valor_coluna.vcol_desc%TYPE;

begin

SELECT MAX(vcol_desc)
  INTO result
  FROM valor_coluna
 WHERE vcol_tabe = UPPER(pTabe)
   AND vcol_colu = UPPER(pColu)
   AND vcol_codi = UPPER(pCodi);

return(result);
     
end F_DESC_VCOL;
/

create or replace 
function F_DESC_VCOL(   pTabe valor_coluna.vcol_tabe%TYPE
                      , pColu valor_coluna.vcol_colu%TYPE
				      , pCodi valor_coluna.vcol_codi%TYPE ) return varchar2 DETERMINISTIC is 

PRAGMA UDF;

result valor_coluna.vcol_desc%TYPE;

begin

open pkg_util.c_valo_colu(UPPER(pTabe), UPPER(pColu), UPPER(pCodi));
fetch pkg_util.c_valo_colu into result;
close pkg_util.c_valo_colu;

return result;
     
end F_DESC_VCOL;
/

SET SERVEROUTPUT ON
--declare 
create or replace
procedure teste_result_cache is

l_time      simple_integer := 0;
l_cpu       simple_integer := 0;
l_cont      simple_integer := 0;

cursor c01 is
    select F_DESC_VCOL(table_name, column_name, '1') funcao
      from all_tab_columns
     where owner = 'DBAASS';

begin

l_time := DBMS_UTILITY.get_time;
l_cpu  := DBMS_UTILITY.get_cpu_time;

for r_c01 in c01 loop

    if  (r_c01.funcao is not null) then
        l_cont := l_cont + 1;
    end if;
end loop;

for r_c01 in c01 loop

    if  (r_c01.funcao is not null) then
        l_cont := l_cont + 1;
    end if;
end loop;

DBMS_OUTPUT.put_line('Total: ' || l_cont ||
                    ' Time=' || TO_CHAR(DBMS_UTILITY.get_time - l_time) || ' hsecs ' ||
                   ' CPU Time=' || (DBMS_UTILITY.get_cpu_time - l_cpu) || ' hsecs ');

end;
/

/*
    Com cursor
    Total: 942 Time=1445 hsecs  CPU Time=1427 hsecs
    Total: 942 Time=1242 hsecs  CPU Time=1237 hsecs
    Total: 942 Time=1354 hsecs  CPU Time=1346 hsecs
    Total: 942 Time=1251 hsecs  CPU Time=1248 hsecs
    Total: 942 Time=1201 hsecs  CPU Time=1198 hsecs
            AVG     1298,6              1291,2
    Sem cursor
    Total: 942 Time=1348 hsecs  CPU Time=1334 hsecs
    Total: 942 Time=1189 hsecs  CPU Time=1180 hsecs
    Total: 942 Time=1347 hsecs  CPU Time=1327 hsecs
    Total: 942 Time=1095 hsecs  CPU Time=1093 hsecs
    Total: 942 Time=1113 hsecs  CPU Time=1112 hsecs
                    1218,4              1209,2 
*/
SET SERVEROUTPUT ON
--declare 
create or replace
procedure teste_result_cache is

l_time      simple_integer := 0;
l_cpu       simple_integer := 0;
l_cont      simple_integer := 0;

cursor c01 is
    select table_name
         , column_name
      from all_tab_columns
     where owner = 'DBAASS';

begin

l_time := DBMS_UTILITY.get_time;
l_cpu  := DBMS_UTILITY.get_cpu_time;

for r_c01 in c01 loop

    if  (F_DESC_VCOL(r_c01.table_name, r_c01.column_name, '1') is not null) then
        l_cont := l_cont + 1;
    end if;
end loop;

for r_c01 in c01 loop

    if  (F_DESC_VCOL(r_c01.table_name, r_c01.column_name, '1') is not null) then
        l_cont := l_cont + 1;
    end if;
end loop;

DBMS_OUTPUT.put_line('Total: ' || l_cont ||
                    ' Time=' || TO_CHAR(DBMS_UTILITY.get_time - l_time) || ' hsecs ' ||
                   ' CPU Time=' || (DBMS_UTILITY.get_cpu_time - l_cpu) || ' hsecs ');

end;
/
/*
    Com cursor
    Total: 942 Time=1044 hsecs  CPU Time=1035 hsecs
    Total: 942 Time=956 hsecs   CPU Time=955 hsecs
    Total: 942 Time=975 hsecs   CPU Time=968 hsecs
    Total: 942 Time=1011 hsecs  CPU Time=999 hsecs
    Total: 942 Time=1048 hsecs  CPU Time=1037 hsecs
            AVG     1006,8              998,8
    Sem cursor
    Total: 942 Time=1072 hsecs  CPU Time=1062 hsecs
    Total: 942 Time=895 hsecs   CPU Time=890 hsecs
    Total: 942 Time=820 hsecs   CPU Time=818 hsecs
    Total: 942 Time=797 hsecs   CPU Time=796 hsecs
    Total: 942 Time=794 hsecs   CPU Time=792 hsecs
            AVG     895,6               871,6
*/
----------------------------------------------------------------------------------------

------------------------- TESTE COM OUTPUT ---------------------------------
SET SERVEROUTPUT ON
declare

l_time    PLS_INTEGER;
l_cpu     PLS_INTEGER;
l_teste     number;

cursor c01 is
    SELECT pkg_mgr_imp_producao_aux.f_retorna_mec_ies_iunicod(msed_chav) teste
         , msed_chav
      FROM mgr_aluno
         , mgr_sede
    WHERE malu_atua = 'S'
      AND msed_sequ = malu_msed;

begin

l_time := DBMS_UTILITY.get_time;
l_cpu  := DBMS_UTILITY.get_cpu_time;

for r_c01 in c01 loop

    l_teste := r_c01.teste;
end loop;

DBMS_OUTPUT.put_line('WITH_FUNCTION  : ' ||
                   'Time=' || TO_CHAR(DBMS_UTILITY.get_time - l_time) || ' hsecs ' ||
                   'CPU Time=' || (DBMS_UTILITY.get_cpu_time - l_cpu) || ' hsecs ');

end;
/
--------------------------------------------------------------------------------

------------ BURLESTON SCRIPT PARA MONITORAR OBJETOS CANDIDATOS PARA A KEEP POOL --------------
set pages 999
 
set lines 92 
 
spool keep_syn.lst
 
drop table t1;
 
create table t1 as

select
   o.owner          owner,
   o.object_name    object_name,
   o.subobject_name subobject_name,
   o.object_type    object_type,
   count(distinct file# || block#)         num_blocks
from
   dba_objects  o,
   v$bh         bh
where
   o.data_object_id  = bh.objd
and
   o.owner not in ('SYS','SYSTEM')
and
   bh.status != 'free'
group by
   o.owner,
   o.object_name,
   o.subobject_name,
   o.object_type
order by
   count(distinct file# || block#) desc;
 
select 'alter '||s.segment_type||' '||t1.owner||'.'||s.segment_name||' storage (buffer_pool keep);'
from t1,
   dba_segments s
where
   s.segment_name = t1.object_name
and
   s.owner = t1.owner
and
   s.segment_type = t1.object_type
and
   nvl(s.partition_name,'-') = nvl(t1.subobject_name,'-')
and
   buffer_pool <> 'KEEP'
and
   object_type in ('TABLE','INDEX')
group by
   s.segment_type,
   t1.owner,
   s.segment_name
having
   (sum(num_blocks)/greatest(sum(blocks), .001))*100 > 80;
 
spool off;
 
-- RESULTADO --
 
alter TABLE BOM.BOM_DELETE_SUB_ENTITIES storage (buffer_pool keep);
alter TABLE BOM.BOM_OPERATIONAL_ROUTINGS storage (buffer_pool keep);
alter INDEX BOM.CST_ITEM_COSTS_U1 storage (buffer_pool keep);
alter TABLE APPLSYS.FND_CONCURRENT_PROGRAMS storage (buffer_pool keep);
alter TABLE APPLSYS.FND_CONCURRENT_REQUESTS storage (buffer_pool keep);
alter TABLE GL.GL_JE_BATCHES storage (buffer_pool keep);
alter INDEX GL.GL_JE_BATCHES_U2 storage (buffer_pool keep);
alter TABLE GL.GL_JE_HEADERS storage (buffer_pool keep);
alter TABLE INV.MTL_DEMAND_INTERFACE storage (buffer_pool keep);
alter INDEX INV.MTL_DEMAND_INTERFACE_N10 storage (buffer_pool keep);
alter TABLE INV.MTL_ITEM_CATEGORIES storage (buffer_pool keep);
alter TABLE INV.MTL_ONHAND_QUANTITIES storage (buffer_pool keep);
alter TABLE INV.MTL_SUPPLY_DEMAND_TEMP storage (buffer_pool keep);
alter TABLE PO.PO_REQUISITION_LINES_ALL storage (buffer_pool keep);
alter TABLE AR.RA_CUSTOMER_TRX_ALL storage (buffer_pool keep);
alter TABLE AR.RA_CUSTOMER_TRX_LINES_ALL storage (buffer_pool keep);
alter INDEX WIP.WIP_REQUIREMENT_OPERATIONS_N3 storage (buffer_pool keep);

-- ADAPTA��O PARA 1 SELECT
WITH t1 AS (
select o.owner          owner
     , o.object_name    object_name
     , o.subobject_name subobject_name
     , o.object_type    object_type
     , count(distinct file# || block#) num_blocks
  from dba_objects  o
     , v$bh         bh
 where o.data_object_id  = bh.objd
   and o.owner not in ('SYS','SYSTEM')
   and bh.status != 'free'
 group by o.owner,
          o.object_name,
          o.subobject_name,
          o.object_type
 order by count(distinct file# || block#) desc
 )
select 'alter '||s.segment_type||' '||t1.owner||'.'||s.segment_name||' storage (buffer_pool keep);'
  from t1
     , dba_segments s
 where s.segment_name = t1.object_name
   and s.owner = t1.owner
   and s.segment_type = t1.object_type
   and nvl(s.partition_name,'-') = nvl(t1.subobject_name,'-')
   and buffer_pool <> 'KEEP'
   and object_type in ('TABLE','INDEX')
 group by s.segment_type
     , t1.owner
     , s.segment_name
having (sum(num_blocks)/greatest(sum(blocks), .001))*100 > 80;

--------------------------------------------------------------------------------

----------------- Verificar as options do banco ----------------------

SELECT PARAMETER
     , VALUE 
 FROM V$OPTION 
ORDER BY 1;

--------------------------------------------------------------------------------

----------------- Verificar as features e se est�o sendo usadas -----------------

SELECT NAME
     , DETECTED_USAGES
     , CURRENTLY_USED
     , FIRST_USAGE_DATE
     , LAST_USAGE_DATE 
  FROM DBA_FEATURE_USAGE_STATISTICS 
 ORDER BY LAST_USAGE_DATE DESC;

--------------------------------------------------------------------------------

----------------- @explain ---------------------------

Antes de executar � necess�rio salvar o sql que precisa ser verificado no @sql
pois no explain ele ir� executar o que estiver no @sql para gerar um trace

--------------------------------------------------

-------- @sql -------------
@view - explain da view com os acessos e plano de execu��o
@vc - valor de coluna - UNIASSELVI
@trigger - verifica o status da trigger
@tabela_oli - faz count em todas as tabelas OLI_ e retorna caso n�o exista registro - UNIASSELVI
@integridade @integridade_nm @fk - verifica as integridades de uma tabela - Philips
@gmud_erro - Mostra os erros que aconteceram na gmud pelo id - UNIASSELVI
@jls - verifica se existe algum objeto com jls
@lock - mostra os locks do banco
@int - retorna as integridades da tabela
@referencia - busca as tabelas que referenciam uma outra passada de par�metro
@kill - matar a sess�o, passar sid e serial
@session - busca as sess�es de uma determinada m�quina
@clear @cls - limpa tela
@deadlock
@busca - busca todos objetos que possuam o texto passado no par�metro
@explain - mostra o plano de execu��o de um select
@altera_senha - muda a senha de acesso - UNIASSELVI
@busca_text - proucura em todos os objetos por um trecho de c�digo
@cliente - conecta com o usu�rio cliente na wheb - Philips
@estatisticas - roda as estatisticas das tabelas que iniciem com o parametro passado
@fun - verifica se existem fun��es com o nome passado
@desc - describe ordenado pelo nome do campo
@gmud - retorna tudo que foi executado na gmud com um determinado ID - UNIASSELVI
--------------------------------

--------------- VARIAVEIS DE AMBIENTE ------------------

CONN SYSTEM@INSTANCIA
SPOOL C:\LOGS
SET ECHO ON
SET TIMING ON
SET LINES 1000
SET SQLBL ON

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
SELECT SYSDATE FROM DUAL;
SHOW USER

� VERIFICA INSTANCIA

SELECT * FROM GLOBAL_NAME;

DUMP
----------------------------------------------------

------------ CONTA OBJETOS DO SCHEMA ---------------

SELECT COUNT(OBJECT_TYPE), OBJECT_TYPE
FROM DBA_OBJECTS
WHERE OWNER LIKE 'USER%'
GROUP BY OBJECT_TYPE;
SPOOL OFF

----------------------------------------------------

------------  NO TERMINAL LINUX -------------------

$export ORACLE_SID=INSTANCE

$exp system@INSTANCE BUFFER=1000000 FILE=EXP_INSTANCE_USER_DATA.DMP LOG=EXP_INSTANCE_USER_DATA.LOG OWNER=USU�RIOS LISTADOS CONSISTENT=Y

gzip EXP_INSTANCE_USER_DATA*

---------------------------------------------------

----------------- DESATIVA��O DE UM SCHEMA --------------

� VERIFICAR SE TEM ALGUM USU�RIO USANDO O SISTEMA

SELECT SADDR, SID, USERNAME, LOGON_TIME, STATUS, OSUSER, MACHINE, PROGRAM
FROM V$SESSION
WHERE USERNAME LIKE 'USER%';

� VERIFICAR QUAIS S�O OS USU�RIOS DO SISTEMA

SELECT USERNAME FROM DBA_USERS
WHERE USERNAME LIKE 'USER%';

� VERIFICA ATRIBUTOS DO USU�RIO

SELECT * FROM DBA_USERS
WHERE USERNAME LIKE 'USER%';
SELECT * FROM DBA_TAB_PRIVS
WHERE GRANTOR LIKE 'USER%';

� VERIFICA PREVILEGIOS DO USU�RIO

SELECT * FROM DBA_SYS_PRIVS
WHERE GRANTEE LIKE 'USER%';
SELECT * FROM DBA_ROLE_PRIVS
WHERE GRANTEE LIKE 'USER%';

� CONTA OBJETOS DO SCHEMA

SELECT COUNT(OBJECT_TYPE), OBJECT_TYPE
FROM DBA_OBJECTS
WHERE OWNER LIKE LIKE 'USER%'
GROUP BY OBJECT_TYPE;

� DESATIVA USU�RIO

ALTER USER USER ACCOUNT LOCK;
ALTER USER USER PASSWORD EXPIRE;

� VERIFICA STATUS DA CONTA

SELECT USERNAME, ACCOUNT_STATUS FROM DBA_USERS
WHERE USERNAME LIKE 'USER%';
SPOOL OFF

DESATIVA��O DE UMA INSTANCIA

� VERIFICAR SE TEM ALGUM USU�RIO USANDO O SISTEMA

SELECT SADDR, SID, USERNAME, LOGON_TIME, STATUS,
OSUSER, MACHINE, PROGRAM
FROM V$SESSION;

� VERIFICAR QUAIS S�O OS USU�RIOS DO SISTEMA

SELECT USERNAME FROM DBA_USERS ;

� VERIFICA ATRIBUTOS DO USU�RIO

SELECT * FROM DBA_USERS;

SELECT * FROM DBA_TAB_PRIVS;

� VERIFICA PREVILEGIOS DO USU�RIO

SELECT * FROM DBA_SYS_PRIVS;

� VERIFICA PREVILEGIOS DE ROLE

SELECT * FROM DBA_ROLE_PRIVS;

� NO TERMINAL

EXPORT ORACLE_SID=INSTANCE

SQLPLUS / AS SYSDBA

SQL> SHUTDOWN IMMEDIATE;

EXECU��O DE SCRIPT

� VERIFICAR QUAIS S�O OS USU�RIOS DO SISTEMA

SELECT USERNAME FROM DBA_USERS
WHERE USERNAME LIKE 'USER%';

� VERIFICA SE O OBJETOS J� EXISTE

SELECT OWNER, OBJECT_NAME, OBJECT_TYPE,
CREATED, LAST_DDL_TIME, STATUS
FROM ALL_OBJECTS
WHERE OWNER LIKE 'USER%'
AND OBJECT_NAME = 'OBJECT_NAME';

� CONTA OBJETOS DO SCHEMA

SELECT COUNT(OBJECT_TYPE), OBJECT_TYPE
FROM DBA_OBJECTS
WHERE OWNER LIKE 'USER%'
GROUP BY OBJECT_TYPE;

� CONTA OBJETOS INVALIDOS

SELECT COUNT (*)
FROM DBA_OBJECTS
WHERE STATUS='INVALID'
AND OWNER LIKE 'USER%';

� VERIFICA OBJETOS INVALIDOS

SELECT OBJECT_TYPE, OBJECT_NAME, STATUS
FROM DBA_OBJECTS
WHERE STATUS='INVALID'
AND OWNER LIKE 'USER%';

� EXECUTA O SCRIPT

CONN USER@INSTANCE

@C:\CAMINHO\SCRIPT.SQL

CONN SYSTEM@INSTANCE

� VERIFICA SE O OBJETOS J� EXISTE

SELECT OWNER, OBJECT_NAME, OBJECT_TYPE,
CREATED, LAST_DDL_TIME, STATUS
FROM ALL_OBJECTS
WHERE OWNER LIKE 'USER%'
AND OBJECT_NAME = 'OBJECT_NAME';
SELECT * FROM DBA_TAB_PRIVS
WHERE GRANTOR LIKE 'USER%';

� CONTA OBJETOS DO SCHEMA

SELECT COUNT(OBJECT_TYPE), OBJECT_TYPE
FROM DBA_OBJECTS
WHERE OWNER LIKE 'USER%'
GROUP BY OBJECT_TYPE;

� CONTA OBJETOS INVALIDOS

SELECT COUNT (*)
FROM DBA_OBJECTS
WHERE STATUS='INVALID'
AND OWNER LIKE 'USER%';

� VERIFICA OBJETOS INVALIDOS

SELECT OBJECT_TYPE, OBJECT_NAME, STATUS
FROM DBA_OBJECTS
WHERE STATUS='INVALID'
AND OWNER LIKE 'USER%';

� GERA SCRIPTS DOS OBJETOS INVALIDOS

SELECT 'ALTER'||' '|| OBJECT_TYPE ||' '||OWNER ||'.'|| OBJECT_NAME || ' COMPILE;'
FROM DBA_OBJECTS
WHERE STATUS='INVALID'
AND OWNER LIKE 'USER%';

� VERIFICA OBJETOS INVALIDOS

SELECT OBJECT_NAME, OBJECT_TYPE, STATUS
FROM DBA_OBJECTS
WHERE STATUS='INVALID'
AND OWNER LIKE 'USER%';
SPOOL OFF

CRIACAO DE USU�RIO

� VERIFICAR SE EXISTE ESSE USU�RIO NO SISTEMA

SELECT USERNAME FROM DBA_USERS
WHERE USERNAME LIKE 'USER%';

� CRIAR A TABLESPACE PARA O USU�RIO

CREATE TABLESPACE INSTANCE_SCHEMA_01
DATAFILE 'CAMINHO/INSTANCE_SCHEMA.DBF' SIZE 64M
AUTOEXTEND ON NEXT 1M
SEGMENT SPACE MANAGEMENT AUTO;

� VERIFICA SE TEM ALGUMA ROLE PARA ESSE USU�RIO

SELECT * FROM DBA_ROLES WHERE ROLE LIKE '%USER%';

SELECT * FROM DBA_SYS_PRIVS WHERE LIKE '%USER%';

SELECT * FROM DBA_TAB_PRIVS WHERE LIKE '%USER%';

� CRIAR O USU�RIO

CREATE USER usuario
IDENTIFIED BY 'SENHA'
DEFAULT TABLESPACE INSTANCE_SCHEMA_01
TEMPORARY TABLESPACE TEMP;

� APLICA GRANT

GRANT RESOURCE, CONNECT TO USER;

� VERIFICAR SE O USU�RIO FOI CRIADO

SELECT * FROM DBA_USERS
WHERE USERNAME LIKE 'USER%';

� VERIFICA ROLES DO USUARIO CRIADO

SELECT * FROM DBA_SYS_PRIVS
WHERE GRANTEE LIKE 'USER%';
SELECT * FROM DBA_ROLE_PRIVS
WHERE GRANTEE LIKE 'USER%';

ALTERAR SENHA

� VERIFICAR OS USU�RIOS DO SISTEMA

SELECT * FROM DBA_USERS
WHERE USERNAME LIKE 'USER%';

� ALTERA A SENHA

ALTER USER USER IDENTIFIED BY 'SENHA';

� VERIFICAR OS USU�RIOS DO SISTEMA

SELECT * FROM DBA_USERS
WHERE USERNAME LIKE 'USER%';
SPOOL OFF

------------------ Exemplo de como utilizar o profiler -----------

-- verificar se j� existe algum profiler gerado
SELECT runid,run_comment FROM plsql_profiler_runs;

-- utilizando o profiler
SET SERVEROUTPUT ON
DECLARE

l_profilerresult BINARY_INTEGER;
l_val       NUMBER;
l_time      PLS_INTEGER;
l_cpu       PLS_INTEGER;
l_varchar   varchar2(500);
l_number    number;

cursor c01 is
    SELECT TO_CHAR(pess_dnas, 'DD/MM/YYYY') pess_dnas
      FROM pessoa
     WHERE ROWNUM <= 50000;

BEGIN

l_time := DBMS_UTILITY.get_time;
l_cpu  := DBMS_UTILITY.get_cpu_time;
l_profilerresult := DBMS_PROFILER.START_PROFILER('profiler01: ' || TO_CHAR(SYSDATE,'YYYYMMDD HH24:MI:SS'));

for r_c01 in c01 loop

    l_number := SO_NUMERO(r_c01.pess_dnas);
end loop;

l_profilerresult := DBMS_PROFILER.STOP_PROFILER;

DBMS_OUTPUT.put_line('Time=' || TO_CHAR(DBMS_UTILITY.get_time - l_time) || ' hsecs ' ||
                     'CPU Time=' || (DBMS_UTILITY.get_cpu_time - l_cpu) || ' hsecs ');
END;
/

-- utilizando o primeiro select � poss�vel encontrar o profiler que se deseja verificar
-- com o select abaixo � poss�vel verificar qual o comando de cada linha do pl/sql 
-- quantidade de vezes que foi chamada e quanto tempo levou
SELECT ppu.runid,
        ppu.unit_type,
        ppu.unit_name,
        ppd.line#,
        ppd.total_occur,
        ppd.total_time,
        ppd.min_time,
        ppd.max_time,
        a.TEXT
 FROM   plsql_profiler_units ppu,
        plsql_profiler_data ppd,
        all_source a
 WHERE ppu.runid = ppd.runid
 AND ppu.unit_number = ppd.unit_number
AND ppu.runid = &run_id
AND a.NAME(+) = ppu.unit_name
AND a.TYPE(+) = ppu.unit_type
AND a.OWNER(+) = ppu.unit_owner
AND a.LINE(+) = ppd.line#
ORDER BY ppu.unit_number, ppd.line#;

-------------------------------------------------------------------------------------------------------

--------- Buscar tabelas com full table scan executados nos últimos 10 minutos  -----------------------

SELECT a.sql_id, dbms_lob.substr(a.sql_fulltext, 4000, 1)
     , b.OBJECT_NAME, b.OBJECT_OWNER, max(x.BLOCKS) * 8 / 1024 MB
     , MAX(b.CPU_COST) cpu, max(b.COST) custo
     , max(b.IO_COST), max(b.CARDINALITY)
     , max(a.EXECUTIONS), max(a.ELAPSED_TIME) / 1000000
  FROM v$sqlarea a
     , v$sql_plan b
     , all_tables x
 WHERE a.last_active_time between sysdate - 0.00695 and sysdate
   AND b.SQL_ID = a.SQL_ID
   AND b.OPTIONS = 'FULL'
   AND x.table_name = b.OBJECT_NAME
   AND x.BLOCKS < 1280
 GROUP BY a.sql_id, dbms_lob.substr(a.sql_fulltext, 4000, 1)
     , b.OBJECT_NAME, b.OBJECT_OWNER;
     
-------------------------------------------------------------------------------------------------------