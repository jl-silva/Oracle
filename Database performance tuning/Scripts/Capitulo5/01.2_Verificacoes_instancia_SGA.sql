-- verificar tamanho da SGA e cada subdivisao de memoria
-- avaliar nesta consulta, principalmente, shared pool e large pool
select             name,
                   mb as mb_total,
                   nvl(inuse,0) as mb_used,
                   round(100 - ((nvl(inuse,0) / mb) * 100),2) "perc_mb_free"                    
from  (
                  select   name, 
                          round(sum(mb),2) mb, 
                          round(sum(inuse),2) inuse        
                  from (
                          select case when name = 'buffer_cache' then 'buffer cache'
                                       when name = 'log_buffer'   then 'log buffer'
                                      else pool                     
                                  end name,                      
                                  bytes/1024/1024 mb,
                                  case when name = 'buffer_cache'
                                        then (bytes - (select count(*) 
                                                       from v$bh where status='free') *
                                                      (select value 
                                                      from v$parameter 
                                                      where name = 'db_block_size')
                                              )/1024/1024
                                      when name <> 'free memory'
                                            then bytes/1024/1024
                                  end inuse
                          from    v$sgastat
                        )
                WHERE     NAME is not null
                group by  name
            )
UNION ALL    
select      'SGA',
            round(sum(bytes)/1024/1024,2),
            (round(sum(bytes)/1024/1024,2)) - round(sum(decode(name,'free memory',bytes,0))/1024/1024,2),
            round((sum(decode(name,'free memory',bytes,0))/sum(bytes))*100,2)                        
from        v$sgastat;


-- ver a eficiencia da buffer cache, por subdivisao de memoria configurada (default, keep e recycle)
-- buffer cache pequeno gera muitas leituras fisicas e escritas adicionais p/ liberar espaco, gera "buffer cache LRU chains latch" 
SELECT  name,
        round((1 - (physical_reads / (db_block_gets + consistent_gets))) * 100,2) "perc_hit_ratio" 
FROM    V$BUFFER_POOL_STATISTICS
WHERE   db_block_gets + consistent_gets > 0;

-- verificar advisor de memoria para ver se aumentando memoria teria melhora de desempenho (estd_db_time)
select * from v$memory_target_advice order by memory_size;

-- verificar operacoes de redimensionamento automaticas
select 	component,oper_type,oper_mode,parameter, 
		initial_size, final_size, to_char(start_time,'dd/mm/yyyy hh24:mi:ss') start_time, to_char(end_time,'dd/mm/yyyy hh24:mi:ss') end_time 
from 	v$memory_resize_ops;
