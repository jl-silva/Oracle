-- ver estatisticas de sistema acumuladas (desde o startup)
SELECT      S.name, S.value
FROM        v$sysstat s
order by    value desc;


-- V$SYSSTAT: Contem estatisticas globais de varias partes do BD, incluindo rollback, 
-- I/O fisico e logico e outros. Pode ser usada p/ calcular hit ratio de areas de memoria, tais como a buffer cache.