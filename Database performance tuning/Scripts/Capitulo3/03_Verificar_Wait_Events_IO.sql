-- ver lista de eventos de espera por I/O (para ver todos tire o filtro na coluna WAIT_CLASS)
SELECT     NAME
FROM       V$EVENT_NAME
WHERE      WAIT_CLASS = 'User I/O'
ORDER BY   NAME;

-- ver estatisticas de I/O dos processos de background: rman, dbwr, lgwr, buffer cache reads etc:
select * from v$iostat_function order by 1;