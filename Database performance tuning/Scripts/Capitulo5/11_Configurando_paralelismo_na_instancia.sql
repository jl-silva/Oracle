/*
Parametros:
- PARALLEL_DEGREE_POLICY = MANUAL, LIMITED ou AUTO. Valor AUTO: calcula automaticamente DOP para todas as instrucoes SQL usando TODAs as caracteristicas tais como enfileiramento e "in memory parallel execute". Valor LIMITED:  calcula automaticamente DOP somente para instrucoes SQL que envolvem tabelas configuradas com "DEFAULT DOP".
- PARALLEL_MIN_TIME_THRESHOLD = AUTO | Segundos. Especifica a qtde minima de tempo em segundos que uma query devera levar (conforme CBO), antes do Auto DOP ser realizado. 
  O valor default eh de 30 segundos.
  
- PARALLEL_ADAPTIVE_MULTI_USER = true ou false. Habilita controle de requisicoes de processos paralelos em SQL para evitar sobrecarga do sistema.
- PARALLEL_DEGREE_LIMIT = CPU, IO ou Numero. Valor default = CPU_COUNT X PARALLEL_THREADS_PER_CPU X ACTIVE_INSTANCES. Qtde maxima de DOP q uma instrucao pode ter com auto dop.
- PARALLEL_EXECUTION_MESSAGE_SIZE = De 2148 a 32768. Valor default = 16kb. Valor do buffer utilizado p/ comunicacao entre QC e parallel execution servers.
- PARALLEL_FORCE_LOCAL = true ou false (default). Restringe execucao paralela na atual instancia do RAC.
- PARALLEL_INSTANCE_GRouP = Oracle RAC service_name ou group_name.
- PARALLEL_MIN_PERCENT = De 0 a 100. valor default 0 indica q se nao tiver processos paralelos disponiveis o processo eh executado serialmente
- PARALLEL_MIN_SERVERS = Numero entre 0 e PARALLEL_MAX_SERVERS.

- PARALLEL_SERVERS_TARGET = Numero entre 0 e PARALLEL_MAX_SERVERS. Valor padrao eh 4 X default DOP (PARALLEL_THREADS_PER_CPU x CPU_COUNT). Indica qtde. maxima de instrucoes que serao paralelizadas. Se o valor deste parametro for menor que PARALLEL_MAX_SERVERS, enfileiramento podera ocorrer.
- PARALLEL_MAX_SERVERS = De 0 a 3600. Qtde maxima de processos paralelos por instancia. Valor default = CPU_COUNT x PARALLEL_THREADS_PER_CPU x (2 if PGA_AGGREGATE_TARGET > 0; otherwise 1) x 5

Parametros obsoletos:
- PARALLEL_AUTOMATIC_TUNING: Deprecated.
- PARALLEL_IO_CAP_ENABLED = Deprecated.
*/
    
-- Obs.: Considere configurar tambem os parametros: parallel_servers_target e parallel_max_servers
-- ver artigos Automatic Degree of Parallelism in Oracle 11gR2 - http://www.centroid.com/knowledgebase/blog/automatic-degree-of-parallelism-in-oracle-11gr2
--   Paralelismo automatico no Oracle Database 11G: http://www.fabioprado.net/2013/02/paralelismo-automatico-no-oracle.html


-- monitorando ooperacoes paralelas:
SELECT    NAME , VALUE
FROM      V$SYSSTAT
WHERE     name LIKE '%Parallel%';

SELECT * FROM v$pq_sysstat
WHERE statistic LIKE 'Server%';

-- executar na mesma sessao para ver processos paralelos executados para uma query
SELECT dfo_number, tq_id, server_type, process, num_rows, bytes
FROM v$pq_tqstat
ORDER BY dfo_number DESC, tq_id, server_type DESC , process;

-- veja o tempo de execucao da query abaixo antes de habilitar paralelismo automatico
EXPLAIN PLAN FOR
     SELECT * FROM DBA_OBJECTS;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Para forcar auto dop em uma secao qq (evitando configuracao de paralelismo no nivel da tabela), execute:
ALTER SESSION FORCE PARALLEL QUERY;

-- habilitando paralelismo na instancia com parallel_degree_policy = AUTO (valor default eh MANUAL)
alter system set parallel_degree_policy = AUTO;
alter system set PARALLEL_MIN_TIME_THRESHOLD = 3;

-- veja o tempo de execucao da query abaixo depois de habilitar paralelismo automatico
EXPLAIN PLAN FOR
     SELECT * FROM DBA_OBJECTS;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
