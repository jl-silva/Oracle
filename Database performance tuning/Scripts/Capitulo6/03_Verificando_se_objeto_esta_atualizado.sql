-- ver se determinado objeto possui estatistica atualizada (coluna LAST_ANALYZED)
SELECT  OWNER, TABLE_NAME, avg_row_len, blocks, empty_blocks, num_rows, TO_CHAR(last_analyzed, 'DD/MM/YYYY HH24:MI:SS') LAST_ANALYZED
FROM    DBA_TABLES
WHERE   OWNER = UPPER(NVL('&OWNER',OWNER))
AND     TABLE_NAME = UPPER(NVL('&TABLE_NAME',TABLE_NAME));

-- ver qtas alteracoes objeto ja teve desde a ultima coleta de estatisticas:
SELECT * FROM DBA_TAB_MODIFICATIONS
WHERE   TABLE_OWNER = UPPER(NVL('&OWNER',TABLE_OWNER))
AND     TABLE_NAME = UPPER(NVL('&TABLE_NAME',TABLE_NAME));
