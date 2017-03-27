-- ver se parametro STATISTICS_LEVEL tem valor igual a TYPICAL (padrao) ou ALL. Valor BASIC desabilita coleta de estatisticas e AWR:
SELECT 	statistics_name, activation_level, system_status
FROM 	v$statistics_level;


-- *** 10G ***
-- ver se coleta esta habilitada ou nao:
select * from dba_scheduler_jobs where schedule_name = 'GATHER_STATS_JOB';

-- desabilita coleta
BEGIN
  DBMS_SCHEDULER.DISABLE('GATHER_STATS_JOB');
END;

-- habilita coleta
BEGIN
  DBMS_SCHEDULER.ENABLE('GATHER_STATS_JOB');
END;


-- *** 11G ***
-- ver se coleta esta habilitada ou nao
SELECT 	client_name, status 
FROM 	dba_autotask_operation 
where 	client_name = 'auto optimizer stats collection';

-- desabilita coleta
BEGIN
  DBMS_AUTO_TASK_ADMIN.disable(  client_name => 'auto optimizer stats collection',
                    operation => NULL,  window_name => NULL);
END;

-- habilita coleta
BEGIN
  DBMS_AUTO_TASK_ADMIN.enable(  client_name => 'auto optimizer stats collection',
                    operation => NULL,  window_name => NULL);
END;
