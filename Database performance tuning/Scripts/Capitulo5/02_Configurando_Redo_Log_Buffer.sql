-- ver se log buffer esta bem configurada (Tuning the Redolog Buffer Cache and Resolving Redo Latch Contention [ID 147471.1])
-- Colunas "misses" nao devem ser maior que 1% de GETS ou "IMMEDIATE_MISSES" nao deve ser maior que 1% de "IMMEDIATE_GETS" + "IMMEDIATE_MISSES". Se valores passarem 1%, existe contencao de atrasos na log buffer e ela necessita ser incrementada.
SELECT  substr(ln.name, 1, 20), gets, misses, immediate_gets, immediate_misses, 
        round( (misses / gets) * 100, 2) as perc_misses ,
        round( (immediate_misses / immediate_gets) * 100, 2) as perc_immediate_misses
FROM 	v$latch l, v$latchname ln 
WHERE   ln.name in ('redo allocation', 'redo copy') 
and 	ln.latch# = l.latch#;

-- ver eficiencia de alocacao de bytes no redo log buffer 
SELECT    T.VALUE AS EMTRIES,
          S.VALUE AS SPACE_REQUESTS,
          100-round((s.value/t.value)*100,5) "Redo log allocation eficiency"
from      v$sysstat s, v$sysstat t
WHERE     S.NAME = 'redo log space requests'
and       t.name = 'redo entries';

-- se for necessario alterar execute o comando abaixo (considerando o valor apropriado em bytes):
alter system set log_buffer=4096000 scope=spfile;


