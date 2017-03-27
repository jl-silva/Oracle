-- O numero de Reloads devera ser menor que 1% dos pins. Se for maior que 1%, podem estar ocorrendo 2 situacoes:
--		1- A SQL Area tem pouco espaço e os objetos estao expirando. Neste caso aumente o valor do parametro SHARED_POOL_SIZE
--		2- Objetos estao sendo invalidados. Neste caso faca tarefas de manutencao do BD, tais como criacao de indices, somente em periodos de menor uso do BD.

-- Query para verificar reloads:
SELECT  SUM(pins) "Executions",
        SUM(reloads) "Cache Misses",
        SUM(reloads)/SUM(pins) "%"
FROM    V$LIBRARYCACHE;
			
