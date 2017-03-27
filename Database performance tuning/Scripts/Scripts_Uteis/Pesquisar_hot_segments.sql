-- A query abaixo ajuda pesquisar os TOP 10 segmentos quentes:
SELECT 	* 
FROM
        (SELECT   owner,
                  object_name,
                  object_type,
                  statistic_name,
                  sum(value)
         FROM     V$SEGMENT_STATISTICS
         GROUP BY owner, object_name, object_type, statistic_name
         ORDER BY SUM(value) DESC)
WHERE  	ROWNUM < 10;		
