declare

begin
EXECUTE IMMEDIATE 'alter session set statistics_level=ALL';
EXECUTE IMMEDIATE 'alter session set tracefile_identifier=ger_arq_monitor_ans';
EXECUTE IMMEDIATE 'alter session set max_dump_file_size=UNLIMITED';
EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context forever, level 12''';
EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context off''';
end;

-- pegar o caminho onde o mesmo está salvo
SHOW PARAMETER USER_DUMP_DEST

-- aplicando tkprof
tkprof caminho/arquivo_trace.trc caminho/arquivo_destino.txt

exemplo => tkprof /app/oracle/admin/udump/msid_146632.trc /home/oracle/saida_trace.txt


-- outra forma
-- Ver sessões abertas (Filtrar de acordo com necessidade)
select * from v$session where program <> 'plsqldev.exe' and username = 'GESTOR_MASTER'
 
-- Para ativar o Trace (Especificar SID e SERIAL#)
exec DBMS_MONITOR.session_trace_enable (session_id => 136,serial_num => 7854);
 
-- Após operações de DML, será necessário desativar o trace.
-- Para desativar o Trace (Especificar SID e SERIAL#)
exec DBMS_MONITOR.session_trace_disable (session_id => 136,serial_num => 7854);
 
-- Para ver onde o arquivo de trace (TRC) será armazenado:
SHOW PARAMETER USER_DUMP_DEST;
 
-- Para gerar o arquivo de texto contendo as operações auditadas
-- Executar no SHELL:
-- tkprof /caminho/arquivo.trc /caminho/arquivo_destino.txt