select  SID,
        SERIAL#,
        PROGRAM
from    v$session
where   upper(osuser) = Upper('&1')
/
