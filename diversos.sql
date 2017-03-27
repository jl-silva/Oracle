CREATE OR REPLACE VIEW OLI_V_EQUIDISC AS
SELECT b.equcod, b.equdesc, b.equtipo, b.equdata
     , a.discod disc_antiga, e.disdesc disc_antiga_desc
     , c.discod disc_nova, f.disdesc disc_nova_desc
     , (SELECT MAX(d.msem_seme)
        FROM mgr_semestre d
       WHERE b.equdata BETWEEN d.msem_dini AND d.msem_dfim) seme
    FROM oli_discanti a
     , oli_equidisc b
     , oli_discnova c
     , oli_discipli e
     , oli_discipli f
   WHERE b.equcod = a.equcod
     AND c.equcod = b.equcod
     AND e.discod = a.discod
     AND f.discod = c.discod
   UNION ALL
  SELECT ge.grupcod equcod, ge.grupdesc equdesc, 'D' equtipo, ge.grupalteradoem equdata
     , de1.discod disc_antiga, z.disdesc disc_antiga_desc
     , de2.discod disc_nova, y.disdesc disc_nova_desc
     , (SELECT MAX(d.msem_seme)
        FROM mgr_semestre d
       WHERE NVL(ge.grupcadastradoem, ge.grupalteradoem) BETWEEN d.msem_dini AND d.msem_dfim) seme
      FROM oli_grupoequivalencia ge
       , oli_disciplinaequivalente de1
     , oli_disciplinaequivalente de2
     , oli_discipli z
     , oli_discipli y
   WHERE ge.grupcod = de1.grupcod
       AND ge.grupcod = de2.grupcod
     AND de1.discod <> de2.discod
     AND z.discod = de1.discod
     AND y.discod = de2.discod;

oli_discanti                    744757          745.934         1177
oli_equidisc                    743231          744.412         1181
oli_discnova                    750565          751.717         1152
oli_discipli                    18070           166.038         147968
oli_grupoequivalencia           997             997             0
oli_disciplinaequivalente       69552           69.551          -1

CREATE TABLE OLI_EQUIDISC_TAB AS SELECT * FROM OLI_V_EQUIDISC

declare

begin

DELETE FROM jls_1;
commit work write batch nowait;

DELETE FROM jls_2;
commit work write batch nowait;

end;
/

