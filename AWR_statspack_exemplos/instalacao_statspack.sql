-- verificar se existe algum snapshot do statspack
select name, snap_id, to_char(snap_time, 'DD/MM/YYYY HH24:MI:SS') "Snapshot Time" from stats$snapshot,v$database;

-- cria um tablespace próprio para o statspack, não é necessário mas é recomendado
create tablespace PERFSTAT datafile '/home/oracle/app/oracle/oradata/orcl/perfstat.dbf' size 50M autoextend on next 50M maxsize 500M;

-- No oracle 12c para instalar o statspack no CDB é necessário alterar uma variável
alter session set "_oracle_script"=true;

-- instalação do statspack executar o script spcreate.sql que está dentro do oracle home conforme caminho abaixo
@?/rdbms/admin/spcreate.sql

-- alterando a senha caso necessário
alter user perfstat identified by oracle;

-- depois de criar os objetos que serão utilizados é recomendado coletar as estatisticas
exec dbms_stats.gather_schema_stats('PERFSTAT');

-- após estas etapas logar com o usuário perfstat e gerar o primeiro snapshot além de criar a job parar gera automáticamente os snaps
-- sqlplus perfstat/oracle
exec statspack.snap;
@?/rdbms/admin/spauto.sql

-- verificar se a job realmente foi criada
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
select job, what, LAST_DATE, NEXT_DATE, TOTAL_TIME, BROKEN, FAILURES from dba_jobs where SCHEMA_USER='PERFSTAT';

-- para gerar o relatório basta executar o script abaixo, lembrando que é necessário pelo menos 2 snaps para isto
@?/rdbms/admin/spreport.sql
