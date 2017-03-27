EXEC DBMS_STATS.set_table_prefs('HR', 'EMPLOYEES', 'STALE_PERCENT', '50');

EXEC DBMS_STATS.set_table_prefs('HR', 'EMPLOYEES', 'ESTIMATE_PERCENT', '10');

EXEC DBMS_STATS.set_table_prefs('HR', 'EMPLOYEES', 'CASCADE', 'FALSE');

-- bloqueando coleta em objetos volateis ou GTTs
exec dbms_stats.lock_table_stats('owner', 'table');