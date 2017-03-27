-- Considere configurar tamanhos de blocos maiores na buffer cache para dados de indices em oltp. 
-- O tamanho da area de memoria deve ser bem calculado para comportar eficientemente os dados em memoria.
alter system set db_32k_cache_size = xM scope=spfile;

-- em OLAP considere criar o BD com tamanho de bloco maior para tudo (dados e indices)

