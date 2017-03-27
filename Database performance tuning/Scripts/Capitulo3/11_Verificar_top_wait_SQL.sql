-- p/ consultar a V$ACTIVE_SESSION_HISTORY precisa ter a licenca da option "Diagnostics Pack"

-- ver top SQL em tempo de espera nos ultimos 30 minutos
select      u.username,
            (sum(ash.wait_time + ash.time_waited) / 1000000) as ttl_wait_time_sec,
            s.sql_text              
from        v$active_session_history ash
inner join  v$sqlarea s
    on      ash.sql_id = s.sql_id
inner join  dba_users u
    on      ASH.USER_ID = U.USER_ID
where       ash.sample_time > TO_TIMESTAMP(sysdate - 30/60/24)
group by    ash.user_id,s.sql_text, u.username
order by    ttl_wait_time_sec DESC;

-- ver mais info detalhadas sobre os top sql executados no ultimos 30 minutos
-- não depende do AWR
select      * 
from        v$sqlstats
where       last_active_time  > TO_TIMESTAMP(sysdate - 30/60/24)
order by    elapsed_time desc;