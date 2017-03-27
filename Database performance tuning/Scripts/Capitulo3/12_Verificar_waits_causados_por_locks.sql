-- Ver lock em nivel de linha. Analisar se tempo de espera eh alto
select 	wait_class, event, time_waited / 100 time_secs
from 	v$system_event e
where 	e.wait_class <> 'Idle' AND time_waited > 0
and    	event LIKE 'enq: TX - row lock contention'
union
select 	'Time Model', stat_name NAME,
		round((value / 1000000), 2) time_secs
from 	v$sys_time_model
WHERE 	STAT_NAME NOT IN ('background elapsed time', 'background cpu time') 
and    	stat_name LIKE 'enq: TX - row lock contention'
order by 3 desc;


-- V$SYS_TIME_MODEL: Contem estatisticas acumuladas de varias operacoes de todo o sistema