SELECT NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       sw.event,
       sw.wait_class,
       sw.wait_time,
       sw.seconds_in_wait,
       sw.state
FROM   v$session_wait sw,
       v$session s
WHERE  s.sid = sw.sid
  AND sw.EVENT NOT IN ('VKTM Logical Idle Wait','VKRM Idle','SQL*Net message from client')
ORDER BY sw.seconds_in_wait DESC;
