-- configurando keep buffer pool
alter system set db_keep_cache_size = 100M;

-- alterando objeto para armazenar dados no keep pool
-- coloca
alter TABLE SCHEMA_NAME.TABLE_NAME storage (buffer_pool keep);
-- tira
alter index SCHEMA_NAME.INDEX_NAME storage (buffer_pool default);

-- voltar objeto para default buffer cache
alter TABLE SCHEMA.TABLE storage (buffer_pool default);

-- Para ver se objeto foi para a Keep Pool, execute a consulta abaixo e anote o valor de buf_got na Keep Pool, depois execute a instrucao SELECT na tabela q deve ir p/ a KP e execute novamente a instrucao SQL abaixo. Veja se buf_got aumentou. Se sim, foi p/ a KP, caso contrario, limpe antes a DP (ALTER SYSTEM FLUSH BUFFER_CACHE) e teste de novo.
select name, buf_got from v$buffer_pool_statistics;

-- adicionar objetos nao muito grandes que tenham alto percentual de blocos na buffer cache
SELECT      t1.owner                                          "OWNER",
            object_name                                       "Object_Name",
            CASE WHEN object_type = 'TABLE PARTITION' THEN 'TAB PART'
                    WHEN object_type = 'INDEX PARTITION' THEN 'IDX PART'
                    ELSE object_type END Object_Type,
            t2.num_rows, 
            t2.size_mb,
            SUM(num_blocks) "Num of Blocks in Buffer Cache",
            (SUM(num_blocks)/GREATEST(SUM(blocks), .001))*100   "% of Blocks in Buffer Cache",
            BUFFER_POOL "Buffer Pool",
            SUM(bytes)/SUM(blocks) "Block Size",
            t2.last_analyzed
FROM        (SELECT     o.owner,
                        o.object_name,
                        o.subobject_name,
                        o.object_type,
                        COUNT(DISTINCT FILE# || BLOCK#) num_blocks
             FROM       dba_objects o, 
                        v$bh bh
            WHERE       o.data_object_id  = bh.objd 
            AND         o.owner NOT IN ('SYS','SYSTEM')
            AND         bh.status != 'free'
            GROUP BY    o.owner, o.object_name, o.subobject_name, o.object_type
            ) T1,
            dba_segments S,
            (SELECT     t.owner,
                        t.table_name, 
                        t.num_rows, 
                        ROUND((t.blocks * p.value)/1024/1024,2) AS size_mb, 
                        t.last_analyzed
            FROM        dba_tables t,
                        v$parameter p
            WHERE       p.name = 'db_block_size') T2
WHERE       s.segment_name = t1.object_name
AND         s.owner = t1.owner
AND         s.segment_type = t1.object_type
AND         NVL(s.partition_name,'-') = NVL(t1.subobject_name,'-')
AND         T2.OWNER = T1.OWNER
AND         T2.table_name = object_name  
GROUP BY    t1.owner, object_name, object_type, BUFFER_POOL, t2.num_rows, t2.size_mb, t2.last_analyzed
HAVING      SUM(num_blocks) > 10
ORDER BY    SUM(num_blocks) DESC;