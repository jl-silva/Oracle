-- Configuracao inicial recomendada para a PGA:
--  para OLTP:  PGA_AGGREGATE_TARGET  = (physical memory * 80%) * 20%
--  para OLAP:  PGA_AGGREGATE_TARGET  = (physical memory * 80%) * 50%


-- 1: descobrir tamanho da PGA
	-- se estiver usando ASMM:
		select name, value, display_value from v$parameter where name = 'pga_aggregate_target';
		-- ou
		show parameter pga_aggregate_target
    -- alter system set pga_aggregate_target = 268M;
		
	-- se estiver usando AMM tamanho da PGA esta incluso em memory_target:
		select name, value, display_value from v$parameter where name = 'memory_target';
		-- ou
		show parameter memory_target
  
-- 2: verificar se tamanho atende necessidade do BD. 
	-- overaloc deve ser igual a zero ou um valor muito baixo
	-- cache hit deve ser maior que 60% (se bd for oltp e estiver em uso constante)
	 select name, value from v$pgastat;
     
     -- na consulta abaixo se "ESTD_OVERALLOC_COUNT" > 0, aumente a PGA 
    SELECT  round(PGA_TARGET_FOR_ESTIMATE/1024/1024) target_mb,
            ESTD_PGA_CACHE_HIT_PERCENTAGE cache_hit_perc,
            ESTD_OVERALLOC_COUNT
    FROM    V$PGA_TARGET_ADVICE;

-- Mais informacoes: 
    -- http://www.dba-oracle.com/t_v_pgastat.htm
    -- http://docs.oracle.com/cd/B12037_01/server.101/b10752/memory.htm    
    
    

