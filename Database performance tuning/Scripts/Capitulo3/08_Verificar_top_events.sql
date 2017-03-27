-- ver top events nos ultimos 30 minutos (linha com valor NULL eh o tempo que a sessao nao teve wait time
-- p/ consultar a V$ACTIVE_SESSION_HISTORY precisa ter a licenca da option "Diagnostics Pack"
SELECT    EVENT,
          sum(WAIT_TIME) / 1000000 total_cpu_sec,
          sum(TIME_WAITED) / 1000000 total_wait_sec,
          SUM(WAIT_TIME + TIME_WAITED) / 1000000 TOTAL_sec
FROM      V$ACTIVE_SESSION_HISTORY
WHERE     SAMPLE_TIME > to_timestamp(sysdate - 30/60/24)
GROUP BY  EVENT
order by  TOTAL_sec desc;

-- VER top WAIT EVENTS POR CLASSE
select    wait_class, sum(time_waited), sum(time_waited)/sum(total_waits)
          sum_waits
FROM      V$SYSTEM_WAIT_CLASS
GROUP BY  WAIT_CLASS
order by  3 desc;

-- ver TOP WAIT EVENTS POR Application E Concurrency
select      a.event, a.total_waits, a.time_waited, a.average_wait
from        v$system_event a, v$event_name b, v$system_wait_class c
where       a.event_id=b.event_id
and         b.wait_class#=c.wait_class#
AND         C.WAIT_CLASS IN ('Application','Concurrency')
order by    average_wait desc;


-- V$ACTIVE_SESSION_HISTORY: Contem estatisticas atualizadas a cada segundo, de snapshots de sessoes de BD ativas.
