declare

cursor c01 is
   SELECT object_name
     FROM user_objects
    WHERE object_type = 'TABLE'
      AND object_name LIKE 'MGR_%';

begin

for r_c01 in c01 loop

    DBMS_STATS.GATHER_TABLE_STATS('DBAASS', r_c01.object_name, cascade=>TRUE);
end loop;

end;
/
SELECT *
  FROM USER_CONSTRAINTS
 WHERE TABLE_NAME LIKE 'OLI_%'
   AND CONSTRAINT_TYPE IN ('R', 'C');
   
declare

cursor c01 is
    SELECT ' ALTER TABLE ' || table_name || ' ENABLE CONSTRAINT ' || constraint_name sql_w 
      FROM USER_CONSTRAINTS
     WHERE TABLE_NAME LIKE 'OLI_%'
       --AND TABLE_NAME NOT IN ('OLI_MENSALID')
       AND CONSTRAINT_TYPE IN ('R', 'C')
       AND CONSTRAINT_NAME NOT IN ( 'CAMPUS_ESPECIAL', 'HABILITA_ALUNCURS', 'DISCIPLI_GRADDISC', 'ESPECIAL_ALUNCURS'
                                  , 'FACULDAD_ESPECIAL', 'FK_ALUNOS_IUNIEMPRESA', 'FK_AREACURS_IUNIEMPRESA', 'FK_CURSOS_IUNIEMPRESA'
                                  , 'FK_DISCIPLI_DISCODPAI', 'FK_GRADDISC_IUNIEMPRESA', 'FK_GRADE_IUNIEMPRESA', 'FK_GRUPCURS_IUNIEMPRESA'
                                  , 'FK_HABILITA_IUNIEMPRESA', 'FK_PARAMEDI_IUNIEMPRESA', 'FK_PESSFISI_IUNIEMPRESA', 'SYS_C0057454')
       AND STATUS = 'DISABLED';

begin

for r_c01 in c01 loop

    EXECUTE IMMEDIATE r_c01.sql_w;
end loop;

end;
/
----------------------- ENABLE/DISABLE DAS CONSTRAINTS QUE ESTÃO DESABILITADAS NA DEV ------------------------
declare

cursor c01 is
    SELECT ' ALTER TABLE ' || table_name || ' DISABLED CONSTRAINT ' || constraint_name sql_w 
      FROM USER_CONSTRAINTS
     WHERE TABLE_NAME LIKE 'OLI_%'
       AND CONSTRAINT_TYPE = 'R'
       AND STATUS = 'DISABLED';

begin

for r_c01 in c01 loop

    EXECUTE IMMEDIATE r_c01.sql_w;
end loop;

end;
/