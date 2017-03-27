-- VER tempo gasto por operacao do BD em uma sessao
WITH tb_dbtime as
      ( SELECT  sid, value
        FROM    v$sess_time_model
        where   sid = &sid
        AND     stat_name = 'DB time')
SELECT      stm.stat_name as statistic,
            trunc(stm.value/1000000,3) as seconds,
            trunc(stm.value/tot.value*100,1) as "%"
FROM        v$sess_time_model stm
INNER JOIN  tb_dbtime tot
    ON      stm.sid = tot.sid
WHERE       stm.stat_name <> 'DB time'
AND         stm.value > 0
ORDER BY    stm.value DESC;