-- configurando db_file_multiblock_read_count em OLTP
alter system set db_file_multiblock_read_count = 8;

-- configurando db_file_multiblock_read_count em OLAP
alter system set db_file_multiblock_read_count = 128;

-- para voltar valor default
alter system reset db_file_multiblock_read_count;

-- Obs.: O valor default configura auto tuning deste parametro (que parece nao funcionar bem sem mbrc da coleta de estatisticas de sistema).
