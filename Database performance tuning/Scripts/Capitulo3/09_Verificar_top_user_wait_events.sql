-- p/ consultar a V$ACTIVE_SESSION_HISTORY precisa ter a licenca da option "Diagnostics Pack"

-- para ver lista de usuarios com mais waits dos ultimos 30 minutos
select      s.sid, s.username,
            sum(time_waited) / 1000000 total_wait_time_sec
from        v$active_session_history a
inner join  v$session s
    on      a.session_id=s.sid
where       a.sample_time > to_timestamp(sysdate - 10/60/24)
and         s.username is not null
GROUP BY    S.SID, S.USERNAME
order by    total_wait_time_sec desc;