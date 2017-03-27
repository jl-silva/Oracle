-- first_rows favorece melhor tempo de resposta e consequentemente o uso de indices
ALTER SESSION SET OPTIMIZER_MODE = FIRST_ROWS; 
ALTER SYSTEM SET OPTIMIZER_MODE = FIRST_ROWS; 

-- all_rows favorece melhor throughput (boa configuracao para hardware muito bom (Ex.: Exadata) ou OLAP e consequentemente FTS
ALTER SESSION SET OPTIMIZER_MODE = ALL_ROWS; 
ALTER SYSTEM SET OPTIMIZER_MODE = ALL_ROWS; 
