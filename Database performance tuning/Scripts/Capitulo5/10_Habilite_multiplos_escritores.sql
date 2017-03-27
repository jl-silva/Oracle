-- Se o seu sistema permite escrita assincrona normalmente vc nao precisara aumentar a qtde de processos escritores.
-- Aumente somente se "buffer busy waits" ocorrerem. Configure 1 escritor para cada 8 CPUs. Nunca crie mais escritores do que a qtde. de CPUs.
alter system set db_writer_processes=x scope=spfile;
shutdown immediate;
startup;

--Obs.: 10G suporte ate 20, no 11G suporta ate 36 processos escritores


-- Se o seu sistema nao permite escrita assincrona, nao configure db_writer_processes, configure o parametro DBWR_IO_SLAVES (simula escrita assincrona)
alter system set DBWR_IO_SLAVES=x scope=spfile;
shutdown immediate;
startup; 


-- CONSIDERE USAR QUANDO ENCONTRAR MENSAGEM SIMILAR NO ALERT:
Thread 1 advanced to log sequence 2234 
    Current log# 4 seq# 2234 mem# 0: /orcl/oradata/logs/redo_logs04.log 
  Thread 1 cannot allocate new log, sequence 2234 
  Checkpoint not complete