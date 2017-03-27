-- Consulte a visao V$SYSSTAT  e procure por "table fetch continued row"
select  name, value 
from    v$sysstat  
where   name like '%table%';

-- encontrando objetos que possuem linhas encadeadas
set serveroutput on
declare
    v_SQL VARCHAR2(1000);
    v_contador NUMBER;
begin
        dbms_output.enable(null);
        FOR cur_tab IN (SELECT      owner, 
                                    table_name
                        FROM        dba_tables
                        WHERE       owner NOT IN ('SYS','SYSTEM','WKSYS','WMSYS','XDB','DBSNMP','OLAPSYS','MDSYS','EXFSYS','CTXSYS')
                        and         owner = UPPER('&schema')
                        AND         status = 'VALID'                        
                        AND         num_rows > 0
                        AND         (owner, table_name) NOT IN (SELECT OWNER, MVIEW_NAME FROM DBA_MVIEWS)
                        ORDER BY    1, 2 ) loop
            
            v_SQL:='ANALYZE TABLE ' || cur_tab.owner || '.' || cur_tab.table_name || ' COMPUTE STATISTICS';
            EXECUTE IMMEDIATE v_SQL;
            
             --2: Verifica se existem linhas encadeadas/migradas
            v_SQL:='SELECT  NVL(SUM(Chain_cnt),0)
                FROM    DBA_TABLES
                WHERE   owner = ''' || cur_tab.owner || '''
                AND     table_name = ''' || cur_tab.table_name || '''
                AND     status = ''VALID''
                AND     chain_cnt > 0';
            EXECUTE IMMEDIATE v_SQL INTO v_contador;
            
            if v_contador > 0 then
              dbms_output.put_line('A tabela ' || cur_tab.owner || '.' || cur_tab.table_name || ' possui ' || v_contador || ' lem(s)');
            end if;            
        end loop;
end;

-- executar script abaixo para criar tabela auxiliar CHAINED_ROWS (caso ela ainda nao exista)
  ORACLE_HOME/rdbms/admin/utlchain.sql
 
-- analise a tabela 
analyze table schema.table list chained rows into CHAINED_ROWS;  

-- veja as linhas encadeadas
select * from CHAINED_ROWS;

-- crie uma tabela auxiliar p/ conter os dados das linhas encadeadas
create table aux_chained as 
select * from xx
where rowid in (select head_rowid from chained_rows
                where table_name = UPPER('table')
                and owner_name = UPPER('schema'))

-- apague os dados da tabela analisada                
delete from xx
where rowid in (select head_rowid from chained_rows
                where table_name = UPPER('table')
                and owner_name = UPPER('schema'));

-- efetue um shrink na tabela                
ALTER TABLE xx SHRINK SPACE;                

-- insira os dados da tabela auxiliar na tabela analisada
insert into xx select * from aux_chained;

-- atualize estatisticas com dbms_stats
exec dbms_stats.gather_table_stats('SCHEMA','TABLE');
