-- executar no sqlplus o script $ORACLE_HOME/rdbms/admin/ashrpt.sql:
	SQL > @?/rdbms/admin/ashrpt.sql

-- verificar dados mais antigos no ASH:
	SELECT min(sample_time) FROM dba_hist_active_sess_history;

