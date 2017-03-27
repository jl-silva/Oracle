-- V$SYS_TIME_MODEL mostra tempo (em microsegundos) acumulado de sistema para varias operacoes no BD
select lpad( ' ', ( level - 1 ) * 2 )  ||
  stat_name as stat_name
        , round(value/1000000,2) time_second 
        , round(value/1000000/60,2) time_min
        , case stat_name
            when 'background elapsed time'                           then '1'
            when 'background cpu time'                               then '1-1'
            when 'RMAN cpu time (backup/restore)'                    then '1-1-1'
            when 'DB time'                                           then '2'
            when 'DB CPU'                                            then '2-1'
            when 'connection management call elapsed time'           then '2-2'
            when 'sequence load elapsed time'                        then '2-3'
            when 'sql execute elapsed time'                          then '2-4'
            when 'parse time elapsed'                                then '2-5'
            when 'hard parse elapsed time'                           then '2-5-1'
            when 'hard parse (sharing criteria) elapsed time'        then '2-5-1-1'
            when 'hard parse (bind mismatch) elapsed time'           then '2-5-1-1-1'
            when 'failed parse elapsed time'                         then '2-5-2'
            when 'failed parse (out of shared memory) elapsed time'  then '2-5-2-1'
            when 'PL/SQL execution elapsed time'                     then '2-6'
            when 'inbound PL/SQL rpc elapsed time'                   then '2-7'
            when 'PL/SQL compilation elapsed time'                   then '2-8'
            when 'Java execution elapsed time'                       then '2-9'
            when 'repeated bind elapsed time'                        then '2-A'
            else '9'
          end as pos
     from (
            select /*+ no_merge */
                   stat_name
                 , stat_id
                 , value
                 , case
                   when stat_id in (2411117902)
                   then 2451517896
                   when stat_id in (268357648)
                   then 3138706091
                   when stat_id in (3138706091)
                   then 372226525
                   when stat_id in (4125607023)
                   then 1824284809
                   when stat_id in (2451517896)
                   then 4157170894
                   when stat_id in (372226525,1824284809)
                   then 1431595225
                   when stat_id in (3649082374,4157170894)
                   then null
                   else 3649082374
                   end parent_stat_id
              from v$sys_time_model
          )
   connect by prior stat_id = parent_stat_id
   start with parent_stat_id is null
   order by pos;


/* algumas estatisticas sao filhas de outras, que contem o valor acumulado, como detalhado na lista abaixo
1) background elapsed time
      2) background cpu time
1) DB time
    2) DB CPU
    2) connection management call elapsed time
    2) sequence load elapsed time
    2) sql execute elapsed time
    2) parse time elapsed
          3) hard parse elapsed time
                4) hard parse (sharing criteria) elapsed time
                    5) hard parse (bind mismatch) elapsed time
          3) failed parse elapsed time
                4) failed parse (out of shared memory) elapsed time
    2) PL/SQL execution elapsed time
    2) inbound PL/SQL rpc elapsed time
    2) PL/SQL compilation elapsed time
    2) Java execution elapsed time
/*