-- VER TEMPO TOTAL DE WAITs E DE CPU ULTIMOS EVENTOS. Aqui da para ver se BD gastou mais tempo com wait events ou cpu e da p/ ver detalhes de onde foi gasto o tempo
SELECT  METRIC_NAME, VALUE, metric_unit
FROM    V$SYSMETRIC
WHERE   METRIC_NAME IN ('Database CPU Time Ratio','Database Wait Time Ratio') 
AND     INTSIZE_CSEC = (select max(INTSIZE_CSEC) from V$SYSMETRIC);

-- ver media da ultima hora de varias metricas do BD
SELECT    metric_name, average, metric_unit
FROM      V$SYSMETRIC_SUMMARY
ORDER BY  2 DESC;


-- V$SYSMETRIC: Contem metricas de sistema capturadas em 2 intervalos de tempo: ultimos 15 segundos ou ultimos 60 segundos.
-- V$SYSMETRIC_SUMMARY: media ultima hora (ultimo snapshot)
-- DBA_HIST_SYSMETRIC_SUMMARY: resumo da ultima semana --> depende de licenciamento do AWR