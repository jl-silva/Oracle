-- por precaucao, faca um copia do spfile em pfile antes de fazer as alteracoes
create pfile from spfile;

-- Configurando AMM
alter system set memory_max_target = xG scope=spfile; 
alter system set memory_target = xG scope=spfile; 
alter system set sga_target = 0 scope=spfile;   -- se valor de sga_target for maior que 0 este sera o valor minimo da SGA em AMM
alter system set pga_aggregate_target = 0 scope=spfile;  -- se valor de pga_aggregate_target for maior que 0 este sera o valor minimo da PGA em AMM
shutdown immediate
startup

-- Configurando ASMM + PGA 
alter system set memory_max_target = 0 scope=spfile;  
alter system set memory_target = 0 scope=spfile; 
alter system set sga_target = xG scope=spfile;
alter system set sga_max_size = xG scope=spfile;
alter system set pga_aggregate_target = xG scope=spfile;
shutdown immediate
startup

-- IMPORTANTE: em alguns ambiente pode ser necessario configurar um tamanho minimo de buffer cache
ALTER SYSTEM SET DB_CACHE_SIZE = X;


-- Mais informacoes: 
    -- http://www.dba-oracle.com/t_v_pgastat.htm
    -- http://docs.oracle.com/cd/B12037_01/server.101/b10752/memory.htm

-- Parametros auto-tunados dentro da SGA:
            - SHARED_POOL_SIZE
            - DB_CACHE_SIZE
            - LARGE_POOL_SIZE
            - JAVA_POOL_SIZE
            - STREAMS_POOL_SIZE