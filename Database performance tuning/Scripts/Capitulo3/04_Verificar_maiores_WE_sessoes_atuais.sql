-- Verificar maiores wait events das sessoes atuais
SELECT      EVENT,            
            (sum(time_waited) / 100) total_time_waited_sec,
            SUM(TOTAL_WAITS) total_waits
FROM        V$SESSION_EVENT
WHERE       EVENT NOT IN
                        ('SQL*Net message from client', 'SQL*Net message to client', 'pmon timer', 'smon timer', 
                        'rdbms ipc message', 'jobq slave wait', 'rdbms ipc reply', 'i/o slave wait', 'PX Deq: Execution Msg')
GROUP BY    event
order by    total_time_waited_sec desc;


-- V$SESSION_EVENT: Fornece um resumo de estatisicas de eventos que a sessão esperou desde o momento em que o BD foi inicializado