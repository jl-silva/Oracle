-- verificar se já existe algum profiler gerado
SELECT runid, run_comment FROM plsql_profiler_runs;

-- utilizando o profiler
SET SERVEROUTPUT ON
DECLARE

l_profilerresult BINARY_INTEGER;
l_val       NUMBER;
l_time      PLS_INTEGER;
l_cpu       PLS_INTEGER;
l_varchar   varchar2(500);
l_number    number;

cursor c01 is
    SELECT TO_CHAR(pess_dnas, 'DD/MM/YYYY') pess_dnas
      FROM pessoa
     WHERE ROWNUM <= 50000;

BEGIN

l_time := DBMS_UTILITY.get_time;
l_cpu  := DBMS_UTILITY.get_cpu_time;
l_profilerresult := DBMS_PROFILER.START_PROFILER('profiler01: ' || TO_CHAR(SYSDATE,'YYYYMMDD HH24:MI:SS'));

for r_c01 in c01 loop

    l_number := SO_NUMERO(r_c01.pess_dnas);
end loop;

l_profilerresult := DBMS_PROFILER.STOP_PROFILER;

DBMS_OUTPUT.put_line('Time=' || TO_CHAR(DBMS_UTILITY.get_time - l_time) || ' hsecs ' ||
                     'CPU Time=' || (DBMS_UTILITY.get_cpu_time - l_cpu) || ' hsecs ');
END;
/

-- utilizando o primeiro select é possível encontrar o profiler que se deseja verificar
-- com o select abaixo é possível verificar qual o comando de cada linha do pl/sql 
-- quantidade de vezes que foi chamada e quanto tempo levou
SELECT ppu.runid,
        ppu.unit_type,
        ppu.unit_name,
        ppd.line#,
        ppd.total_occur,
        ppd.total_time,
        ppd.min_time,
        ppd.max_time,
        a.TEXT
 FROM   plsql_profiler_units ppu,
        plsql_profiler_data ppd,
        all_source a
 WHERE ppu.runid = ppd.runid
 AND ppu.unit_number = ppd.unit_number
AND ppu.runid = &run_id
AND a.NAME(+) = ppu.unit_name
AND a.TYPE(+) = ppu.unit_type
AND a.OWNER(+) = ppu.unit_owner
AND a.LINE(+) = ppd.line#
ORDER BY ppu.unit_number, ppd.line#;