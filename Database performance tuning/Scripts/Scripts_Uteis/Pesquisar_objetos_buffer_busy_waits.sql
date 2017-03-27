-- pesquisar objetos causando buffer busy waits
SELECT    object_name,
          value
FROM      V$SEGMENT_STATISTICS
WHERE     statistic_name = 'buffer busy waits' 
AND       value > 20000;
