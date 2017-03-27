-- ver instrucoes SQL na SGA por ordem decrescente de tempo total de execucao 
--      a visao v$sqlstats tbem mostra quase todas as mesmas informacoes (nao inclui: optimizer_mode, user_name, schema_name ...)
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
        where         U.username = NVL('&USER',u.username)
		order by	  "elapsed_time (s)" desc;

-- Executar comando abaixo p/ coletar valor ultima variavel bind a cada 10s. (somente p/ teste). Valor padrao eh de 15 minutos.
--			ALTER system SET "_cursor_bind_capture_interval" = 10; 		


-- VER SQLs que consomem disco excessivo:
SELECT *
FROM		(SELECT	parsing_schema_name,
					direct_writes,
					SUBSTR(sql_text,1,75),
					disk_reads
  			 FROM 	v$sql
    		ORDER BY DISK_READS DESC)
WHERE rownum < 20;

-- ver sessoes esperando I/O
SELECT	username,
        program,
        machine,
        sql_id
FROM 	v$session
WHERE 	event LIKE 'db file%read';

-- ver objetos esperando I/O
SELECT	    object_name,
            object_type,
            owner
FROM 		    v$session a
inner join	dba_objects b
	on		    b.data_object_id = a.row_wait_obj#
WHERE 		  a.event LIKE 'db file%read';