EXEC DBMS_STATS.GATHER_TABLE_STATS('DBAASS', 'OLI_ALUNDISCMINI_TEMP', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('DBAASS', 'OLI_HISTORICO_ALUNO', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('DBAASS', 'OLI_HISTORICO_ALUNO_CONV', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('DBAASS', 'OLI_EQUIDISC_TAB', cascade=>TRUE);

create or replace
procedure p_alimenta_grade_aluno_teste is

cursor c_alun_gcur is
    SELECT b.malu_alun
         , MAX(c.mgcu_gcur) mgcu_gcur
      FROM mgr_versao a
         , mgr_aluno b
         , mgr_grade_curso c
     WHERE a.mver_migr = 3
       AND b.malu_mver = a.mver_sequ
       AND b.malu_atua = 'S'
       AND c.mgcu_sequ = b.malu_mgcu
     GROUP BY b.malu_alun;

begin

for r_c01 in c_alun_gcur loop

    begin
        UPDATE aluno
           SET alun_gcur = r_c01.mgcu_gcur
         WHERE alun_codi = r_c01.malu_alun;
    exception
    when others then
        rollback;
        INSERT INTO JLS (DS) VALUES ('Aluno: ' || r_c01.malu_alun || ' grade: ' || r_c01.mgcu_gcur);
        commit;
        raise_application_error(-20011, 'Erro');
    end;
end loop;

end p_alimenta_grade_aluno_teste;
/

-- gerar o excel, mandar e-mail e ligar
-- EXPORTAÇÃO DOS DADOS PARA ROBERTA
SELECT DISTINCT ohia_disc discod, ohia_turs tmacod, ohia_dtip dimtip
     , ohia_curs espcod, ohia_grad gracod, null habcod
     , ohia_ddgi nome_disciplina, espdesc nome_curso
     , msed_nome unidade, ohia_seme semestre
     , ohia_dgio codigo_disciplina_gioconda
  FROM oli_historico_aluno
     , oli_especial
     , mgr_sede
 WHERE 1 = 1
   AND espcod(+) = ohia_curs
   AND msed_chav(+) = iunicodempresa
 ORDER BY nome_disciplina, ohia_seme

--Z:\TI\Sistemas Presencial\importacao_olimpo\tratativas uniasselvi\trabalho_com_areas\academico

FINANCEIRO DESSA 949724

ACADEMICO LIGIA 274120 ESTÁ COMO DESISTENTE
o update no aluno pega o MIN -- VER COM DÉCIO ESTA SITUAÇÃO

declare

begin

DBMS_STATS.set_global_prefs (pname   => 'GLOBAL_TEMP_TABLE_STATS', pvalue  => 'SHARED');

pkg_mgr_olimpo.p_alim_tabelas_temporarias;

DBMS_STATS.gather_table_stats('DBAASS','OLI_ALUNDISCMINI_TEMP');
end;
/

declare

begin

UPDATE jls
   SET ds_clob = '2';
commit;

end;
/

declare

t_num       pkg_util.tb_number;

cursor c01 is
    SELECT num
      FROM jls;

begin
open c01;
loop
    fetch c01 bulk collect into t_num
    limit 50000;
    exit when t_num.count = 0;

    forall i in t_num.first..t_num.last
        UPDATE jls
           SET ds_clob = '2'
         WHERE num = t_num(i);
        commit;
end loop;
close c01;
end;
/

DECLARE
  l_sql_stmt VARCHAR2(1000);
  l_try NUMBER;
  l_status NUMBER;
BEGIN
 
  -- Create the TASK
  DBMS_PARALLEL_EXECUTE.CREATE_TASK ('mytask');
 
  -- Chunk the table by ROWID
  --DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_ROWID('mytask', 'HR', 'EMPLOYEES', true, 100);
 
  -- Chunk the table by number column
  DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_NUMBER_COL ('mytask', 'DBAASS', 'JLS', 'NUM', 250);

  -- Execute the DML in parallel
  l_sql_stmt := 'update JLS  
      SET ds_clob = ''1''
      WHERE num BETWEEN :start_id AND :end_id';

  DBMS_PARALLEL_EXECUTE.RUN_TASK('mytask', l_sql_stmt, DBMS_SQL.NATIVE, parallel_level => 10);
 
  -- If there is an error, RESUME it for at most 2 times.
  L_try := 0;
  L_status := DBMS_PARALLEL_EXECUTE.TASK_STATUS('mytask');
  WHILE(l_try < 2 and L_status != DBMS_PARALLEL_EXECUTE.FINISHED) 
  LOOP
    L_try := l_try + 1;
    DBMS_PARALLEL_EXECUTE.RESUME_TASK('mytask');
    L_status := DBMS_PARALLEL_EXECUTE.TASK_STATUS('mytask');
  END LOOP;
 
  -- Done with processing; drop the task
  DBMS_PARALLEL_EXECUTE.DROP_TASK('mytask');
   
END;
/

DECLARE
  l_sql_stmt VARCHAR2(1000);
  l_try NUMBER;
  l_status NUMBER;
BEGIN

  -- Create the TASK
  DBMS_PARALLEL_EXECUTE.CREATE_TASK ('mytask');

  -- Chunk the table by ROWID
  DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_ROWID('mytask', 'DBAASS', 'JLS', true, 50000);

  -- Execute the DML in parallel
  l_sql_stmt := 'update JLS 
      SET DS_CLOB = ''1''
      WHERE rowid BETWEEN :start_id AND :end_id';

  DBMS_PARALLEL_EXECUTE.RUN_TASK('mytask', l_sql_stmt, DBMS_SQL.NATIVE, parallel_level => 10);

  -- If there is an error, RESUME it for at most 2 times.
  L_try := 0;
  L_status := DBMS_PARALLEL_EXECUTE.TASK_STATUS('mytask');
  WHILE(l_try < 2 and L_status != DBMS_PARALLEL_EXECUTE.FINISHED)
  LOOP
    L_try := l_try + 1;
    DBMS_PARALLEL_EXECUTE.RESUME_TASK('mytask');
    L_status := DBMS_PARALLEL_EXECUTE.TASK_STATUS('mytask');
  END LOOP;

  -- Done with processing; drop the task
  DBMS_PARALLEL_EXECUTE.DROP_TASK('mytask');

END;
/

643219 

update full =   33.79       37.17       37.50
update bulk =   44.56       45.96       47.45
update para =   27.26       32.81       24.42

2366041

update full =   2:19.64     2:15.97     2:02.59
update bulk =   2:47.61     2:38.14     2:49.15
update para =   1:52.68     2:01.15     2:00.78

teste aumentando a transação para 50000
update bulk =   2:57.42     2:53.57
update para =   1:55.54     2:01.68

declare

t_titu_nnum     pkg_util.tb_varchar2_50;

cursor c01 is
    SELECT DISTINCT mcra_rnum
      FROM mgr_credito_aluno
     WHERE mcra_rnum IS NOT NULL;

begin

open c01;
loop
    fetch c01 bulk collect into t_titu_nnum
    limit pkg_util.c_limit_trans;
    exit when t_titu_nnum.count = 0;

    forall i in t_titu_nnum.first..t_titu_nnum.last
        UPDATE titulo
           SET titu_vdif = 0
         WHERE titu_nnum = t_titu_nnum(i);
    COMMIT;
end loop;
close c01;

end;
/


UPDATE MGR_ALUNO SET MALU_MGCU = NULL;
COMMIT;
UPDATE OLI_HISTORICO_ALUNO SET OHIA_MGCU = NULL;
COMMIT;
DELETE FROM mgr_formando;
COMMIT;
DELETE FROM mgr_grade_seme_prof_disc;
COMMIT;
DELETE FROM mgr_matricula;
COMMIT;
DELETE FROM mgr_aluno_validacao;
COMMIT;
DELETE FROM mgr_grade_semestre;
COMMIT;
DELETE FROM mgr_grade;
COMMIT;
DELETE FROM mgr_grade_curso;
COMMIT;


MGR_ATIVIDADE_COMPLEMENTAR

MACO_SEQU   NUMBER         
MACO_ATUA   VARCHAR2(1)    
MACO_DATU   DATE           
MACO_MVER   NUMBER         
MACO_SEME   V6             semestre
MACO_ALUN   N10            aluno
MACO_CODI   N9             codigo
MACO_DATA   D              data da ativ
MACO_DESC   V150           descrição
MACO_CARG   N3             carga total
MACO_HORA   N3             horas aprovadas
MACO_ATIP   N5 99999       
MACO_VALI   V1  'S'        
MACO_MALU   N10
MACO_MSEM   N10



SELECT NVL(b.aevtermino, b.aevinicio) maco_data
     , b.aevdesc maco_desc
     , DECODE(b.aevabono, 'S', b.aevcargahoraria, null) maco_hora
     , b.aevcargahoraria maco_carg
     , a.malu_sequ maco_malu
     , d.msem_sequ maco_msem
     , b.aevabono maco_vali
     , b.alucod || ';' || b.espcod || ';' || b.aevnum maco_chav
  FROM mgr_aluno a
     , oli_aluneven b
     , mgr_curso c
     , mgr_semestre d
 WHERE a.malu_atua = 'S'
   AND EXISTS( SELECT 1
                 FROM mgr_versao x
                WHERE x.mver_migr = 3
                  AND x.mver_sequ = a.malu_mver)
   AND c.mcur_sequ = a.malu_mcur
   AND b.alucod = a.malu_chav
   AND b.espcod = c.mcur_chav
   AND d.msem_chav = b.pelcod;
   
   
declare

t_malu_alun     pkg_util.tb_number;

cursor c01 is 
    SELECT DISTINCT malu_alun
      FROM mgr_aluno
     WHERE malu_atua = 'S';

begin

for r_c01 in c01 loop
    begin
        DELETE FROM atividade_complementar
         WHERE ativ_alun = r_c01.malu_alun;
    COMMIT;
    exception
        when others then
        null;
    end;
end loop;

end;
/


declare

t_mfor_sequ     pkg_util.tb_number;
t_form_alun     pkg_util.tb_number;
t_form_seme     pkg_util.tb_varchar2_10;
t_form_turs     pkg_util.tb_varchar2_10;

cursor c01 is 
    SELECT a.mfor_sequ
         , a.mfor_alun
         , a.mfor_seme
         , a.mfor_turs
      FROM mgr_formando a
     WHERE a.mfor_atua = 'S'
       AND a.mfor_mver = 5
       AND EXISTS(SELECT 1
                    FROM formando b
                   WHERE b.form_alun = a.mfor_alun
                     AND b.form_seme = a.mfor_seme
                     AND b.form_turs = a.mfor_turs);

begin

open c01;
loop
    fetch c01 bulk collect into t_mfor_sequ, t_form_alun, t_form_seme, t_form_turs
    limit pkg_util.c_limit_trans;
    exit when t_form_turs.count = 0;

    begin
        forall i in t_form_turs.first..t_form_turs.last SAVE EXCEPTIONS
            DELETE FROM formando
             WHERE form_alun = t_form_alun(i)
               AND form_seme = t_form_seme(i)
               AND form_turs = t_form_turs(i);
    exception
    when others then
        NULL;
    end;
    COMMIT;
    
    forall i in t_mfor_sequ.first..t_mfor_sequ.last
        UPDATE mgr_formando
           SET mfor_alun = null
             , mfor_seme = null
             , mfor_turs = null
         WHERE mfor_sequ = t_mfor_sequ(i);
end loop;
close c01;

end;
/

declare

t_ativ_alun     pkg_util.tb_number;
t_ativ_codi     pkg_util.tb_number;
t_ativ_seme     pkg_util.tb_varchar2_10;

cursor c01 is 
    SELECT a.ativ_seme
         , a.ativ_alun
         , a.ativ_codi
      FROM atividade_complementar a
     WHERE EXISTS( SELECT 1
                     FROM mgr_aluno x
                    WHERE x.malu_alun = a.ativ_alun);

begin

DELETE FROM mgr_atividade_complementar;
COMMIT;

open c01;
loop
    fetch c01 bulk collect into t_ativ_seme, t_ativ_alun, t_ativ_codi
    limit pkg_util.c_limit_trans;
    exit when t_ativ_seme.count = 0;

    begin
        forall i in t_ativ_seme.first..t_ativ_seme.last SAVE EXCEPTIONS
            DELETE FROM atividade_complementar
             WHERE ativ_seme = t_ativ_seme(i)
               AND ativ_alun = t_ativ_alun(i)
               AND ativ_codi = t_ativ_codi(i);
    exception
    when others then
        NULL;
    end;
    COMMIT;
end loop;
close c01;

end;
/

UPDATE MGR_PROFESSOR
   SET MPRO_PROF = 100101508
 WHERE MPRO_SEQU = 850;

 UPDATE MGR_PROFESSOR
   SET MPRO_PROF = 100101509
 WHERE MPRO_SEQU = 1250;
 
 UPDATE MGR_PROFESSOR
   SET MPRO_PROF = 100101510
 WHERE MPRO_SEQU = 1258;
 
 UPDATE MGR_PROFESSOR
   SET MPRO_PROF = 100101511
 WHERE MPRO_SEQU = 1261;
 
 COMMIT;
 
 MPRO_SEQU MPES_PESS PROF_CODI
 850   1000088875    100101508
1250   1000088876    100101509
1258   1000088877    100101510
1261   1000088878    100101511
