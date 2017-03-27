-- p/ consultar a V$ACTIVE_SESSION_HISTORY precisa ter a licenca da option "Diagnostics Pack"

-- verificar objetos q causam mais waits nos ultimos 30 minutos
select      d.object_name, d.object_type, a.event,
            sum(a.wait_time + a.time_waited) / 1000000 as total_wait_time_sec
from        v$active_session_history a
inner join  DBA_OBJECTS D
    on      a.current_obj# = d.object_id
where       a.sample_time > to_timestamp(sysdate - 30/60/24) 
GROUP BY    D.OBJECT_NAME, D.OBJECT_TYPE, A.EVENT
order by    total_wait_time_sec desc;