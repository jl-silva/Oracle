create or replace
package pkg_mgr_olimpo is

TYPE t_dado_disc IS RECORD( 
	 credito 		number(3)
   , pratica 		number(3)
   , complementar 	number(3)
   , estagio		number(3)
   , carga_horaria	number(3)
   , tipo			varchar2(1));

function f_seme_ini_imp_academico return varchar2 DETERMINISTIC;

function f_seme_ini_imp_financeiro return varchar2 DETERMINISTIC;

function f_seme_fim_imp_financeiro return varchar2 DETERMINISTIC;

procedure p_alim_tabelas_temporarias;

function f_obter_disc_equi_roberta( p_discod 	oli_discipli.discod%type
								  , p_espcod	oli_graddisc.gracod%type
								  , p_gracod	oli_graddisc.gracod%type) return number;

function f_retorna_cpf_aluno( p_alucod oli_alunos.alucod%type
                            , p_alucpf oli_alunos.alucpf%type
                            , p_so_cpf varchar2 default 'N') return varchar2 DETERMINISTIC;

function f_retorna_cpf_professor(   p_prfcod oli_professo.prfcod%type
                                  , p_prfcpf oli_professo.prfcpf%type
                                  , p_so_cpf varchar2 default 'N') return varchar2 DETERMINISTIC;

procedure p_executa_importacao( p_migr_sequ     mgr_migracao.migr_sequ%type
                              , p_mver_sequ     mgr_versao.mver_sequ%type);

procedure p_alimenta_forma_ingresso( p_migr_sequ     mgr_migracao.migr_sequ%type);

procedure p_importa_formando(   p_migr_sequ     mgr_migracao.migr_sequ%type
                              , p_mver_sequ     mgr_versao.mver_sequ%type);

end pkg_mgr_olimpo;
/
create or replace
package body pkg_mgr_olimpo is

function f_seme_ini_imp_academico return varchar2 DETERMINISTIC is

l_semestre	mgr_semestre.msem_seme%type;

begin
	SELECT MIN(msem_seme)
	  INTO l_semestre
	  FROM oli_perileti_uni
		 , mgr_semestre
	 WHERE msem_chav = pelcod;
	 
	return l_semestre;

end f_seme_ini_imp_academico;

function f_seme_ini_imp_financeiro return varchar2 DETERMINISTIC is

l_semestre	mgr_semestre.msem_seme%type;

begin
	l_semestre := '2013/1';
	 
	return l_semestre;

end f_seme_ini_imp_financeiro;

function f_seme_fim_imp_financeiro return varchar2 DETERMINISTIC is

l_semestre	mgr_semestre.msem_seme%type;

begin
	l_semestre := '2016/2';
	 
	return l_semestre;

end f_seme_fim_imp_financeiro;

function f_retorna_cpf_aluno( p_alucod oli_alunos.alucod%type
                            , p_alucpf oli_alunos.alucpf%type
                            , p_so_cpf varchar2 default 'N') return varchar2 DETERMINISTIC is

begin

if  (p_alucod = 815399) then
    return '09805309975';
elsif (p_so_cpf = 'S') then
    return pkg_mgr_imp_producao_aux.mgr_compara_string(p_alucpf);
else
    return pkg_mgr_imp_producao_aux.mgr_compara_string(NVL(p_alucpf, TO_CHAR(p_alucod)));
end if;

end f_retorna_cpf_aluno;

function f_retorna_cpf_professor(   p_prfcod oli_professo.prfcod%type
                                  , p_prfcpf oli_professo.prfcpf%type
                                  , p_so_cpf varchar2 default 'N') return varchar2 DETERMINISTIC is

begin

if  (p_prfcod = 4928) then
    return '51473461120';
elsif (p_so_cpf = 'S') then
    return pkg_mgr_imp_producao_aux.mgr_compara_string(p_prfcpf);
else
    return pkg_mgr_imp_producao_aux.mgr_compara_string(NVL(p_prfcpf, TO_CHAR(p_prfcod)));
end if;

end f_retorna_cpf_professor;

procedure p_alimenta_tab_cidade_temp is

t_cidd_codi     pkg_util.tb_number;
t_cidd_nome     pkg_util.tb_varchar2_150;
t_cidd_esta     pkg_util.tb_varchar2_5;

-- retorna apenas as cidades do pais 1, que nos interessam hoje
cursor c_cidd_temp is
    SELECT cidd_codi
         , pkg_mgr_imp_producao_aux.mgr_compara_string(cidd_nome)
         , cidd_esta
      FROM cidade
     WHERE cidd_pais = 1;

begin

-- primeiro trunca a tabela para garantir que não existam dados gerados na sessão, como é uma tabela temporária não temos problemas em truncar
EXECUTE IMMEDIATE ' truncate table mgr_cidade_temp ';

-- alimenta a tabela temporária das cidades, esta tabela é utilizada para identificar as cidades
open c_cidd_temp;
loop
    fetch c_cidd_temp bulk collect into t_cidd_codi, t_cidd_nome, t_cidd_esta
    limit pkg_util.c_limit_trans;
    exit when t_cidd_codi.count = 0;
    
    forall i in t_cidd_codi.first .. t_cidd_codi.last
        INSERT INTO mgr_cidade_temp (
               cidd_codi, cidd_nome, cidd_esta
        ) VALUES (
               t_cidd_codi(i), t_cidd_nome(i), t_cidd_esta(i)
        );
    COMMIT;
end loop;
close c_cidd_temp;

end p_alimenta_tab_cidade_temp;

procedure p_alimenta_alunos_temp is

t_alucod        pkg_util.tb_number;
t_mpes_pcpf     pkg_util.tb_varchar2_50;

cursor c_alun_temp is
    SELECT a.alucod
         , pkg_mgr_olimpo.f_retorna_cpf_aluno(a.alucod, a.alucpf) alucpf
      FROM oli_alunos a;

begin
-- primeiro trunca a tabela para garantir que não existam dados gerados na sessão, como é uma tabela temporária não temos problemas em truncar
EXECUTE IMMEDIATE ' truncate table oli_aluno_temp ';

open c_alun_temp;
loop
    fetch c_alun_temp bulk collect into t_alucod, t_mpes_pcpf
    limit pkg_util.c_limit_trans;
    exit when t_mpes_pcpf.count = 0;
    
    forall i in t_mpes_pcpf.first .. t_mpes_pcpf.last
        INSERT INTO oli_aluno_temp(
               alucod, mpes_pcpf
        ) VALUES (
               t_alucod(i), t_mpes_pcpf(i)
        );
    COMMIT;
end loop;
close c_alun_temp;

end p_alimenta_alunos_temp;

procedure p_alimenta_alundiscmini_temp is

t_alucod    pkg_util.tb_number;
t_tmacod    pkg_util.tb_varchar2_50;
t_pelcod    pkg_util.tb_number;
t_espcod    pkg_util.tb_number;

-- guardamos registros de todos os semestres que o aluno possui matricula juntamente com as turmas
-- utilizamos esta tabela para diminuir a quantidade de registros no processamento e agilizar o processo
-- um registro nesta tabela significa que o aluno tem matrícula em pelo menos uma disciplina no referido semestre
cursor c_admt is
    SELECT DISTINCT a.alucod
         , a.tmacod
         , b.pelcod
         , a.espcod
      FROM oli_alundisc a
         , oli_discmini b
         , oli_perileti_uni c
     WHERE b.discod = a.discod
       AND b.tmacod = a.tmacod
       AND b.dimtip = a.dimtip
       AND c.pelcod = b.pelcod
     UNION
    SELECT DISTINCT a.alucod
         , b.tmacod
         , b.pelcod
         , a.espcod
      FROM oli_alundisc a
         , oli_aluncurs b
         , oli_perileti_uni c
     WHERE b.alucod = a.alucod
       AND b.espcod = a.espcod
       AND c.pelcod = b.pelcod;

begin
-- primeiro trunca a tabela para garantir que não existam dados gerados na sessão, como é uma tabela temporária não temos problemas em truncar
EXECUTE IMMEDIATE ' truncate table oli_alundiscmini_temp ';

open c_admt;
loop
    fetch c_admt bulk collect into  t_alucod, t_tmacod, t_pelcod
                                  , t_espcod
    limit pkg_util.c_limit_trans;
    exit when t_alucod.count = 0;

    forall i in t_alucod.first..t_alucod.last
        INSERT INTO oli_alundiscmini_temp(
               alucod, tmacod, pelcod
             , espcod
        ) VALUES (
               t_alucod(i), t_tmacod(i), t_pelcod(i)
             , t_espcod(i)
        );
    COMMIT;
end loop;
close c_admt;

end p_alimenta_alundiscmini_temp;

procedure p_alimenta_especial_temp is

t_espcod    pkg_util.tb_number;
t_codemp    pkg_util.tb_number;

cursor c_espe is
    SELECT a.espcod
         , a.iunicodempresa
      FROM oli_especial a
      -- só irá retornar os cursos que fazem sentido para nós, cursos que sejam de 2013/1 em diante
      -- que tiveram turmas e alunos matriculados
     WHERE a.iunicodempresa BETWEEN 543 AND 549
     -- foi decidido em reunião de alinhamento do projeto no dia 18/10/2016 
     -- que estes cursos de idioma e pronatec não serão importados neste primeiro momento.
     -- será aberto outro projeto para esta migração
       AND a.espcod NOT IN ('2674', '2705', '2664', '2678', '3083', '3085', '3084'
                          , '3020', '2831', '2829', '3321', '3478', '3470', '3667'
                          , '3469', '3480', '3326', '3322', '3670', '4067', '3487'
                          , '3486', '3668', '3669', '3672', '1038', '9', '10'
                          , '99031', '99070', '99037')
       AND EXISTS( SELECT 1
                     FROM oli_alundiscmini_temp e
                    WHERE e.espcod = a.espcod);

begin
-- primeiro trunca a tabela para garantir que não existam dados gerados na sessão, como é uma tabela temporária não temos problemas em truncar
EXECUTE IMMEDIATE ' truncate table oli_especial_temp ';

-- retorna todas as especialidades que nos interessam neste processo
open c_espe;
loop
    fetch c_espe bulk collect into  t_espcod, t_codemp
    limit pkg_util.c_limit_trans;
    exit when t_espcod.count = 0;

    forall i in t_espcod.first..t_espcod.last
        INSERT INTO oli_especial_temp(
               espcod, iunicodempresa
        ) VALUES (
                t_espcod(i), t_codemp(i)
        );
    COMMIT;
end loop;
close c_espe;

end p_alimenta_especial_temp;

procedure p_alimenta_professor_temp is

t_prfcod        pkg_util.tb_number;
t_mpes_pcpf     pkg_util.tb_varchar2_50;

cursor c_prof_temp is
    SELECT a.prfcod
         , pkg_mgr_olimpo.f_retorna_cpf_professor(a.prfcod, a.prfcpf, 'S')
      FROM oli_professo a;

begin
-- primeiro trunca a tabela para garantir que não existam dados gerados na sessão, como é uma tabela temporária não temos problemas em truncar
EXECUTE IMMEDIATE ' truncate table oli_professo_temp ';

open c_prof_temp;
loop
    fetch c_prof_temp bulk collect into t_prfcod, t_mpes_pcpf
    limit pkg_util.c_limit_trans;
    exit when t_mpes_pcpf.count = 0;
    
    forall i in t_mpes_pcpf.first .. t_mpes_pcpf.last
        INSERT INTO oli_professo_temp(
               prfcod, mpes_pcpf
        ) VALUES (
               t_prfcod(i), t_mpes_pcpf(i)
        );
    COMMIT;
end loop;
close c_prof_temp;

end p_alimenta_professor_temp;

procedure p_alimenta_oli_equidisc_tab is

t_equcod            pkg_util.tb_number;
t_equdesc           pkg_util.tb_varchar2_150;
t_equtipo           pkg_util.tb_varchar2_1;
t_equdata           pkg_util.tb_date;
t_disc_anti         pkg_util.tb_number;
t_disc_antd         pkg_util.tb_varchar2_150;
t_disc_nova         pkg_util.tb_number;
t_disc_novd         pkg_util.tb_varchar2_150;
t_seme              pkg_util.tb_varchar2_10;
t_disc_novt         pkg_util.tb_varchar2_1;
t_disc_antt         pkg_util.tb_varchar2_1;

cursor c_equi is
    SELECT equcod
         , equdesc
         , equtipo
         , equdata
         , disc_antiga
         , disc_antiga_desc
         , disc_nova
         , disc_nova_desc
         , seme
         , disc_antiga_tipo
         , disc_nova_tipo
      FROM oli_v_equidisc
	 -- disciplinas que a Roberta pediu para não considerar
	 WHERE (disc_antiga != 660178 AND disc_nova != 160129)
       AND (disc_antiga != 660178 AND disc_nova != 162096)
       AND (disc_antiga != 167308 AND disc_nova != 163359)
       AND (disc_antiga != 163359 AND disc_nova != 167308);

begin

EXECUTE IMMEDIATE 'TRUNCATE TABLE OLI_EQUIDISC_TAB';

open c_equi;
loop
    fetch c_equi bulk collect into t_equcod, t_equdesc, t_equtipo
                                 , t_equdata, t_disc_anti, t_disc_antd
                                 , t_disc_nova, t_disc_novd, t_seme
                                 , t_disc_antt, t_disc_novt
    limit pkg_util.c_limit_trans;
    exit when t_equcod.count = 0;

    forall i in t_equcod.first..t_equcod.last
        INSERT INTO oli_equidisc_tab(
            equcod, equdesc, equtipo
          , equdata, disc_antiga, disc_antiga_desc
          , disc_nova, disc_nova_desc, seme
          , disc_antiga_tipo, disc_nova_tipo
        ) VALUES (
            t_equcod(i), t_equdesc(i), t_equtipo(i)
          , t_equdata(i), t_disc_anti(i), t_disc_antd(i)
          , t_disc_nova(i), t_disc_novd(i), t_seme(i)
          , t_disc_antt(i), t_disc_novt(i)
        );
    COMMIT;
end loop;
close c_equi;

end p_alimenta_oli_equidisc_tab;

procedure p_alim_tabelas_temporarias is

begin

p_alimenta_tab_cidade_temp;

p_alimenta_alunos_temp;

p_alimenta_alundiscmini_temp;

p_alimenta_especial_temp;

p_alimenta_professor_temp;

p_alimenta_oli_equidisc_tab;

end p_alim_tabelas_temporarias;

procedure p_importa_semestre(   p_migr_sequ     mgr_migracao.migr_sequ%type
                              , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- tabelas utilizadas para fazer os updates necessários
t_msem_desc_upd     pkg_util.tb_varchar2_50;
t_msem_dini_upd     pkg_util.tb_date;
t_msem_dfim_upd     pkg_util.tb_date;
t_msem_nsem_upd     pkg_util.tb_number;
t_msem_asem_upd     pkg_util.tb_number;
t_msem_sequ_upd     pkg_util.tb_varchar2_255;
t_msem_scod_upd     pkg_util.tb_varchar2_10;

-- tabelas utilizadas para fazer os inserts necessários
t_msem_desc_ins     pkg_util.tb_varchar2_50;
t_msem_dini_ins     pkg_util.tb_date;
t_msem_dfim_ins     pkg_util.tb_date;
t_msem_nsem_ins     pkg_util.tb_number;
t_msem_asem_ins     pkg_util.tb_number;
t_msem_chav_ins     pkg_util.tb_varchar2_255;
t_msem_scod_ins     pkg_util.tb_varchar2_10;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

-- cursores
cursor c_peri is
    SELECT a.pelinicio
         , a.pelfinal
         , a.pelsem
         , a.pelano
         , TO_CHAR(a.pelcod) pelcod
         , TO_CHAR(a.pelano) || '/' || TO_CHAR(a.pelsem) msem_scod
         -- monta a descrição do período pois a mesma não existe no Olimpo
         ,  CASE (a.pelsem)
                WHEN 1 THEN  'Primeiro semestre de ' || to_char(a.pelano)
                ELSE 'Segundo semestre de ' || to_char(a.pelano) 
            END desc_seme
         , (SELECT MAX(x.msem_sequ)
              FROM mgr_semestre x
             WHERE x.msem_chav = TO_CHAR(a.pelcod)) msem_sequ
      FROM oli_perileti a
     WHERE a.pelanualsemestral = 'S'
       AND a.pelinicio BETWEEN TO_DATE('01/01/1999', 'DD/MM/YYYY') AND TO_DATE('31/12/2016', 'DD/MM/YYYY');

begin

if  (p_mver_sequ is not null) then

    -- faz o update inicial, para conseguirmos identificar os registros que não serão atualizados
    pkg_mgr_imp_producao_aux.p_update_inicio_semestre(p_migr_sequ);

    -- faz a chamada para inicializar as variáveis
    pkg_mgr_imp_producao_aux.p_update_tabela_semestre(    t_msem_desc_upd, t_msem_dini_upd, t_msem_dfim_upd
													 , t_msem_nsem_upd, t_msem_asem_upd, t_msem_sequ_upd
													 , t_msem_scod_upd, l_contador_upd);

    -- faz a chamada para inicializar as variáveis
    pkg_mgr_imp_producao_aux.p_insert_tabela_semestre(    p_mver_sequ, t_msem_desc_ins, t_msem_dini_ins
													 , t_msem_dfim_ins, t_msem_nsem_ins, t_msem_asem_ins
													 , t_msem_chav_ins, t_msem_scod_ins, l_contador_ins);

    -- inicia o contador da transação, o mesmo irá verificar se a quantidade de registros de update e inserts
    -- atingem a quantidade de registros para transação (definido na pkg_util)
    l_contador_trans := 1;

    for r_c_peri in c_peri loop

        -- se identificou um registro na mgr_semestre então é atualização
        if   (r_c_peri.msem_sequ is not null) then

            -- alimenta as variáveis table utilizadas no update
            t_msem_sequ_upd(l_contador_upd) := r_c_peri.msem_sequ;
            t_msem_desc_upd(l_contador_upd) := r_c_peri.desc_seme;
            t_msem_dini_upd(l_contador_upd) := r_c_peri.pelinicio;
            t_msem_dfim_upd(l_contador_upd) := r_c_peri.pelfinal;
            t_msem_nsem_upd(l_contador_upd) := r_c_peri.pelsem;
            t_msem_asem_upd(l_contador_upd) := r_c_peri.pelano;
            t_msem_scod_upd(l_contador_upd) := r_c_peri.msem_scod;
            
            l_contador_upd := l_contador_upd + 1;

        -- se não é inserção de novo registro
        else

            -- alimenta as variáveis table utilizadas no insert
            t_msem_desc_ins(l_contador_ins) := r_c_peri.desc_seme;
            t_msem_dini_ins(l_contador_ins) := r_c_peri.pelinicio;
            t_msem_dfim_ins(l_contador_ins) := r_c_peri.pelfinal;
            t_msem_nsem_ins(l_contador_ins) := r_c_peri.pelsem;
            t_msem_asem_ins(l_contador_ins) := r_c_peri.pelano;
            t_msem_chav_ins(l_contador_ins) := r_c_peri.pelcod;
            t_msem_scod_ins(l_contador_ins) := r_c_peri.msem_scod;
            
            l_contador_ins := l_contador_ins + 1;
        end if;

        -- verifica se atingiu a quantidade de registros por transação
        if  (l_contador_trans >= pkg_util.c_limit_trans) then

            -- atualiza os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_update_tabela_semestre(    t_msem_desc_upd, t_msem_dini_upd, t_msem_dfim_upd
															 , t_msem_nsem_upd, t_msem_asem_upd, t_msem_sequ_upd
															 , t_msem_scod_upd, l_contador_upd);

            -- insere os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_insert_tabela_semestre(    p_mver_sequ, t_msem_desc_ins, t_msem_dini_ins
															 , t_msem_dfim_ins, t_msem_nsem_ins, t_msem_asem_ins
															 , t_msem_chav_ins, t_msem_scod_ins, l_contador_ins);

            l_contador_trans := 1;
        else
            l_contador_trans := l_contador_trans + 1;
        end if;
    end loop;
    -- caso dentro do loop não tenha chego à quantidade que precisa para fechar a transação
    -- então envia tudo que tiver para o update e insert
    pkg_mgr_imp_producao_aux.p_update_tabela_semestre(    t_msem_desc_upd, t_msem_dini_upd, t_msem_dfim_upd
													 , t_msem_nsem_upd, t_msem_asem_upd, t_msem_sequ_upd
													 , t_msem_scod_upd, l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_semestre(    p_mver_sequ, t_msem_desc_ins, t_msem_dini_ins
													 , t_msem_dfim_ins, t_msem_nsem_ins, t_msem_asem_ins
													 , t_msem_chav_ins, t_msem_scod_ins, l_contador_ins);

    -- realiza a identificação do registro nas tabelas do Gioconda e víncula nas tabelas de importação (MGR)
    pkg_mgr_imp_producao_aux.p_vincula_semestre_mgr_seme(p_migr_sequ);
end if;

end p_importa_semestre;

procedure p_importa_semestre_financeiro(   p_migr_sequ     mgr_migracao.migr_sequ%type
                                         , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- tabelas utilizadas para fazer os updates necessários
t_msef_desc_upd     pkg_util.tb_varchar2_50;
t_msef_dini_upd     pkg_util.tb_date;
t_msef_dfim_upd     pkg_util.tb_date;
t_msef_nsem_upd     pkg_util.tb_number;
t_msef_asem_upd     pkg_util.tb_number;
t_msef_sequ_upd     pkg_util.tb_varchar2_255;
t_msef_scod_upd     pkg_util.tb_varchar2_10;

-- tabelas utilizadas para fazer os inserts necessários
t_msef_desc_ins     pkg_util.tb_varchar2_50;
t_msef_dini_ins     pkg_util.tb_date;
t_msef_dfim_ins     pkg_util.tb_date;
t_msef_nsem_ins     pkg_util.tb_number;
t_msef_asem_ins     pkg_util.tb_number;
t_msef_chav_ins     pkg_util.tb_varchar2_255;
t_msef_scod_ins     pkg_util.tb_varchar2_10;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

-- cursores
cursor c_peri is
    SELECT a.pelinicio
         , a.pelfinal
         , a.pelsem
         , a.pelano
         , TO_CHAR(a.pelcod) pelcod
         , TO_CHAR(a.pelano) || '/' || TO_CHAR(a.pelsem) msef_scod
         -- monta a descrição do período pois a mesma não existe no Olimpo
         ,  CASE (a.pelsem)
                WHEN 1 THEN  'Primeiro semestre de ' || to_char(a.pelano)
                ELSE 'Segundo semestre de ' || to_char(a.pelano) 
            END desc_seme
         , (SELECT MAX(x.msef_sequ)
              FROM mgr_semestre_financeiro x
             WHERE x.msef_chav = TO_CHAR(a.pelcod)) msef_sequ
      FROM oli_perileti a
     WHERE a.pelanualsemestral = 'S'
       AND a.pelinicio BETWEEN TO_DATE('01/01/2013', 'DD/MM/YYYY') AND TO_DATE('31/12/2019', 'DD/MM/YYYY');

begin

if  (p_mver_sequ is not null) then

    -- faz o update inicial, para conseguirmos identificar os registros que não serão atualizados
    pkg_mgr_imp_producao_aux.p_update_inic_semestre_finan(p_migr_sequ);

    -- faz a chamada para inicializar as variáveis
    pkg_mgr_imp_producao_aux.p_update_tabe_semestre_finan(  t_msef_desc_upd, t_msef_dini_upd, t_msef_dfim_upd
                                                          , t_msef_nsem_upd, t_msef_asem_upd, t_msef_sequ_upd
                                                          , t_msef_scod_upd, l_contador_upd);

    -- faz a chamada para inicializar as variáveis
    pkg_mgr_imp_producao_aux.p_insert_tabe_semestre_finan(  p_mver_sequ, t_msef_desc_ins, t_msef_dini_ins
                                                          , t_msef_dfim_ins, t_msef_nsem_ins, t_msef_asem_ins
                                                          , t_msef_chav_ins, t_msef_scod_ins, l_contador_ins);

    -- inicia o contador da transação, o mesmo irá verificar se a quantidade de registros de update e inserts
    -- atingem a quantidade de registros para transação (definido na pkg_util)
    l_contador_trans := 1;

    for r_c_peri in c_peri loop

        -- se identificou um registro na mgr_semestre então é atualização
        if   (r_c_peri.msef_sequ is not null) then

            -- alimenta as variáveis table utilizadas no update
            t_msef_sequ_upd(l_contador_upd) := r_c_peri.msef_sequ;
            t_msef_desc_upd(l_contador_upd) := r_c_peri.desc_seme;
            t_msef_dini_upd(l_contador_upd) := r_c_peri.pelinicio;
            t_msef_dfim_upd(l_contador_upd) := r_c_peri.pelfinal;
            t_msef_nsem_upd(l_contador_upd) := r_c_peri.pelsem;
            t_msef_asem_upd(l_contador_upd) := r_c_peri.pelano;
            t_msef_scod_upd(l_contador_upd) := r_c_peri.msef_scod;
            
            l_contador_upd := l_contador_upd + 1;

        -- se não é inserção de novo registro
        else

            -- alimenta as variáveis table utilizadas no insert
            t_msef_desc_ins(l_contador_ins) := r_c_peri.desc_seme;
            t_msef_dini_ins(l_contador_ins) := r_c_peri.pelinicio;
            t_msef_dfim_ins(l_contador_ins) := r_c_peri.pelfinal;
            t_msef_nsem_ins(l_contador_ins) := r_c_peri.pelsem;
            t_msef_asem_ins(l_contador_ins) := r_c_peri.pelano;
            t_msef_chav_ins(l_contador_ins) := r_c_peri.pelcod;
            t_msef_scod_ins(l_contador_ins) := r_c_peri.msef_scod;
            
            l_contador_ins := l_contador_ins + 1;
        end if;

        -- verifica se atingiu a quantidade de registros por transação
        if  (l_contador_trans >= pkg_util.c_limit_trans) then

            -- atualiza os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_update_tabe_semestre_finan(  t_msef_desc_upd, t_msef_dini_upd, t_msef_dfim_upd
                                                                  , t_msef_nsem_upd, t_msef_asem_upd, t_msef_sequ_upd
                                                                  , t_msef_scod_upd, l_contador_upd);

            -- insere os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_insert_tabe_semestre_finan(  p_mver_sequ, t_msef_desc_ins, t_msef_dini_ins
                                                                  , t_msef_dfim_ins, t_msef_nsem_ins, t_msef_asem_ins
                                                                  , t_msef_chav_ins, t_msef_scod_ins, l_contador_ins);

            l_contador_trans := 1;
        else
            l_contador_trans := l_contador_trans + 1;
        end if;
    end loop;

    -- caso dentro do loop não tenha chego à quantidade que precisa para fechar a transação
    -- então envia tudo que tiver para o update e insert
    pkg_mgr_imp_producao_aux.p_update_tabe_semestre_finan(  t_msef_desc_upd, t_msef_dini_upd, t_msef_dfim_upd
                                                          , t_msef_nsem_upd, t_msef_asem_upd, t_msef_sequ_upd
                                                          , t_msef_scod_upd, l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabe_semestre_finan(  p_mver_sequ, t_msef_desc_ins, t_msef_dini_ins
                                                          , t_msef_dfim_ins, t_msef_nsem_ins, t_msef_asem_ins
                                                          , t_msef_chav_ins, t_msef_scod_ins, l_contador_ins);

    -- realiza a identificação do registro nas tabelas do Gioconda e víncula nas tabelas de importação (MGR)
    pkg_mgr_imp_producao_aux.p_vincula_semestre_financeiro(p_migr_sequ);
end if;

end p_importa_semestre_financeiro;

procedure p_importa_cidade( p_migr_sequ     mgr_migracao.migr_sequ%type
                          , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- tabelas usadas no update
t_mcid_esta_upd     pkg_util.tb_varchar2_5;
t_mcid_nome_upd     pkg_util.tb_varchar2_150;
t_mcid_sequ_upd     pkg_util.tb_number;
t_mcid_fnom_upd     pkg_util.tb_varchar2_150;

-- tabelas utilizadas no insert
t_mcid_esta_ins     pkg_util.tb_varchar2_5;
t_mcid_nome_ins     pkg_util.tb_varchar2_150;
t_mcid_chav_ins     pkg_util.tb_varchar2_150;
t_mcid_fnom_ins     pkg_util.tb_varchar2_150;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

cursor c_mcid is
    SELECT a.ciddesc
         , pkg_mgr_imp_producao_aux.mgr_compara_string(a.ciduf) ciduf
         , TO_CHAR(a.cidcod) cidcod
         , pkg_mgr_imp_producao_aux.mgr_compara_string(a.ciddesc) mcid_fnom
         , (SELECT MAX(x.mcid_sequ)
              FROM mgr_cidade x
             WHERE x.mcid_chav = TO_CHAR(a.cidcod)) mcid_sequ
      FROM oli_cidade a
     WHERE a.paicod = 1
       AND a.ciduf IS NOT NULL
	   -- cidades que foram desconsideradas do cadastro do Olimpo
	   -- os motivos são os mais variados, como por exemplo, cadastro duplicado e cidade inexistente
       AND a.cidcod NOT IN (215, 279, 281, 405, 1803, 2441, 4586, 750, 2285, 6113
                          , 8041, 3235, 3394, 3935, 5058, 5072, 5075, 5293, 6812, 9113
                          , 7166, 7275, 7311, 15343, 15350, 15366, 15385, 15399, 15413, 15426
                          , 15442, 31492, 53493, 73492, 79492, 81492, 85493, 87492, 91494, 127492
                          , 133492, 161492, 163492, 193492, 207494, 239492, 241492, 251492, 265492, 273492
                          , 291492, 319492, 341492, 345492, 349492, 353492, 403492, 409492, 429492, 433492
                          , 443492, 445492, 447492, 449492, 451492, 481492, 485492, 503492, 539492, 543492
                          , 559492, 559493, 9887, 15004, 15006, 15007, 15041, 15017, 15016, 15047
                          , 15048, 15058, 15059, 15082, 15083, 15087, 15090, 15094, 15097, 15099
                          , 15104, 15145, 15114, 15120, 15128, 15152, 15156, 15055, 15131, 15197
                          , 15214, 15222, 15256, 15060, 15088, 15168, 15170, 15171, 15172, 15173
                          , 15179, 15183, 15193, 15194, 15196, 15202, 15208, 15210, 15211, 15213
                          , 15215, 15227, 15228, 15233, 15234, 15238, 15245, 15248, 15093, 15198
                          , 15201, 15230, 15158, 15092, 15143, 15161, 15181, 15186, 15188, 15189
                          , 15199, 15226, 15231, 15243, 15281, 15297, 15304, 15326, 15337, 15340
                          , 15341, 15357, 15358, 15360, 15370, 15371, 15374, 15407, 15412, 15421
                          , 15427, 15434, 15456, 15457, 15472, 15477, 15481, 15485, 25492, 35492
                          , 61492, 65492, 91493, 93493, 93495, 115492, 117492, 127493, 129492, 147492
                          , 151493, 153492, 191492, 229492, 245492, 303492, 307492, 321492, 323492, 333492
                          , 361492, 387492, 411492, 475492, 493492, 495492, 545492, 557492, 569492, 575492
                          , 15262, 15265, 15287, 15291, 15300, 15328, 15351, 15354, 15361, 15382
                          , 15389, 15390, 15393, 15400, 15411, 15414, 15419, 15431, 15450, 15451
                          , 15470, 15474, 15489, 15492, 17492, 37492, 41494, 325492, 47492, 51492
                          , 55492, 59492, 67492, 75493, 97493, 123492, 125492, 141492, 157492, 175492
                          , 179492, 181492, 197492, 217492, 229493, 243492, 289492, 313492, 337492, 339492
                          , 369492, 373492, 375492, 385492, 391492, 407492, 423492, 465492, 467492, 481493
                          , 523492, 523493, 541492, 15284, 15306, 15327, 15345, 15346, 15352, 15364
                          , 15365, 15383, 15408, 15471, 15478, 15480, 33492, 53492, 71492, 75492
                          , 95492, 101493, 113492, 137492, 139492, 151492, 165492, 167492, 173492, 177492
                          , 203492, 209492, 211492, 235492, 237492, 281492, 311492, 327492, 337493, 377492
                          , 367492, 383492, 439492, 453492, 459492, 461492, 479492, 483492, 517492, 519492
                          , 17493, 561492, 561493, 573493, 15267, 15292, 15293, 15303, 15310, 15313
                          , 18, 4448);

begin
-- só faz algo caso a versão tenha sido passado de parâmetro
if  (p_mver_sequ is not null) then
    -- faz os updates necessários para o inicio da importação
    pkg_mgr_imp_producao_aux.p_update_inicio_cidade(p_migr_sequ);
    
    -- inicializa as variáveis
    pkg_mgr_imp_producao_aux.p_update_tabela_cidade(  t_mcid_esta_upd, t_mcid_nome_upd, t_mcid_sequ_upd
                                              , t_mcid_fnom_upd, l_contador_upd);

    -- inicializa as variáveis
    pkg_mgr_imp_producao_aux.p_insert_tabela_cidade(  p_mver_sequ, t_mcid_esta_ins, t_mcid_nome_ins
                                              , t_mcid_chav_ins, t_mcid_fnom_ins, l_contador_ins);
    -- inicia o contador
    l_contador_trans := 1;

    for r_c_mcid in c_mcid loop

        -- se identificou um registro na mgr_cidade então é atualização
        if   (r_c_mcid.mcid_sequ is not null) then

            -- alimenta as variáveis table utilizadas no update
            t_mcid_esta_upd(l_contador_upd) := r_c_mcid.ciduf;
            t_mcid_nome_upd(l_contador_upd) := r_c_mcid.ciddesc;
            t_mcid_sequ_upd(l_contador_upd) := r_c_mcid.mcid_sequ;
            t_mcid_fnom_upd(l_contador_upd) := r_c_mcid.mcid_fnom;

            l_contador_upd := l_contador_upd + 1;

        -- se não é inserção de novo registro
        else

            -- alimenta as variáveis table utilizadas no insert
            t_mcid_esta_ins(l_contador_ins) := r_c_mcid.ciduf;
            t_mcid_nome_ins(l_contador_ins) := r_c_mcid.ciddesc;
            t_mcid_chav_ins(l_contador_ins) := r_c_mcid.cidcod;
            t_mcid_fnom_ins(l_contador_ins) := r_c_mcid.mcid_fnom;

            l_contador_ins := l_contador_ins + 1;
        end if;

        -- verifica se atingiu a quantidade de registros por transação
        if  (l_contador_trans >= pkg_util.c_limit_trans) then

            -- atualiza os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_update_tabela_cidade(  t_mcid_esta_upd, t_mcid_nome_upd, t_mcid_sequ_upd
                                                      , t_mcid_fnom_upd, l_contador_upd);

            -- insere os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_insert_tabela_cidade(  p_mver_sequ, t_mcid_esta_ins, t_mcid_nome_ins
                                                      , t_mcid_chav_ins, t_mcid_fnom_ins, l_contador_ins);

            l_contador_trans := 1;
        else
            l_contador_trans := l_contador_trans + 1;
        end if;
    end loop;
    -- caso dentro do loop não tenha chego à quantidade que precisa para fechar a transação
    -- então envia tudo que tiver para o update e insert
    pkg_mgr_imp_producao_aux.p_update_tabela_cidade(  t_mcid_esta_upd, t_mcid_nome_upd, t_mcid_sequ_upd
                                              , t_mcid_fnom_upd, l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_cidade(  p_mver_sequ, t_mcid_esta_ins, t_mcid_nome_ins
                                              , t_mcid_chav_ins, t_mcid_fnom_ins, l_contador_ins);

    pkg_mgr_imp_producao_aux.p_vincula_cidade_mgr_cid(p_migr_sequ);
end if;

end p_importa_cidade;

procedure p_importa_sede(   p_migr_sequ     mgr_migracao.migr_sequ%type
                          , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- utilizadas no update da sede
t_msed_sequ_upd     pkg_util.tb_number;
t_msed_stat_upd     pkg_util.tb_varchar2_1;
t_msed_nome_upd     pkg_util.tb_varchar2_50;
t_msed_rsoc_upd     pkg_util.tb_varchar2_150;
t_msed_cnpj_upd     pkg_util.tb_varchar2_50;
t_msed_ende_upd     pkg_util.tb_varchar2_150;
t_msed_cidd_upd     pkg_util.tb_number;

-- tabelas utilizadas no insert da sede
t_msed_stat_ins     pkg_util.tb_varchar2_5;
t_msed_nome_ins     pkg_util.tb_varchar2_50;
t_msed_rsoc_ins     pkg_util.tb_varchar2_150;
t_msed_cnpj_ins     pkg_util.tb_varchar2_50;
t_msed_ende_ins     pkg_util.tb_varchar2_150;
t_msed_cidd_ins     pkg_util.tb_number;
t_msed_chav_ins     pkg_util.tb_varchar2_150;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

cursor c_msed is
    SELECT TO_CHAR(a.iunicodempresa) iunicodempresa
         , SUBSTR(a.iuninomeempresa, 1, 30) iuninomeempresa
         , SUBSTR(a.iunirazaosocial, 1, 60) iunirazaosocial
         -- retira os caracteres . - / do cnpj na tabela sede salvamos apenas os numeros do cnpj
         , SUBSTR(SO_NUMEROC(a.iunicgc), 1, 14) iunicgc
         -- no sistema olimpo não tem o endereço completo montado, por isso contatenamos as informações aqui, não possui a informação do bairro
         , SUBSTR(TO_CHAR(iuniend) || ' - CEP ' || TO_CHAR(iunicep) || ' - ' || TO_CHAR(iunicidade) || '/' || TO_CHAR(iuniuf), 1, 150) iuniend
         -- identifica a cidade na tabela mgr_cidade pela chav do sistema olimpo e busca nossa sequencia da tabela CIDADE
         , (SELECT MAX(y.mcid_sequ)
              FROM mgr_cidade y
             WHERE y.mcid_chav = TO_CHAR(a.cidcod)
               AND y.mcid_atua = 'S') msed_cidd
         , (SELECT MAX(x.msed_sequ)
              FROM mgr_sede x
             WHERE x.msed_chav = TO_CHAR(a.iunicodempresa)) msed_sequ
      FROM oli_iuniempresa a
     WHERE a.iunicodempresa BETWEEN 543 AND 549;

begin
-- só processa caso tenha sido passado uma versão
if  (p_mver_sequ is not null) then

    -- faz os updates iniciais na tabela mgr_sede necessários
    pkg_mgr_imp_producao_aux.p_update_inicio_sede(p_migr_sequ);

    -- inicializa as variáveis
    pkg_mgr_imp_producao_aux.p_update_tabela_sede(    t_msed_sequ_upd, t_msed_stat_upd, t_msed_nome_upd
                                              , t_msed_rsoc_upd, t_msed_cnpj_upd, t_msed_ende_upd
                                              , t_msed_cidd_upd, l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_sede(    p_mver_sequ, t_msed_stat_ins, t_msed_nome_ins
                                              , t_msed_rsoc_ins, t_msed_cnpj_ins, t_msed_ende_ins
                                              , t_msed_cidd_ins, t_msed_chav_ins, l_contador_ins);

    -- inicia o contador
    l_contador_trans := 1;

    for r_c_msed in c_msed loop

        -- se identificou um registro na mgr_sede então é atualização
        if   (r_c_msed.msed_sequ is not null) then

            -- alimenta as variáveis table utilizadas no update
            t_msed_sequ_upd(l_contador_upd) := r_c_msed.msed_sequ;
            t_msed_stat_upd(l_contador_upd) := '1';
            t_msed_nome_upd(l_contador_upd) := r_c_msed.iuninomeempresa;
            t_msed_rsoc_upd(l_contador_upd) := r_c_msed.iunirazaosocial;
            t_msed_cnpj_upd(l_contador_upd) := r_c_msed.iunicgc;
            t_msed_ende_upd(l_contador_upd) := r_c_msed.iuniend;
            t_msed_cidd_upd(l_contador_upd) := r_c_msed.msed_cidd;

            l_contador_upd := l_contador_upd + 1;

        -- se não é inserção de novo registro
        else

            -- alimenta as variáveis table utilizadas no insert
            t_msed_stat_ins(l_contador_ins) := '1';
            t_msed_nome_ins(l_contador_ins) := r_c_msed.iuninomeempresa;
            t_msed_rsoc_ins(l_contador_ins) := r_c_msed.iunirazaosocial;
            t_msed_cnpj_ins(l_contador_ins) := r_c_msed.iunicgc;
            t_msed_ende_ins(l_contador_ins) := r_c_msed.iuniend;
            t_msed_cidd_ins(l_contador_ins) := r_c_msed.msed_cidd;
            t_msed_chav_ins(l_contador_ins) := r_c_msed.iunicodempresa;

            l_contador_ins := l_contador_ins + 1;
        end if;

        -- verifica se atingiu a quantidade de registros por transação
        if  (l_contador_trans >= pkg_util.c_limit_trans) then

            -- atualiza os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_update_tabela_sede(    t_msed_sequ_upd, t_msed_stat_upd, t_msed_nome_upd
                                                      , t_msed_rsoc_upd, t_msed_cnpj_upd, t_msed_ende_upd
                                                      , t_msed_cidd_upd, l_contador_upd);

            -- insere os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_insert_tabela_sede(    p_mver_sequ, t_msed_stat_ins, t_msed_nome_ins
                                                      , t_msed_rsoc_ins, t_msed_cnpj_ins, t_msed_ende_ins
                                                      , t_msed_cidd_ins, t_msed_chav_ins, l_contador_ins);

            l_contador_trans := 1;
        else
            l_contador_trans := l_contador_trans + 1;
        end if;
    end loop;
    -- caso dentro do loop não tenha chego à quantidade que precisa para fechar a transação
    -- então envia tudo que tiver para o update e insert
    pkg_mgr_imp_producao_aux.p_update_tabela_sede(    t_msed_sequ_upd, t_msed_stat_upd, t_msed_nome_upd
                                              , t_msed_rsoc_upd, t_msed_cnpj_upd, t_msed_ende_upd
                                              , t_msed_cidd_upd, l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_sede(    p_mver_sequ, t_msed_stat_ins, t_msed_nome_ins
                                              , t_msed_rsoc_ins, t_msed_cnpj_ins, t_msed_ende_ins
                                              , t_msed_cidd_ins, t_msed_chav_ins, l_contador_ins);

    pkg_mgr_imp_producao_aux.p_vincula_sede_mgr_sede(p_migr_sequ);
end if;

end p_importa_sede;

procedure p_importa_curso(  p_migr_sequ     mgr_migracao.migr_sequ%type
                          , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- tabelas utilizadas no update
t_mcur_sequ_upd     pkg_util.tb_number;
t_mcur_nome_upd     pkg_util.tb_varchar2_150;
t_mcur_abrv_upd     pkg_util.tb_varchar2_50;
t_mcur_clas_upd     pkg_util.tb_varchar2_1;
t_mcur_stat_upd     pkg_util.tb_varchar2_1;
t_mcur_moda_upd     pkg_util.tb_varchar2_1;
t_mcur_mcla_upd     pkg_util.tb_varchar2_1;
t_mcur_igra_upd     pkg_util.tb_varchar2_1;
t_mcur_crsq_upd     pkg_util.tb_number;
t_mcur_clam_upd     pkg_util.tb_varchar2_5;
t_mcur_nhis_upd     pkg_util.tb_varchar2_255;
t_mcur_onhi_upd     pkg_util.tb_varchar2_4000;

-- tabelas utilizadas no insert
t_mcur_nome_ins     pkg_util.tb_varchar2_150;
t_mcur_abrv_ins     pkg_util.tb_varchar2_50;
t_mcur_clas_ins     pkg_util.tb_varchar2_1;
t_mcur_stat_ins     pkg_util.tb_varchar2_1;
t_mcur_moda_ins     pkg_util.tb_varchar2_1;
t_mcur_mcla_ins     pkg_util.tb_varchar2_1;
t_mcur_igra_ins     pkg_util.tb_varchar2_1;
t_mcur_crsq_ins     pkg_util.tb_number;
t_mcur_clam_ins     pkg_util.tb_varchar2_5;
t_mcur_chav_ins     pkg_util.tb_varchar2_150;
t_mcur_nhis_ins     pkg_util.tb_varchar2_255;
t_mcur_onhi_ins     pkg_util.tb_varchar2_4000;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

-- outras variáveis
l_mcur_clas         mgr_curso.mcur_clas%type;
l_mcur_clam         mgr_curso.mcur_clam%type;
l_mcur_moda         mgr_curso.mcur_moda%type;

cursor c_mcur is
    SELECT TO_CHAR(a.espcod) espe_codi
         , NVL(a.espnomehistorico, a.espdesc) espe_desc
         , PKG_FORMATA_VALIDA.F_ABREVIA_NOME(NVL(a.espnomehistorico, a.espdesc), 40) espe_desc_abrv
         , (SELECT MAX(x.aregrauacademico)
              FROM oli_areacurs x
             WHERE x.arecod = a.arecod) esp_class
         , CASE (a.espsituacao)
               WHEN 'A' THEN '1'
               ELSE '2'
           END esp_situacao
         , (SELECT MAX(y.mcur_sequ)
              FROM mgr_curso y
             WHERE y.mcur_chav = TO_CHAR(a.espcod)) mcur_sequ
         , SUBSTR(a.espnomehistorico, 1, 200) espnomehistorico
         , SUBSTR(( SELECT MAX(w.curdesc)
                      FROM oli_cursos w
                     WHERE w.curcod = a.curcod), 1, 1000) curdesc
      -- na tabela temporária temos apenas as especialidades que nos fazem sentido
      FROM oli_especial_temp b
         , oli_especial a
     WHERE a.espcod = b.espcod;

begin
-- só faz algo se foi passada a versão
if  (p_mver_sequ is not null) then

    -- faz os updates iniciais na tabela mgr_curso necessários
    pkg_mgr_imp_producao_aux.p_update_inicio_curso(p_migr_sequ);

    -- incializa as variáveis
    pkg_mgr_imp_producao_aux.p_update_tabela_curso(   t_mcur_sequ_upd, t_mcur_nome_upd, t_mcur_abrv_upd
                                              , t_mcur_clas_upd, t_mcur_stat_upd, t_mcur_moda_upd
                                              , t_mcur_mcla_upd, t_mcur_igra_upd, t_mcur_crsq_upd
                                              , t_mcur_clam_upd, t_mcur_nhis_upd, t_mcur_onhi_upd
                                              , l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_curso(   p_mver_sequ, t_mcur_nome_ins, t_mcur_abrv_ins
                                              , t_mcur_clas_ins, t_mcur_stat_ins, t_mcur_moda_ins
                                              , t_mcur_mcla_ins, t_mcur_igra_ins, t_mcur_crsq_ins
                                              , t_mcur_clam_ins, t_mcur_chav_ins, t_mcur_nhis_ins
                                              , t_mcur_onhi_ins, l_contador_ins);

    -- inicia o contador
    l_contador_trans := 1;

    for r_c_mcur in c_mcur loop

        -- busca os valores da tabela oli_areacurs, esta contém os seguintes valores
        -- B = 'Bacharelado'; L = 'Licenciatura'; T = 'Tecnológico' e A = 'Bacharelado e Licenciatura'
        -- tudo que for diferente de B, L ou T iremos colocar o valor de B
        if  (r_c_mcur.esp_class in ('B', 'L', 'T')) then

            l_mcur_clas := r_c_mcur.esp_class;
            l_mcur_clam := r_c_mcur.esp_class;
        else

            l_mcur_clas := 'B';
            l_mcur_clam := 'B';
        end if;

        -- se for algum dos cursos abaixo setamos a modalidade como 7
        -- estes cursos são cursos de idioma, foi feito um levantamento manual dos códigos para colocar no in
        if  (r_c_mcur.espe_codi in ('2678', '2674', '3084', '2664'
                                  , '2705', '3083', '3085', '3020')) then

            l_mcur_moda := '7';
        else

            l_mcur_moda := '1';
        end if;
        
        -- se identificou um registro na mgr_curso então é atualização
        if   (r_c_mcur.mcur_sequ is not null) then

            -- alimenta as variáveis table utilizadas no update
            t_mcur_sequ_upd(l_contador_upd) := r_c_mcur.mcur_sequ;
            t_mcur_nome_upd(l_contador_upd) := r_c_mcur.espe_desc;
            t_mcur_abrv_upd(l_contador_upd) := r_c_mcur.espe_desc_abrv;
            t_mcur_clas_upd(l_contador_upd) := l_mcur_clas;
            t_mcur_stat_upd(l_contador_upd) := r_c_mcur.esp_situacao;
            t_mcur_moda_upd(l_contador_upd) := l_mcur_moda;
            t_mcur_mcla_upd(l_contador_upd) := 'N';
            t_mcur_igra_upd(l_contador_upd) := 'N';
            t_mcur_crsq_upd(l_contador_upd) := 1;
            t_mcur_clam_upd(l_contador_upd) := l_mcur_clam;
            t_mcur_nhis_upd(l_contador_upd) := r_c_mcur.espnomehistorico;
            t_mcur_onhi_upd(l_contador_upd) := r_c_mcur.curdesc;

            l_contador_upd := l_contador_upd + 1;

        -- se não é inserção de novo registro
        else

            -- alimenta as variáveis table utilizadas no insert
            t_mcur_nome_ins(l_contador_ins) := r_c_mcur.espe_desc;
            t_mcur_abrv_ins(l_contador_ins) := r_c_mcur.espe_desc_abrv;
            t_mcur_clas_ins(l_contador_ins) := l_mcur_clas;
            t_mcur_stat_ins(l_contador_ins) := r_c_mcur.esp_situacao;
            t_mcur_moda_ins(l_contador_ins) := l_mcur_moda;
            t_mcur_mcla_ins(l_contador_ins) := 'N';
            t_mcur_igra_ins(l_contador_ins) := 'N';
            t_mcur_crsq_ins(l_contador_ins) := 1;
            t_mcur_clam_ins(l_contador_ins) := l_mcur_clam;
            t_mcur_chav_ins(l_contador_ins) := r_c_mcur.espe_codi;
            t_mcur_nhis_ins(l_contador_ins) := r_c_mcur.espnomehistorico;
            t_mcur_onhi_ins(l_contador_ins) := r_c_mcur.curdesc;

            l_contador_ins := l_contador_ins + 1;
        end if;

        -- verifica se atingiu a quantidade de registros por transação
        if  (l_contador_trans >= pkg_util.c_limit_trans) then

            -- atualiza os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_update_tabela_curso(   t_mcur_sequ_upd, t_mcur_nome_upd, t_mcur_abrv_upd
                                                      , t_mcur_clas_upd, t_mcur_stat_upd, t_mcur_moda_upd
                                                      , t_mcur_mcla_upd, t_mcur_igra_upd, t_mcur_crsq_upd
                                                      , t_mcur_clam_upd, t_mcur_nhis_upd, t_mcur_onhi_upd
                                                      , l_contador_upd);

            -- insere os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_insert_tabela_curso(   p_mver_sequ, t_mcur_nome_ins, t_mcur_abrv_ins
                                                      , t_mcur_clas_ins, t_mcur_stat_ins, t_mcur_moda_ins
                                                      , t_mcur_mcla_ins, t_mcur_igra_ins, t_mcur_crsq_ins
                                                      , t_mcur_clam_ins, t_mcur_chav_ins, t_mcur_nhis_ins
                                                      , t_mcur_onhi_ins, l_contador_ins);

            l_contador_trans := 1;
        else
            l_contador_trans := l_contador_trans + 1;
        end if;
    end loop;

    -- caso dentro do loop não tenha chego à quantidade que precisa para fechar a transação
    -- então envia tudo que tiver para o update e insert
    pkg_mgr_imp_producao_aux.p_update_tabela_curso(   t_mcur_sequ_upd, t_mcur_nome_upd, t_mcur_abrv_upd
                                              , t_mcur_clas_upd, t_mcur_stat_upd, t_mcur_moda_upd
                                              , t_mcur_mcla_upd, t_mcur_igra_upd, t_mcur_crsq_upd
                                              , t_mcur_clam_upd, t_mcur_nhis_upd, t_mcur_onhi_upd
                                              , l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_curso(   p_mver_sequ, t_mcur_nome_ins, t_mcur_abrv_ins
                                              , t_mcur_clas_ins, t_mcur_stat_ins, t_mcur_moda_ins
                                              , t_mcur_mcla_ins, t_mcur_igra_ins, t_mcur_crsq_ins
                                              , t_mcur_clam_ins, t_mcur_chav_ins, t_mcur_nhis_ins
                                              , t_mcur_onhi_ins, l_contador_ins);

    pkg_mgr_imp_producao_aux.p_vincula_curso_mgr_curso;
end if;

end p_importa_curso;

function f_de_para_periodo_gioconda(    p_curs_moda     varchar2
                                      , p_mtus_curs     varchar2) return number is

l_mtus_peri         mgr_turma_semestre.mtus_peri%type;

begin

-- período diferenciado
if  (p_curs_moda = '7') then

    l_mtus_peri := 20;

-- gastronomia
elsif   (p_mtus_curs = 'GST') then

    l_mtus_peri := 7;
    
-- Relações Públicas - Ênfase em Comunicação Empresarial
elsif   (p_mtus_curs = 'REM') then

    l_mtus_peri := 2;
    
-- Geografia, História e Letras
elsif	(p_mtus_curs IN ('GEO', 'HIS', 'LET')) then
    
    l_mtus_peri := 8;

-- Formação Continuada nas Áreas de Ciências Humanas e suas Tecnologias
-- Gestão Imobiliária
elsif	(p_mtus_curs IN ('FCX')) then

    l_mtus_peri := 10;

-- cursos da área de saúde
elsif   (p_mtus_curs in (   'BIM', 'EFI', 'EDF'
                          , 'ENF', 'FIS', 'NUT'
                          , 'EST', 'RAD', 'PSI')) then
    l_mtus_peri := 19;

-- demais cursos
else
    l_mtus_peri := 1;
end if;

return l_mtus_peri;

end f_de_para_periodo_gioconda;

function f_de_para_turno_gioconda(    p_mtus_turn   varchar2) return varchar2 is

l_mtus_turn         mgr_turma_semestre.mtus_turn%type;

begin

case (p_mtus_turn)

    -- (D - Diurno, M - Matutino, N - Noturno, V - Vespertino)
    when 'N' then 
            l_mtus_turn := '3';
    when 'V' then 
            l_mtus_turn := '2';
    else
            l_mtus_turn := '1';
end case;

return l_mtus_turn;

end f_de_para_turno_gioconda;

procedure p_importa_turma_semestre( p_migr_sequ     mgr_migracao.migr_sequ%type
                                  , p_mver_sequ     mgr_versao.mver_sequ%type
                                  , p_separador     mgr_migracao.migr_sepa%type) is

-- tabelas utilizadas no update
t_mtus_sequ_upd     pkg_util.tb_number;
t_mtus_sede_upd     pkg_util.tb_varchar2_5;
t_mtus_peri_upd     pkg_util.tb_number;
t_mtus_nsem_upd     pkg_util.tb_number;
t_mtus_curs_upd     pkg_util.tb_varchar2_5;
t_mtus_asen_upd     pkg_util.tb_varchar2_10;
t_mtus_stat_upd     pkg_util.tb_varchar2_1;
t_mtus_pave_upd     pkg_util.tb_varchar2_10;
t_mtus_sein_upd     pkg_util.tb_varchar2_10;
t_mtus_segi_upd     pkg_util.tb_varchar2_10;
t_mtus_turm_upd     pkg_util.tb_varchar2_50;
t_mtus_turn_upd     pkg_util.tb_varchar2_1;

-- tabelas utilizadas no insert
t_mtus_sede_ins     pkg_util.tb_varchar2_5;
t_mtus_peri_ins     pkg_util.tb_number;
t_mtus_nsem_ins     pkg_util.tb_number;
t_mtus_curs_ins     pkg_util.tb_varchar2_5;
t_mtus_asen_ins     pkg_util.tb_varchar2_10;
t_mtus_stat_ins     pkg_util.tb_varchar2_1;
t_mtus_pave_ins     pkg_util.tb_varchar2_10;
t_mtus_sein_ins     pkg_util.tb_varchar2_10;
t_mtus_chav_ins     pkg_util.tb_varchar2_150;
t_mtus_segi_ins     pkg_util.tb_varchar2_10;
t_mtus_turm_ins     pkg_util.tb_varchar2_50;
t_mtus_turn_ins     pkg_util.tb_varchar2_1;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

-- outras variáveis
l_mtus_peri         mgr_turma_semestre.mtus_peri%type;
l_mtus_base         mgr_turma_semestre.mtus_sequ%type;
l_qtde_regi         pls_integer;
l_mtus_novo         mgr_turma_semestre.mtus_sequ%type;
l_mtus_segi         mgr_turma_semestre.mtus_segi%type;
l_mtus_turn         mgr_turma_semestre.mtus_turn%type;

cursor c_turm_etap( pc_separador    mgr_migracao.migr_sepa%type
                  , pc_migr_sequ  mgr_migracao.migr_sequ%type) is
	SELECT * FROM (
					SELECT TO_CHAR(a.etucod) || pc_separador || a.tmacod mtus_chav
						 , a.tmacod
						 , (SELECT MAX(x.msed_sequ)
							  FROM oli_especial h
								 , mgr_sede x
							 WHERE h.espcod = b.espcod
							   AND x.msed_chav = TO_CHAR(h.iunicodempresa)
							   AND x.msed_atua = 'S') mtus_sede
						 , (SELECT MAX(h.espturno)
							  FROM oli_especial h
							 WHERE h.espcod = b.espcod) mtus_turn
						 , a.etucod
						 , c.mcur_curs mtus_curs
						 , c.mcur_sequ mcur_sequ
						 , c.mcur_moda mcur_moda
						 , (SELECT MAX(w.msem_seme)
							  FROM mgr_semestre w
							 WHERE w.msem_chav = TO_CHAR(b.pelcod)
							   AND w.msem_atua = 'S') mtus_asen
						 , (SELECT MAX(w.msem_seme)
							  FROM mgr_semestre w
							 WHERE w.msem_chav = TO_CHAR(a.pelcod)
							   AND w.msem_atua = 'S') mtus_segi
						 , CASE b.tmasituacao
								WHEN 'S' THEN '2'
								ELSE '1'
						   END mtus_stat
						 , (SELECT MAX(z.mtus_sequ)
							  FROM mgr_turma_semestre z
							 WHERE z.mtus_chav = TO_CHAR(a.etucod) || pc_separador || a.tmacod) mtus_sequ
					  FROM oli_etapturm a
						 , oli_turma b
						 , mgr_curso c
					 WHERE b.tmacod = a.tmacod
					   AND c.mcur_chav = TO_CHAR(b.espcod)
					   AND c.mcur_atua = 'S'
					   -- alguma matrícula no período ou aluno vinculado a turma (turma base do aluno)
					   AND EXISTS (SELECT 1
									 FROM oli_alundiscmini_temp f
									WHERE f.tmacod = b.tmacod
									  AND f.pelcod = a.pelcod
									UNION ALL
								   SELECT 1
									 FROM oli_aluncurs g
									WHERE g.tmacod = b.tmacod)
					   AND EXISTS (SELECT 1
									 FROM mgr_versao v
									WHERE v.mver_sequ = c.mcur_mver
									  AND v.mver_migr = pc_migr_sequ)
				) ab
		 , mgr_semestre cd
		 , oli_perileti_uni bc
     WHERE cd.msem_seme = ab.mtus_segi
	   AND bc.pelcod = cd.msem_chav
	 ORDER BY tmacod;

cursor c_turm_espe( pc_separador    mgr_migracao.migr_sepa%type
                  , pc_migr_sequ    mgr_migracao.migr_sequ%type) is
    SELECT DISTINCT
		   TO_CHAR(a.pelcod) || pc_separador || a.tmacod mtus_chav
		 , a.tmacod
		 , (SELECT MAX(x.msed_sequ)
			  FROM oli_especial h
				 , mgr_sede x
			 WHERE h.espcod = b.espcod
			   AND x.msed_chav = TO_CHAR(h.iunicodempresa)
			   AND x.msed_atua = 'S') mtus_sede
		 , (SELECT MAX(h.espturno)
			  FROM oli_especial h
			 WHERE h.espcod = b.espcod) mtus_turn
		 , 1 etucod
		 , c.mcur_curs mtus_curs
		 , c.mcur_sequ mcur_sequ
		 , c.mcur_moda mcur_moda
		 , (SELECT MAX(w.msem_seme)
			  FROM mgr_semestre w
			 WHERE w.msem_chav = TO_CHAR(b.pelcod)
			   AND w.msem_atua = 'S') mtus_asen
		 , (SELECT MAX(w.msem_seme)
			  FROM mgr_semestre w
			 WHERE w.msem_chav = TO_CHAR(a.pelcod)
			   AND w.msem_atua = 'S') mtus_segi
		 , CASE b.tmasituacao
				WHEN 'S' THEN '2'
				ELSE '1'
		   END mtus_stat
		 , (SELECT MAX(z.mtus_sequ)
			  FROM mgr_turma_semestre z
			 WHERE z.mtus_chav = TO_CHAR(a.pelcod) || pc_separador || a.tmacod) mtus_sequ
      FROM oli_alundiscmini_temp a
	     , oli_turma b
		 , mgr_curso c
     WHERE b.tmacod = a.tmacod
	   AND c.mcur_chav = TO_CHAR(b.espcod)
       AND EXISTS(  SELECT 1
                      FROM mgr_versao x
                     WHERE x.mver_migr = pc_migr_sequ
                       AND x.mver_sequ = c.mcur_mver)
	   AND c.mcur_atua = 'S'
	   AND NOT EXISTS (SELECT 1 
                        FROM mgr_turma_semestre b
                           , mgr_semestre c
                       WHERE c.msem_chav = TO_CHAR(a.pelcod)
                         AND b.mtus_segi = c.msem_seme
                         AND b.mtus_turm = a.tmacod
                         AND b.mtus_atua = 'S');

begin
-- só faz algo se foi passada a versão
if  (p_mver_sequ is not null) then

    -- faz os updates iniciais na tabela mgr_turma_semestre necessários
    pkg_mgr_imp_producao_aux.p_update_inic_turma_semestre(p_migr_sequ);

    -- incializa as variáveis
    pkg_mgr_imp_producao_aux.p_update_tabe_turma_semestre( t_mtus_sequ_upd, t_mtus_sede_upd, t_mtus_peri_upd
														 , t_mtus_nsem_upd, t_mtus_curs_upd, t_mtus_asen_upd
														 , t_mtus_stat_upd, t_mtus_pave_upd, t_mtus_sein_upd
														 , t_mtus_segi_upd, t_mtus_turm_upd, t_mtus_turn_upd
														 , l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabe_turma_semestre( p_mver_sequ, t_mtus_sede_ins, t_mtus_peri_ins
														 , t_mtus_nsem_ins, t_mtus_curs_ins, t_mtus_asen_ins
														 , t_mtus_stat_ins, t_mtus_pave_ins, t_mtus_sein_ins
														 , t_mtus_segi_ins, t_mtus_turm_ins, t_mtus_chav_ins
														 , t_mtus_turn_ins, l_contador_ins);

    -- inicia o contador
    l_contador_trans := 1;

    for r_c_turm_etap in c_turm_etap(p_separador, p_migr_sequ) loop

        l_mtus_peri := f_de_para_periodo_gioconda(   r_c_turm_etap.mcur_moda, r_c_turm_etap.mtus_curs);

        l_mtus_turn := f_de_para_turno_gioconda(    r_c_turm_etap.mtus_turn);

        -- se identificou um registro na mgr_turma_semestre então é atualização
        if   (r_c_turm_etap.mtus_sequ is not null) then

            -- alimenta as variáveis table utilizadas no update
            t_mtus_sequ_upd(l_contador_upd) := r_c_turm_etap.mtus_sequ;
            t_mtus_nsem_upd(l_contador_upd) := r_c_turm_etap.etucod;
            t_mtus_asen_upd(l_contador_upd) := r_c_turm_etap.mtus_asen;
            t_mtus_stat_upd(l_contador_upd) := r_c_turm_etap.mtus_stat;
            t_mtus_pave_upd(l_contador_upd) := '0';
            t_mtus_sein_upd(l_contador_upd) := r_c_turm_etap.mtus_asen;
            t_mtus_sede_upd(l_contador_upd) := r_c_turm_etap.mtus_sede;
            t_mtus_peri_upd(l_contador_upd) := l_mtus_peri;
            t_mtus_curs_upd(l_contador_upd) := r_c_turm_etap.mcur_sequ;
            t_mtus_segi_upd(l_contador_upd) := r_c_turm_etap.mtus_segi;
            t_mtus_turm_upd(l_contador_upd) := r_c_turm_etap.tmacod;
            t_mtus_turn_upd(l_contador_upd) := l_mtus_turn;

            l_contador_upd := l_contador_upd + 1;

        -- se não é inserção de novo registro
        else

            -- alimenta as variáveis table utilizadas no insert
            t_mtus_sede_ins(l_contador_ins) := r_c_turm_etap.mtus_sede;
            t_mtus_peri_ins(l_contador_ins) := l_mtus_peri;
            t_mtus_nsem_ins(l_contador_ins) := r_c_turm_etap.etucod;
            t_mtus_curs_ins(l_contador_ins) := r_c_turm_etap.mcur_sequ;
            t_mtus_asen_ins(l_contador_ins) := r_c_turm_etap.mtus_asen;
            t_mtus_stat_ins(l_contador_ins) := r_c_turm_etap.mtus_stat;
            t_mtus_pave_ins(l_contador_ins) := '0';
            t_mtus_sein_ins(l_contador_ins) := r_c_turm_etap.mtus_asen;
            t_mtus_segi_ins(l_contador_ins) := r_c_turm_etap.mtus_segi;
            t_mtus_turm_ins(l_contador_ins) := r_c_turm_etap.tmacod;
            t_mtus_chav_ins(l_contador_ins) := r_c_turm_etap.mtus_chav;
            t_mtus_turn_ins(l_contador_ins) := l_mtus_turn;

            l_contador_ins := l_contador_ins + 1;
        end if;

        -- verifica se atingiu a quantidade de registros por transação
        if  (l_contador_trans >= pkg_util.c_limit_trans) then

            -- atualiza os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_update_tabe_turma_semestre( t_mtus_sequ_upd, t_mtus_sede_upd, t_mtus_peri_upd
																 , t_mtus_nsem_upd, t_mtus_curs_upd, t_mtus_asen_upd
																 , t_mtus_stat_upd, t_mtus_pave_upd, t_mtus_sein_upd
																 , t_mtus_segi_upd, t_mtus_turm_upd, t_mtus_turn_upd
																 , l_contador_upd);

            -- insere os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_insert_tabe_turma_semestre( p_mver_sequ, t_mtus_sede_ins, t_mtus_peri_ins
																 , t_mtus_nsem_ins, t_mtus_curs_ins, t_mtus_asen_ins
																 , t_mtus_stat_ins, t_mtus_pave_ins, t_mtus_sein_ins
																 , t_mtus_segi_ins, t_mtus_turm_ins, t_mtus_chav_ins
																 , t_mtus_turn_ins, l_contador_ins);

            l_contador_trans := 1;
        else
            l_contador_trans := l_contador_trans + 1;
        end if;
    end loop;

    -- caso dentro do loop não tenha chego à quantidade que precisa para fechar a transação
    -- então envia tudo que tiver para o update e insert
    pkg_mgr_imp_producao_aux.p_update_tabe_turma_semestre( t_mtus_sequ_upd, t_mtus_sede_upd, t_mtus_peri_upd
														 , t_mtus_nsem_upd, t_mtus_curs_upd, t_mtus_asen_upd
														 , t_mtus_stat_upd, t_mtus_pave_upd, t_mtus_sein_upd
														 , t_mtus_segi_upd, t_mtus_turm_upd, t_mtus_turn_upd
														 , l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabe_turma_semestre( p_mver_sequ, t_mtus_sede_ins, t_mtus_peri_ins
														 , t_mtus_nsem_ins, t_mtus_curs_ins, t_mtus_asen_ins
														 , t_mtus_stat_ins, t_mtus_pave_ins, t_mtus_sein_ins
														 , t_mtus_segi_ins, t_mtus_turm_ins, t_mtus_chav_ins
														 , t_mtus_turn_ins, l_contador_ins);

	-- existem algumas situações especiais que precisamos tratar, são casos onde existe um aluno
    -- matriculado em uma ou mais disciplinas para uma determinada turma, porém no Olimpo esta turma
    -- no determinado semestre onde há esta matricula não existe. Ex. Turma finalizou em 2014/2 porém
    -- existe um aluno que fez o TCC em 2015/1, ao invés deste aluno ter sido colocado em uma outra turma
    -- deixaram ele nesta mesma turma mas não geraram um registro para esta turma na etapturm (equivalente a nossa aluno_semestre)
    -- inicia o contador
    l_contador_trans := 1;

    for r_c_turm_espe in c_turm_espe(p_separador, p_migr_sequ) loop

        l_mtus_peri := f_de_para_periodo_gioconda(   r_c_turm_espe.mcur_moda, r_c_turm_espe.mtus_curs);

        l_mtus_turn := f_de_para_turno_gioconda(    r_c_turm_espe.mtus_turn);

        -- se identificou um registro na mgr_turma_semestre então é atualização
        if   (r_c_turm_espe.mtus_sequ is not null) then

            -- alimenta as variáveis table utilizadas no update
            t_mtus_sequ_upd(l_contador_upd) := r_c_turm_espe.mtus_sequ;
            t_mtus_nsem_upd(l_contador_upd) := r_c_turm_espe.etucod;
            t_mtus_asen_upd(l_contador_upd) := r_c_turm_espe.mtus_asen;
            t_mtus_stat_upd(l_contador_upd) := r_c_turm_espe.mtus_stat;
            t_mtus_pave_upd(l_contador_upd) := '0';
            t_mtus_sein_upd(l_contador_upd) := r_c_turm_espe.mtus_asen;
            t_mtus_sede_upd(l_contador_upd) := r_c_turm_espe.mtus_sede;
            t_mtus_peri_upd(l_contador_upd) := l_mtus_peri;
            t_mtus_curs_upd(l_contador_upd) := r_c_turm_espe.mcur_sequ;
            t_mtus_segi_upd(l_contador_upd) := r_c_turm_espe.mtus_segi;
            t_mtus_turm_upd(l_contador_upd) := r_c_turm_espe.tmacod;
            t_mtus_turn_upd(l_contador_upd) := l_mtus_turn;

            l_contador_upd := l_contador_upd + 1;

        -- se não é inserção de novo registro
        else

            -- alimenta as variáveis table utilizadas no insert
            t_mtus_sede_ins(l_contador_ins) := r_c_turm_espe.mtus_sede;
            t_mtus_peri_ins(l_contador_ins) := l_mtus_peri;
            t_mtus_nsem_ins(l_contador_ins) := r_c_turm_espe.etucod;
            t_mtus_curs_ins(l_contador_ins) := r_c_turm_espe.mcur_sequ;
            t_mtus_asen_ins(l_contador_ins) := r_c_turm_espe.mtus_asen;
            t_mtus_stat_ins(l_contador_ins) := r_c_turm_espe.mtus_stat;
            t_mtus_pave_ins(l_contador_ins) := '0';
            t_mtus_sein_ins(l_contador_ins) := r_c_turm_espe.mtus_asen;
            t_mtus_segi_ins(l_contador_ins) := r_c_turm_espe.mtus_segi;
            t_mtus_turm_ins(l_contador_ins) := r_c_turm_espe.tmacod;
            t_mtus_chav_ins(l_contador_ins) := r_c_turm_espe.mtus_chav;
            t_mtus_turn_ins(l_contador_ins) := l_mtus_turn;

            l_contador_ins := l_contador_ins + 1;
        end if;

        -- verifica se atingiu a quantidade de registros por transação
        if  (l_contador_trans >= pkg_util.c_limit_trans) then

            -- atualiza os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_update_tabe_turma_semestre( t_mtus_sequ_upd, t_mtus_sede_upd, t_mtus_peri_upd
																 , t_mtus_nsem_upd, t_mtus_curs_upd, t_mtus_asen_upd
																 , t_mtus_stat_upd, t_mtus_pave_upd, t_mtus_sein_upd
																 , t_mtus_segi_upd, t_mtus_turm_upd, t_mtus_turn_upd
																 , l_contador_upd, 1);

            -- insere os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_insert_tabe_turma_semestre( p_mver_sequ, t_mtus_sede_ins, t_mtus_peri_ins
																 , t_mtus_nsem_ins, t_mtus_curs_ins, t_mtus_asen_ins
																 , t_mtus_stat_ins, t_mtus_pave_ins, t_mtus_sein_ins
																 , t_mtus_segi_ins, t_mtus_turm_ins, t_mtus_chav_ins
																 , t_mtus_turn_ins, l_contador_ins, 1);

            l_contador_trans := 1;
        else
            l_contador_trans := l_contador_trans + 1;
        end if;
    end loop;

    -- caso dentro do loop não tenha chego à quantidade que precisa para fechar a transação
    -- então envia tudo que tiver para o update e insert
    pkg_mgr_imp_producao_aux.p_update_tabe_turma_semestre( t_mtus_sequ_upd, t_mtus_sede_upd, t_mtus_peri_upd
														 , t_mtus_nsem_upd, t_mtus_curs_upd, t_mtus_asen_upd
														 , t_mtus_stat_upd, t_mtus_pave_upd, t_mtus_sein_upd
														 , t_mtus_segi_upd, t_mtus_turm_upd, t_mtus_turn_upd
														 , l_contador_upd, 1);

    pkg_mgr_imp_producao_aux.p_insert_tabe_turma_semestre( p_mver_sequ, t_mtus_sede_ins, t_mtus_peri_ins
														 , t_mtus_nsem_ins, t_mtus_curs_ins, t_mtus_asen_ins
														 , t_mtus_stat_ins, t_mtus_pave_ins, t_mtus_sein_ins
														 , t_mtus_segi_ins, t_mtus_turm_ins, t_mtus_chav_ins
														 , t_mtus_turn_ins, l_contador_ins, 1);

    pkg_mgr_imp_producao_aux.p_vinc_mtus_turma_semestre(p_migr_sequ);
end if;

end p_importa_turma_semestre;

procedure p_importa_semestre_sede(  p_migr_sequ     mgr_migracao.migr_sequ%type
                                  , p_mver_sequ     mgr_versao.mver_sequ%type
                                  , p_separador     mgr_migracao.migr_sepa%type) is

-- tabelas utilizadas no update
t_mses_sequ_upd     pkg_util.tb_number;
t_mses_msem_upd     pkg_util.tb_number;
t_mses_msed_upd     pkg_util.tb_number;
t_mses_eper_upd     pkg_util.tb_number;

-- tabelas utilizadas nos inserts
t_mses_msem_ins     pkg_util.tb_varchar2_5;
t_mses_msed_ins     pkg_util.tb_number;
t_mses_eper_ins     pkg_util.tb_number;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

cursor c_mses(  pc_migr_sequ  mgr_migracao.migr_sequ%type) is
    SELECT c.msem_sequ
         , b.msed_sequ
         , a.mtus_peri
         , (SELECT MAX(y.mses_sequ)
              FROM mgr_semestre_sede y
             WHERE y.mses_msem = c.msem_sequ
               AND y.mses_msed = b.msed_sequ
               AND y.mses_eper = a.mtus_peri) mses_sequ
      FROM mgr_turma_semestre a
         , mgr_sede b
         , mgr_semestre c
     WHERE a.mtus_atua = 'S'
       AND b.msed_sequ = a.mtus_msed
       AND c.msem_scod = a.mtus_segi
       AND EXISTS(  SELECT 1
                      FROM mgr_versao w
                     WHERE w.mver_migr = pc_migr_sequ
                       AND w.mver_sequ = a.mtus_mver)
     GROUP BY c.msem_sequ, b.msed_sequ, a.mtus_peri;

begin
-- faz o update incial para sabermos quais registros foram alterados ao término do processo
pkg_mgr_imp_producao_aux.p_update_inic_semestre_sede( p_migr_sequ);
-- inicializa as variáveis
pkg_mgr_imp_producao_aux.p_update_tabe_semestre_sede( t_mses_sequ_upd, t_mses_msem_upd, t_mses_msed_upd
                                              , t_mses_eper_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabe_semestre_sede( p_mver_sequ, t_mses_msem_ins, t_mses_msed_ins
                                              , t_mses_eper_ins, l_contador_ins);

l_contador_trans := 1;

for r_c_mses in c_mses(p_migr_sequ) loop

    -- se não encontrou a sequencia então alimenta as tabelas para o insert
    if (r_c_mses.mses_sequ is null) then

        t_mses_msem_ins(l_contador_ins) := r_c_mses.msem_sequ;
        t_mses_msed_ins(l_contador_ins) := r_c_mses.msed_sequ;
        t_mses_eper_ins(l_contador_ins) := r_c_mses.mtus_peri;

        l_contador_ins := l_contador_ins + 1;
    else
        -- se encontrou alimenta as tabelas para update
        t_mses_sequ_upd(l_contador_upd) := r_c_mses.mses_sequ;
        t_mses_msem_upd(l_contador_upd) := r_c_mses.msem_sequ;
        t_mses_msed_upd(l_contador_upd) := r_c_mses.msed_sequ;
        t_mses_eper_upd(l_contador_upd) := r_c_mses.mtus_peri;

        l_contador_upd := l_contador_upd + 1;
    end if;

    -- se chegou no limite da transação então manda pro banco, se não apenas incrementa o contador
    if  (l_contador_trans >= pkg_util.c_limit_trans) then

        pkg_mgr_imp_producao_aux.p_update_tabe_semestre_sede( t_mses_sequ_upd, t_mses_msem_upd, t_mses_msed_upd
                                                      , t_mses_eper_upd, l_contador_upd);

        pkg_mgr_imp_producao_aux.p_insert_tabe_semestre_sede( p_mver_sequ, t_mses_msem_ins, t_mses_msed_ins
                                                      , t_mses_eper_ins, l_contador_ins);

        l_contador_trans := 0;
    else
        l_contador_trans := l_contador_trans + 1;
    end if;
end loop;
-- se não chegou no limite de transação dentro do cursor então manda pro banco os registros que tem nas tabelas
pkg_mgr_imp_producao_aux.p_update_tabe_semestre_sede( t_mses_sequ_upd, t_mses_msem_upd, t_mses_msed_upd
                                              , t_mses_eper_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabe_semestre_sede( p_mver_sequ, t_mses_msem_ins, t_mses_msed_ins
                                              , t_mses_eper_ins, l_contador_ins);

-- faz o vínculo da tabela mgr com a tabela do gioconda
pkg_mgr_imp_producao_aux.p_vinc_mses_semestre_sede(   p_migr_sequ);

end p_importa_semestre_sede;

procedure p_importa_pessoa( p_migr_sequ   mgr_migracao.migr_sequ%type
                          , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- tabelas para update
t_mpes_sequ_upd     pkg_util.tb_number;
t_mpes_nome_upd     pkg_util.tb_varchar2_150;
t_mpes_sexo_upd     pkg_util.tb_varchar2_1;
t_mpes_dnas_upd     pkg_util.tb_date;
t_mpes_cidd_upd     pkg_util.tb_number;
t_mpes_bair_upd     pkg_util.tb_varchar2_150;
t_mpes_ende_upd     pkg_util.tb_varchar2_150;
t_mpes_nume_upd     pkg_util.tb_varchar2_50;
t_mpes_comp_upd     pkg_util.tb_varchar2_50;
t_mpes_fone_upd     pkg_util.tb_varchar2_50;
t_mpes_celu_upd     pkg_util.tb_varchar2_50;
t_mpes_mail_upd     pkg_util.tb_varchar2_150;
t_mpes_pcpf_upd     pkg_util.tb_varchar2_50;
t_mpes_esta_upd     pkg_util.tb_varchar2_5;
t_mpes_npai_upd     pkg_util.tb_varchar2_150;
t_mpes_nmae_upd     pkg_util.tb_varchar2_150;
t_mpes_natu_upd     pkg_util.tb_varchar2_150;
t_mpes_iden_upd     pkg_util.tb_varchar2_50;
t_mpes_ideo_upd     pkg_util.tb_varchar2_50;
t_mpes_titu_upd     pkg_util.tb_varchar2_50;
t_mpes_tizo_upd     pkg_util.tb_number;
t_mpes_tise_upd     pkg_util.tb_number;
t_mpes_tiuf_upd     pkg_util.tb_varchar2_5;
t_mpes_croe_upd     pkg_util.tb_varchar2_50;
t_mpes_cres_upd     pkg_util.tb_varchar2_50;
t_mpes_fonc_upd     pkg_util.tb_varchar2_50;
t_mpes_naci_upd     pkg_util.tb_varchar2_1;
t_mpes_ance_upd     pkg_util.tb_number;
t_mpes_eciv_upd     pkg_util.tb_varchar2_1;
t_mpes_gins_upd     pkg_util.tb_varchar2_5;
t_mpes_tipo_upd     pkg_util.tb_varchar2_5;
t_mpes_ntuf_upd     pkg_util.tb_varchar2_5;
t_mpes_tdef_upd     pkg_util.tb_varchar2_5;
t_mpes_pspc_upd     pkg_util.tb_varchar2_1;
t_mpes_cnat_upd     pkg_util.tb_number;
t_mpes_cora_upd     pkg_util.tb_varchar2_5;
t_mpes_pcep_upd     pkg_util.tb_varchar2_10;
t_mpes_cmai_upd     pkg_util.tb_varchar2_1;
t_mpes_cosr_upd     pkg_util.tb_varchar2_150;
t_mpes_text_upd     pkg_util.tb_varchar2_4000;

-- tabelas para insert
t_mpes_nome_ins     pkg_util.tb_varchar2_150;
t_mpes_sexo_ins     pkg_util.tb_varchar2_1;
t_mpes_dnas_ins     pkg_util.tb_date;
t_mpes_cidd_ins     pkg_util.tb_number;
t_mpes_bair_ins     pkg_util.tb_varchar2_150;
t_mpes_ende_ins     pkg_util.tb_varchar2_150;
t_mpes_nume_ins     pkg_util.tb_varchar2_50;
t_mpes_comp_ins     pkg_util.tb_varchar2_50;
t_mpes_fone_ins     pkg_util.tb_varchar2_50;
t_mpes_celu_ins     pkg_util.tb_varchar2_50;
t_mpes_mail_ins     pkg_util.tb_varchar2_150;
t_mpes_pcpf_ins     pkg_util.tb_varchar2_50;
t_mpes_esta_ins     pkg_util.tb_varchar2_5;
t_mpes_npai_ins     pkg_util.tb_varchar2_150;
t_mpes_nmae_ins     pkg_util.tb_varchar2_150;
t_mpes_natu_ins     pkg_util.tb_varchar2_150;
t_mpes_iden_ins     pkg_util.tb_varchar2_50;
t_mpes_ideo_ins     pkg_util.tb_varchar2_50;
t_mpes_titu_ins     pkg_util.tb_varchar2_50;
t_mpes_tizo_ins     pkg_util.tb_number;
t_mpes_tise_ins     pkg_util.tb_number;
t_mpes_tiuf_ins     pkg_util.tb_varchar2_5;
t_mpes_croe_ins     pkg_util.tb_varchar2_50;
t_mpes_cres_ins     pkg_util.tb_varchar2_50;
t_mpes_fonc_ins     pkg_util.tb_varchar2_50;
t_mpes_naci_ins     pkg_util.tb_varchar2_1;
t_mpes_ance_ins     pkg_util.tb_number;
t_mpes_eciv_ins     pkg_util.tb_varchar2_1;
t_mpes_gins_ins     pkg_util.tb_varchar2_5;
t_mpes_tipo_ins     pkg_util.tb_varchar2_5;
t_mpes_ntuf_ins     pkg_util.tb_varchar2_5;
t_mpes_tdef_ins     pkg_util.tb_varchar2_5;
t_mpes_pspc_ins     pkg_util.tb_varchar2_1;
t_mpes_cnat_ins     pkg_util.tb_number;
t_mpes_cora_ins     pkg_util.tb_varchar2_5;
t_mpes_pcep_ins     pkg_util.tb_varchar2_10;
t_mpes_cmai_ins     pkg_util.tb_varchar2_1;
t_mpes_chav_ins     pkg_util.tb_varchar2_150;
t_mpes_cosr_ins     pkg_util.tb_varchar2_150;
t_mpes_text_ins     pkg_util.tb_varchar2_4000;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

-- outras variáveis
l_mpes_eciv         mgr_pessoa.mpes_eciv%type;
l_mpes_gins         mgr_pessoa.mpes_gins%type;
l_mpes_tdef         mgr_pessoa.mpes_tdef%type;

-- variável que controla quando trata-se de um novo registro
l_ult_mpes_pcpf     mgr_pessoa.mpes_pcpf%type;

cursor c_pess(  pc_migr_sequ    mgr_migracao.migr_sequ%type) is
    SELECT pkg_mgr_olimpo.f_retorna_cpf_aluno(a.alucod, a.alucpf) alucod
         , pkg_formata_valida.f_formata_nome_novo(a.alunome) alunome
         , a.alusexo
         , a.aludatanasc
         , (SELECT MAX(x.mcid_sequ)
              FROM mgr_cidade x
             WHERE x.mcid_chav = TO_CHAR(a.cidcodendereco)
               AND x.mcid_atua = 'S') mpes_cidd
         , UPPER(TRIM(SUBSTR(a.alubairro, 1, 60))) alubairro
         , UPPER(TRIM(SUBSTR(a.aluendereco, 1, 60))) aluendereco
         , a.alunumero
         , UPPER(TRIM(SUBSTR(a.alucomplemento, 1, 30))) alucomplemento
         , NVL(a.alutelefone, a.alutelefone4) alutelefone
         , NVL(a.alutelefone2, a.alutelefone4) alutelefone2
         , NVL(a.alutelefone3, a.alutelefone4) alutelefone3
         , LOWER(TRIM(a.aluemail)) aluemail
         , pkg_mgr_olimpo.f_retorna_cpf_aluno(a.alucod, a.alucpf, 'S') alucpf
         , a.aluuf
         , SUBSTR(a.alunomepai, 1, 60) alunomepai
         , SUBSTR(a.alunomemae, 1, 60) alunomemae
         , a.alucidadenasc || ' - ' || a.aluufnasc alunatu
         , SUBSTR(a.alurg, 1, 20) alurg
         , UPPER(TRIM(SUBSTR(a.aluexprg, 1, 20))) aluexprg
         , SUBSTR(a.alutituloeleitor, 1, 12) alutituloeleitor
         , SO_NUMERO(a.aluzonaeleitoral) aluzonaeleitoral
         , SO_NUMERO(a.alusecaoeleitoral) alusecaoeleitoral
         , a.aluuftitulo
         , SUBSTR(a.alureservista, 1, 15) alureservista
         , SUBSTR(a.alurmreserv || ' ' || a.alucsmreserv, 1, 15) alurmreserv
         , NVL(a.alunacionalidadetipo, '1') alunacionalidadetipo
         , a.aluanoconcensmedio
         , a.aluestadocivil
         , a.alucandidatoescolaridade
         , a.aluufnasc
         , NVL(a.aludefauditivo, 'N') aludefauditivo
         , NVL(a.aludeffisico, 'N') aludeffisico
         , NVL(a.aludefvisual, 'N') aludefvisual
         , a.aluretspc
         , (SELECT MAX(x.mcid_sequ)
              FROM mgr_cidade x
             WHERE x.mcid_chav = TO_CHAR(a.cidcod)
               AND x.mcid_atua = 'S') cidd_codi_natu
         , TO_CHAR(a.alucorraca) alucorraca
         , SUBSTR(SO_NUMEROC(a.alucep), 1, 8) alucep
         , (SELECT MAX(y.mpes_sequ)
              FROM mgr_pessoa y
                 , oli_aluno_temp w
             WHERE w.alucod = a.alucod
               AND y.mpes_chav = w.mpes_pcpf) mpes_sequ
         , COMPARA_STRING(a.alunome) nom_compara
         , 'FONES OLIMPO - ' || TRIM(NVL(a.alutelefone, '')) || ', ' || TRIM(NVL(a.alutelefone2, '')) || ', ' ||
                           TRIM(NVL(a.alutelefone3, '')) || ', ' || TRIM(NVL(a.alutelefone4, '')) mpes_text
      FROM oli_alunos a
     WHERE EXISTS(  SELECT 1
                      FROM oli_alundiscmini_temp b
                     WHERE b.alucod = a.alucod
                       AND EXISTS(  SELECT 1
                                      FROM mgr_curso l
                                         , mgr_curso j
                                         , mgr_versao m
                                     WHERE l.mcur_chav = TO_CHAR(b.espcod)
                                       AND j.mcur_curs = l.mcur_curs
                                       AND j.mcur_atua = 'S'
                                       AND m.mver_sequ = j.mcur_mver
                                       AND m.mver_migr = pc_migr_sequ))
     ORDER BY alucpf, alucod DESC;

begin
-- só faz algo caso tenha sido passada a versão
if  (p_mver_sequ is not null) then

    -- faz os updates iniciais na tabela mgr_turma_semestre necessários
    pkg_mgr_imp_producao_aux.p_update_inicio_pessoa(p_migr_sequ);

    -- incializa as variáveis
    pkg_mgr_imp_producao_aux.p_update_tabela_pessoa(  t_mpes_sequ_upd, t_mpes_nome_upd, t_mpes_sexo_upd
                                              , t_mpes_dnas_upd, t_mpes_cidd_upd, t_mpes_bair_upd
                                              , t_mpes_ende_upd, t_mpes_nume_upd, t_mpes_comp_upd
                                              , t_mpes_fone_upd, t_mpes_celu_upd, t_mpes_mail_upd
                                              , t_mpes_pcpf_upd, t_mpes_esta_upd, t_mpes_npai_upd
                                              , t_mpes_nmae_upd, t_mpes_natu_upd, t_mpes_iden_upd
                                              , t_mpes_ideo_upd, t_mpes_titu_upd, t_mpes_tizo_upd
                                              , t_mpes_tise_upd, t_mpes_tiuf_upd, t_mpes_croe_upd
                                              , t_mpes_cres_upd, t_mpes_fonc_upd, t_mpes_naci_upd
                                              , t_mpes_ance_upd, t_mpes_eciv_upd, t_mpes_gins_upd
                                              , t_mpes_tipo_upd, t_mpes_ntuf_upd, t_mpes_tdef_upd
                                              , t_mpes_pspc_upd, t_mpes_cnat_upd, t_mpes_cora_upd
                                              , t_mpes_pcep_upd, t_mpes_cmai_upd, t_mpes_cosr_upd
                                              , t_mpes_text_upd, l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_pessoa(  p_mver_sequ, t_mpes_nome_ins, t_mpes_sexo_ins
                                              , t_mpes_dnas_ins, t_mpes_cidd_ins, t_mpes_bair_ins
                                              , t_mpes_ende_ins, t_mpes_nume_ins, t_mpes_comp_ins
                                              , t_mpes_fone_ins, t_mpes_celu_ins, t_mpes_mail_ins
                                              , t_mpes_pcpf_ins, t_mpes_esta_ins, t_mpes_npai_ins
                                              , t_mpes_nmae_ins, t_mpes_natu_ins, t_mpes_iden_ins
                                              , t_mpes_ideo_ins, t_mpes_titu_ins, t_mpes_tizo_ins
                                              , t_mpes_tise_ins, t_mpes_tiuf_ins, t_mpes_croe_ins
                                              , t_mpes_cres_ins, t_mpes_fonc_ins, t_mpes_naci_ins
                                              , t_mpes_ance_ins, t_mpes_eciv_ins, t_mpes_gins_ins
                                              , t_mpes_tipo_ins, t_mpes_ntuf_ins, t_mpes_tdef_ins
                                              , t_mpes_pspc_ins, t_mpes_cnat_ins, t_mpes_cora_ins
                                              , t_mpes_pcep_ins, t_mpes_cmai_ins, t_mpes_chav_ins
                                              , t_mpes_cosr_ins, t_mpes_text_ins, l_contador_ins);

    -- inicia o contador
    l_contador_trans := 1;
    
    for r_c_pess in c_pess(p_migr_sequ) loop

        -- limpa as variáveis
        l_mpes_gins := null;
        l_mpes_tdef := null;
        l_mpes_eciv := null;

        -- Estado civil
        if  (r_c_pess.aluestadocivil is not null) then

            case (r_c_pess.aluestadocivil)
                -- C - Casado
                when 'C' then l_mpes_eciv := '2';
                --  D - Divorciado
                when 'D' then l_mpes_eciv := '3';
                -- E - Desquitado 
                when 'E' then l_mpes_eciv := '4';
                -- P - Separado
                when 'P' then l_mpes_eciv := '4';
                -- Q - Separado (extra-judicialmente)
                when 'Q' then l_mpes_eciv := '4';
                -- V - Viuvo
                when 'V' then l_mpes_eciv := '5';
                -- U - União Estável
                when 'U' then l_mpes_eciv := '7';
                -- Todo o resto é solteiro
                else l_mpes_eciv := '1';

            end case;
        end if;

        -- Só altera a escolaridade se a mesma está informada
        if  (r_c_pess.alucandidatoescolaridade is not null) then
        
            case (r_c_pess.alucandidatoescolaridade)
                -- 1º grau completo
                when 1 then l_mpes_gins := '12';
                -- 2º grau completo
                when 2 then l_mpes_gins := '16';
                -- Graduado
                when 3 then l_mpes_gins := '20';

                else l_mpes_gins := null;
            end case;
        end if;

        -- verifica se a pessoa tem alguma necessidade especial, como os valores do Olimpo são apenas
        -- sim e não, decidimos assumir a menor deficiencia de cada tipo
        if  (r_c_pess.aludefauditivo = 'S') then

            l_mpes_tdef := '16';

        elsif  (r_c_pess.aludeffisico = 'S') then

            l_mpes_tdef := '3';

        elsif  (r_c_pess.aludefvisual = 'S') then

            l_mpes_tdef := '15';
        end if;

        if  (nvl(r_c_pess.alucpf, 'Y') != NVL(l_ult_mpes_pcpf, 'X')) then

            -- verifica se atingiu a quantidade de registros por transação
            if  (l_contador_trans >= pkg_util.c_limit_trans) then

                -- atualiza os registro e devolve as variáveis reinicializadas
                pkg_mgr_imp_producao_aux.p_update_tabela_pessoa(  t_mpes_sequ_upd, t_mpes_nome_upd, t_mpes_sexo_upd
                                                          , t_mpes_dnas_upd, t_mpes_cidd_upd, t_mpes_bair_upd
                                                          , t_mpes_ende_upd, t_mpes_nume_upd, t_mpes_comp_upd
                                                          , t_mpes_fone_upd, t_mpes_celu_upd, t_mpes_mail_upd
                                                          , t_mpes_pcpf_upd, t_mpes_esta_upd, t_mpes_npai_upd
                                                          , t_mpes_nmae_upd, t_mpes_natu_upd, t_mpes_iden_upd
                                                          , t_mpes_ideo_upd, t_mpes_titu_upd, t_mpes_tizo_upd
                                                          , t_mpes_tise_upd, t_mpes_tiuf_upd, t_mpes_croe_upd
                                                          , t_mpes_cres_upd, t_mpes_fonc_upd, t_mpes_naci_upd
                                                          , t_mpes_ance_upd, t_mpes_eciv_upd, t_mpes_gins_upd
                                                          , t_mpes_tipo_upd, t_mpes_ntuf_upd, t_mpes_tdef_upd
                                                          , t_mpes_pspc_upd, t_mpes_cnat_upd, t_mpes_cora_upd
                                                          , t_mpes_pcep_upd, t_mpes_cmai_upd, t_mpes_cosr_upd
                                                          , t_mpes_text_upd, l_contador_upd);

                -- insere os registro e devolve as variáveis reinicializadas
                pkg_mgr_imp_producao_aux.p_insert_tabela_pessoa(  p_mver_sequ, t_mpes_nome_ins, t_mpes_sexo_ins
                                                          , t_mpes_dnas_ins, t_mpes_cidd_ins, t_mpes_bair_ins
                                                          , t_mpes_ende_ins, t_mpes_nume_ins, t_mpes_comp_ins
                                                          , t_mpes_fone_ins, t_mpes_celu_ins, t_mpes_mail_ins
                                                          , t_mpes_pcpf_ins, t_mpes_esta_ins, t_mpes_npai_ins
                                                          , t_mpes_nmae_ins, t_mpes_natu_ins, t_mpes_iden_ins
                                                          , t_mpes_ideo_ins, t_mpes_titu_ins, t_mpes_tizo_ins
                                                          , t_mpes_tise_ins, t_mpes_tiuf_ins, t_mpes_croe_ins
                                                          , t_mpes_cres_ins, t_mpes_fonc_ins, t_mpes_naci_ins
                                                          , t_mpes_ance_ins, t_mpes_eciv_ins, t_mpes_gins_ins
                                                          , t_mpes_tipo_ins, t_mpes_ntuf_ins, t_mpes_tdef_ins
                                                          , t_mpes_pspc_ins, t_mpes_cnat_ins, t_mpes_cora_ins
                                                          , t_mpes_pcep_ins, t_mpes_cmai_ins, t_mpes_chav_ins
                                                          , t_mpes_cosr_ins, t_mpes_text_ins, l_contador_ins);

                l_contador_trans := 1;
            else
                l_contador_trans := l_contador_trans + 1;
            end if;
        end if;

        -- se identificou um registro na mgr_pessoa então é atualização
        if  (r_c_pess.mpes_sequ is not null) then

            -- garante que o cpf não é o mesmo do anterior, isso para não gerarmos registros duplicados 
            -- na mgr_pessoa por existir mais de um aluno para a mesma pessoa
            -- quando for igual apenas vamos alimentar informações que não vieram no registro mais atual, 
            -- isso o order by feito no cursor irá nos garantir pois ele trará sempre o último aluno da tabela oli_alunos
            if  (nvl(r_c_pess.alucpf, 'Y') != NVL(l_ult_mpes_pcpf, 'X')) then

                l_contador_upd := l_contador_upd + 1;

                t_mpes_sequ_upd(l_contador_upd) := r_c_pess.mpes_sequ;
                t_mpes_nome_upd(l_contador_upd) := r_c_pess.alunome;
                t_mpes_sexo_upd(l_contador_upd) := r_c_pess.alusexo;
                t_mpes_dnas_upd(l_contador_upd) := r_c_pess.aludatanasc;
                t_mpes_cidd_upd(l_contador_upd) := r_c_pess.mpes_cidd;
                t_mpes_bair_upd(l_contador_upd) := r_c_pess.alubairro;
                t_mpes_ende_upd(l_contador_upd) := r_c_pess.aluendereco;
                t_mpes_nume_upd(l_contador_upd) := r_c_pess.alunumero;
                t_mpes_comp_upd(l_contador_upd) := r_c_pess.alucomplemento;
                t_mpes_fone_upd(l_contador_upd) := r_c_pess.alutelefone;
                t_mpes_celu_upd(l_contador_upd) := r_c_pess.alutelefone2;
                t_mpes_mail_upd(l_contador_upd) := r_c_pess.aluemail;
                t_mpes_pcpf_upd(l_contador_upd) := r_c_pess.alucpf;
                t_mpes_esta_upd(l_contador_upd) := r_c_pess.aluuf;
                t_mpes_npai_upd(l_contador_upd) := r_c_pess.alunomepai;
                t_mpes_nmae_upd(l_contador_upd) := r_c_pess.alunomemae;
                t_mpes_natu_upd(l_contador_upd) := r_c_pess.alunatu;
                t_mpes_iden_upd(l_contador_upd) := r_c_pess.alurg;
                t_mpes_ideo_upd(l_contador_upd) := r_c_pess.aluexprg;
                t_mpes_titu_upd(l_contador_upd) := r_c_pess.alutituloeleitor;
                t_mpes_tizo_upd(l_contador_upd) := r_c_pess.aluzonaeleitoral;
                t_mpes_tise_upd(l_contador_upd) := r_c_pess.alusecaoeleitoral;
                t_mpes_tiuf_upd(l_contador_upd) := r_c_pess.aluuftitulo;
                t_mpes_croe_upd(l_contador_upd) := r_c_pess.alurmreserv;
                t_mpes_cres_upd(l_contador_upd) := r_c_pess.alureservista;
                t_mpes_fonc_upd(l_contador_upd) := r_c_pess.alutelefone3;
                t_mpes_naci_upd(l_contador_upd) := r_c_pess.alunacionalidadetipo;
                t_mpes_ance_upd(l_contador_upd) := r_c_pess.aluanoconcensmedio;
                t_mpes_eciv_upd(l_contador_upd) := l_mpes_eciv;
                t_mpes_gins_upd(l_contador_upd) := l_mpes_gins;
                t_mpes_tipo_upd(l_contador_upd) := 'F';
                t_mpes_ntuf_upd(l_contador_upd) := r_c_pess.aluufnasc;
                t_mpes_tdef_upd(l_contador_upd) := l_mpes_tdef;
                t_mpes_pspc_upd(l_contador_upd) := r_c_pess.aluretspc;
                t_mpes_cnat_upd(l_contador_upd) := r_c_pess.cidd_codi_natu;
                t_mpes_cora_upd(l_contador_upd) := r_c_pess.alucorraca;
                t_mpes_pcep_upd(l_contador_upd) := r_c_pess.alucep;
                t_mpes_cmai_upd(l_contador_upd) := 'N';
                t_mpes_cosr_upd(l_contador_upd) := r_c_pess.nom_compara;
                t_mpes_text_upd(l_contador_upd) := r_c_pess.mpes_text;

            else

                t_mpes_sequ_upd(l_contador_upd) := NVL(t_mpes_sequ_upd(l_contador_upd), r_c_pess.mpes_sequ);
                t_mpes_nome_upd(l_contador_upd) := NVL(t_mpes_nome_upd(l_contador_upd), r_c_pess.alunome);
                t_mpes_sexo_upd(l_contador_upd) := NVL(t_mpes_sexo_upd(l_contador_upd), r_c_pess.alusexo);
                t_mpes_dnas_upd(l_contador_upd) := NVL(t_mpes_dnas_upd(l_contador_upd), r_c_pess.aludatanasc);
                t_mpes_cidd_upd(l_contador_upd) := NVL(t_mpes_cidd_upd(l_contador_upd), r_c_pess.mpes_cidd);
                t_mpes_bair_upd(l_contador_upd) := NVL(t_mpes_bair_upd(l_contador_upd), r_c_pess.alubairro);
                t_mpes_ende_upd(l_contador_upd) := NVL(t_mpes_ende_upd(l_contador_upd), r_c_pess.aluendereco);
                t_mpes_nume_upd(l_contador_upd) := NVL(t_mpes_nume_upd(l_contador_upd), r_c_pess.alunumero);
                t_mpes_comp_upd(l_contador_upd) := NVL(t_mpes_comp_upd(l_contador_upd), r_c_pess.alucomplemento);
                t_mpes_fone_upd(l_contador_upd) := NVL(t_mpes_fone_upd(l_contador_upd), r_c_pess.alutelefone);
                t_mpes_celu_upd(l_contador_upd) := NVL(t_mpes_celu_upd(l_contador_upd), r_c_pess.alutelefone2);
                t_mpes_mail_upd(l_contador_upd) := NVL(t_mpes_mail_upd(l_contador_upd), r_c_pess.aluemail);
                t_mpes_pcpf_upd(l_contador_upd) := NVL(t_mpes_pcpf_upd(l_contador_upd), r_c_pess.alucpf);
                t_mpes_esta_upd(l_contador_upd) := NVL(t_mpes_esta_upd(l_contador_upd), r_c_pess.aluuf);
                t_mpes_npai_upd(l_contador_upd) := NVL(t_mpes_npai_upd(l_contador_upd), r_c_pess.alunomepai);
                t_mpes_nmae_upd(l_contador_upd) := NVL(t_mpes_nmae_upd(l_contador_upd), r_c_pess.alunomemae);
                t_mpes_natu_upd(l_contador_upd) := NVL(t_mpes_natu_upd(l_contador_upd), r_c_pess.alunatu);
                t_mpes_iden_upd(l_contador_upd) := NVL(t_mpes_iden_upd(l_contador_upd), r_c_pess.alurg);
                t_mpes_ideo_upd(l_contador_upd) := NVL(t_mpes_ideo_upd(l_contador_upd), r_c_pess.aluexprg);
                t_mpes_titu_upd(l_contador_upd) := NVL(t_mpes_titu_upd(l_contador_upd), r_c_pess.alutituloeleitor);
                t_mpes_tizo_upd(l_contador_upd) := NVL(t_mpes_tizo_upd(l_contador_upd), r_c_pess.aluzonaeleitoral);
                t_mpes_tise_upd(l_contador_upd) := NVL(t_mpes_tise_upd(l_contador_upd), r_c_pess.alusecaoeleitoral);
                t_mpes_tiuf_upd(l_contador_upd) := NVL(t_mpes_tiuf_upd(l_contador_upd), r_c_pess.aluuftitulo);
                t_mpes_croe_upd(l_contador_upd) := NVL(t_mpes_croe_upd(l_contador_upd), r_c_pess.alurmreserv);
                t_mpes_cres_upd(l_contador_upd) := NVL(t_mpes_cres_upd(l_contador_upd), r_c_pess.alureservista);
                t_mpes_fonc_upd(l_contador_upd) := NVL(t_mpes_fonc_upd(l_contador_upd), r_c_pess.alutelefone3);
                t_mpes_naci_upd(l_contador_upd) := NVL(t_mpes_naci_upd(l_contador_upd), r_c_pess.alunacionalidadetipo);
                t_mpes_ance_upd(l_contador_upd) := NVL(t_mpes_ance_upd(l_contador_upd), r_c_pess.aluanoconcensmedio);
                t_mpes_eciv_upd(l_contador_upd) := NVL(t_mpes_eciv_upd(l_contador_upd), l_mpes_eciv);
                t_mpes_gins_upd(l_contador_upd) := NVL(t_mpes_gins_upd(l_contador_upd), l_mpes_gins);
                t_mpes_tipo_upd(l_contador_upd) := NVL(t_mpes_tipo_upd(l_contador_upd), 'F');
                t_mpes_ntuf_upd(l_contador_upd) := NVL(t_mpes_ntuf_upd(l_contador_upd), r_c_pess.aluufnasc);
                t_mpes_tdef_upd(l_contador_upd) := NVL(t_mpes_tdef_upd(l_contador_upd), l_mpes_tdef);
                t_mpes_pspc_upd(l_contador_upd) := NVL(t_mpes_pspc_upd(l_contador_upd), r_c_pess.aluretspc);
                t_mpes_cnat_upd(l_contador_upd) := NVL(t_mpes_cnat_upd(l_contador_upd), r_c_pess.cidd_codi_natu);
                t_mpes_cora_upd(l_contador_upd) := NVL(t_mpes_cora_upd(l_contador_upd), r_c_pess.alucorraca);
                t_mpes_pcep_upd(l_contador_upd) := NVL(t_mpes_pcep_upd(l_contador_upd), r_c_pess.alucep);
                t_mpes_cmai_upd(l_contador_upd) := NVL(t_mpes_cmai_upd(l_contador_upd), 'N');
                t_mpes_cosr_upd(l_contador_upd) := NVL(t_mpes_cosr_upd(l_contador_upd), r_c_pess.nom_compara);
                t_mpes_text_upd(l_contador_upd) := NVL(t_mpes_text_upd(l_contador_upd), r_c_pess.mpes_text);

            end if;
        -- se não é inserção de novo registro
        else
            -- garante que o cpf não é o mesmo do anterior, isso para não gerarmos registros duplicados 
            -- na mgr_pessoa por existir mais de um aluno para a mesma pessoa
            -- quando for igual apenas vamos alimentar informações que não vieram no registro mais atual, 
            -- isso o order by feito no cursor irá nos garantir pois ele trará sempre o último aluno da tabela oli_alunos
            if  (nvl(r_c_pess.alucpf, 'Y') != NVL(l_ult_mpes_pcpf, 'X')) then

                l_contador_ins := l_contador_ins + 1;

                t_mpes_nome_ins(l_contador_ins) := r_c_pess.alunome;
                t_mpes_sexo_ins(l_contador_ins) := r_c_pess.alusexo;
                t_mpes_dnas_ins(l_contador_ins) := r_c_pess.aludatanasc;
                t_mpes_cidd_ins(l_contador_ins) := r_c_pess.mpes_cidd;
                t_mpes_bair_ins(l_contador_ins) := r_c_pess.alubairro;
                t_mpes_ende_ins(l_contador_ins) := r_c_pess.aluendereco;
                t_mpes_nume_ins(l_contador_ins) := r_c_pess.alunumero;
                t_mpes_comp_ins(l_contador_ins) := r_c_pess.alucomplemento;
                t_mpes_fone_ins(l_contador_ins) := r_c_pess.alutelefone;
                t_mpes_celu_ins(l_contador_ins) := r_c_pess.alutelefone2;
                t_mpes_mail_ins(l_contador_ins) := r_c_pess.aluemail;
                t_mpes_pcpf_ins(l_contador_ins) := r_c_pess.alucpf;
                t_mpes_esta_ins(l_contador_ins) := r_c_pess.aluuf;
                t_mpes_npai_ins(l_contador_ins) := r_c_pess.alunomepai;
                t_mpes_nmae_ins(l_contador_ins) := r_c_pess.alunomemae;
                t_mpes_natu_ins(l_contador_ins) := r_c_pess.alunatu;
                t_mpes_iden_ins(l_contador_ins) := r_c_pess.alurg;
                t_mpes_ideo_ins(l_contador_ins) := r_c_pess.aluexprg;
                t_mpes_titu_ins(l_contador_ins) := r_c_pess.alutituloeleitor;
                t_mpes_tizo_ins(l_contador_ins) := r_c_pess.aluzonaeleitoral;
                t_mpes_tise_ins(l_contador_ins) := r_c_pess.alusecaoeleitoral;
                t_mpes_tiuf_ins(l_contador_ins) := r_c_pess.aluuftitulo;
                t_mpes_croe_ins(l_contador_ins) := r_c_pess.alurmreserv;
                t_mpes_cres_ins(l_contador_ins) := r_c_pess.alureservista;
                t_mpes_fonc_ins(l_contador_ins) := r_c_pess.alutelefone3;
                t_mpes_naci_ins(l_contador_ins) := r_c_pess.alunacionalidadetipo;
                t_mpes_ance_ins(l_contador_ins) := r_c_pess.aluanoconcensmedio;
                t_mpes_eciv_ins(l_contador_ins) := l_mpes_eciv;
                t_mpes_gins_ins(l_contador_ins) := l_mpes_gins;
                t_mpes_tipo_ins(l_contador_ins) := 'F';
                t_mpes_ntuf_ins(l_contador_ins) := r_c_pess.aluufnasc;
                t_mpes_tdef_ins(l_contador_ins) := l_mpes_tdef;
                t_mpes_pspc_ins(l_contador_ins) := r_c_pess.aluretspc;
                t_mpes_cnat_ins(l_contador_ins) := r_c_pess.cidd_codi_natu;
                t_mpes_cora_ins(l_contador_ins) := r_c_pess.alucorraca;
                t_mpes_pcep_ins(l_contador_ins) := r_c_pess.alucep;
                t_mpes_cmai_ins(l_contador_ins) := 'N';
                t_mpes_chav_ins(l_contador_ins) := r_c_pess.alucod;
                t_mpes_cosr_ins(l_contador_ins) := r_c_pess.nom_compara;
                t_mpes_text_ins(l_contador_ins) := r_c_pess.mpes_text;
            else

                t_mpes_nome_ins(l_contador_ins) := NVL(t_mpes_nome_ins(l_contador_ins), r_c_pess.alunome);
                t_mpes_sexo_ins(l_contador_ins) := NVL(t_mpes_sexo_ins(l_contador_ins), r_c_pess.alusexo);
                t_mpes_dnas_ins(l_contador_ins) := NVL(t_mpes_dnas_ins(l_contador_ins), r_c_pess.aludatanasc);
                t_mpes_cidd_ins(l_contador_ins) := NVL(t_mpes_cidd_ins(l_contador_ins), r_c_pess.mpes_cidd);
                t_mpes_bair_ins(l_contador_ins) := NVL(t_mpes_bair_ins(l_contador_ins), r_c_pess.alubairro);
                t_mpes_ende_ins(l_contador_ins) := NVL(t_mpes_ende_ins(l_contador_ins), r_c_pess.aluendereco);
                t_mpes_nume_ins(l_contador_ins) := NVL(t_mpes_nume_ins(l_contador_ins), r_c_pess.alunumero);
                t_mpes_comp_ins(l_contador_ins) := NVL(t_mpes_comp_ins(l_contador_ins), r_c_pess.alucomplemento);
                t_mpes_fone_ins(l_contador_ins) := NVL(t_mpes_fone_ins(l_contador_ins), r_c_pess.alutelefone);
                t_mpes_celu_ins(l_contador_ins) := NVL(t_mpes_celu_ins(l_contador_ins), r_c_pess.alutelefone2);
                t_mpes_mail_ins(l_contador_ins) := NVL(t_mpes_mail_ins(l_contador_ins), r_c_pess.aluemail);
                t_mpes_pcpf_ins(l_contador_ins) := NVL(t_mpes_pcpf_ins(l_contador_ins), r_c_pess.alucpf);
                t_mpes_esta_ins(l_contador_ins) := NVL(t_mpes_esta_ins(l_contador_ins), r_c_pess.aluuf);
                t_mpes_npai_ins(l_contador_ins) := NVL(t_mpes_npai_ins(l_contador_ins), r_c_pess.alunomepai);
                t_mpes_nmae_ins(l_contador_ins) := NVL(t_mpes_nmae_ins(l_contador_ins), r_c_pess.alunomemae);
                t_mpes_natu_ins(l_contador_ins) := NVL(t_mpes_natu_ins(l_contador_ins), r_c_pess.alunatu);
                t_mpes_iden_ins(l_contador_ins) := NVL(t_mpes_iden_ins(l_contador_ins), r_c_pess.alurg);
                t_mpes_ideo_ins(l_contador_ins) := NVL(t_mpes_ideo_ins(l_contador_ins), r_c_pess.aluexprg);
                t_mpes_titu_ins(l_contador_ins) := NVL(t_mpes_titu_ins(l_contador_ins), r_c_pess.alutituloeleitor);
                t_mpes_tizo_ins(l_contador_ins) := NVL(t_mpes_tizo_ins(l_contador_ins), r_c_pess.aluzonaeleitoral);
                t_mpes_tise_ins(l_contador_ins) := NVL(t_mpes_tise_ins(l_contador_ins), r_c_pess.alusecaoeleitoral);
                t_mpes_tiuf_ins(l_contador_ins) := NVL(t_mpes_tiuf_ins(l_contador_ins), r_c_pess.aluuftitulo);
                t_mpes_croe_ins(l_contador_ins) := NVL(t_mpes_croe_ins(l_contador_ins), r_c_pess.alurmreserv);
                t_mpes_cres_ins(l_contador_ins) := NVL(t_mpes_cres_ins(l_contador_ins), r_c_pess.alureservista);
                t_mpes_fonc_ins(l_contador_ins) := NVL(t_mpes_fonc_ins(l_contador_ins), r_c_pess.alutelefone3);
                t_mpes_naci_ins(l_contador_ins) := NVL(t_mpes_naci_ins(l_contador_ins), r_c_pess.alunacionalidadetipo);
                t_mpes_ance_ins(l_contador_ins) := NVL(t_mpes_ance_ins(l_contador_ins), r_c_pess.aluanoconcensmedio);
                t_mpes_eciv_ins(l_contador_ins) := NVL(t_mpes_eciv_ins(l_contador_ins), l_mpes_eciv);
                t_mpes_gins_ins(l_contador_ins) := NVL(t_mpes_gins_ins(l_contador_ins), l_mpes_gins);
                t_mpes_tipo_ins(l_contador_ins) := NVL(t_mpes_tipo_ins(l_contador_ins), 'F');
                t_mpes_ntuf_ins(l_contador_ins) := NVL(t_mpes_ntuf_ins(l_contador_ins), r_c_pess.aluufnasc);
                t_mpes_tdef_ins(l_contador_ins) := NVL(t_mpes_tdef_ins(l_contador_ins), l_mpes_tdef);
                t_mpes_pspc_ins(l_contador_ins) := NVL(t_mpes_pspc_ins(l_contador_ins), r_c_pess.aluretspc);
                t_mpes_cnat_ins(l_contador_ins) := NVL(t_mpes_cnat_ins(l_contador_ins), r_c_pess.cidd_codi_natu);
                t_mpes_cora_ins(l_contador_ins) := NVL(t_mpes_cora_ins(l_contador_ins), r_c_pess.alucorraca);
                t_mpes_pcep_ins(l_contador_ins) := NVL(t_mpes_pcep_ins(l_contador_ins), r_c_pess.alucep);
                t_mpes_cmai_ins(l_contador_ins) := NVL(t_mpes_cmai_ins(l_contador_ins), 'N');
                t_mpes_chav_ins(l_contador_ins) := NVL(t_mpes_chav_ins(l_contador_ins), r_c_pess.alucod);
                t_mpes_cosr_ins(l_contador_ins) := NVL(t_mpes_cosr_ins(l_contador_ins), r_c_pess.nom_compara);
                t_mpes_text_ins(l_contador_ins) := NVL(t_mpes_text_ins(l_contador_ins), r_c_pess.mpes_text);
            end if;
        end if;

        l_ult_mpes_pcpf := r_c_pess.alucpf;
    end loop;

    -- caso dentro do loop não tenha chego à quantidade que precisa para fechar a transação
    -- então envia tudo que tiver para o update e insert
    pkg_mgr_imp_producao_aux.p_update_tabela_pessoa(  t_mpes_sequ_upd, t_mpes_nome_upd, t_mpes_sexo_upd
                                              , t_mpes_dnas_upd, t_mpes_cidd_upd, t_mpes_bair_upd
                                              , t_mpes_ende_upd, t_mpes_nume_upd, t_mpes_comp_upd
                                              , t_mpes_fone_upd, t_mpes_celu_upd, t_mpes_mail_upd
                                              , t_mpes_pcpf_upd, t_mpes_esta_upd, t_mpes_npai_upd
                                              , t_mpes_nmae_upd, t_mpes_natu_upd, t_mpes_iden_upd
                                              , t_mpes_ideo_upd, t_mpes_titu_upd, t_mpes_tizo_upd
                                              , t_mpes_tise_upd, t_mpes_tiuf_upd, t_mpes_croe_upd
                                              , t_mpes_cres_upd, t_mpes_fonc_upd, t_mpes_naci_upd
                                              , t_mpes_ance_upd, t_mpes_eciv_upd, t_mpes_gins_upd
                                              , t_mpes_tipo_upd, t_mpes_ntuf_upd, t_mpes_tdef_upd
                                              , t_mpes_pspc_upd, t_mpes_cnat_upd, t_mpes_cora_upd
                                              , t_mpes_pcep_upd, t_mpes_cmai_upd, t_mpes_cosr_upd
                                              , t_mpes_text_upd, l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_pessoa(  p_mver_sequ, t_mpes_nome_ins, t_mpes_sexo_ins
                                              , t_mpes_dnas_ins, t_mpes_cidd_ins, t_mpes_bair_ins
                                              , t_mpes_ende_ins, t_mpes_nume_ins, t_mpes_comp_ins
                                              , t_mpes_fone_ins, t_mpes_celu_ins, t_mpes_mail_ins
                                              , t_mpes_pcpf_ins, t_mpes_esta_ins, t_mpes_npai_ins
                                              , t_mpes_nmae_ins, t_mpes_natu_ins, t_mpes_iden_ins
                                              , t_mpes_ideo_ins, t_mpes_titu_ins, t_mpes_tizo_ins
                                              , t_mpes_tise_ins, t_mpes_tiuf_ins, t_mpes_croe_ins
                                              , t_mpes_cres_ins, t_mpes_fonc_ins, t_mpes_naci_ins
                                              , t_mpes_ance_ins, t_mpes_eciv_ins, t_mpes_gins_ins
                                              , t_mpes_tipo_ins, t_mpes_ntuf_ins, t_mpes_tdef_ins
                                              , t_mpes_pspc_ins, t_mpes_cnat_ins, t_mpes_cora_ins
                                              , t_mpes_pcep_ins, t_mpes_cmai_ins, t_mpes_chav_ins
                                              , t_mpes_cosr_ins, t_mpes_text_ins, l_contador_ins);

    pkg_mgr_imp_producao_aux.p_vincula_pessoa_mgr_pessoa(p_migr_sequ);
end if;

end p_importa_pessoa;

procedure p_importa_aluno(  p_migr_sequ     mgr_migracao.migr_sequ%type
                          , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- tabelas utilizadas no update
t_malu_sequ_upd     pkg_util.tb_number;
t_malu_form_upd     pkg_util.tb_varchar2_1;
t_malu_stat_upd     pkg_util.tb_varchar2_5;
t_malu_mpes_upd     pkg_util.tb_number;
t_malu_asig_upd     pkg_util.tb_varchar2_10;
t_malu_mcur_upd     pkg_util.tb_number;
t_malu_psem_upd     pkg_util.tb_varchar2_10;
t_malu_msed_upd     pkg_util.tb_number;
t_malu_diis_upd     pkg_util.tb_varchar2_1;
t_malu_fing_upd     pkg_util.tb_varchar2_5;
t_malu_ding_upd     pkg_util.tb_date;
t_malu_ogra_upd     pkg_util.tb_varchar2_150;

-- tabelas utilizadas no insert
t_malu_form_ins     pkg_util.tb_varchar2_1;
t_malu_stat_ins     pkg_util.tb_varchar2_5;
t_malu_mpes_ins     pkg_util.tb_number;
t_malu_asig_ins     pkg_util.tb_varchar2_10;
t_malu_mcur_ins     pkg_util.tb_number;
t_malu_chav_ins     pkg_util.tb_varchar2_150;
t_malu_psem_ins     pkg_util.tb_varchar2_10;
t_malu_msed_ins     pkg_util.tb_number;
t_malu_diis_ins     pkg_util.tb_varchar2_1;
t_malu_fing_ins     pkg_util.tb_varchar2_5;
t_malu_ding_ins     pkg_util.tb_date;
t_malu_ogra_ins     pkg_util.tb_varchar2_150;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

-- demais variáveis
l_malu_form         mgr_aluno.malu_form%type;
l_malu_stat         mgr_aluno.malu_stat%type;
l_malu_fing         mgr_aluno.malu_fing%type;
l_malu_ogra         mgr_aluno.malu_ogra%type;

cursor c_malu(  pc_migr_sequ        mgr_migracao.migr_sequ%type
              , pc_seme_inic_acad   varchar2) is
    SELECT TO_CHAR(b.alucod) alucod
         , (SELECT MAX(x.asisituacao)
              FROM oli_v_alunsituatual x
             WHERE x.alucod = b.alucod
               AND x.espcod = c.espcod) alusitu
         , a.mpes_sequ
         , (SELECT MIN(r.msem_seme)
              FROM oli_alundisc o
                 , oli_discmini p
                 , mgr_semestre r
             WHERE o.alucod = c.alucod
               AND o.espcod = c.espcod
               AND p.discod = o.discod
               AND p.tmacod = o.tmacod
               AND p.dimtip = o.dimtip
               AND r.msem_chav = p.pelcod
               AND r.msem_atua = 'S'
               AND r.msem_seme >= pc_seme_inic_acad) malu_psem
          , (SELECT MIN(r.msem_seme)
              FROM oli_alundisc o
                 , oli_discmini p
                 , mgr_semestre r
             WHERE o.alucod = c.alucod
               AND p.discod = o.discod
               AND p.tmacod = o.tmacod
               AND p.dimtip = o.dimtip
               AND r.msem_chav = p.pelcod
               AND r.msem_atua = 'S'
               AND r.msem_seme >= pc_seme_inic_acad) malu_psem_null
          , l.mcur_sequ
          -- busca de aluno verificando se é disciplina isolada
          , (SELECT MAX(q.malu_sequ)
              FROM oli_especial_temp e
                 , mgr_sede f
                 , mgr_aluno q
             WHERE e.espcod = c.espcod
               AND f.msed_chav = TO_CHAR(e.iunicodempresa)
               AND q.malu_chav = TO_CHAR(b.alucod)
               AND q.malu_mcur = l.mcur_sequ
               AND q.malu_msed = f.msed_sequ
               AND q.malu_diis = 'S'
               AND c.acrtipoingresso = 'D') malu_sequ_diis
          -- busca de aluno quando não for disciplina isolada
          , (SELECT MAX(q.malu_sequ)
              FROM oli_especial_temp e
                 , mgr_sede f
                 , mgr_aluno q
             WHERE e.espcod = c.espcod
               AND f.msed_chav = TO_CHAR(e.iunicodempresa)
               AND q.malu_chav = TO_CHAR(b.alucod)
               AND q.malu_mcur = l.mcur_sequ
               AND q.malu_msed = f.msed_sequ
               AND q.malu_diis = 'N'
               AND c.acrtipoingresso != 'D') malu_sequ
          , (SELECT MAX(f.msed_sequ)
               FROM oli_especial_temp e
                  , mgr_sede f
              WHERE e.espcod = c.espcod
                AND f.msed_chav = TO_CHAR(e.iunicodempresa)) malu_msed
         , DECODE(c.acrtipoingresso, 'D', 'S', 'N') malu_diis
         , c.acrtipoingresso
         , c.acrdataingresso
         , c.acrsituacao
		 , (SELECT MAX(z.msem_seme)
		      FROM mgr_semestre z
		     WHERE z.msem_chav = c.pelcodfinanceiro) malu_asig
         , c.gracod
         , (SELECT MAX(t.gracod)
              FROM oli_turma t
             WHERE t.tmacod = c.tmacod) grad_turs
      FROM mgr_pessoa a
         , oli_aluno_temp d
         , oli_alunos b
         , oli_aluncurs c
         , mgr_curso l
     WHERE a.mpes_atua = 'S'
       AND d.mpes_pcpf = a.mpes_chav
       AND b.alucod = d.alucod
       AND c.alucod = b.alucod
       AND l.mcur_chav = TO_CHAR(c.espcod)
       AND l.mcur_atua = 'S'
       AND EXISTS ( SELECT 1
                      FROM mgr_curso n
                         , oli_alundiscmini_temp x
                     WHERE n.mcur_curs = l.mcur_curs
                       AND x.alucod = b.alucod
                       AND x.espcod = n.mcur_chav)
       AND EXISTS (SELECT 1
                     FROM mgr_versao m
                    WHERE m.mver_sequ = l.mcur_mver
                      AND m.mver_migr = pc_migr_sequ);

begin
-- só faz algo se foi passada a versão
if  (p_mver_sequ is not null) then

    -- faz os updates iniciais na tabela mgr_turma_semestre necessários
    pkg_mgr_imp_producao_aux.p_update_inicio_aluno(p_migr_sequ);

    -- incializa as variáveis
    pkg_mgr_imp_producao_aux.p_update_tabela_aluno(   t_malu_sequ_upd, t_malu_form_upd, t_malu_stat_upd
                                                    , t_malu_mpes_upd, t_malu_asig_upd, t_malu_mcur_upd
                                                    , t_malu_psem_upd, t_malu_msed_upd, t_malu_diis_upd
                                                    , t_malu_fing_upd, t_malu_ding_upd, t_malu_ogra_upd
                                                    , l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_aluno(   p_mver_sequ, t_malu_form_ins, t_malu_stat_ins
                                                    , t_malu_mpes_ins, t_malu_asig_ins, t_malu_mcur_ins
                                                    , t_malu_chav_ins, t_malu_psem_ins, t_malu_msed_ins
                                                    , t_malu_diis_ins, t_malu_fing_ins, t_malu_ding_ins
                                                    , t_malu_ogra_ins, l_contador_ins);

    -- inicia o contador
    l_contador_trans := 1;

    for r_c_malu in c_malu(p_migr_sequ, f_seme_ini_imp_academico) loop

        -- verificamos que quando o aluno possui situação M não existe nenhuma informação do aluno no OLIMPO
        -- por este motivo quando é M não importamos
        if  (r_c_malu.alusitu != 'M') then 

            -- Verifica se o aluno já está formado
            if  (r_c_malu.alusitu = 'F') then

                l_malu_form := 'S';
            else

                l_malu_form := 'N';
            end if;

            -- verifica a situação do aluno
            case    (r_c_malu.alusitu)
                -- Cursando - Cadastrado
                when 'C' then l_malu_stat := '1';
                -- Desistente - Desistente
                when 'D' then l_malu_stat := '2';
                -- Matrícula Cancelada- Desistente
                when 'E' then l_malu_stat := '2';
                -- Não Rematriculado - Desistente
                when 'N' then l_malu_stat := '2';
                -- Transferido - Desistente
                when 'R' then l_malu_stat := '2';
                -- Trancado - Desistente
                when 'T' then l_malu_stat := '2';
                -- Expulso - Desistente
                when 'X' then l_malu_stat := '2';
                -- Período de Matrícula - Cursando
                when 'P' then l_malu_stat := '1';
                -- Solicitou Transferência - Desistente
                when 'S' then l_malu_stat := '2';
                -- Formado
                when 'F' then l_malu_stat := '5';
                -- Término de Contrato - Cadastrado
                when 'T' then l_malu_stat := '5';
                -- Qualquer coisa diferente disto é nulo
                else l_malu_stat := '2';
            end case;

            -- se acima o aluno ficou como ativo precisamos verificar a situação dele
            -- na tabela oli_aluncurs, quando estiver Inativo colocamos como desistente
            if  (l_malu_stat = '1') and
                (r_c_malu.acrsituacao = 'I') then

                l_malu_stat := '2';
            end if;

            -- Forma de ingresso
            case    (r_c_malu.acrtipoingresso)
                -- S - Segunda graduação
                when 'C' then l_malu_fing := 'S';
                -- T - Transferência
                when 'T' then l_malu_fing := 'T';
                -- V - Vestibular
                when 'V' then l_malu_fing := 'V';
                -- R - Histórico escolar
                when 'A' then l_malu_fing := 'R';
                -- E - ENEM
                when 'N' then l_malu_fing := 'E';
                -- Qualquer coisa diferente disto é nulo
                else l_malu_fing := 'R';
            end case;

            -- alunos de disciplina isolada não possuem grade, os mesmos não recebem histórico apenas uma declaração
            -- de que cursaram a disciplina
            if  (r_c_malu.malu_diis = 'S') then
            
                l_malu_ogra := null;
            else
                l_malu_ogra := NVL(r_c_malu.gracod, r_c_malu.grad_turs);
            end if;
            
            -- se identificou um registro na mgr_aluno então é atualização
            if  (r_c_malu.malu_sequ is not null or r_c_malu.malu_sequ_diis is not null) then

                -- alimenta as variáveis table utilizadas no update
                t_malu_sequ_upd(l_contador_upd) := NVL(r_c_malu.malu_sequ_diis, r_c_malu.malu_sequ);
                t_malu_form_upd(l_contador_upd) := l_malu_form;
                t_malu_stat_upd(l_contador_upd) := l_malu_stat;
                t_malu_mpes_upd(l_contador_upd) := r_c_malu.mpes_sequ;
                t_malu_asig_upd(l_contador_upd) := r_c_malu.malu_asig;
                t_malu_mcur_upd(l_contador_upd) := r_c_malu.mcur_sequ;
                t_malu_psem_upd(l_contador_upd) := NVL(r_c_malu.malu_psem, r_c_malu.malu_psem_null);
                t_malu_msed_upd(l_contador_upd) := r_c_malu.malu_msed;
                t_malu_diis_upd(l_contador_upd) := r_c_malu.malu_diis;
                t_malu_fing_upd(l_contador_upd) := l_malu_fing;
                t_malu_ding_upd(l_contador_upd) := r_c_malu.acrdataingresso;
                t_malu_ogra_upd(l_contador_upd) := l_malu_ogra;

                l_contador_upd := l_contador_upd + 1;

            -- se não é inserção de novo registro
            else

                -- alimenta as variáveis table utilizadas no insert
                t_malu_form_ins(l_contador_ins) := l_malu_form;
                t_malu_stat_ins(l_contador_ins) := l_malu_stat;
                t_malu_mpes_ins(l_contador_ins) := r_c_malu.mpes_sequ;
                t_malu_asig_ins(l_contador_ins) := r_c_malu.malu_asig;
                t_malu_mcur_ins(l_contador_ins) := r_c_malu.mcur_sequ;
                t_malu_chav_ins(l_contador_ins) := r_c_malu.alucod;
                t_malu_psem_ins(l_contador_ins) := NVL(r_c_malu.malu_psem, r_c_malu.malu_psem_null);
                t_malu_msed_ins(l_contador_ins) := r_c_malu.malu_msed;
                t_malu_diis_ins(l_contador_ins) := r_c_malu.malu_diis;
                t_malu_fing_ins(l_contador_ins) := l_malu_fing;
                t_malu_ding_ins(l_contador_ins) := r_c_malu.acrdataingresso;
                t_malu_ogra_ins(l_contador_ins) := l_malu_ogra;

                l_contador_ins := l_contador_ins + 1;
            end if;

            -- verifica se atingiu a quantidade de registros por transação
            if  (l_contador_trans >= pkg_util.c_limit_trans) then

                -- atualiza os registro e devolve as variáveis reinicializadas
                pkg_mgr_imp_producao_aux.p_update_tabela_aluno(   t_malu_sequ_upd, t_malu_form_upd, t_malu_stat_upd
                                                                , t_malu_mpes_upd, t_malu_asig_upd, t_malu_mcur_upd
                                                                , t_malu_psem_upd, t_malu_msed_upd, t_malu_diis_upd
                                                                , t_malu_fing_upd, t_malu_ding_upd, t_malu_ogra_upd
                                                                , l_contador_upd);

                -- insere os registro e devolve as variáveis reinicializadas
                pkg_mgr_imp_producao_aux.p_insert_tabela_aluno(   p_mver_sequ, t_malu_form_ins, t_malu_stat_ins
                                                                , t_malu_mpes_ins, t_malu_asig_ins, t_malu_mcur_ins
                                                                , t_malu_chav_ins, t_malu_psem_ins, t_malu_msed_ins
                                                                , t_malu_diis_ins, t_malu_fing_ins, t_malu_ding_ins
                                                                , t_malu_ogra_ins, l_contador_ins);

                l_contador_trans := 1;
            else
                l_contador_trans := l_contador_trans + 1;
            end if;
        end if;
    end loop;

    -- caso dentro do loop não tenha chego à quantidade que precisa para fechar a transação
    -- então envia tudo que tiver para o update e insert
    pkg_mgr_imp_producao_aux.p_update_tabela_aluno(   t_malu_sequ_upd, t_malu_form_upd, t_malu_stat_upd
                                                    , t_malu_mpes_upd, t_malu_asig_upd, t_malu_mcur_upd
                                                    , t_malu_psem_upd, t_malu_msed_upd, t_malu_diis_upd
                                                    , t_malu_fing_upd, t_malu_ding_upd, t_malu_ogra_upd
                                                    , l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_aluno(   p_mver_sequ, t_malu_form_ins, t_malu_stat_ins
                                                    , t_malu_mpes_ins, t_malu_asig_ins, t_malu_mcur_ins
                                                    , t_malu_chav_ins, t_malu_psem_ins, t_malu_msed_ins
                                                    , t_malu_diis_ins, t_malu_fing_ins, t_malu_ding_ins
                                                    , t_malu_ogra_ins, l_contador_ins);

    pkg_mgr_imp_producao_aux.p_vincula_aluno_mgr_aluno(p_migr_sequ);
end if;

end p_importa_aluno;

procedure p_importa_aluno_turma(    p_migr_sequ     mgr_migracao.migr_sequ%type
                                  , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- tables utilizadas no update
t_malt_sequ_upd     pkg_util.tb_number;
t_malt_msem_upd     pkg_util.tb_number;
t_malt_malu_upd     pkg_util.tb_number;
t_malt_stat_upd     pkg_util.tb_varchar2_5;
t_malt_mtus_upd     pkg_util.tb_number;

-- tables utilizadas no insert
t_malt_msem_ins     pkg_util.tb_number;
t_malt_malu_ins     pkg_util.tb_number;
t_malt_stat_ins     pkg_util.tb_varchar2_5;
t_malt_mtus_ins     pkg_util.tb_number;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

cursor c_malt(  pc_migr_sequ        mgr_migracao.migr_sequ%type
              , pc_seme_inic_acad   varchar2) is
    SELECT malt_msem
         , malt_malu
         , malt_sequ
         , MAX(NVL(turs_curs, NVL(turs_alse, NVL(NVL(NVL(NVL(malt_mtus_aluno, malt_mtus_matricula), malt_mtus_seme_turs), malt_mtus_curs_aluno), malt_mtus_curs_matricula)))) malt_mtus
      FROM (
        SELECT e.msem_sequ malt_msem
             , a.malu_sequ malt_malu
             -- primeiro damos preferencia para encontrar uma turma que seja do mesmo curso do aluno
             -- no olimpo, se não encontrar uma que seja de mesmo curso para o GIOCONDA
             , (SELECT MAX(o.mtus_sequ)
                  FROM oli_aluncurs p
                     , mgr_turma_semestre o
                 WHERE p.alucod = a.malu_chav
                   AND p.espcod = i.mcur_chav
                   AND o.mtus_segi = e.msem_scod
                   AND o.mtus_turm = p.tmacod
                   AND o.mtus_msed = a.malu_msed) turs_curs
			 , (SELECT MAX(o.mtus_sequ)
                  FROM oli_aluncurs p
                     , mgr_turma_semestre o
                 WHERE p.alucod = a.malu_chav
                   AND p.espcod = j.mcur_chav
                   AND o.mtus_segi = e.msem_scod
                   AND o.mtus_turm = p.tmacod
                   AND o.mtus_msed = a.malu_msed) turs_alse
             , (SELECT MAX(f.mtus_sequ)
                  FROM mgr_turma_semestre f
                 WHERE f.mtus_atua = 'S'
                   AND f.mtus_segi = e.msem_scod
                   AND f.mtus_mcur = a.malu_mcur
                   AND f.mtus_msed = a.malu_msed
                   AND f.mtus_turm = c.tmacod) malt_mtus_aluno
             , (SELECT MAX(h.mtus_sequ)
                  FROM mgr_turma_semestre h
                 WHERE h.mtus_atua = 'S'
                   AND h.mtus_segi = e.msem_scod
                   AND h.mtus_mcur = j.mcur_sequ
                   AND h.mtus_msed = a.malu_msed
                   AND h.mtus_turm = c.tmacod) malt_mtus_matricula
             , (SELECT MAX(h.mtus_sequ)
                  FROM mgr_turma_semestre h
                 WHERE h.mtus_segi = e.msem_scod
                   AND h.mtus_turm = c.tmacod
                   AND h.mtus_atua = 'S') malt_mtus_seme_turs
             , (SELECT MAX(f.mtus_sequ)
                  FROM mgr_turma_semestre f
                 WHERE f.mtus_atua = 'S'
                   AND f.mtus_segi = e.msem_scod
                   AND f.mtus_mcur = a.malu_mcur
                   AND f.mtus_msed = a.malu_msed) malt_mtus_curs_aluno
             , (SELECT MAX(h.mtus_sequ)
                  FROM mgr_turma_semestre h
                 WHERE h.mtus_atua = 'S'
                   AND h.mtus_segi = e.msem_scod
                   AND h.mtus_mcur = j.mcur_sequ
                   AND h.mtus_msed = a.malu_msed) malt_mtus_curs_matricula
             , (SELECT MAX(x.malt_sequ)
                  FROM mgr_aluno_turma x
                 WHERE x.malt_malu = a.malu_sequ
                   AND x.malt_msem = e.msem_sequ) malt_sequ
          FROM mgr_aluno a
             , mgr_curso i
             , mgr_curso j
             , oli_alundiscmini_temp c
             , mgr_semestre e
         WHERE a.malu_atua = 'S'
           AND i.mcur_sequ = a.malu_mcur
           AND j.mcur_curs = i.mcur_curs
           AND c.espcod = j.mcur_chav
           AND c.alucod = a.malu_chav
           AND e.msem_chav = c.pelcod
           AND e.msem_seme >= pc_seme_inic_acad
           AND EXISTS(  SELECT 1
                          FROM mgr_versao v
                         WHERE v.mver_sequ = j.mcur_mver
                           AND v.mver_migr = pc_migr_sequ))
    GROUP BY malt_msem, malt_malu, malt_sequ;

begin
-- só faz algo quando a versão é passada
if  (p_mver_sequ is not null) then

    -- faz os updates iniciais na tabela mgr_turma_semestre necessários
    pkg_mgr_imp_producao_aux.p_update_inicio_aluno_turma(p_migr_sequ);

    -- incializa as variáveis
    pkg_mgr_imp_producao_aux.p_update_tabela_aluno_turma( t_malt_sequ_upd, t_malt_msem_upd, t_malt_malu_upd
                                                  , t_malt_stat_upd, t_malt_mtus_upd, l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_aluno_turma( p_mver_sequ, t_malt_msem_ins, t_malt_malu_ins
                                                  , t_malt_stat_ins, t_malt_mtus_ins, l_contador_ins);

    -- inicia o contador
    l_contador_trans := 1;

    for r_c_malt in c_malt(p_migr_sequ, f_seme_ini_imp_academico) loop

        -- se identificou um registro na mgr_aluno_turma então é atualização
        if (r_c_malt.malt_sequ is not null) then

            -- alimenta as variáveis table utilizadas no update
            t_malt_sequ_upd(l_contador_upd) := r_c_malt.malt_sequ;
            t_malt_msem_upd(l_contador_upd) := r_c_malt.malt_msem;
            t_malt_malu_upd(l_contador_upd) := r_c_malt.malt_malu;
            t_malt_stat_upd(l_contador_upd) := '1';
            t_malt_mtus_upd(l_contador_upd) := r_c_malt.malt_mtus;

            l_contador_upd := l_contador_upd + 1;

        -- se não é inserção de novo registro
        else

            -- alimenta as variáveis table utilizadas no insert
            t_malt_msem_ins(l_contador_ins) := r_c_malt.malt_msem;
            t_malt_malu_ins(l_contador_ins) := r_c_malt.malt_malu;
            t_malt_stat_ins(l_contador_ins) := '1';
            t_malt_mtus_ins(l_contador_ins) := r_c_malt.malt_mtus;

            l_contador_ins := l_contador_ins + 1;
        end if;

        -- verifica se atingiu a quantidade de registros por transação
        if  (l_contador_trans >= pkg_util.c_limit_trans) then

            -- atualiza os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_update_tabela_aluno_turma( t_malt_sequ_upd, t_malt_msem_upd, t_malt_malu_upd
																, t_malt_stat_upd, t_malt_mtus_upd, l_contador_upd);

            -- insere os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_insert_tabela_aluno_turma( p_mver_sequ, t_malt_msem_ins, t_malt_malu_ins
																, t_malt_stat_ins, t_malt_mtus_ins, l_contador_ins);

            l_contador_trans := 1;
        else
            l_contador_trans := l_contador_trans + 1;
        end if;
    end loop;
    
    -- caso dentro do loop não tenha chego à quantidade que precisa para fechar a transação
    -- então envia tudo que tiver para o update e insert
    pkg_mgr_imp_producao_aux.p_update_tabela_aluno_turma( t_malt_sequ_upd, t_malt_msem_upd, t_malt_malu_upd
														, t_malt_stat_upd, t_malt_mtus_upd, l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_aluno_turma( p_mver_sequ, t_malt_msem_ins, t_malt_malu_ins
														, t_malt_stat_ins, t_malt_mtus_ins, l_contador_ins);

    pkg_mgr_imp_producao_aux.p_vincula_aluno_turma_malt(p_migr_sequ);
end if;

end p_importa_aluno_turma;

function f_obter_disc_equi( p_discod 	oli_discipli.discod%type
                          , p_semestre 	semestre.seme_codi%type
						  , p_alucod	oli_alundisc.alucod%type
						  , p_espcod	oli_graddisc.gracod%type
						  , p_gracod	oli_graddisc.gracod%type) return number is

l_codigo_disc oli_discipli.discod%type;

begin

	-- busca as equivalências gerais de disciplinas
	SELECT MAX(disc_usar)
	  INTO l_codigo_disc
	  FROM (
			SELECT disc_usar, seme, equdata, rownum linha
			  FROM (
					SELECT disc_nova disc_usar, seme, equdata
					  FROM oli_equidisc_tab
					 WHERE disc_antiga = p_discod
					   -- não pode considerar as optativas
					   AND disc_nova_tipo != 'O'
					   AND EXISTS (SELECT 1
									 FROM oli_graddisc b
									WHERE b.espcod = p_espcod
									  AND b.gracod = p_gracod
									  AND b.discod = disc_nova)
					   AND NOT EXISTS (SELECT 1
									     FROM oli_alundisc d
									    WHERE d.alucod = p_alucod
									      AND d.discod = disc_nova
										  AND d.adisituacao = 'A')
					 UNION ALL
					SELECT disc_antiga disc_usar, seme, equdata
					  FROM oli_equidisc_tab
					 WHERE disc_nova = p_discod
					   -- não pode considerar as optativas
					   AND disc_antiga_tipo != 'O'
					   AND equtipo = 'D'
					   AND EXISTS (SELECT 1
									 FROM oli_graddisc b
									WHERE b.espcod = p_espcod
									  AND b.gracod = p_gracod
									  AND b.discod = disc_antiga)
					   AND NOT EXISTS (SELECT 1
									     FROM oli_alundisc f
									    WHERE f.alucod = p_alucod
									      AND f.discod = disc_antiga
										  AND f.adisituacao = 'A')
					 ORDER BY seme, equdata
				   )
		   )
	 WHERE linha = 1;
	
	-- se não encontrou nada, faz uma pesquisa considerando a descrição da disciplina
	-- aplicamos esta técnica apenas para disciplinas de ED
	if	(l_codigo_disc IS NULL) then
		
		SELECT MAX(b.discod)
		  INTO l_codigo_disc
		  FROM oli_discipli a
			 , oli_discipli c
			 , oli_graddisc b
		 WHERE a.discod = p_discod
		   AND a.distipo = 'X'
		   AND pkg_mgr_imp_producao_aux.mgr_compara_string(c.disdesc) LIKE pkg_mgr_imp_producao_aux.mgr_compara_string(a.disdesc)
		   AND c.discod != p_discod
		   AND b.espcod = p_espcod
		   AND b.gracod = p_gracod
		   AND b.discod = c.discod
		   -- não pode considerar as optativas
		   AND c.distipo != 'O'
		   AND NOT EXISTS (SELECT 1
							 FROM oli_alundisc z
							WHERE z.alucod = p_alucod
							  AND z.discod = b.discod);

	end if;

	return l_codigo_disc;

end f_obter_disc_equi;

function f_obter_disc_equi_roberta( p_discod 	oli_discipli.discod%type
								  , p_espcod	oli_graddisc.gracod%type
								  , p_gracod	oli_graddisc.gracod%type) return number is

l_codigo_disc oli_discipli.discod%type;

begin

	-- busca as equivalências gerais de disciplinas
	SELECT MAX(disc_usar)
	  INTO l_codigo_disc
	  FROM (
			SELECT disc_usar, seme, equdata, rownum linha
			  FROM (
					SELECT disc_nova disc_usar, seme, equdata
					  FROM oli_equidisc_tab
					 WHERE disc_antiga = p_discod
					   -- não pode considerar as optativas
					   AND disc_nova_tipo != 'O'
					   AND EXISTS (SELECT 1
									 FROM oli_graddisc b
									WHERE b.espcod = p_espcod
									  AND b.gracod = p_gracod
									  AND b.discod = disc_nova)
					 UNION ALL
					SELECT disc_antiga disc_usar, seme, equdata
					  FROM oli_equidisc_tab
					 WHERE disc_nova = p_discod
					   -- não pode considerar as optativas
					   AND disc_antiga_tipo != 'O'
					   AND equtipo = 'D'
					   AND EXISTS (SELECT 1
									 FROM oli_graddisc b
									WHERE b.espcod = p_espcod
									  AND b.gracod = p_gracod
									  AND b.discod = disc_antiga)
					 ORDER BY seme, equdata
				   )
		   )
	 WHERE linha = 1;
	
	-- se não encontrou nada, faz uma pesquisa considerando a descrição da disciplina
	-- aplicamos esta técnica apenas para disciplinas de ED
	if	(l_codigo_disc IS NULL) then
		
		SELECT MAX(b.discod)
		  INTO l_codigo_disc
		  FROM oli_discipli a
			 , oli_discipli c
			 , oli_graddisc b
		 WHERE a.discod = p_discod
		   AND a.distipo = 'X'
		   AND pkg_mgr_imp_producao_aux.mgr_compara_string(c.disdesc) LIKE pkg_mgr_imp_producao_aux.mgr_compara_string(a.disdesc)
		   AND c.discod != p_discod
		   AND b.espcod = p_espcod
		   AND b.gracod = p_gracod
		   AND b.discod = c.discod
		   -- não pode considerar as optativas
		   AND c.distipo != 'O';

	end if;

	return l_codigo_disc;

end f_obter_disc_equi_roberta;

function obter_codigo_gioconda_matr( p_discod		oli_alundisc.discod%type
								   , p_tmacod		oli_alundisc.tmacod%type
								   , p_grade_aluno	oli_grade.gracod%type
								   , p_dimtip		oli_alundisc.dimtip%type
								   , p_espcod		oli_alundisc.espcod%type) return varchar2 is

l_codigo_disc_gio 	disciplina.disc_codi%type;
l_qt_registro		pls_integer;

begin
	l_codigo_disc_gio := null;

	-- busca o código do Gioconda considerando o dimtip
	SELECT MAX(b.codigo_disciplina_gioconda)
	  INTO l_codigo_disc_gio
	  FROM oli_disciplina_juncao b
	 WHERE b.discod = p_discod
	   AND b.tmacod = p_tmacod
	   AND b.gracod = p_grade_aluno
	   AND b.dimtip = p_dimtip
	   AND b.espcod = p_espcod;
	
	-- busca o código do Gioconda sem considerar o dimtip
	if	(l_codigo_disc_gio IS NULL) then
		
		SELECT MAX(b.codigo_disciplina_gioconda)
		  INTO l_codigo_disc_gio
		  FROM oli_disciplina_juncao b
		 WHERE b.discod = p_discod
		   AND b.tmacod = p_tmacod
		   AND b.gracod = p_grade_aluno
		   AND b.espcod = p_espcod;
	end if;

	return l_codigo_disc_gio;
	
end obter_codigo_gioconda_matr;

function obter_codigo_gioconda_conv( p_discod		oli_alundisc.discod%type
								   , p_espcod		oli_alundisc.espcod%type
								   , p_grade_aluno	oli_grade.gracod%type) return varchar2 is

l_codigo_disc_gio 	disciplina.disc_codi%type;
l_qt_registro		pls_integer;

begin
	l_codigo_disc_gio := null;

	-- busca o código do Gioconda considerando o dimtip
	SELECT MAX(b.codigo_disciplina_gioconda)
	  INTO l_codigo_disc_gio
	  FROM oli_disciplina_juncao b
	 WHERE b.discod = p_discod
	   AND b.espcod = p_espcod
	   AND b.gracod = p_grade_aluno;

	return l_codigo_disc_gio;
	
end obter_codigo_gioconda_conv;

function obter_dados_disciplina(p_discod oli_discipli.discod%type) return t_dado_disc is

l_dado_disc t_dado_disc;

cursor c_dado(pc_discod oli_discipli.discod%type) is
	SELECT d.discargapratica
		 , d.discargacomplementar
		 , d.distipo
		 , NVL(d.discargateorica, 0) + NVL(d.discargahorateorica, 0) +
		   NVL(d.discargahorapratica, 0) + NVL(d.discargaefetiva, 0) carga_horaria
	  FROM oli_discipli d
	 WHERE d.discod = pc_discod;

begin

l_dado_disc.credito := null;
l_dado_disc.pratica := null;
l_dado_disc.complementar := null;
l_dado_disc.estagio := null;
l_dado_disc.carga_horaria := null;
l_dado_disc.tipo := null;

for r_c_dado in c_dado(p_discod) loop
	
	l_dado_disc.credito := r_c_dado.carga_horaria;
	l_dado_disc.pratica := r_c_dado.discargapratica;
	l_dado_disc.complementar := r_c_dado.discargacomplementar;
	
	/* Tabela DE - PARA Tipo
	  OLIMPO                            GIOCONDA
	  E - Educação Física               'A' - Seminário da Prática 
	  N - Normal                        'E' - Estágio
	  S - Estágio Supervisionado        'T' - TG (utilizar M)
	  R - Realidade Brasileira          'S' - SemiPresencial
	  O - Optativa                      'P' - Prática
	  X - Estudo Dirigido               'N' - Padrão
	  P - Estudo Complementar           'M' - Monografia/TCC
	  I - Projeto Integrador            'I' - Interativa
	  A - Disciplina Integrada 
	  D - Estudo Independente 
	  T - TCC/Monografia  
	  C - Ciclo Básico
	  W - SemiPresencial
	  F - Profissionalizante
	  Y - Opcional
	  Z - Estágio Opcional
	*/
	
	case (r_c_dado.distipo)

		when 'S' then
			l_dado_disc.tipo := 'E';
		when 'O' then
			l_dado_disc.tipo := 'N';
		when 'T' then
			l_dado_disc.tipo := 'M';
		when 'W' then
			l_dado_disc.tipo := 'S';
		when 'Y' then
			l_dado_disc.tipo := 'N';
		when 'Z' then
			l_dado_disc.tipo := 'E';
		-- tudo que não cair acima é tipo do Padrão
		else
			l_dado_disc.tipo := 'N';
	end case;
	
	-- se for do tipo estágio, faz a soma
	if	(l_dado_disc.tipo = 'E') then
		l_dado_disc.carga_horaria := 0;
		l_dado_disc.estagio := r_c_dado.carga_horaria;
	else
		l_dado_disc.carga_horaria := r_c_dado.carga_horaria;
		l_dado_disc.estagio := 0;
	end if;
end loop;

return l_dado_disc;

end obter_dados_disciplina;

procedure p_importa_historico_matr(	p_alucod 			oli_alundisc.alucod%type
								  , p_espcod			oli_alundisc.espcod%type
								  , p_grade_aluno		oli_grade.gracod%type
								  , p_alun_diis			mgr_aluno.malu_diis%type
								  , p_malu_sequ			mgr_aluno.malu_sequ%type
								  , p_iunicodempresa	oli_alundisc.iunicodempresa%type
								  , p_mver_sequ    		mgr_versao.mver_sequ%type) is

l_semestre 			semestre.seme_codi%type;
l_codigo_disc 		oli_discipli.discod%type;
l_codigo_disc_gio 	disciplina.disc_codi%type;
l_dado_disc			t_dado_disc;

cursor c_matr_alun( pc_alucod oli_alundisc.alucod%type
				  , pc_espcod oli_alundisc.espcod%type
				  , pc_grade  oli_grade.gracod%type) is
    SELECT a.alucod
	     , a.espcod
		 , a.discod
		 , a.tmacod
		 , a.dimtip
		 , d.disdesc
		 , NVL(a.adimediafinal, 0) media
		 , DECODE(a.adisituacao
				 , 'A', 'Aprovado'
				 , 'C', 'Cursando'
				 , 'D', 'Desistente'
				 , 'E', 'Necessita fazer exame'
				 , 'F', 'Reprovado por falta'
				 , 'M', 'Reprovado por média'
				 , 'R', 'Reprovado por média e falta') situacao
		 , (SELECT MAX(y.msem_seme)
		      FROM oli_discmini x
			     , mgr_semestre y
		     WHERE x.discod = a.discod
			   AND x.tmacod = a.tmacod
			   AND x.dimtip = a.dimtip
			   AND y.msem_chav = x.pelcod) semestre_cursou
		 , (SELECT MAX(v.msem_seme)
		      FROM mgr_semestre v
		     WHERE a.adidatamatr BETWEEN v.msem_dini AND v.msem_dfim) semestre_matricula
	     , TRUNC(a.adidatamatr) adidatamatr
		 , d.distipo
		 , NVL(a.adifaltas, 0) adifaltas
		 , (SELECT COUNT(1)
		      FROM oli_graddisc g
			 WHERE g.espcod = pc_espcod
			   AND g.gracod = pc_grade
			   AND g.discod = a.discod) qt_disc_grade_aluno
	  FROM oli_alundisc a
	     , oli_discipli d
	 WHERE a.alucod = pc_alucod
	   AND a.espcod = pc_espcod
	   AND d.discod = a.discod
	   AND EXISTS (SELECT 1
	                 FROM oli_especial_temp y
					WHERE y.espcod = a.espcod)
	 ORDER BY media, discod, alucod;

begin
	-- todas as disciplinas que o aluno se matriculou
	for r_c_matr_alun in c_matr_alun(p_alucod, p_espcod, p_grade_aluno) loop
		
		l_semestre := NVL(r_c_matr_alun.semestre_cursou, r_c_matr_alun.semestre_matricula);
		
		l_codigo_disc := null;
		
		-- se a disciplina não faz parte da grade do aluno
		-- busca uma possível regra de equivalência
		if	(r_c_matr_alun.qt_disc_grade_aluno = 0) then
			l_codigo_disc := f_obter_disc_equi( r_c_matr_alun.discod, l_semestre
											  , p_alucod, p_espcod
											  , p_grade_aluno);
		end if;

		-- se não tem disciplina equivalente geral, usa a da matrícula								  
		if	(l_codigo_disc is null) then
			l_codigo_disc := r_c_matr_alun.discod;
			l_dado_disc := obter_dados_disciplina(r_c_matr_alun.discod);
		else
			-- busca a carga horária da nova disciplina somente se for ED
			if	(r_c_matr_alun.distipo = 'X') then
				l_dado_disc := obter_dados_disciplina(l_codigo_disc);
			else
				l_dado_disc := obter_dados_disciplina(r_c_matr_alun.discod);
			end if;
		end if;
		
		-- Roberta pediu para desconsiderar disciplina porque está errado  (repetida na grade)
		if not	((p_espcod = 99040 AND p_grade_aluno = 921802 AND r_c_matr_alun.discod = 137778) OR
		         (p_espcod = 99011 AND p_grade_aluno = 200922 AND r_c_matr_alun.discod = 34164) OR
				 (p_espcod = 99011 AND p_grade_aluno = 200922 AND r_c_matr_alun.discod = 132851) OR
				 (p_espcod = 99064 AND p_grade_aluno = 20112 AND r_c_matr_alun.discod = 33630) OR
				 (p_espcod = 99064 AND p_grade_aluno = 20112 AND r_c_matr_alun.discod = 28772)) then

			-- busca o código da disciplina no Gioconda
			l_codigo_disc_gio := obter_codigo_gioconda_matr( l_codigo_disc, r_c_matr_alun.tmacod
														   , p_grade_aluno, r_c_matr_alun.dimtip
														   , p_espcod);

			INSERT INTO oli_historico_aluno (
				   ohia_sequ, ohia_alun, ohia_curs
				 , ohia_disc, ohia_turs, ohia_dtip
				 , ohia_grad, ohia_sede, ohia_dgio
				 , ohia_ddgi, ohia_mver, ohia_carg
				 , ohia_medi, ohia_seme, ohia_situ
				 , ohia_atua, ohia_smed, ohia_mdis
				 , ohia_diis, ohia_cred, ohia_prat
				 , ohia_comp, ohia_esta, ohia_tipo
				 , ohia_malu, ohia_falt
			) VALUES (
				   SEQU_OLI_HISTORICO_ALUNO.NEXTVAL, r_c_matr_alun.alucod, r_c_matr_alun.espcod
				 , l_codigo_disc, r_c_matr_alun.tmacod, r_c_matr_alun.dimtip
				 , p_grade_aluno, p_iunicodempresa, l_codigo_disc_gio
				 , (SELECT MAX(z.disdesc)
					  FROM oli_discipli z
					 WHERE z.discod = l_codigo_disc), p_mver_sequ, l_dado_disc.carga_horaria
				 , r_c_matr_alun.media, l_semestre, r_c_matr_alun.situacao
				 , 'S', 'N', r_c_matr_alun.discod
				 , p_alun_diis, l_dado_disc.credito, l_dado_disc.pratica
				 , l_dado_disc.complementar, l_dado_disc.estagio, l_dado_disc.tipo
				 , p_malu_sequ, r_c_matr_alun.adifaltas
			);
		
		end if;
		
	end loop;

	commit;

end p_importa_historico_matr;

procedure p_importa_historico_conv(	p_alucod 			oli_alundisc.alucod%type
								  , p_espcod			oli_alundisc.tmacod%type
								  , p_grade_aluno		oli_grade.gracod%type
								  , p_alun_diis			mgr_aluno.malu_diis%type
								  , p_malu_sequ			mgr_aluno.malu_sequ%type
								  , p_iunicodempresa	oli_alundisc.iunicodempresa%type
								  , p_mver_sequ    		mgr_versao.mver_sequ%type
								  , p_separador     	mgr_migracao.migr_sepa%type) is

l_codigo_disc_pesq	oli_discipli.discod%type;
l_codigo_disc_gio 	disciplina.disc_codi%type;
l_ohia_smed			oli_historico_aluno.ohia_smed%type;
l_ohia_seq			oli_historico_aluno.ohia_sequ%type;
l_dado_disc			t_dado_disc;

l_chav_agrup		varchar2(150);
l_chav_agrup_ant	varchar2(150);

cursor c_conv_alun( pc_alucod 		oli_alundisc.alucod%type
				  , pc_espcod		oli_alundisc.tmacod%type
				  , pc_grade  		oli_grade.gracod%type		
				  , pc_separador    mgr_migracao.migr_sepa%type) is
    SELECT b.alucod ohia_alun
		 , b.espcod ohia_curs
		 , b.discod ohia_disc
		 , b.dconum
		 , (SELECT MAX(v.msem_seme)
			  FROM mgr_semestre v
			 WHERE v.msem_chav = a.pelcod) ohia_seme
		 , c.disdesc ohia_ddgi
		 , b.dconome ohiv_cdis
		 , b.dcocurso ohiv_ccur
		 , b.inscod ohiv_cins
		 , (SELECT MAX(x.insdesc)
			  FROM oli_institui x
			 WHERE x.inscod = b.inscod) ohiv_cide
		 , NVL(b.dcocargahoraria, 0) ohiv_ccar
		 , NVL(b.dcomedia, 0) ohiv_capr
		 , b.dcoperiodo ohiv_csem
		 , b.discodcredito ohiv_cdic
		 , c.distipo
		 , (SELECT MAX(z.codigo_gioconda)
		      FROM oli_juncao_instituicao z
			 WHERE z.inscod = b.inscod) ohiv_ccgi
	  FROM oli_alundisp a
		 , oli_disccomp b
		 , oli_discipli c
	 WHERE a.alucod = pc_alucod
	   AND a.espcod = pc_espcod
	   AND b.alucod = a.alucod
	   AND b.espcod = a.espcod
	   AND b.discod = a.discod
	   AND c.discod = b.discod
	   AND EXISTS (SELECT 1
	                 FROM oli_especial_temp y
					WHERE y.espcod = a.espcod)
	 ORDER BY ohia_alun, ohia_curs
		 , ohia_disc, dconum;

begin
	l_chav_agrup_ant := null;
	-- todas as disciplinas que o aluno tem convalidação
	for r_c_conv_alun in c_conv_alun(p_alucod, p_espcod, p_grade_aluno, p_separador) loop
	
		-- Roberta pediu para desconsiderar disciplina porque está errado  (repetida na grade)
		if not	((p_espcod = 99040 AND p_grade_aluno = 921802 AND r_c_conv_alun.ohia_disc = 137778) OR
		         (p_espcod = 99011 AND p_grade_aluno = 200922 AND r_c_conv_alun.ohia_disc = 34164) OR
				 (p_espcod = 99011 AND p_grade_aluno = 200922 AND r_c_conv_alun.ohia_disc = 132851) OR
				 (p_espcod = 99064 AND p_grade_aluno = 20112 AND r_c_conv_alun.ohia_disc = 33630) OR
				 (p_espcod = 99064 AND p_grade_aluno = 20112 AND r_c_conv_alun.ohia_disc = 28772)) then

			l_chav_agrup := TO_CHAR(r_c_conv_alun.ohia_alun) || p_separador || 
							TO_CHAR(r_c_conv_alun.ohia_curs) || p_separador ||
							TO_CHAR(r_c_conv_alun.ohia_disc);

			-- se for diferente, processamos o registro da regra pai
			-- comparação com NULL é por causa do primeiro registro
			if	((l_chav_agrup != l_chav_agrup_ant) OR (l_chav_agrup_ant IS NULL)) then

				-- busca o código da disciplina no Gioconda (utiliza a disciplina da grade)
				l_codigo_disc_gio := obter_codigo_gioconda_conv( r_c_conv_alun.ohia_disc, p_espcod
															   , p_grade_aluno);

				-- crédito concedido
				if	(r_c_conv_alun.ohiv_cdic IS NOT NULL) then

					l_codigo_disc_pesq := r_c_conv_alun.ohiv_cdic;
					l_ohia_smed := 'CC';

				else
					-- convalidação normal
					l_codigo_disc_pesq := r_c_conv_alun.ohia_disc;
					l_ohia_smed := 'AE';
				end if;

				-- busca a carga horária da nova disciplina somente se for ED
				if	(r_c_conv_alun.distipo = 'X') then
					l_dado_disc := obter_dados_disciplina(l_codigo_disc_pesq);
				else
					l_dado_disc := obter_dados_disciplina(r_c_conv_alun.ohia_disc);
				end if;

				INSERT INTO oli_historico_aluno (
					   ohia_sequ, ohia_alun, ohia_curs
					 , ohia_disc, ohia_turs, ohia_dtip
					 , ohia_grad, ohia_sede, ohia_dgio
					 , ohia_ddgi, ohia_mver, ohia_carg
					 , ohia_medi, ohia_seme, ohia_situ
					 , ohia_smed, ohia_mdis, ohia_atua
					 , ohia_datu, ohia_diis, ohia_cred
					 , ohia_prat, ohia_comp, ohia_esta
					 , ohia_tipo, ohia_malu
				) VALUES (
					   SEQU_OLI_HISTORICO_ALUNO.NEXTVAL, p_alucod, p_espcod
					 , r_c_conv_alun.ohia_disc, NULL, NULL
					 , p_grade_aluno, p_iunicodempresa, l_codigo_disc_gio
					 , r_c_conv_alun.ohia_ddgi, p_mver_sequ, l_dado_disc.carga_horaria
					 , NULL, r_c_conv_alun.ohia_seme, 'Aprovado'
					 , l_ohia_smed, r_c_conv_alun.ohiv_cdic, 'S'
					 , SYSDATE, p_alun_diis, l_dado_disc.credito
					 , l_dado_disc.pratica, l_dado_disc.complementar, l_dado_disc.estagio
					 , l_dado_disc.tipo, p_malu_sequ
				) RETURNING ohia_sequ INTO l_ohia_seq;
			end if;

			INSERT INTO oli_historico_aluno_conv (
				   ohiv_sequ, ohiv_ohia, ohiv_cdis
				 , ohiv_ccur, ohiv_cins, ohiv_cide
				 , ohiv_ccar, ohiv_capr, ohiv_csem
				 , ohiv_cdic, ohiv_atua, ohiv_datu
				 , ohiv_mver, ohiv_chav, ohiv_ccgi
			) VALUES (
				   SEQU_OLI_HISTORICO_ALUNO_CONV.NEXTVAL, l_ohia_seq, r_c_conv_alun.ohiv_cdis
				 , r_c_conv_alun.ohiv_ccur, r_c_conv_alun.ohiv_cins, r_c_conv_alun.ohiv_cide
				 , r_c_conv_alun.ohiv_ccar, r_c_conv_alun.ohiv_capr, r_c_conv_alun.ohiv_csem
				 , r_c_conv_alun.ohiv_cdic, 'S', SYSDATE
				 , p_mver_sequ, l_chav_agrup, r_c_conv_alun.ohiv_ccgi
			);

			-- atribui para acima comparar novamente
			l_chav_agrup_ant := TO_CHAR(r_c_conv_alun.ohia_alun) || p_separador || 
								TO_CHAR(r_c_conv_alun.ohia_curs) || p_separador ||
								TO_CHAR(r_c_conv_alun.ohia_disc);
		end if;
		
	end loop;

	commit;

end p_importa_historico_conv;

procedure p_importa_historico_disc_falt( p_alucod 			oli_alundisc.alucod%type
									   , p_espcod			oli_alundisc.tmacod%type
									   , p_grade_aluno		oli_grade.gracod%type
									   , p_alun_diis		mgr_aluno.malu_diis%type
									   , p_malu_sequ		mgr_aluno.malu_sequ%type
									   , p_iunicodempresa	oli_alundisc.iunicodempresa%type
									   , p_mver_sequ    	mgr_versao.mver_sequ%type) is

l_codigo_disc_gio 	disciplina.disc_codi%type;
l_dado_disc			t_dado_disc;

cursor c_falt_alun( pc_grade	oli_grade.gracod%type
				  , pc_espcod	oli_alundisc.tmacod%type
				  , pc_alucod	oli_alundisc.alucod%type) is
    SELECT c.discod ohia_disc
		 , c.disdesc ohia_ddgi
	  FROM oli_graddisc a
		 , oli_discipli c
	 WHERE a.espcod = pc_espcod
	   AND a.gracod = pc_grade
	   AND c.discod = a.discod
	   AND NOT EXISTS (SELECT 1
	                     FROM oli_historico_aluno z
						WHERE z.ohia_alun = pc_alucod
						  AND z.ohia_curs = a.espcod
						  AND z.ohia_grad = a.gracod
						  AND z.ohia_disc = c.discod
						UNION ALL
					   SELECT 1
	                     FROM oli_historico_aluno z
						WHERE z.ohia_alun = pc_alucod
						  AND z.ohia_curs = a.espcod
						  AND z.ohia_grad = a.gracod
						  AND z.ohia_mdis = c.discod);

begin
	-- todas as disciplinas da grade do aluno que faltam ser cursadas
	for r_c_falt_alun in c_falt_alun(p_grade_aluno, p_espcod, p_alucod) loop
	
		-- Roberta pediu para desconsiderar disciplina porque está errado  (repetida na grade)
		if not	((p_espcod = 99040 AND p_grade_aluno = 921802 AND r_c_falt_alun.ohia_disc = 137778) OR
		         (p_espcod = 99011 AND p_grade_aluno = 200922 AND r_c_falt_alun.ohia_disc = 34164) OR
				 (p_espcod = 99011 AND p_grade_aluno = 200922 AND r_c_falt_alun.ohia_disc = 132851) OR
				 (p_espcod = 99064 AND p_grade_aluno = 20112 AND r_c_falt_alun.ohia_disc = 33630) OR
				 (p_espcod = 99064 AND p_grade_aluno = 20112 AND r_c_falt_alun.ohia_disc = 28772)) then

			-- busca o código da disciplina no Gioconda (utiliza a disciplina da grade)
			l_codigo_disc_gio := obter_codigo_gioconda_conv( r_c_falt_alun.ohia_disc, p_espcod
														   , p_grade_aluno);

			l_dado_disc := obter_dados_disciplina(r_c_falt_alun.ohia_disc);
			
			INSERT INTO oli_historico_aluno (
				   ohia_sequ, ohia_alun, ohia_curs
				 , ohia_disc, ohia_turs, ohia_dtip
				 , ohia_grad, ohia_sede, ohia_dgio
				 , ohia_ddgi, ohia_mver, ohia_carg
				 , ohia_medi, ohia_seme, ohia_situ
				 , ohia_atua, ohia_smed, ohia_diis
				 , ohia_cred, ohia_prat, ohia_comp
				 , ohia_esta, ohia_tipo, ohia_malu
			) VALUES (
				   SEQU_OLI_HISTORICO_ALUNO.NEXTVAL, p_alucod, p_espcod
				 , r_c_falt_alun.ohia_disc, NULL, NULL
				 , p_grade_aluno, p_iunicodempresa, l_codigo_disc_gio
				 , r_c_falt_alun.ohia_ddgi, p_mver_sequ, l_dado_disc.carga_horaria
				 , NULL, NULL, 'A cursar'
				 , 'S', 'AC', p_alun_diis
				 , l_dado_disc.credito, l_dado_disc.pratica, l_dado_disc.complementar
				 , l_dado_disc.estagio, l_dado_disc.tipo, p_malu_sequ
			);
		
		end if;

	end loop;

	commit;

end p_importa_historico_disc_falt;

procedure p_importa_historico_disc_extra( p_alucod 			oli_alundisc.alucod%type
									    , p_espcod			oli_alundisc.tmacod%type
									    , p_grade_aluno		oli_grade.gracod%type
									    , p_iunicodempresa	oli_alundisc.iunicodempresa%type
									    , p_mver_sequ    	mgr_versao.mver_sequ%type) is

t_ohia_sequ     pkg_util.tb_number;

cursor c_extra_alun( pc_grade	oli_grade.gracod%type
				   , pc_espcod	oli_alundisc.espcod%type
				   , pc_alucod	oli_alundisc.alucod%type) is
    SELECT a.ohia_sequ
	  FROM oli_historico_aluno a
	 WHERE a.ohia_alun = pc_alucod
	   AND a.ohia_curs = pc_espcod
	   AND a.ohia_smed IN ('N', 'EC')
	   AND NOT EXISTS (SELECT 1
	                     FROM oli_graddisc z
						WHERE z.espcod = pc_espcod
						  AND z.gracod = pc_grade
						  AND z.discod = a.ohia_disc
						UNION ALL
					   SELECT 1
	                     FROM oli_graddisc z
						WHERE z.espcod = pc_espcod
						  AND z.gracod = pc_grade
						  AND z.discod = a.ohia_mdis);

begin

-- todas as disciplinas "normais" do histórico do aluno que não estão na sua grade
open c_extra_alun(p_grade_aluno, p_espcod, p_alucod);
loop
    fetch c_extra_alun bulk collect into t_ohia_sequ
    limit pkg_util.c_limit_trans;
    exit when t_ohia_sequ.count = 0;

    forall i in t_ohia_sequ.first..t_ohia_sequ.last
        UPDATE oli_historico_aluno SET
			   ohia_atua = 'S'
			 , ohia_datu = SYSDATE
			 , ohia_smed = 'EC'
		 WHERE ohia_sequ = t_ohia_sequ(i);
    COMMIT;
end loop;
close c_extra_alun;

end p_importa_historico_disc_extra;

procedure p_ajusta_historico( p_alucod 		oli_alundisc.alucod%type
							, p_grade_aluno	oli_grade.gracod%type
							, p_espcod		oli_alundisc.tmacod%type) is

t_ohia_sequ     pkg_util.tb_number;

cursor c_sem_media(pc_alucod	oli_alundisc.alucod%type) is
    SELECT a.ohia_sequ
	  FROM oli_historico_aluno a
	 WHERE a.ohia_alun = pc_alucod
	   AND a.ohia_smed IN ('AE', 'AC')
	   AND a.ohia_medi IS NOT NULL
	 UNION ALL
	SELECT b.ohia_sequ
	  FROM oli_historico_aluno b
	 WHERE b.ohia_alun = pc_alucod
	   AND b.ohia_situ = 'Cursando'
	   AND b.ohia_medi IS NOT NULL;

begin

-- todas as disciplinas que precisamos zerar a média pois vem "lixo" do Olimpo
open c_sem_media(p_alucod);
loop
    fetch c_sem_media bulk collect into t_ohia_sequ
    limit pkg_util.c_limit_trans;
    exit when t_ohia_sequ.count = 0;

    forall i in t_ohia_sequ.first..t_ohia_sequ.last
        UPDATE oli_historico_aluno SET
			   ohia_atua = 'S'
			 , ohia_datu = SYSDATE
			 , ohia_medi = NULL
		 WHERE ohia_sequ = t_ohia_sequ(i);
    COMMIT;
end loop;
close c_sem_media;

end p_ajusta_historico;

procedure p_alimenta_nsem_hist_alun(    p_migr_sequ   	mgr_migracao.migr_sequ%type) is

t_ohia_sequ     pkg_util.tb_number;
t_ohia_nsem     pkg_util.tb_number;

cursor c_hist(pc_migr_sequ   		mgr_migracao.migr_sequ%type) is
    SELECT ohia_sequ
         , NVL(NVL(nsem, nsem_mdis), NVL(nsem_alun, nsem_semestre)) nsem
      FROM (
    SELECT a.ohia_sequ
         -- busca o nsem utilizando o código da disciplina cursada, primeiro tentamos na graddisc
         -- se não encontrar tentamos da discmini
         , NVL((SELECT MIN(x.gdiano)
                  FROM oli_graddisc x
                 WHERE x.espcod = a.ohia_curs
                   AND x.gracod = a.ohia_grad
                   AND x.discod = a.ohia_disc)
              , (SELECT MIN(w.dimetapa)
                  FROM oli_discmini w
                 WHERE w.discod = a.ohia_disc
                   AND w.tmacod = a.ohia_turs)) nsem
         -- aqui é feito o mesmo select acima porém utilizando a disciplina que o aluno foi matriculado
         , NVL((SELECT MIN(x.gdiano)
                  FROM oli_graddisc x
                 WHERE x.espcod = a.ohia_curs
                   AND x.gracod = a.ohia_grad
                   AND x.discod = a.ohia_mdis)
             , (SELECT MIN(w.dimetapa)
                  FROM oli_discmini w
                 WHERE w.discod = a.ohia_mdis
                   AND w.tmacod = a.ohia_turs)) nsem_mdis
         -- se não existir na grade e na disciplina ministrada para aquele curso ou turma
         -- então verificamos na alundisc se o aluno não cursou essa disciplina em outra turma
         , NVL((SELECT MIN(w.dimetapa)
                  FROM oli_alundisc z
                     , oli_discmini w
                 WHERE z.alucod = a.ohia_alun
                   AND z.discod = a.ohia_disc
                   AND w.discod = z.discod
                   AND w.tmacod = z.tmacod
                   AND w.dimtip = z.dimtip)
             , (SELECT MIN(w.dimetapa)
                  FROM oli_alundisc z
                     , oli_discmini w
                 WHERE z.alucod = a.ohia_alun
                   AND z.discod = a.ohia_mdis
                   AND w.discod = z.discod
                   AND w.tmacod = z.tmacod
                   AND w.dimtip = z.dimtip)) nsem_alun
	     , (SELECT MAX(z.ohia_nsem)
		      FROM oli_historico_aluno z
			 WHERE z.ohia_alun = a.ohia_alun
			   AND z.ohia_seme = a.ohia_seme
			   AND z.ohia_curs = a.ohia_curs
			   AND z.ohia_atua = 'S') nsem_semestre
      FROM oli_historico_aluno a
     WHERE a.ohia_atua = 'S'
	   AND a.ohia_nsem IS NULL
       AND EXISTS( SELECT 1
                     FROM mgr_versao y
                    WHERE y.mver_migr = pc_migr_sequ
                      AND y.mver_sequ = a.ohia_mver));

begin
-- retorna o nsem que o aluno cursou a disciplina e salva no histórico
open c_hist(p_migr_sequ);
loop
    fetch c_hist bulk collect into t_ohia_sequ, t_ohia_nsem
    limit pkg_util.c_limit_trans;
    exit when t_ohia_sequ.count = 0;

    forall i in t_ohia_sequ.first..t_ohia_sequ.last
        UPDATE oli_historico_aluno
           SET ohia_nsem = t_ohia_nsem(i)
         WHERE ohia_sequ = t_ohia_sequ(i);
    COMMIT;
end loop;
close c_hist;

end p_alimenta_nsem_hist_alun;

procedure p_alimenta_turs_hist_alun(    p_migr_sequ   	mgr_migracao.migr_sequ%type) is

t_ohia_sequ     pkg_util.tb_number;
t_ohia_mtus     pkg_util.tb_number;
t_ohia_mtusf    pkg_util.tb_number;

cursor c_turs( pc_migr_sequ			mgr_migracao.migr_sequ%type
			 , pc_seme_inic_acad	varchar2) is
    SELECT a.ohia_sequ, b.mtus_sequ
	  FROM oli_historico_aluno a
		 , mgr_turma_semestre b
	 WHERE a.ohia_seme >= pc_seme_inic_acad
	   AND a.ohia_atua = 'S'
	   AND a.ohia_mtus IS NULL
	   AND b.mtus_segi = a.ohia_seme
	   AND b.mtus_turm = a.ohia_turs
       AND EXISTS( SELECT 1
                     FROM mgr_versao y
                    WHERE y.mver_migr = pc_migr_sequ
                      AND y.mver_sequ = a.ohia_mver);
					  
cursor c_turs_sc( pc_migr_sequ		mgr_migracao.migr_sequ%type
				, pc_seme_inic_acad	varchar2) is
    SELECT a.ohia_sequ
	     -- busca a turma base do aluno
	     , (SELECT MAX(z.mtus_sequ)
		      FROM oli_aluncurs y
			     , mgr_turma_semestre z
			 WHERE y.alucod = a.ohia_alun
			   AND y.espcod = a.ohia_curs
			   AND z.mtus_turm = y.tmacod
			   AND z.mtus_segi = a.ohia_seme
			   AND z.mtus_atua = 'S') ohia_mtus
		 -- pega alguma turma que o aluno teve no semestre para o mesmo curso
		 , (SELECT MAX(k.ohia_mtus)
		      FROM oli_historico_aluno k
			 WHERE k.ohia_alun = a.ohia_alun
			   AND k.ohia_seme = a.ohia_seme
			   AND k.ohia_curs = a.ohia_curs
			   AND k.ohia_atua = 'S') ohia_mtus_f
	  FROM oli_historico_aluno a
	 WHERE a.ohia_seme >= pc_seme_inic_acad
	   AND a.ohia_atua = 'S'
	   AND a.ohia_mtus IS NULL
	   AND a.ohia_turs IS NOT NULL
       AND EXISTS( SELECT 1
                     FROM mgr_versao y
                    WHERE y.mver_migr = pc_migr_sequ
                      AND y.mver_sequ = a.ohia_mver);
					  
cursor c_turs_fi( pc_migr_sequ		mgr_migracao.migr_sequ%type
				, pc_seme_inic_acad	varchar2) is
    SELECT a.ohia_sequ
		 -- pega alguma turma do mesmo semestre para o mesmo curso do aluno
		 , (SELECT MAX(k.ohia_mtus)
		      FROM oli_historico_aluno k
			 WHERE k.ohia_seme = a.ohia_seme
			   AND k.ohia_curs = a.ohia_curs
			   AND k.ohia_atua = 'S') ohia_mtus
		 -- pega alguma turma do mesmo semestre
		 , (SELECT MAX(k.ohia_mtus)
		      FROM oli_historico_aluno k
			 WHERE k.ohia_seme = a.ohia_seme
			   AND k.ohia_atua = 'S') ohia_mtus_f
	  FROM oli_historico_aluno a
	 WHERE a.ohia_seme >= pc_seme_inic_acad
	   AND a.ohia_atua = 'S'
	   AND a.ohia_mtus IS NULL
	   AND a.ohia_turs IS NOT NULL
       AND EXISTS( SELECT 1
                     FROM mgr_versao y
                    WHERE y.mver_migr = pc_migr_sequ
                      AND y.mver_sequ = a.ohia_mver);

begin
-- retorna a relação da mgr_turma_semestre com os dados do histórico do aluno
open c_turs(p_migr_sequ, f_seme_ini_imp_academico);
loop
    fetch c_turs bulk collect into t_ohia_sequ, t_ohia_mtus
    limit pkg_util.c_limit_trans;
    exit when t_ohia_sequ.count = 0;

    forall i in t_ohia_sequ.first..t_ohia_sequ.last
        UPDATE oli_historico_aluno
           SET ohia_mtus = t_ohia_mtus(i)
         WHERE ohia_sequ = t_ohia_sequ(i);
    COMMIT;
end loop;
close c_turs;

-- retorna a relação da mgr_turma_semestre considerando a turma base do aluno
open c_turs_sc(p_migr_sequ, f_seme_ini_imp_academico);
loop
    fetch c_turs_sc bulk collect into t_ohia_sequ, t_ohia_mtus, t_ohia_mtusf
    limit pkg_util.c_limit_trans;
    exit when t_ohia_sequ.count = 0;

    forall i in t_ohia_sequ.first..t_ohia_sequ.last
        UPDATE oli_historico_aluno
           SET ohia_mtus = NVL(t_ohia_mtus(i), t_ohia_mtusf(i))
         WHERE ohia_sequ = t_ohia_sequ(i);
    COMMIT;
end loop;
close c_turs_sc;

-- retorna a relação da mgr_turma_semestre considerando alguma turma qualquer para o aluno
-- basicamente é feito este caminho por causa das disciplinas de ED
open c_turs_fi(p_migr_sequ, f_seme_ini_imp_academico);
loop
    fetch c_turs_fi bulk collect into t_ohia_sequ, t_ohia_mtus, t_ohia_mtusf
    limit pkg_util.c_limit_trans;
    exit when t_ohia_sequ.count = 0;

    forall i in t_ohia_sequ.first..t_ohia_sequ.last
        UPDATE oli_historico_aluno
           SET ohia_mtus = NVL(t_ohia_mtus(i), t_ohia_mtusf(i))
         WHERE ohia_sequ = t_ohia_sequ(i);
    COMMIT;
end loop;
close c_turs_fi;

end p_alimenta_turs_hist_alun;

procedure p_alimenta_asit_hist_alun(p_migr_sequ   	mgr_migracao.migr_sequ%type) is

t_ohia_sequ     pkg_util.tb_number;
t_ohia_asit     pkg_util.tb_number;

cursor c_asit( pc_migr_sequ mgr_migracao.migr_sequ%type) is
    SELECT a.ohia_sequ
		 , DECODE( LOWER(a.ohia_situ)
				 , 'aprovado', 8
				 , 'cursando', 7
				 , 'reprovado por média e falta', 6
				 , 'reprovado por média', 5
				 , 'reprovado por falta', 4
				 , 'a cursar', 3
				 , 'desistente', 2
				 , 'necessita fazer exame', 1
				 , 0) ohia_asit
	  FROM oli_historico_aluno a
	 WHERE a.ohia_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao y
                    WHERE y.mver_migr = pc_migr_sequ
                      AND y.mver_sequ = a.ohia_mver);

begin
-- retorna a relação da mgr_turma_semestre com os dados do histórico do aluno
open c_asit(p_migr_sequ);
loop
    fetch c_asit bulk collect into t_ohia_sequ, t_ohia_asit
    limit pkg_util.c_limit_trans;
    exit when t_ohia_sequ.count = 0;

    forall i in t_ohia_sequ.first..t_ohia_sequ.last
        UPDATE oli_historico_aluno
           SET ohia_asit = t_ohia_asit(i)
         WHERE ohia_sequ = t_ohia_sequ(i);
    commit;
end loop;
close c_asit;

end p_alimenta_asit_hist_alun;

function f_grade_existe( p_espcod	oli_graddisc.gracod%type
					   , p_gracod	oli_grade.gracod%type) return varchar2 DETERMINISTIC is 

l_retorno	varchar2(3);
qt_registro	pls_integer;
begin

l_retorno := 'N';

SELECT COUNT(1)
  INTO qt_registro
  FROM oli_graddisc
 WHERE espcod = p_espcod
   AND gracod = p_gracod;
   
if	(qt_registro > 0) then
   l_retorno := 'S';
end if;

return l_retorno;

end f_grade_existe;

procedure p_importa_historico_aluno( p_migr_sequ   	mgr_migracao.migr_sequ%type
								   , p_mver_sequ    mgr_versao.mver_sequ%type
								   , p_separador    mgr_migracao.migr_sepa%type) is

l_grade_aluno	oli_grade.gracod%type;

-- no caso de repetência de registros, prevalece o que tem a grade específica
-- informada no aluno, depois as demais
cursor c_alun(  pc_migr_sequ   	mgr_migracao.migr_sequ%type) is
    SELECT DISTINCT a.malu_chav alucod, b.mcur_chav espcod
		 , a.malu_ogra, c.gracod grade_aluno
		 , d.gracod grade_turma, TO_NUMBER(e.msed_chav) iunicodempresa
		 , a.malu_diis, a.malu_ding
		 , a.malu_asig, a.malu_psem
		 , a.malu_sequ
	  FROM mgr_aluno a
		 , mgr_curso b
		 , oli_aluncurs c
		 , oli_turma d
		 , mgr_sede e
	 WHERE a.malu_atua = 'S'
	   AND EXISTS(  SELECT 1
					  FROM mgr_versao v
					 WHERE v.mver_sequ = a.malu_mver
					   AND v.mver_migr = pc_migr_sequ)
	   AND b.mcur_sequ = a.malu_mcur
	   AND c.alucod = a.malu_chav
	   AND c.espcod = b.mcur_chav
	   AND d.tmacod = c.tmacod
	   AND e.msed_sequ = a.malu_msed
	 ORDER BY malu_chav, malu_diis DESC, grade_aluno DESC
	     , malu_ding DESC, malu_sequ, espcod, malu_asig DESC
		 , malu_psem DESC;

-- busca somente o aluno e o curso para fazer limpezas	 
cursor c_alun_limp(  pc_migr_sequ   	mgr_migracao.migr_sequ%type) is
	SELECT DISTINCT a.malu_chav alucod, b.mcur_chav espcod
		 , NVL(c.gracod, d.gracod) grade_aluno
      FROM mgr_aluno a
		 , mgr_curso b
		 , oli_aluncurs c
		 , oli_turma d
	 WHERE a.malu_atua = 'S'
	   AND a.malu_diis = 'N'
	   AND EXISTS(  SELECT 1
					  FROM mgr_versao v
					 WHERE v.mver_sequ = a.malu_mver
					   AND v.mver_migr = pc_migr_sequ)
       AND b.mcur_sequ = a.malu_mcur
       AND c.alucod = a.malu_chav
       AND c.espcod = b.mcur_chav
       AND d.tmacod = c.tmacod
     ORDER BY malu_chav;

begin
-- só faz algo quando a versão é passada
if  (p_mver_sequ is not null) then

	-- limpa o histórico e as convalidações
	pkg_mgr_olimpo_aux.p_limpa_historico_aluno(p_migr_sequ);

    -- faz os updates iniciais na tabela oli_historico_aluno necessários
    pkg_mgr_imp_producao_aux.p_update_inicio_hist_aluno(p_migr_sequ);
	
	-- faz os updates iniciais na tabela oli_historico_aluno_conv necessários
	pkg_mgr_imp_producao_aux.p_update_inicio_hist_alun_conv(p_migr_sequ);
	
	-- todos os alunos que foram migrados
    for r_c_alun in c_alun(p_migr_sequ) loop
		
		-- tratamento, pois nem sempre a grade existe no Olimpo
		if	(f_grade_existe(r_c_alun.espcod, r_c_alun.malu_ogra) = 'S') then
			l_grade_aluno := r_c_alun.malu_ogra;
			
		elsif	(f_grade_existe(r_c_alun.espcod, r_c_alun.grade_aluno) = 'S') then
			l_grade_aluno := r_c_alun.grade_aluno;
			
		elsif	(f_grade_existe(r_c_alun.espcod, r_c_alun.grade_turma) = 'S') then
			l_grade_aluno := r_c_alun.grade_turma;
			
		else
			l_grade_aluno := NVL(r_c_alun.malu_ogra, NVL(r_c_alun.grade_aluno, r_c_alun.grade_turma));
		end if;
		
		-- gera o histórico do aluno com as informações das disciplinas que 
		-- ele está matriculado
		p_importa_historico_matr( r_c_alun.alucod, r_c_alun.espcod
								, l_grade_aluno, r_c_alun.malu_diis
								, r_c_alun.malu_sequ, r_c_alun.iunicodempresa
								, p_mver_sequ);
		
		-- aluno em disciplina isolada não gera disciplinas faltantes ou extra-curriculares
		if	(r_c_alun.malu_diis = 'N') then
		
			-- gera o histórico com base nas disciplinas em que o aluno possui convalidação
			-- ou crédito concedido
			p_importa_historico_conv(	r_c_alun.alucod, r_c_alun.espcod
									, l_grade_aluno, r_c_alun.malu_diis
									, r_c_alun.malu_sequ, r_c_alun.iunicodempresa
									, p_mver_sequ, p_separador);

			-- seta disciplinas que não fazem parte da grade como extra-curriculares
			p_importa_historico_disc_extra( r_c_alun.alucod, r_c_alun.espcod
										  , l_grade_aluno, r_c_alun.iunicodempresa
										  , p_mver_sequ);
										  
			-- gera todas as disciplinas que estão na grade do aluno, porém ele ainda não cursou e nem convalidou
			p_importa_historico_disc_falt( r_c_alun.alucod, r_c_alun.espcod
										 , l_grade_aluno, r_c_alun.malu_diis
										 , r_c_alun.malu_sequ, r_c_alun.iunicodempresa
										 , p_mver_sequ);
		end if;
		
    end loop;

	commit;
	
	-- todos os alunos que foram migrados para fazer uma limpeza
    for r_c_alun_limp in c_alun_limp(p_migr_sequ) loop
	
		-- faz ajustes para arrumar alguns dados que vieram com incoerência do Olimpo
		p_ajusta_historico( r_c_alun_limp.alucod, r_c_alun_limp.grade_aluno
						  , r_c_alun_limp.espcod);

	end loop;
	
	commit;
	
	-- alimenta o ohia_mtus para vincular a turma onde o aluno cursou a disciplina
	p_alimenta_turs_hist_alun(p_migr_sequ);
	commit;
	
	-- alimenta o nsem das disciplinas do aluno
	p_alimenta_nsem_hist_alun(p_migr_sequ);
	commit;
	
	-- alimenta o ohia_asit que é utilizado para definir prioridade em relação a situação da disciplina do aluno
	p_alimenta_asit_hist_alun(p_migr_sequ);
	commit;
	
	-- situação muito estranha onde sabemos que tudo deve ficar no primeiro semestre
	UPDATE oli_historico_aluno SET ohia_nsem = 1
	 WHERE ohia_curs = 2191
	   AND ohia_grad = 292
	   AND ohia_dgio = '11530'
	   AND ohia_nsem = 2;
	commit;
	
end if;

end p_importa_historico_aluno;

procedure p_ordena_grade_curso( p_mgcu_sequ     mgr_grade_curso.mgcu_sequ%type) is

l_cont_orde     pls_integer;

cursor c_orde_mgra( pc_mgcu_sequ     mgr_grade_curso.mgcu_sequ%type) is
    SELECT a.mgra_sequ
		 , (SELECT MAX(b.nome_disciplina)
		      FROM oli_disciplina_juncao b
			 WHERE b.codigo_disciplina_gioconda = a.mgra_vdis) nome_disciplina
      FROM mgr_grade a
     WHERE a.mgra_mgcu = pc_mgcu_sequ
     ORDER BY a.mgra_nsem, nome_disciplina;

begin
if  (p_mgcu_sequ is not null) then

    l_cont_orde := 1;

    for r_c_orde_mgra in c_orde_mgra(p_mgcu_sequ) loop

        UPDATE mgr_grade
           SET mgra_orde = l_cont_orde
         WHERE mgra_sequ = r_c_orde_mgra.mgra_sequ;

         l_cont_orde := l_cont_orde + 1;
    end loop;

    UPDATE mgr_grade_curso
       SET mgcu_atua = 'S'
         , mgcu_datu = sysdate
         , mgcu_nsem = NVL((SELECT MAX(mgra_nsem) 
							  FROM mgr_grade 
							 WHERE mgra_mgcu = p_mgcu_sequ), 1)
     WHERE mgcu_sequ = p_mgcu_sequ;

     commit;
end if;

end p_ordena_grade_curso;

function obter_carga_disc( p_ohia_curs	oli_historico_aluno.ohia_curs%type
						 , p_ohia_grad	oli_historico_aluno.ohia_grad%type
						 , p_ohia_dgio oli_historico_aluno.ohia_dgio%type
						 , p_ohia_nsem oli_historico_aluno.ohia_nsem%type) return t_dado_disc is

l_dado_disc t_dado_disc;

cursor c_ohia_disc( pc_ohia_curs	oli_historico_aluno.ohia_curs%type
				  , pc_ohia_grad	oli_historico_aluno.ohia_grad%type
				  , pc_ohia_dgio 	oli_historico_aluno.ohia_dgio%type
				  , pc_ohia_nsem 	oli_historico_aluno.ohia_nsem%type) is
	SELECT ohia_carg
		 , ohia_cred
		 , ohia_prat
		 , ohia_comp
		 , ohia_esta
		 , ohia_tipo
	     , COUNT(1) qtde
	  FROM oli_historico_aluno z
	 WHERE z.ohia_atua = 'S'
	   AND z.ohia_curs = pc_ohia_curs
	   AND z.ohia_grad = pc_ohia_grad
	   AND z.ohia_smed NOT IN ('AE', 'CC', 'EC')
	   AND z.ohia_dgio = pc_ohia_dgio
	   AND z.ohia_nsem = pc_ohia_nsem
	 GROUP BY ohia_carg
		 , ohia_cred
		 , ohia_prat
		 , ohia_comp
		 , ohia_esta
		 , ohia_tipo
	 ORDER BY qtde DESC;

begin
	l_dado_disc.credito := 0;
	l_dado_disc.pratica := 0;
	l_dado_disc.complementar := 0;
	l_dado_disc.estagio := 0;
	l_dado_disc.carga_horaria := 0;
	l_dado_disc.tipo := null;
	
	-- busca a combinação de dados que mais se repete e retorna a mesma
	for r_c_ohia_disc in c_ohia_disc(p_ohia_curs, p_ohia_grad, p_ohia_dgio, p_ohia_nsem) loop
	
		l_dado_disc.credito := NVL(r_c_ohia_disc.ohia_cred, 0);
		l_dado_disc.pratica := NVL(r_c_ohia_disc.ohia_prat, 0);
		l_dado_disc.complementar := NVL(r_c_ohia_disc.ohia_comp, 0);
		l_dado_disc.estagio := NVL(r_c_ohia_disc.ohia_esta, 0);
		l_dado_disc.carga_horaria := NVL(r_c_ohia_disc.ohia_carg, 0);
		l_dado_disc.tipo := NVL(r_c_ohia_disc.ohia_tipo, 'N');
		
		exit;
		
	end loop;
	
	return l_dado_disc;
	
end obter_carga_disc;

procedure p_gera_grade( p_ohia_curs	oli_historico_aluno.ohia_curs%type
					  , p_ohia_grad	oli_historico_aluno.ohia_grad%type
					  , p_migr_sequ	mgr_migracao.migr_sequ%type
					  , p_mver_sequ	mgr_versao.mver_sequ%type
					  , p_mgcu_sequ	mgr_grade_curso.mgcu_sequ%type) is
					  
l_dado_disc t_dado_disc;

cursor c_disc( pc_ohia_curs	oli_historico_aluno.ohia_curs%type
			 , pc_ohia_grad	oli_historico_aluno.ohia_grad%type
			 , pc_mgcu_sequ	mgr_grade_curso.mgcu_sequ%type
			 , pc_migr_sequ	mgr_migracao.migr_sequ%type) is
	SELECT a.ohia_dgio
		 , mcur_sequ
		 , a.ohia_nsem
		 , (SELECT MAX(x.mgra_sequ)
			  FROM mgr_grade x
			 WHERE x.mgra_mgcu = pc_mgcu_sequ
			   AND x.mgra_vdis = a.ohia_dgio) mgra_sequ
	     , (SELECT COUNT(1)
			  FROM oli_historico_aluno z
			 WHERE z.ohia_atua = 'S'
			   AND z.ohia_curs = pc_ohia_curs
			   AND z.ohia_grad = pc_ohia_grad
			   AND z.ohia_smed NOT IN ('AE', 'CC', 'EC')
			   AND z.ohia_dgio = a.ohia_dgio
			   AND z.ohia_nsem = a.ohia_nsem) qtde_matr
	  FROM oli_historico_aluno a
	     , mgr_curso
	 WHERE a.ohia_atua = 'S'
	   AND a.ohia_curs = pc_ohia_curs
	   AND a.ohia_grad = pc_ohia_grad
	   AND a.ohia_smed NOT IN ('AE', 'CC', 'EC')
	   AND a.ohia_dgio IS NOT NULL
	   AND a.ohia_nsem IS NOT NULL
	   AND EXISTS(  SELECT 1
					  FROM mgr_versao x
					 WHERE x.mver_migr = pc_migr_sequ
					   AND x.mver_sequ = a.ohia_mver)
	   AND mcur_chav = TO_CHAR(pc_ohia_curs)
	 GROUP BY a.ohia_dgio, mcur_sequ, a.ohia_nsem
	 ORDER BY a.ohia_dgio, qtde_matr;

begin
-- para fazer algo nesta rotina é necessário que a grade_curso já tenha sido gerada e passada de parâmetro
if  (p_mgcu_sequ is not null) then
	
	-- retorna todas as disciplinas que devem fazer parte da grade
	for r_c_disc in c_disc(p_ohia_curs, p_ohia_grad, p_mgcu_sequ, p_migr_sequ) loop
		
		-- busca os dados de carga horária da disciplina
		l_dado_disc := obter_carga_disc( p_ohia_curs, p_ohia_grad, r_c_disc.ohia_dgio, r_c_disc.ohia_nsem);
			
		-- se não tem grade insere
		if	(r_c_disc.mgra_sequ IS NULL) then

            INSERT INTO mgr_grade (
                   mgra_sequ, mgra_cred, mgra_carg
                 , mgra_esta, mgra_prat, mgra_comp
                 , mgra_taul, mgra_orde, mgra_nsem
                 , mgra_crfi, mgra_doce, mgra_peda
                 , mgra_mver, mgra_atua, mgra_datu
                 , mgra_mcur, mgra_mgcu, mgra_opta
                 , mgra_vdis
            ) VALUES (
                   FGET_SEQU('SEQU_MGR_GRADE', 'MGRA_SEQU', 'MGR_GRADE'), l_dado_disc.credito, l_dado_disc.carga_horaria
                 , l_dado_disc.estagio, l_dado_disc.pratica, l_dado_disc.complementar
                 , l_dado_disc.tipo, 1, r_c_disc.ohia_nsem
                 , l_dado_disc.credito, 'S', 0
                 , p_mver_sequ, 'S', sysdate
                 , r_c_disc.mcur_sequ, p_mgcu_sequ, 'N'
                 , r_c_disc.ohia_dgio
            );

        -- apenas atualizamos os campos para os registros que já existem
        else

            -- só atualiza algum campo nulo
            UPDATE mgr_grade
               SET mgra_cred = l_dado_disc.credito
                 , mgra_carg = l_dado_disc.carga_horaria
                 , mgra_esta = l_dado_disc.estagio
                 , mgra_prat = l_dado_disc.pratica
                 , mgra_comp = l_dado_disc.complementar
                 , mgra_taul = l_dado_disc.tipo
                 , mgra_nsem = r_c_disc.ohia_nsem
                 , mgra_crfi = l_dado_disc.credito
                 , mgra_atua = 'S'
                 , mgra_datu = sysdate
             WHERE mgra_sequ = r_c_disc.mgra_sequ;
        end if;
    end loop;

    commit;
end if;
end p_gera_grade;

procedure p_gera_grade_curso( p_ohia_curs	in oli_historico_aluno.ohia_curs%type
						    , p_ohia_grad	in oli_historico_aluno.ohia_grad%type
							, p_migr_sequ	in mgr_migracao.migr_sequ%type
						    , p_mver_sequ	in mgr_versao.mver_sequ%type
							, p_separador	in mgr_migracao.migr_sepa%type
						    , p_mgcu_sequ	in out mgr_grade_curso.mgcu_sequ%type) is

l_mcur_abrv     mgr_curso.mcur_abrv%type;
l_mcur_sequ     mgr_curso.mcur_sequ%type;
l_mgcu_msem     mgr_grade_curso.mgcu_msem%type;
l_mgcu_sequ     mgr_grade_curso.mgcu_sequ%type;
l_mgcu_seme     mgr_grade_curso.mgcu_seme%type;
l_mgcu_comp		mgr_grade_curso.mgcu_comp%type;

begin
-- busca alguns dados para gerar a grade
SELECT MIN(mcur_abrv)
     , MIN(mcur_sequ)
     , MIN(ohia_seme)
  INTO l_mcur_abrv
     , l_mcur_sequ
	 , l_mgcu_seme
  FROM oli_historico_aluno
     , mgr_curso
 WHERE ohia_atua = 'S'
   AND ohia_curs = p_ohia_curs
   AND ohia_grad = p_ohia_grad
   AND ohia_dgio IS NOT NULL
   AND ohia_nsem IS NOT NULL
   AND EXISTS(  SELECT 1
				  FROM mgr_versao x
				 WHERE x.mver_migr = p_migr_sequ
				   AND x.mver_sequ = ohia_mver)
   AND mcur_chav = ohia_curs
 GROUP BY mcur_abrv
     , mcur_sequ;

-- pega a sequência do semestre
SELECT MAX(msem_sequ)
  INTO l_mgcu_msem
  FROM mgr_semestre
 WHERE msem_seme = l_mgcu_seme;

-- parte da carga horária das atividades complementares
SELECT MAX(graextensaouni)
  INTO l_mgcu_comp
  FROM oli_grade
 WHERE espcod = p_ohia_curs
   AND gracod = p_ohia_grad;

-- insert ou update
if (p_mgcu_sequ IS NULL) then

	-- gera uma nova sequencia para a grade_curso
	l_mgcu_sequ := FGET_SEQU('SEQU_MGR_GRADE_CURSO', 'MGCU_SEQU', 'MGR_GRADE_CURSO');

	-- insere o registro
	INSERT INTO mgr_grade_curso(
		   mgcu_sequ, mgcu_desc, mgcu_seme
		 , mgcu_matr, mgcu_nsem, mgcu_ativ
		 , mgcu_mver, mgcu_atua, mgcu_datu
		 , mgcu_mcur, mgcu_msem, mgcu_chav
		 , mgcu_comp
	) VALUES (
		   l_mgcu_sequ, l_mcur_abrv, l_mgcu_seme
		 , 'N', 1, '1'
		 , p_mver_sequ, 'S', sysdate
		 , l_mcur_sequ, l_mgcu_msem, p_ohia_curs || p_separador || p_ohia_grad
		 , l_mgcu_comp
	);
	
	-- alimenta o parâmetro out
	p_mgcu_sequ := l_mgcu_sequ;
else
	l_mgcu_sequ := p_mgcu_sequ;
	
	UPDATE mgr_grade_curso SET
		   mgcu_desc = l_mcur_abrv
		 , mgcu_seme = l_mgcu_seme
		 , mgcu_atua = 'S'
		 , mgcu_datu = sysdate
		 , mgcu_mcur = l_mcur_sequ
		 , mgcu_chav = p_ohia_curs || p_separador || p_ohia_grad
		 , mgcu_comp = l_mgcu_comp
	 WHERE mgcu_sequ = l_mgcu_sequ;
end if;
commit;

end p_gera_grade_curso;

procedure p_gera_rateio_ativ_comp( p_mgcu_sequ     mgr_grade_curso.mgcu_sequ%type) is

l_qt_nsem			pls_integer;
l_carga_ativ_comp	mgr_grade_curso.mgcu_comp%type;
l_valor_carga		mgr_grade.mgra_comp%type;
l_valor_carga_dif	mgr_grade.mgra_comp%type;
l_carga_lancar		mgr_grade.mgra_comp%type;
l_qt_registro		pls_integer;

-- joga na primeira disciplina do semestre
cursor c_ativ_mgra( pc_mgcu_sequ     mgr_grade_curso.mgcu_sequ%type) is
	SELECT a.mgra_nsem
		 , MAX(a.mgra_sequ) mgra_sequ
	  FROM mgr_grade a
	 WHERE a.mgra_mgcu = pc_mgcu_sequ
	   AND a.mgra_taul = 'N'
	   AND a.mgra_comp = 0
	   AND a.mgra_orde = ( SELECT MIN(b.mgra_orde)
							 FROM mgr_grade b
							WHERE b.mgra_mgcu = pc_mgcu_sequ
							  AND b.mgra_taul = 'N'
							  AND b.mgra_comp = 0
							  AND b.mgra_nsem = a.mgra_nsem)
	 GROUP BY a.mgra_nsem
	 ORDER BY a.mgra_nsem;

begin

if  (p_mgcu_sequ is not null) then

    SELECT COUNT(DISTINCT mgra_nsem)
	  INTO l_qt_nsem
	  FROM mgr_grade
	 WHERE mgra_mgcu = p_mgcu_sequ
	   AND mgra_taul = 'N'
	   AND mgra_comp = 0;
	   
	SELECT MAX(mgcu_comp)
	  INTO l_carga_ativ_comp
	  FROM mgr_grade_curso
	 WHERE mgcu_sequ = p_mgcu_sequ;
	 
	if	(l_carga_ativ_comp is not null and l_qt_nsem > 0) then
	
		-- faz a divisão das cargas
		pkg_util.p_divide_valor_inteiro(l_carga_ativ_comp, l_qt_nsem, l_valor_carga, l_valor_carga_dif);
		
		l_qt_registro := 0;
		for r_c_ativ_mgra in c_ativ_mgra(p_mgcu_sequ) loop
			
			-- primeiro registro coloca o valor da diferença
			-- os demais coloca o valor normal
			if	(l_qt_registro = 0) then
				l_carga_lancar := l_valor_carga_dif;
			else
				l_carga_lancar := l_valor_carga;
			end if;
			
			UPDATE mgr_grade SET 
				   mgra_comp = l_carga_lancar
			 WHERE mgra_sequ = r_c_ativ_mgra.mgra_sequ;
			
			l_qt_registro := l_qt_registro + 1;
		end loop;

		commit;
	end if;
end if;

end p_gera_rateio_ativ_comp;

procedure p_atualiza_grad_hist(	p_ohia_curs	oli_historico_aluno.ohia_curs%type
							  , p_ohia_grad	oli_historico_aluno.ohia_grad%type
							  , p_mgcu		mgr_grade_curso.mgcu_sequ%type) is

begin

UPDATE oli_historico_aluno SET
	   ohia_mgcu = p_mgcu
 WHERE ohia_curs = p_ohia_curs
   AND ohia_grad = p_ohia_grad;
commit;

end p_atualiza_grad_hist;

procedure p_importa_grade( p_migr_sequ	mgr_migracao.migr_sequ%type
                         , p_mver_sequ	mgr_versao.mver_sequ%type
                         , p_separador	mgr_migracao.migr_sepa%type) is
						 
l_qtde_disc		pls_integer;
l_mgcu_sequ     mgr_grade_curso.mgcu_sequ%type;

-- alguma grade com alguém aprovado acima do semestre de início da integração
-- importamos primeiro as grades de maior quantidade de disciplinas
cursor c_grad_oli( pc_migr_sequ     	mgr_migracao.migr_sequ%type
				 , pc_seme_inic_acad	varchar2) is
	SELECT ohia_curs, ohia_grad
	     , MAX(ohia_mgcu) ohia_mgcu
	     , COUNT(ohia_dgio) qtde_disc
	  FROM oli_historico_aluno
	 WHERE ohia_atua = 'S'
	   AND ohia_diis = 'N'
	   AND ohia_seme >= pc_seme_inic_acad
	   AND ohia_dgio IS NOT NULL
	   AND ohia_nsem IS NOT NULL
	   AND ohia_smed NOT IN ('AE', 'CC', 'EC')
	   AND EXISTS(  SELECT 1
					  FROM mgr_versao x
					 WHERE x.mver_migr = pc_migr_sequ
					   AND x.mver_sequ = ohia_mver)
	 GROUP BY ohia_curs, ohia_grad
	 ORDER BY qtde_disc DESC, ohia_curs, ohia_grad;

cursor c_grad_curs( pc_migr_sequ     	mgr_migracao.migr_sequ%type
				  , pc_mcur_chav    mgr_curso.mcur_chav%type) is
    SELECT mgcu_sequ
      FROM mgr_grade_curso
	     , mgr_curso
     WHERE mgcu_mcur = mcur_sequ
	   AND mcur_chav = pc_mcur_chav
	   AND EXISTS(  SELECT 1
					  FROM mgr_versao x
					 WHERE x.mver_migr = pc_migr_sequ
					   AND x.mver_sequ = mcur_mver)
     ORDER BY mgcu_sequ;
								  
begin
	-- atualizar o _atua para N
	pkg_mgr_imp_producao_aux.p_update_inicio_grade_curso(p_migr_sequ);
	pkg_mgr_imp_producao_aux.p_update_inicio_grade(p_migr_sequ);
	
	-- lista as grades que estão passando pelo processo de verificação
	for r_c_grad_oli in c_grad_oli(p_migr_sequ, f_seme_ini_imp_academico) loop
	
		-- Roberta pediu para desconsiderar disciplina porque está errado  (aluna 46145)
		if	((r_c_grad_oli.ohia_curs = 99066 AND r_c_grad_oli.ohia_grad = 200521)) then
			null;
		else
			-- sempre inicializa a variável
			l_mgcu_sequ := null;
		
			-- se já teve uma grade gerada no passado para ele
			-- apenas verifica se precisamos incluir ou alterar alguma disciplina dentro da grade
			-- que já foi criada no passado
			if	(r_c_grad_oli.ohia_mgcu IS NOT NULL) then
				l_mgcu_sequ := r_c_grad_oli.ohia_mgcu;
			end if;
			
			-- gera a mgr_grade_curso (se não encontrou nada acima)
			p_gera_grade_curso( r_c_grad_oli.ohia_curs, r_c_grad_oli.ohia_grad
							  , p_migr_sequ, p_mver_sequ
							  , p_separador, l_mgcu_sequ);
			
			-- gera as disciplinas da grade
			p_gera_grade( r_c_grad_oli.ohia_curs, r_c_grad_oli.ohia_grad
						, p_migr_sequ, p_mver_sequ
						, l_mgcu_sequ);
			
			-- alimenta a ordem das disciplinas na grade e atualiza a mgr_grade_curso
			p_ordena_grade_curso(l_mgcu_sequ);
			
			-- faz o rateio das atividades complementares
			p_gera_rateio_ativ_comp(l_mgcu_sequ);
			
			-- atualiza a grade da oli_historico_aluno para termos um local com a grade equivalente que foi gerada
			p_atualiza_grad_hist( r_c_grad_oli.ohia_curs, r_c_grad_oli.ohia_grad, l_mgcu_sequ);
			
		end if;
	end loop;

end p_importa_grade;

procedure p_importa_grade_semestre( p_migr_sequ	mgr_migracao.migr_sequ%type
								  , p_mver_sequ	mgr_versao.mver_sequ%type) is

-- tabelas utilizadas no update
t_mgse_sequ_upd     pkg_util.tb_number;
t_mgse_cred_upd     pkg_util.tb_number;
t_mgse_taul_upd     pkg_util.tb_varchar2_1;
t_mgse_mcur_upd     pkg_util.tb_number;
t_mgse_mgcu_upd     pkg_util.tb_number;
t_mgse_orde_upd     pkg_util.tb_number;

-- tabelas utilizadas no insert
t_mgse_cred_ins     pkg_util.tb_number;
t_mgse_taul_ins     pkg_util.tb_varchar2_1;
t_mgse_mcur_ins     pkg_util.tb_number;
t_mgse_mgcu_ins     pkg_util.tb_number;
t_mgse_orde_ins     pkg_util.tb_number;
t_mgse_mtus_ins     pkg_util.tb_number;
t_mgse_vdis_ins     pkg_util.tb_varchar2_10;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;
qt_registro	        pls_integer;

l_mgse_sequ	mgr_grade_semestre.mgse_sequ%type;
l_mgcu_sequ	mgr_grade_semestre.mgse_mgcu%type;
l_mgse_orde mgr_grade.mgra_orde%type;

cursor c_disc_grad( pc_migr_sequ     	mgr_migracao.migr_sequ%type
				  , pc_seme_inic_acad	varchar2) is
	SELECT mtus_sequ mgse_mtus
		 , ohia_dgio mgse_vdis
		 , MAX(ohia_cred) mgse_cred
		 -- tratamento para TG que na grade é M e na grade_semestre é T
		 , MAX(DECODE(ohia_tipo, 'M', 'T', ohia_tipo)) mgse_taul
		 , MAX(mtus_mcur) mgse_mcur
		 , MIN(ohia_mgcu) mgse_mgcu
		 , (SELECT MAX(mgse_sequ)
			  FROM mgr_grade_semestre
			 WHERE mgse_mtus = mtus_sequ
			   AND mgse_vdis = ohia_dgio) mgse_sequ
	  FROM oli_historico_aluno
		 , mgr_turma_semestre
	 WHERE ohia_atua = 'S'
	   AND ohia_seme >= pc_seme_inic_acad
	   AND ohia_smed IN ('N', 'EC')
	   AND ohia_dgio IS NOT NULL
	   AND EXISTS(  SELECT 1
					  FROM mgr_versao x
					 WHERE x.mver_migr = pc_migr_sequ
					   AND x.mver_sequ = ohia_mver)
	   AND mtus_sequ = ohia_mtus
	 GROUP BY mtus_sequ, ohia_dgio;

begin
-- faz os updates de início do campo _atua
pkg_mgr_imp_producao_aux.p_update_inicio_grade_seme(p_migr_sequ);

pkg_mgr_imp_producao_aux.p_update_tabe_grade_semestre(  t_mgse_sequ_upd, t_mgse_cred_upd, t_mgse_taul_upd
                                                      , t_mgse_mcur_upd, t_mgse_mgcu_upd, t_mgse_orde_upd
                                                      , l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabe_grade_semestre(  p_mver_sequ, t_mgse_cred_ins, t_mgse_taul_ins
                                                      , t_mgse_mcur_ins, t_mgse_mgcu_ins, t_mgse_orde_ins
                                                      , t_mgse_mtus_ins, t_mgse_vdis_ins, l_contador_ins);

-- retorna as disciplinas que farão parte da grade_semestre
for r_c_disc_grad in c_disc_grad(p_migr_sequ, f_seme_ini_imp_academico) loop

	SELECT COUNT(1)
	  INTO qt_registro
	  FROM mgr_grade
	 WHERE mgra_mgcu = r_c_disc_grad.mgse_mgcu
	   AND mgra_disc = r_c_disc_grad.mgse_vdis;
	
	-- se a disciplina faz parte da grade informamos o código
	-- senão, deixamos em aberto
	if	(qt_registro > 0) then
		l_mgcu_sequ := r_c_disc_grad.mgse_mgcu;
        
        SELECT MAX(mgra_orde)
          INTO l_mgse_orde
          FROM mgr_grade
         WHERE mgra_mgcu = l_mgcu_sequ
           AND mgra_disc = r_c_disc_grad.mgse_vdis;
	else
		l_mgcu_sequ := null;
        l_mgse_orde := null;
	end if;

	-- insert ou update
	if	(r_c_disc_grad.mgse_sequ IS NULL) then

		t_mgse_cred_ins(l_contador_ins) := r_c_disc_grad.mgse_cred;
        t_mgse_taul_ins(l_contador_ins) := r_c_disc_grad.mgse_taul;
        t_mgse_mcur_ins(l_contador_ins) := r_c_disc_grad.mgse_mcur;
        t_mgse_mgcu_ins(l_contador_ins) := l_mgcu_sequ;
        t_mgse_orde_ins(l_contador_ins) := NVL(l_mgse_orde, 1);
        t_mgse_mtus_ins(l_contador_ins) := r_c_disc_grad.mgse_mtus;
        t_mgse_vdis_ins(l_contador_ins) := r_c_disc_grad.mgse_vdis;

        l_contador_ins := l_contador_ins + 1;
	else

        t_mgse_sequ_upd(l_contador_upd) := r_c_disc_grad.mgse_sequ;
        t_mgse_cred_upd(l_contador_upd) := r_c_disc_grad.mgse_cred;
        t_mgse_taul_upd(l_contador_upd) := r_c_disc_grad.mgse_taul;
        t_mgse_mcur_upd(l_contador_upd) := r_c_disc_grad.mgse_mcur;
        t_mgse_mgcu_upd(l_contador_upd) := l_mgcu_sequ;
        t_mgse_orde_upd(l_contador_upd) := NVL(l_mgse_orde, 1);

        l_contador_upd := l_contador_upd + 1;
	end if;

    -- verifica se atingiu a quantidade de registros por transação
    if  (l_contador_trans >= pkg_util.c_limit_trans) then

        pkg_mgr_imp_producao_aux.p_update_tabe_grade_semestre(  t_mgse_sequ_upd, t_mgse_cred_upd, t_mgse_taul_upd
                                                              , t_mgse_mcur_upd, t_mgse_mgcu_upd, t_mgse_orde_upd
                                                              , l_contador_upd);

        pkg_mgr_imp_producao_aux.p_insert_tabe_grade_semestre(  p_mver_sequ, t_mgse_cred_ins, t_mgse_taul_ins
                                                              , t_mgse_mcur_ins, t_mgse_mgcu_ins, t_mgse_orde_ins
                                                              , t_mgse_mtus_ins, t_mgse_vdis_ins, l_contador_ins);

        l_contador_trans := 1;
    else
        l_contador_trans := l_contador_trans + 1;
    end if;
end loop;

pkg_mgr_imp_producao_aux.p_update_tabe_grade_semestre(  t_mgse_sequ_upd, t_mgse_cred_upd, t_mgse_taul_upd
                                                      , t_mgse_mcur_upd, t_mgse_mgcu_upd, t_mgse_orde_upd
                                                      , l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabe_grade_semestre(  p_mver_sequ, t_mgse_cred_ins, t_mgse_taul_ins
                                                      , t_mgse_mcur_ins, t_mgse_mgcu_ins, t_mgse_orde_ins
                                                      , t_mgse_mtus_ins, t_mgse_vdis_ins, l_contador_ins);

-- atualiza os vínculos com a grade_semestre
pkg_mgr_imp_producao_aux.p_vinc_mgse_grade_semestre(    p_migr_sequ);

end p_importa_grade_semestre;

procedure p_importa_pessoa_professor(  p_migr_sequ     mgr_migracao.migr_sequ%type
                                     , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- tabelas para update
t_mpes_sequ_upd     pkg_util.tb_number;
t_mpes_nome_upd     pkg_util.tb_varchar2_150;
t_mpes_sexo_upd     pkg_util.tb_varchar2_1;
t_mpes_dnas_upd     pkg_util.tb_date;
t_mpes_cidd_upd     pkg_util.tb_number;
t_mpes_bair_upd     pkg_util.tb_varchar2_150;
t_mpes_ende_upd     pkg_util.tb_varchar2_150;
t_mpes_nume_upd     pkg_util.tb_varchar2_50;
t_mpes_comp_upd     pkg_util.tb_varchar2_50;
t_mpes_fone_upd     pkg_util.tb_varchar2_50;
t_mpes_celu_upd     pkg_util.tb_varchar2_50;
t_mpes_mail_upd     pkg_util.tb_varchar2_150;
t_mpes_pcpf_upd     pkg_util.tb_varchar2_50;
t_mpes_esta_upd     pkg_util.tb_varchar2_5;
t_mpes_npai_upd     pkg_util.tb_varchar2_150;
t_mpes_nmae_upd     pkg_util.tb_varchar2_150;
t_mpes_natu_upd     pkg_util.tb_varchar2_150;
t_mpes_iden_upd     pkg_util.tb_varchar2_50;
t_mpes_ideo_upd     pkg_util.tb_varchar2_50;
t_mpes_titu_upd     pkg_util.tb_varchar2_50;
t_mpes_tizo_upd     pkg_util.tb_number;
t_mpes_tise_upd     pkg_util.tb_number;
t_mpes_tiuf_upd     pkg_util.tb_varchar2_5;
t_mpes_croe_upd     pkg_util.tb_varchar2_50;
t_mpes_cres_upd     pkg_util.tb_varchar2_50;
t_mpes_fonc_upd     pkg_util.tb_varchar2_50;
t_mpes_naci_upd     pkg_util.tb_varchar2_1;
t_mpes_ance_upd     pkg_util.tb_number;
t_mpes_eciv_upd     pkg_util.tb_varchar2_1;
t_mpes_gins_upd     pkg_util.tb_varchar2_5;
t_mpes_tipo_upd     pkg_util.tb_varchar2_5;
t_mpes_ntuf_upd     pkg_util.tb_varchar2_5;
t_mpes_tdef_upd     pkg_util.tb_varchar2_5;
t_mpes_pspc_upd     pkg_util.tb_varchar2_1;
t_mpes_cnat_upd     pkg_util.tb_number;
t_mpes_cora_upd     pkg_util.tb_varchar2_5;
t_mpes_pcep_upd     pkg_util.tb_varchar2_10;
t_mpes_cmai_upd     pkg_util.tb_varchar2_1;
t_mpes_cosr_upd     pkg_util.tb_varchar2_150;
t_mpes_text_upd     pkg_util.tb_varchar2_4000;

-- tabelas para insert
t_mpes_nome_ins     pkg_util.tb_varchar2_150;
t_mpes_sexo_ins     pkg_util.tb_varchar2_1;
t_mpes_dnas_ins     pkg_util.tb_date;
t_mpes_cidd_ins     pkg_util.tb_number;
t_mpes_bair_ins     pkg_util.tb_varchar2_150;
t_mpes_ende_ins     pkg_util.tb_varchar2_150;
t_mpes_nume_ins     pkg_util.tb_varchar2_50;
t_mpes_comp_ins     pkg_util.tb_varchar2_50;
t_mpes_fone_ins     pkg_util.tb_varchar2_50;
t_mpes_celu_ins     pkg_util.tb_varchar2_50;
t_mpes_mail_ins     pkg_util.tb_varchar2_150;
t_mpes_pcpf_ins     pkg_util.tb_varchar2_50;
t_mpes_esta_ins     pkg_util.tb_varchar2_5;
t_mpes_npai_ins     pkg_util.tb_varchar2_150;
t_mpes_nmae_ins     pkg_util.tb_varchar2_150;
t_mpes_natu_ins     pkg_util.tb_varchar2_150;
t_mpes_iden_ins     pkg_util.tb_varchar2_50;
t_mpes_ideo_ins     pkg_util.tb_varchar2_50;
t_mpes_titu_ins     pkg_util.tb_varchar2_50;
t_mpes_tizo_ins     pkg_util.tb_number;
t_mpes_tise_ins     pkg_util.tb_number;
t_mpes_tiuf_ins     pkg_util.tb_varchar2_5;
t_mpes_croe_ins     pkg_util.tb_varchar2_50;
t_mpes_cres_ins     pkg_util.tb_varchar2_50;
t_mpes_fonc_ins     pkg_util.tb_varchar2_50;
t_mpes_naci_ins     pkg_util.tb_varchar2_1;
t_mpes_ance_ins     pkg_util.tb_number;
t_mpes_eciv_ins     pkg_util.tb_varchar2_1;
t_mpes_gins_ins     pkg_util.tb_varchar2_5;
t_mpes_tipo_ins     pkg_util.tb_varchar2_5;
t_mpes_ntuf_ins     pkg_util.tb_varchar2_5;
t_mpes_tdef_ins     pkg_util.tb_varchar2_5;
t_mpes_pspc_ins     pkg_util.tb_varchar2_1;
t_mpes_cnat_ins     pkg_util.tb_number;
t_mpes_cora_ins     pkg_util.tb_varchar2_5;
t_mpes_pcep_ins     pkg_util.tb_varchar2_10;
t_mpes_cmai_ins     pkg_util.tb_varchar2_1;
t_mpes_chav_ins     pkg_util.tb_varchar2_150;
t_mpes_cosr_ins     pkg_util.tb_varchar2_150;
t_mpes_text_ins     pkg_util.tb_varchar2_4000;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

-- outras variáveis
l_mpes_eciv         mgr_pessoa.mpes_eciv%type;
l_mpes_gins         mgr_pessoa.mpes_gins%type;

-- variável que controla quando trata-se de um novo registro
l_ult_mpes_pcpf     mgr_pessoa.mpes_pcpf%type;

cursor c_pess(  pc_migr_sequ    mgr_migracao.migr_sequ%type) is
    SELECT f.mpes_pcpf mpes_chav
         , pkg_formata_valida.f_formata_nome_novo(a.prfnome) mpes_nome
         , a.prfsexo mpes_sexo
         , a.prfdatanasc mpes_dnas
         , (SELECT MAX(x.mcid_sequ)
              FROM mgr_cidade x
             WHERE x.mcid_chav = TO_CHAR(a.cidcod)
               AND x.mcid_atua = 'S') mpes_cidd
         , UPPER(TRIM(SUBSTR(a.prfbairro, 1, 60))) mpes_bair
         , UPPER(TRIM(SUBSTR(a.prfendereco, 1, 60))) mpes_ende
         , null mpes_nume
         , null mpes_comp
         , a.prftelefone mpes_fone
         , a.prfcelular mpes_celu
         , NVL(a.prftelefone2, a.prftelefone3) mpes_fonc
         , LOWER(TRIM(a.prfemail)) mpes_mail
         , f.mpes_pcpf
         , a.prfuf mpes_esta
         , SUBSTR(a.prfnomepai, 1, 60) mpes_npai
         , SUBSTR(a.prfnomemae, 1, 60) mpes_nmae
         , a.prfcidadenasc || ' - ' || a.prfufnasc mpes_natu
         , SUBSTR(a.prfrg, 1, 20) mpes_iden
         , UPPER(TRIM(SUBSTR(a.prfexprg, 1, 20))) mpes_ideo
         , SUBSTR(a.prftituloeleitor, 1, 12) mpes_titu
         , SO_NUMERO(a.prfzonaeleitoral) mpes_tizo
         , SO_NUMERO(a.prfsecaoeleitoral) mpes_tise
         , a.prfuftitulo mpes_tiuf
         , SUBSTR(a.prfcertreservista, 1, 15) mpes_cres
         , SUBSTR(a.prfrm || ' ' || a.prfcsm, 1, 15) mpes_croe
         , '1' mpes_naci
         , null mpes_ance
         , a.prfestadocivil mpes_eciv
         , NVL(a.prftitulacaofolha, a.prftitulacaocursando) mpes_gins
         , a.prfufnasc mpes_ntuf
         , null mpes_pspc
         , (SELECT MAX(x.mcid_sequ)
              FROM mgr_cidade x
             WHERE x.mcid_chav = TO_CHAR(a.prfcidcodnasc)
               AND x.mcid_atua = 'S') mpes_cnat
         , null mpes_cora
         , SUBSTR(SO_NUMEROC(a.prfcep), 1, 8) mpes_pcep
         , (SELECT MAX(y.mpes_sequ)
              FROM mgr_pessoa y
             WHERE y.mpes_chav = f.mpes_pcpf) mpes_sequ
         , COMPARA_STRING(a.prfnome) nom_compara
         , null mpes_text
      FROM oli_professo a
         , oli_professo_temp f
     WHERE EXISTS( SELECT 1
                     FROM oli_discprof b
                        , mgr_turma_semestre c
                        , mgr_grade_semestre d
                        , mgr_versao e
                    WHERE b.prfcod = a.prfcod
					  AND b.dmpsituacao != 'C'
                      AND c.mtus_turm = b.tmacod
                      AND d.mgse_mtus = c.mtus_sequ
                      AND e.mver_sequ = d.mgse_mver
                      AND e.mver_migr = pc_migr_sequ)
       AND f.prfcod = a.prfcod
     ORDER BY a.prfcpf, a.prfcod DESC;

begin
-- só faz algo caso tenha sido passada a versão
if  (p_mver_sequ is not null) then

    -- incializa as variáveis
    pkg_mgr_imp_producao_aux.p_update_tabela_pessoa(  t_mpes_sequ_upd, t_mpes_nome_upd, t_mpes_sexo_upd
                                                    , t_mpes_dnas_upd, t_mpes_cidd_upd, t_mpes_bair_upd
                                                    , t_mpes_ende_upd, t_mpes_nume_upd, t_mpes_comp_upd
                                                    , t_mpes_fone_upd, t_mpes_celu_upd, t_mpes_mail_upd
                                                    , t_mpes_pcpf_upd, t_mpes_esta_upd, t_mpes_npai_upd
                                                    , t_mpes_nmae_upd, t_mpes_natu_upd, t_mpes_iden_upd
                                                    , t_mpes_ideo_upd, t_mpes_titu_upd, t_mpes_tizo_upd
                                                    , t_mpes_tise_upd, t_mpes_tiuf_upd, t_mpes_croe_upd
                                                    , t_mpes_cres_upd, t_mpes_fonc_upd, t_mpes_naci_upd
                                                    , t_mpes_ance_upd, t_mpes_eciv_upd, t_mpes_gins_upd
                                                    , t_mpes_tipo_upd, t_mpes_ntuf_upd, t_mpes_tdef_upd
                                                    , t_mpes_pspc_upd, t_mpes_cnat_upd, t_mpes_cora_upd
                                                    , t_mpes_pcep_upd, t_mpes_cmai_upd, t_mpes_cosr_upd
                                                    , t_mpes_text_upd, l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_pessoa(  p_mver_sequ, t_mpes_nome_ins, t_mpes_sexo_ins
                                                    , t_mpes_dnas_ins, t_mpes_cidd_ins, t_mpes_bair_ins
                                                    , t_mpes_ende_ins, t_mpes_nume_ins, t_mpes_comp_ins
                                                    , t_mpes_fone_ins, t_mpes_celu_ins, t_mpes_mail_ins
                                                    , t_mpes_pcpf_ins, t_mpes_esta_ins, t_mpes_npai_ins
                                                    , t_mpes_nmae_ins, t_mpes_natu_ins, t_mpes_iden_ins
                                                    , t_mpes_ideo_ins, t_mpes_titu_ins, t_mpes_tizo_ins
                                                    , t_mpes_tise_ins, t_mpes_tiuf_ins, t_mpes_croe_ins
                                                    , t_mpes_cres_ins, t_mpes_fonc_ins, t_mpes_naci_ins
                                                    , t_mpes_ance_ins, t_mpes_eciv_ins, t_mpes_gins_ins
                                                    , t_mpes_tipo_ins, t_mpes_ntuf_ins, t_mpes_tdef_ins
                                                    , t_mpes_pspc_ins, t_mpes_cnat_ins, t_mpes_cora_ins
                                                    , t_mpes_pcep_ins, t_mpes_cmai_ins, t_mpes_chav_ins
                                                    , t_mpes_cosr_ins, t_mpes_text_ins, l_contador_ins);

    -- inicia o contador
    l_contador_trans := 1;
    
    for r_c_pess in c_pess(p_migr_sequ) loop

        -- limpa as variáveis
        l_mpes_gins := null;
        l_mpes_eciv := null;

        -- Estado civil
        if  (r_c_pess.mpes_eciv is not null) then

            case (r_c_pess.mpes_eciv)
                -- C - Casado
                when 'C' then l_mpes_eciv := '2';
                -- D - Divorciado
                when 'D' then l_mpes_eciv := '3';
                -- E - Desquitado 
                when 'E' then l_mpes_eciv := '4';
                -- V - Viuvo
                when 'V' then l_mpes_eciv := '5';
                -- Todo o resto é solteiro
                else l_mpes_eciv := '1';
            end case;
        end if;

        -- Só altera a escolaridade se a mesma está informada
        if  (r_c_pess.mpes_gins is not null) then

            case (r_c_pess.mpes_gins)

                -- A - Superior Completo
                when 'A' then l_mpes_gins := '20';

                -- B - Aperfeiçoamento - Especialista
                when 'B' then l_mpes_gins := '22';

                -- C - Especialização
                when 'C' then l_mpes_gins := '22';

                -- D - Mestrado Incompleto
                when 'D' then l_mpes_gins := '24';

                -- E - Mestrado Completo
                when 'E' then l_mpes_gins := '26';

                -- F - Doutorado Incompleto
                when 'F' then l_mpes_gins := '28';

                -- G - Doutorado Completo
                when 'G' then l_mpes_gins := '30';

                -- H - Pós-Doutorado Incompleto - Doutorado
                when 'H' then l_mpes_gins := '30';

                -- I - Pós-Doutorado Completo - Doutorado
                when 'I' then l_mpes_gins := '30';

                else l_mpes_gins := null;
            end case;
        end if;

        if  (nvl(r_c_pess.mpes_pcpf, 'Y') != NVL(l_ult_mpes_pcpf, 'X')) then

            -- verifica se atingiu a quantidade de registros por transação
            if  (l_contador_trans >= pkg_util.c_limit_trans) then

                -- atualiza os registro e devolve as variáveis reinicializadas
                pkg_mgr_imp_producao_aux.p_update_tabela_pessoa(  t_mpes_sequ_upd, t_mpes_nome_upd, t_mpes_sexo_upd
                                                                , t_mpes_dnas_upd, t_mpes_cidd_upd, t_mpes_bair_upd
                                                                , t_mpes_ende_upd, t_mpes_nume_upd, t_mpes_comp_upd
                                                                , t_mpes_fone_upd, t_mpes_celu_upd, t_mpes_mail_upd
                                                                , t_mpes_pcpf_upd, t_mpes_esta_upd, t_mpes_npai_upd
                                                                , t_mpes_nmae_upd, t_mpes_natu_upd, t_mpes_iden_upd
                                                                , t_mpes_ideo_upd, t_mpes_titu_upd, t_mpes_tizo_upd
                                                                , t_mpes_tise_upd, t_mpes_tiuf_upd, t_mpes_croe_upd
                                                                , t_mpes_cres_upd, t_mpes_fonc_upd, t_mpes_naci_upd
                                                                , t_mpes_ance_upd, t_mpes_eciv_upd, t_mpes_gins_upd
                                                                , t_mpes_tipo_upd, t_mpes_ntuf_upd, t_mpes_tdef_upd
                                                                , t_mpes_pspc_upd, t_mpes_cnat_upd, t_mpes_cora_upd
                                                                , t_mpes_pcep_upd, t_mpes_cmai_upd, t_mpes_cosr_upd
                                                                , t_mpes_text_upd, l_contador_upd);

                -- insere os registro e devolve as variáveis reinicializadas
                pkg_mgr_imp_producao_aux.p_insert_tabela_pessoa(  p_mver_sequ, t_mpes_nome_ins, t_mpes_sexo_ins
                                                                , t_mpes_dnas_ins, t_mpes_cidd_ins, t_mpes_bair_ins
                                                                , t_mpes_ende_ins, t_mpes_nume_ins, t_mpes_comp_ins
                                                                , t_mpes_fone_ins, t_mpes_celu_ins, t_mpes_mail_ins
                                                                , t_mpes_pcpf_ins, t_mpes_esta_ins, t_mpes_npai_ins
                                                                , t_mpes_nmae_ins, t_mpes_natu_ins, t_mpes_iden_ins
                                                                , t_mpes_ideo_ins, t_mpes_titu_ins, t_mpes_tizo_ins
                                                                , t_mpes_tise_ins, t_mpes_tiuf_ins, t_mpes_croe_ins
                                                                , t_mpes_cres_ins, t_mpes_fonc_ins, t_mpes_naci_ins
                                                                , t_mpes_ance_ins, t_mpes_eciv_ins, t_mpes_gins_ins
                                                                , t_mpes_tipo_ins, t_mpes_ntuf_ins, t_mpes_tdef_ins
                                                                , t_mpes_pspc_ins, t_mpes_cnat_ins, t_mpes_cora_ins
                                                                , t_mpes_pcep_ins, t_mpes_cmai_ins, t_mpes_chav_ins
                                                                , t_mpes_cosr_ins, t_mpes_text_ins, l_contador_ins);

                l_contador_trans := 1;
            else
                l_contador_trans := l_contador_trans + 1;
            end if;
        end if;

        -- se identificou um registro na mgr_pessoa então é atualização
        if  (r_c_pess.mpes_sequ is not null) then

            -- garante que o cpf não é o mesmo do anterior, isso para não gerarmos registros duplicados 
            -- na mgr_pessoa por existir mais de um aluno para a mesma pessoa
            -- quando for igual apenas vamos alimentar informações que não vieram no registro mais atual, 
            -- isso o order by feito no cursor irá nos garantir pois ele trará sempre o último aluno da tabela oli_alunos
            if  (nvl(r_c_pess.mpes_pcpf, 'Y') != NVL(l_ult_mpes_pcpf, 'X')) then

                l_contador_upd := l_contador_upd + 1;

                t_mpes_sequ_upd(l_contador_upd) := r_c_pess.mpes_sequ;
                t_mpes_nome_upd(l_contador_upd) := r_c_pess.mpes_nome;
                t_mpes_sexo_upd(l_contador_upd) := r_c_pess.mpes_sexo;
                t_mpes_dnas_upd(l_contador_upd) := r_c_pess.mpes_dnas;
                t_mpes_cidd_upd(l_contador_upd) := r_c_pess.mpes_cidd;
                t_mpes_bair_upd(l_contador_upd) := r_c_pess.mpes_bair;
                t_mpes_ende_upd(l_contador_upd) := r_c_pess.mpes_ende;
                t_mpes_nume_upd(l_contador_upd) := r_c_pess.mpes_nume;
                t_mpes_comp_upd(l_contador_upd) := r_c_pess.mpes_comp;
                t_mpes_fone_upd(l_contador_upd) := r_c_pess.mpes_fone;
                t_mpes_celu_upd(l_contador_upd) := r_c_pess.mpes_celu;
                t_mpes_mail_upd(l_contador_upd) := r_c_pess.mpes_mail;
                t_mpes_pcpf_upd(l_contador_upd) := r_c_pess.mpes_pcpf;
                t_mpes_esta_upd(l_contador_upd) := r_c_pess.mpes_esta;
                t_mpes_npai_upd(l_contador_upd) := r_c_pess.mpes_npai;
                t_mpes_nmae_upd(l_contador_upd) := r_c_pess.mpes_nmae;
                t_mpes_natu_upd(l_contador_upd) := r_c_pess.mpes_natu;
                t_mpes_iden_upd(l_contador_upd) := r_c_pess.mpes_iden;
                t_mpes_ideo_upd(l_contador_upd) := r_c_pess.mpes_ideo;
                t_mpes_titu_upd(l_contador_upd) := r_c_pess.mpes_titu;
                t_mpes_tizo_upd(l_contador_upd) := r_c_pess.mpes_tizo;
                t_mpes_tise_upd(l_contador_upd) := r_c_pess.mpes_tise;
                t_mpes_tiuf_upd(l_contador_upd) := r_c_pess.mpes_tiuf;
                t_mpes_croe_upd(l_contador_upd) := r_c_pess.mpes_croe;
                t_mpes_cres_upd(l_contador_upd) := r_c_pess.mpes_cres;
                t_mpes_fonc_upd(l_contador_upd) := r_c_pess.mpes_fonc;
                t_mpes_naci_upd(l_contador_upd) := r_c_pess.mpes_naci;
                t_mpes_ance_upd(l_contador_upd) := r_c_pess.mpes_ance;
                t_mpes_eciv_upd(l_contador_upd) := l_mpes_eciv;
                t_mpes_gins_upd(l_contador_upd) := l_mpes_gins;
                t_mpes_tipo_upd(l_contador_upd) := 'F';
                t_mpes_ntuf_upd(l_contador_upd) := r_c_pess.mpes_ntuf;
                t_mpes_tdef_upd(l_contador_upd) := null;
                t_mpes_pspc_upd(l_contador_upd) := r_c_pess.mpes_pspc;
                t_mpes_cnat_upd(l_contador_upd) := r_c_pess.mpes_cnat;
                t_mpes_cora_upd(l_contador_upd) := r_c_pess.mpes_cora;
                t_mpes_pcep_upd(l_contador_upd) := r_c_pess.mpes_pcep;
                t_mpes_cmai_upd(l_contador_upd) := 'N';
                t_mpes_cosr_upd(l_contador_upd) := r_c_pess.nom_compara;
                t_mpes_text_upd(l_contador_upd) := r_c_pess.mpes_text;

            else

                t_mpes_sequ_upd(l_contador_upd) := NVL(t_mpes_sequ_upd(l_contador_upd), r_c_pess.mpes_sequ);
                t_mpes_nome_upd(l_contador_upd) := NVL(t_mpes_nome_upd(l_contador_upd), r_c_pess.mpes_nome);
                t_mpes_sexo_upd(l_contador_upd) := NVL(t_mpes_sexo_upd(l_contador_upd), r_c_pess.mpes_sexo);
                t_mpes_dnas_upd(l_contador_upd) := NVL(t_mpes_dnas_upd(l_contador_upd), r_c_pess.mpes_dnas);
                t_mpes_cidd_upd(l_contador_upd) := NVL(t_mpes_cidd_upd(l_contador_upd), r_c_pess.mpes_cidd);
                t_mpes_bair_upd(l_contador_upd) := NVL(t_mpes_bair_upd(l_contador_upd), r_c_pess.mpes_bair);
                t_mpes_ende_upd(l_contador_upd) := NVL(t_mpes_ende_upd(l_contador_upd), r_c_pess.mpes_ende);
                t_mpes_nume_upd(l_contador_upd) := NVL(t_mpes_nume_upd(l_contador_upd), r_c_pess.mpes_nume);
                t_mpes_comp_upd(l_contador_upd) := NVL(t_mpes_comp_upd(l_contador_upd), r_c_pess.mpes_comp);
                t_mpes_fone_upd(l_contador_upd) := NVL(t_mpes_fone_upd(l_contador_upd), r_c_pess.mpes_fone);
                t_mpes_celu_upd(l_contador_upd) := NVL(t_mpes_celu_upd(l_contador_upd), r_c_pess.mpes_celu);
                t_mpes_mail_upd(l_contador_upd) := NVL(t_mpes_mail_upd(l_contador_upd), r_c_pess.mpes_mail);
                t_mpes_pcpf_upd(l_contador_upd) := NVL(t_mpes_pcpf_upd(l_contador_upd), r_c_pess.mpes_pcpf);
                t_mpes_esta_upd(l_contador_upd) := NVL(t_mpes_esta_upd(l_contador_upd), r_c_pess.mpes_esta);
                t_mpes_npai_upd(l_contador_upd) := NVL(t_mpes_npai_upd(l_contador_upd), r_c_pess.mpes_npai);
                t_mpes_nmae_upd(l_contador_upd) := NVL(t_mpes_nmae_upd(l_contador_upd), r_c_pess.mpes_nmae);
                t_mpes_natu_upd(l_contador_upd) := NVL(t_mpes_natu_upd(l_contador_upd), r_c_pess.mpes_natu);
                t_mpes_iden_upd(l_contador_upd) := NVL(t_mpes_iden_upd(l_contador_upd), r_c_pess.mpes_iden);
                t_mpes_ideo_upd(l_contador_upd) := NVL(t_mpes_ideo_upd(l_contador_upd), r_c_pess.mpes_ideo);
                t_mpes_titu_upd(l_contador_upd) := NVL(t_mpes_titu_upd(l_contador_upd), r_c_pess.mpes_titu);
                t_mpes_tizo_upd(l_contador_upd) := NVL(t_mpes_tizo_upd(l_contador_upd), r_c_pess.mpes_tizo);
                t_mpes_tise_upd(l_contador_upd) := NVL(t_mpes_tise_upd(l_contador_upd), r_c_pess.mpes_tise);
                t_mpes_tiuf_upd(l_contador_upd) := NVL(t_mpes_tiuf_upd(l_contador_upd), r_c_pess.mpes_tiuf);
                t_mpes_croe_upd(l_contador_upd) := NVL(t_mpes_croe_upd(l_contador_upd), r_c_pess.mpes_croe);
                t_mpes_cres_upd(l_contador_upd) := NVL(t_mpes_cres_upd(l_contador_upd), r_c_pess.mpes_cres);
                t_mpes_fonc_upd(l_contador_upd) := NVL(t_mpes_fonc_upd(l_contador_upd), r_c_pess.mpes_fonc);
                t_mpes_naci_upd(l_contador_upd) := NVL(t_mpes_naci_upd(l_contador_upd), r_c_pess.mpes_naci);
                t_mpes_ance_upd(l_contador_upd) := NVL(t_mpes_ance_upd(l_contador_upd), r_c_pess.mpes_ance);
                t_mpes_eciv_upd(l_contador_upd) := NVL(t_mpes_eciv_upd(l_contador_upd), l_mpes_eciv);
                t_mpes_gins_upd(l_contador_upd) := NVL(t_mpes_gins_upd(l_contador_upd), l_mpes_gins);
                t_mpes_tipo_upd(l_contador_upd) := NVL(t_mpes_tipo_upd(l_contador_upd), 'F');
                t_mpes_ntuf_upd(l_contador_upd) := NVL(t_mpes_ntuf_upd(l_contador_upd), r_c_pess.mpes_ntuf);
                t_mpes_tdef_upd(l_contador_upd) := NVL(t_mpes_tdef_upd(l_contador_upd), null);
                t_mpes_pspc_upd(l_contador_upd) := NVL(t_mpes_pspc_upd(l_contador_upd), r_c_pess.mpes_pspc);
                t_mpes_cnat_upd(l_contador_upd) := NVL(t_mpes_cnat_upd(l_contador_upd), r_c_pess.mpes_cnat);
                t_mpes_cora_upd(l_contador_upd) := NVL(t_mpes_cora_upd(l_contador_upd), r_c_pess.mpes_cora);
                t_mpes_pcep_upd(l_contador_upd) := NVL(t_mpes_pcep_upd(l_contador_upd), r_c_pess.mpes_pcep);
                t_mpes_cmai_upd(l_contador_upd) := NVL(t_mpes_cmai_upd(l_contador_upd), 'N');
                t_mpes_cosr_upd(l_contador_upd) := NVL(t_mpes_cosr_upd(l_contador_upd), r_c_pess.nom_compara);
                t_mpes_text_upd(l_contador_upd) := NVL(t_mpes_text_upd(l_contador_upd), r_c_pess.mpes_text);

            end if;
        -- se não é inserção de novo registro
        else
            -- garante que o cpf não é o mesmo do anterior, isso para não gerarmos registros duplicados 
            -- na mgr_pessoa por existir mais de um aluno para a mesma pessoa
            -- quando for igual apenas vamos alimentar informações que não vieram no registro mais atual, 
            -- isso o order by feito no cursor irá nos garantir pois ele trará sempre o último aluno da tabela oli_alunos
            if  (nvl(r_c_pess.mpes_pcpf, 'Y') != NVL(l_ult_mpes_pcpf, 'X')) then

                l_contador_ins := l_contador_ins + 1;

                t_mpes_nome_ins(l_contador_ins) := r_c_pess.mpes_nome;
                t_mpes_sexo_ins(l_contador_ins) := r_c_pess.mpes_sexo;
                t_mpes_dnas_ins(l_contador_ins) := r_c_pess.mpes_dnas;
                t_mpes_cidd_ins(l_contador_ins) := r_c_pess.mpes_cidd;
                t_mpes_bair_ins(l_contador_ins) := r_c_pess.mpes_bair;
                t_mpes_ende_ins(l_contador_ins) := r_c_pess.mpes_ende;
                t_mpes_nume_ins(l_contador_ins) := r_c_pess.mpes_nume;
                t_mpes_comp_ins(l_contador_ins) := r_c_pess.mpes_comp;
                t_mpes_fone_ins(l_contador_ins) := r_c_pess.mpes_fone;
                t_mpes_celu_ins(l_contador_ins) := r_c_pess.mpes_celu;
                t_mpes_mail_ins(l_contador_ins) := r_c_pess.mpes_mail;
                t_mpes_pcpf_ins(l_contador_ins) := r_c_pess.mpes_pcpf;
                t_mpes_esta_ins(l_contador_ins) := r_c_pess.mpes_esta;
                t_mpes_npai_ins(l_contador_ins) := r_c_pess.mpes_npai;
                t_mpes_nmae_ins(l_contador_ins) := r_c_pess.mpes_nmae;
                t_mpes_natu_ins(l_contador_ins) := r_c_pess.mpes_natu;
                t_mpes_iden_ins(l_contador_ins) := r_c_pess.mpes_iden;
                t_mpes_ideo_ins(l_contador_ins) := r_c_pess.mpes_ideo;
                t_mpes_titu_ins(l_contador_ins) := r_c_pess.mpes_titu;
                t_mpes_tizo_ins(l_contador_ins) := r_c_pess.mpes_tizo;
                t_mpes_tise_ins(l_contador_ins) := r_c_pess.mpes_tise;
                t_mpes_tiuf_ins(l_contador_ins) := r_c_pess.mpes_tiuf;
                t_mpes_croe_ins(l_contador_ins) := r_c_pess.mpes_croe;
                t_mpes_cres_ins(l_contador_ins) := r_c_pess.mpes_cres;
                t_mpes_fonc_ins(l_contador_ins) := r_c_pess.mpes_fonc;
                t_mpes_naci_ins(l_contador_ins) := r_c_pess.mpes_naci;
                t_mpes_ance_ins(l_contador_ins) := r_c_pess.mpes_ance;
                t_mpes_eciv_ins(l_contador_ins) := l_mpes_eciv;
                t_mpes_gins_ins(l_contador_ins) := l_mpes_gins;
                t_mpes_tipo_ins(l_contador_ins) := 'F';
                t_mpes_ntuf_ins(l_contador_ins) := r_c_pess.mpes_ntuf;
                t_mpes_tdef_ins(l_contador_ins) := null;
                t_mpes_pspc_ins(l_contador_ins) := r_c_pess.mpes_pspc;
                t_mpes_cnat_ins(l_contador_ins) := r_c_pess.mpes_cnat;
                t_mpes_cora_ins(l_contador_ins) := r_c_pess.mpes_cora;
                t_mpes_pcep_ins(l_contador_ins) := r_c_pess.mpes_pcep;
                t_mpes_cmai_ins(l_contador_ins) := 'N';
                t_mpes_chav_ins(l_contador_ins) := r_c_pess.mpes_chav;
                t_mpes_cosr_ins(l_contador_ins) := r_c_pess.nom_compara;
                t_mpes_text_ins(l_contador_ins) := r_c_pess.mpes_text;
            else

                t_mpes_nome_ins(l_contador_ins) := NVL(t_mpes_nome_ins(l_contador_ins), r_c_pess.mpes_nome);
                t_mpes_sexo_ins(l_contador_ins) := NVL(t_mpes_sexo_ins(l_contador_ins), r_c_pess.mpes_sexo);
                t_mpes_dnas_ins(l_contador_ins) := NVL(t_mpes_dnas_ins(l_contador_ins), r_c_pess.mpes_dnas);
                t_mpes_cidd_ins(l_contador_ins) := NVL(t_mpes_cidd_ins(l_contador_ins), r_c_pess.mpes_cidd);
                t_mpes_bair_ins(l_contador_ins) := NVL(t_mpes_bair_ins(l_contador_ins), r_c_pess.mpes_bair);
                t_mpes_ende_ins(l_contador_ins) := NVL(t_mpes_ende_ins(l_contador_ins), r_c_pess.mpes_ende);
                t_mpes_nume_ins(l_contador_ins) := NVL(t_mpes_nume_ins(l_contador_ins), r_c_pess.mpes_nume);
                t_mpes_comp_ins(l_contador_ins) := NVL(t_mpes_comp_ins(l_contador_ins), r_c_pess.mpes_comp);
                t_mpes_fone_ins(l_contador_ins) := NVL(t_mpes_fone_ins(l_contador_ins), r_c_pess.mpes_fone);
                t_mpes_celu_ins(l_contador_ins) := NVL(t_mpes_celu_ins(l_contador_ins), r_c_pess.mpes_celu);
                t_mpes_mail_ins(l_contador_ins) := NVL(t_mpes_mail_ins(l_contador_ins), r_c_pess.mpes_mail);
                t_mpes_pcpf_ins(l_contador_ins) := NVL(t_mpes_pcpf_ins(l_contador_ins), r_c_pess.mpes_pcpf);
                t_mpes_esta_ins(l_contador_ins) := NVL(t_mpes_esta_ins(l_contador_ins), r_c_pess.mpes_esta);
                t_mpes_npai_ins(l_contador_ins) := NVL(t_mpes_npai_ins(l_contador_ins), r_c_pess.mpes_npai);
                t_mpes_nmae_ins(l_contador_ins) := NVL(t_mpes_nmae_ins(l_contador_ins), r_c_pess.mpes_nmae);
                t_mpes_natu_ins(l_contador_ins) := NVL(t_mpes_natu_ins(l_contador_ins), r_c_pess.mpes_natu);
                t_mpes_iden_ins(l_contador_ins) := NVL(t_mpes_iden_ins(l_contador_ins), r_c_pess.mpes_iden);
                t_mpes_ideo_ins(l_contador_ins) := NVL(t_mpes_ideo_ins(l_contador_ins), r_c_pess.mpes_ideo);
                t_mpes_titu_ins(l_contador_ins) := NVL(t_mpes_titu_ins(l_contador_ins), r_c_pess.mpes_titu);
                t_mpes_tizo_ins(l_contador_ins) := NVL(t_mpes_tizo_ins(l_contador_ins), r_c_pess.mpes_tizo);
                t_mpes_tise_ins(l_contador_ins) := NVL(t_mpes_tise_ins(l_contador_ins), r_c_pess.mpes_tise);
                t_mpes_tiuf_ins(l_contador_ins) := NVL(t_mpes_tiuf_ins(l_contador_ins), r_c_pess.mpes_tiuf);
                t_mpes_croe_ins(l_contador_ins) := NVL(t_mpes_croe_ins(l_contador_ins), r_c_pess.mpes_croe);
                t_mpes_cres_ins(l_contador_ins) := NVL(t_mpes_cres_ins(l_contador_ins), r_c_pess.mpes_cres);
                t_mpes_fonc_ins(l_contador_ins) := NVL(t_mpes_fonc_ins(l_contador_ins), r_c_pess.mpes_fonc);
                t_mpes_naci_ins(l_contador_ins) := NVL(t_mpes_naci_ins(l_contador_ins), r_c_pess.mpes_naci);
                t_mpes_ance_ins(l_contador_ins) := NVL(t_mpes_ance_ins(l_contador_ins), r_c_pess.mpes_ance);
                t_mpes_eciv_ins(l_contador_ins) := NVL(t_mpes_eciv_ins(l_contador_ins), l_mpes_eciv);
                t_mpes_gins_ins(l_contador_ins) := NVL(t_mpes_gins_ins(l_contador_ins), l_mpes_gins);
                t_mpes_tipo_ins(l_contador_ins) := NVL(t_mpes_tipo_ins(l_contador_ins), 'F');
                t_mpes_ntuf_ins(l_contador_ins) := NVL(t_mpes_ntuf_ins(l_contador_ins), r_c_pess.mpes_ntuf);
                t_mpes_tdef_ins(l_contador_ins) := NVL(t_mpes_tdef_ins(l_contador_ins), null);
                t_mpes_pspc_ins(l_contador_ins) := NVL(t_mpes_pspc_ins(l_contador_ins), r_c_pess.mpes_pspc);
                t_mpes_cnat_ins(l_contador_ins) := NVL(t_mpes_cnat_ins(l_contador_ins), r_c_pess.mpes_cnat);
                t_mpes_cora_ins(l_contador_ins) := NVL(t_mpes_cora_ins(l_contador_ins), r_c_pess.mpes_cora);
                t_mpes_pcep_ins(l_contador_ins) := NVL(t_mpes_pcep_ins(l_contador_ins), r_c_pess.mpes_pcep);
                t_mpes_cmai_ins(l_contador_ins) := NVL(t_mpes_cmai_ins(l_contador_ins), 'N');
                t_mpes_chav_ins(l_contador_ins) := NVL(t_mpes_chav_ins(l_contador_ins), r_c_pess.mpes_chav);
                t_mpes_cosr_ins(l_contador_ins) := NVL(t_mpes_cosr_ins(l_contador_ins), r_c_pess.nom_compara);
                t_mpes_text_ins(l_contador_ins) := NVL(t_mpes_text_ins(l_contador_ins), r_c_pess.mpes_text);
            end if;
        end if;

        l_ult_mpes_pcpf := r_c_pess.mpes_pcpf;
    end loop;

    -- caso dentro do loop não tenha chego à quantidade que precisa para fechar a transação
    -- então envia tudo que tiver para o update e insert
    pkg_mgr_imp_producao_aux.p_update_tabela_pessoa(  t_mpes_sequ_upd, t_mpes_nome_upd, t_mpes_sexo_upd
                                                    , t_mpes_dnas_upd, t_mpes_cidd_upd, t_mpes_bair_upd
                                                    , t_mpes_ende_upd, t_mpes_nume_upd, t_mpes_comp_upd
                                                    , t_mpes_fone_upd, t_mpes_celu_upd, t_mpes_mail_upd
                                                    , t_mpes_pcpf_upd, t_mpes_esta_upd, t_mpes_npai_upd
                                                    , t_mpes_nmae_upd, t_mpes_natu_upd, t_mpes_iden_upd
                                                    , t_mpes_ideo_upd, t_mpes_titu_upd, t_mpes_tizo_upd
                                                    , t_mpes_tise_upd, t_mpes_tiuf_upd, t_mpes_croe_upd
                                                    , t_mpes_cres_upd, t_mpes_fonc_upd, t_mpes_naci_upd
                                                    , t_mpes_ance_upd, t_mpes_eciv_upd, t_mpes_gins_upd
                                                    , t_mpes_tipo_upd, t_mpes_ntuf_upd, t_mpes_tdef_upd
                                                    , t_mpes_pspc_upd, t_mpes_cnat_upd, t_mpes_cora_upd
                                                    , t_mpes_pcep_upd, t_mpes_cmai_upd, t_mpes_cosr_upd
                                                    , t_mpes_text_upd, l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_pessoa(  p_mver_sequ, t_mpes_nome_ins, t_mpes_sexo_ins
                                                    , t_mpes_dnas_ins, t_mpes_cidd_ins, t_mpes_bair_ins
                                                    , t_mpes_ende_ins, t_mpes_nume_ins, t_mpes_comp_ins
                                                    , t_mpes_fone_ins, t_mpes_celu_ins, t_mpes_mail_ins
                                                    , t_mpes_pcpf_ins, t_mpes_esta_ins, t_mpes_npai_ins
                                                    , t_mpes_nmae_ins, t_mpes_natu_ins, t_mpes_iden_ins
                                                    , t_mpes_ideo_ins, t_mpes_titu_ins, t_mpes_tizo_ins
                                                    , t_mpes_tise_ins, t_mpes_tiuf_ins, t_mpes_croe_ins
                                                    , t_mpes_cres_ins, t_mpes_fonc_ins, t_mpes_naci_ins
                                                    , t_mpes_ance_ins, t_mpes_eciv_ins, t_mpes_gins_ins
                                                    , t_mpes_tipo_ins, t_mpes_ntuf_ins, t_mpes_tdef_ins
                                                    , t_mpes_pspc_ins, t_mpes_cnat_ins, t_mpes_cora_ins
                                                    , t_mpes_pcep_ins, t_mpes_cmai_ins, t_mpes_chav_ins
                                                    , t_mpes_cosr_ins, t_mpes_text_ins, l_contador_ins);

    pkg_mgr_imp_producao_aux.p_vincula_pessoa_mgr_pessoa(   p_migr_sequ);
end if;

end p_importa_pessoa_professor;

procedure p_importa_professor(  p_migr_sequ     mgr_migracao.migr_sequ%type
                              , p_mver_sequ     mgr_versao.mver_sequ%type) is

--tabelas utilizadas no update
t_mpro_sequ_upd     pkg_util.tb_number;
t_mpro_senh_upd     pkg_util.tb_varchar2_50;
t_mpro_tipo_upd     pkg_util.tb_varchar2_1;
t_mpro_abrv_upd     pkg_util.tb_varchar2_50;
t_mpro_obse_upd     pkg_util.tb_varchar2_4000;
t_mpro_tpag_upd     pkg_util.tb_varchar2_5;
t_mpro_libe_upd     pkg_util.tb_varchar2_5;
t_mpro_mpes_upd     pkg_util.tb_number;

-- tabelas utilizadas no insert
t_mpro_chav_ins     pkg_util.tb_varchar2_150;
t_mpro_senh_ins     pkg_util.tb_varchar2_50;
t_mpro_tipo_ins     pkg_util.tb_varchar2_1;
t_mpro_abrv_ins     pkg_util.tb_varchar2_50;
t_mpro_obse_ins     pkg_util.tb_varchar2_4000;
t_mpro_tpag_ins     pkg_util.tb_varchar2_5;
t_mpro_libe_ins     pkg_util.tb_varchar2_5;
t_mpro_mpes_ins     pkg_util.tb_number;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

cursor c_prof(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT TO_CHAR(c.prfcod) mpro_chav
         -- conforme solicitado pelo Cloves em 18/01/2016, retiramos os últimos dois digitos do CPF
         -- do professor para utilizar como senha, isto para que não fique o mesmo padrão da senha
         -- dos alunos
         , SUBSTR(a.mpes_pcpf, 1, 9) mpro_senh
         , 'P' mpro_tipo
         , NVL(SUBSTR(c.prfnomeguerra, 1, 20), pkg_formata_valida.f_abrevia_nome(c.prfnome, 20)) mpro_abrv
         , null mpro_obse
         , null mpro_tpag
         , 'S' mpro_libe
         , a.mpes_sequ mpro_mpes
         , (SELECT MAX(p.mpro_sequ)
              FROM mgr_professor p
             WHERE p.mpro_chav = TO_CHAR(c.prfcod)) mpro_sequ
      FROM mgr_pessoa a
         , oli_professo_temp b
         , oli_professo c
     WHERE a.mpes_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.mpes_mver)
       AND b.mpes_pcpf = a.mpes_pcpf
       AND c.prfcod = b.prfcod
       AND EXISTS( SELECT 1
                     FROM oli_discprof x
                        , mgr_turma_semestre y
                        , mgr_grade_semestre w
                    WHERE x.prfcod = b.prfcod
                      AND y.mtus_turm = x.tmacod
                      AND w.mgse_mtus = y.mtus_sequ);

begin

-- só faz algo quando a versão é passada
if  (p_mver_sequ is not null) then

    -- faz os updates iniciais na tabela mgr_turma_semestre necessários
    pkg_mgr_imp_producao_aux.p_update_inicio_professor(p_migr_sequ);

    -- incializa as variáveis
    pkg_mgr_imp_producao_aux.p_update_tabela_professor( t_mpro_sequ_upd, t_mpro_senh_upd, t_mpro_tipo_upd
                                                      , t_mpro_abrv_upd, t_mpro_obse_upd, t_mpro_tpag_upd
                                                      , t_mpro_libe_upd, t_mpro_mpes_upd, l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_professor( p_mver_sequ, t_mpro_chav_ins, t_mpro_senh_ins
                                                      , t_mpro_tipo_ins, t_mpro_abrv_ins, t_mpro_obse_ins
                                                      , t_mpro_tpag_ins, t_mpro_libe_ins, t_mpro_mpes_ins
                                                      , l_contador_ins);

    -- inicia o contador
    l_contador_trans := 1;

    for r_c_prof in c_prof(p_migr_sequ) loop

        -- se identificou um registro na mgr_aluno_turma então é atualização
        if (r_c_prof.mpro_sequ is not null) then

            -- alimenta as variáveis table utilizadas no update
            t_mpro_sequ_upd(l_contador_upd) := r_c_prof.mpro_sequ;
            t_mpro_senh_upd(l_contador_upd) := r_c_prof.mpro_senh;
            t_mpro_tipo_upd(l_contador_upd) := r_c_prof.mpro_tipo;
            t_mpro_abrv_upd(l_contador_upd) := r_c_prof.mpro_abrv;
            t_mpro_obse_upd(l_contador_upd) := r_c_prof.mpro_obse;
            t_mpro_tpag_upd(l_contador_upd) := r_c_prof.mpro_tpag;
            t_mpro_libe_upd(l_contador_upd) := r_c_prof.mpro_libe;
            t_mpro_mpes_upd(l_contador_upd) := r_c_prof.mpro_mpes;

            l_contador_upd := l_contador_upd + 1;

        -- se não é inserção de novo registro
        else

            -- alimenta as variáveis table utilizadas no insert
            t_mpro_chav_ins(l_contador_ins) := r_c_prof.mpro_chav;
            t_mpro_senh_ins(l_contador_ins) := r_c_prof.mpro_senh;
            t_mpro_tipo_ins(l_contador_ins) := r_c_prof.mpro_tipo;
            t_mpro_abrv_ins(l_contador_ins) := r_c_prof.mpro_abrv;
            t_mpro_obse_ins(l_contador_ins) := r_c_prof.mpro_obse;
            t_mpro_tpag_ins(l_contador_ins) := r_c_prof.mpro_tpag;
            t_mpro_libe_ins(l_contador_ins) := r_c_prof.mpro_libe;
            t_mpro_mpes_ins(l_contador_ins) := r_c_prof.mpro_mpes;

            l_contador_ins := l_contador_ins + 1;
        end if;

        -- verifica se atingiu a quantidade de registros por transação
        if  (l_contador_trans >= pkg_util.c_limit_trans) then

            -- atualiza os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_update_tabela_professor( t_mpro_sequ_upd, t_mpro_senh_upd, t_mpro_tipo_upd
                                                              , t_mpro_abrv_upd, t_mpro_obse_upd, t_mpro_tpag_upd
                                                              , t_mpro_libe_upd, t_mpro_mpes_upd, l_contador_upd);

            -- insere os registro e devolve as variáveis reinicializadas
            pkg_mgr_imp_producao_aux.p_insert_tabela_professor( p_mver_sequ, t_mpro_chav_ins, t_mpro_senh_ins
                                                              , t_mpro_tipo_ins, t_mpro_abrv_ins, t_mpro_obse_ins
                                                              , t_mpro_tpag_ins, t_mpro_libe_ins, t_mpro_mpes_ins
                                                              , l_contador_ins);

            l_contador_trans := 1;
        else
            l_contador_trans := l_contador_trans + 1;
        end if;
    end loop;
    
    -- caso dentro do loop não tenha chego à quantidade que precisa para fechar a transação
    -- então envia tudo que tiver para o update e insert
    pkg_mgr_imp_producao_aux.p_update_tabela_professor( t_mpro_sequ_upd, t_mpro_senh_upd, t_mpro_tipo_upd
                                                      , t_mpro_abrv_upd, t_mpro_obse_upd, t_mpro_tpag_upd
                                                      , t_mpro_libe_upd, t_mpro_mpes_upd, l_contador_upd);

    pkg_mgr_imp_producao_aux.p_insert_tabela_professor( p_mver_sequ, t_mpro_chav_ins, t_mpro_senh_ins
                                                      , t_mpro_tipo_ins, t_mpro_abrv_ins, t_mpro_obse_ins
                                                      , t_mpro_tpag_ins, t_mpro_libe_ins, t_mpro_mpes_ins
                                                      , l_contador_ins);

    pkg_mgr_imp_producao_aux.p_vincula_professor_mgr_prof(  p_migr_sequ);
end if;

end p_importa_professor;

procedure p_importa_matricula( p_migr_sequ	mgr_migracao.migr_sequ%type
							 , p_mver_sequ	mgr_versao.mver_sequ%type) is

-- tabelas utilizadas no update
t_mmat_sequ_upd     pkg_util.tb_number;
t_mmat_mtus_upd     pkg_util.tb_number;
t_mmat_medi_upd     pkg_util.tb_number;
t_mmat_situ_upd     pkg_util.tb_varchar2_5;
t_mmat_ppre_upd     pkg_util.tb_number;
t_mmat_asit_upd     pkg_util.tb_number;

-- tabelas utilizadas no insert
t_mmat_malu_ins     pkg_util.tb_number;
t_mmat_vdis_ins     pkg_util.tb_varchar2_10;
t_mmat_mtus_ins     pkg_util.tb_number;
t_mmat_medi_ins     pkg_util.tb_number;
t_mmat_situ_ins     pkg_util.tb_varchar2_5;
t_mmat_ppre_ins     pkg_util.tb_number;
t_mmat_asit_ins     pkg_util.tb_number;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;
l_seme_ini_imp_acad	semestre.seme_codi%type;

l_mmat_sequ	mgr_matricula.mmat_sequ%type;
l_mmat_situ mgr_matricula.mmat_situ%type;
l_mmat_ppre mgr_matricula.mmat_ppre%type;

cursor c_disc( pc_migr_sequ     	mgr_migracao.migr_sequ%type
			 , pc_seme_inic_acad	varchar2) is
	SELECT c.ohia_malu mmat_malu
		 , c.ohia_dgio mmat_vdis
		 , c.ohia_mtus mmat_mtus
		 , MAX(c.ohia_medi) mmat_medi
		 , MAX(c.ohia_asit) ohia_asit
		 , (SELECT MAX(mmat_sequ)
			  FROM mgr_matricula
			 WHERE mmat_malu = c.ohia_malu
			   AND mmat_vdis = c.ohia_dgio
			   AND mmat_mtus = c.ohia_mtus) mmat_sequ
	  FROM mgr_aluno a
	     , mgr_curso b
         , oli_historico_aluno c
	 WHERE a.malu_atua = 'S'
	   AND b.mcur_sequ = a.malu_mcur
	   AND EXISTS(  SELECT 1
					  FROM mgr_versao x
					 WHERE x.mver_migr = pc_migr_sequ
					   AND x.mver_sequ = a.malu_mver)
       AND c.ohia_alun = a.malu_chav
	   AND c.ohia_curs = b.mcur_chav
	   AND c.ohia_smed IN ('N', 'EC')
	   AND c.ohia_seme >= pc_seme_inic_acad
	   AND c.ohia_atua = 'S'
	   AND c.ohia_dgio IS NOT NULL
	   AND c.ohia_mtus IS NOT NULL
	   AND EXISTS(  SELECT 1
					  FROM mgr_versao x
					 WHERE x.mver_migr = pc_migr_sequ
					   AND x.mver_sequ = c.ohia_mver)
	 GROUP BY c.ohia_malu, c.ohia_dgio, c.ohia_mtus;

begin
-- atualiza o mmat_atu para N nos registros desta versão
pkg_mgr_imp_producao_aux.p_update_inicio_matricula(p_migr_sequ);

pkg_mgr_imp_producao_aux.p_update_tabela_matricula( t_mmat_sequ_upd, t_mmat_mtus_upd, t_mmat_medi_upd
												  , t_mmat_situ_upd, t_mmat_ppre_upd, t_mmat_asit_upd
                                                  , l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_matricula( p_mver_sequ, t_mmat_malu_ins, t_mmat_vdis_ins
                                                  , t_mmat_mtus_ins, t_mmat_medi_ins, t_mmat_situ_ins
                                                  , t_mmat_ppre_ins, t_mmat_asit_ins, l_contador_ins);

l_seme_ini_imp_acad := f_seme_ini_imp_academico;
l_contador_trans := 1;

-- retorna todas as disciplinas do aluno
for r_c_disc in c_disc( p_migr_sequ, l_seme_ini_imp_acad) loop

    -- verifica a situação do aluno
    case    (r_c_disc.ohia_asit)
        -- Aprovado
        when 8 then l_mmat_situ := 'APRO';
        -- reprovado por média e falta
        when 6 then l_mmat_situ := 'REPR';
        -- reprovado por média
        when 5 then l_mmat_situ := 'REPR';
        -- reprovado por falta
        when 4 then l_mmat_situ := 'RFRE';
        -- necessita fazer exame
        when 1 then l_mmat_situ := 'EXAM';
        -- Qualquer coisa diferente disto é nulo
        else l_mmat_situ := null;
    end case;
    
    -- se teve alguma disciplina que reprovou por frequencia
    -- joga 50% fixo
    if	(r_c_disc.ohia_asit IN (6, 4)) then
        l_mmat_ppre := 50;
    else
        l_mmat_ppre := null;
    end if;

    -- para decidir se vamos de insert ou update
    if	(r_c_disc.mmat_sequ IS NULL) then

        t_mmat_malu_ins(l_contador_ins) := r_c_disc.mmat_malu;
        t_mmat_vdis_ins(l_contador_ins) := r_c_disc.mmat_vdis;
        t_mmat_mtus_ins(l_contador_ins) := r_c_disc.mmat_mtus;
        t_mmat_medi_ins(l_contador_ins) := r_c_disc.mmat_medi;
        t_mmat_asit_ins(l_contador_ins) := r_c_disc.ohia_asit;
        t_mmat_situ_ins(l_contador_ins) := l_mmat_situ;
        t_mmat_ppre_ins(l_contador_ins) := l_mmat_ppre;

        l_contador_ins := l_contador_ins + 1;

    else

        t_mmat_sequ_upd(l_contador_upd) := r_c_disc.mmat_sequ;
        t_mmat_mtus_upd(l_contador_upd) := r_c_disc.mmat_mtus;
        t_mmat_medi_upd(l_contador_upd) := r_c_disc.mmat_medi;
        t_mmat_asit_upd(l_contador_upd) := r_c_disc.ohia_asit;
        t_mmat_situ_upd(l_contador_upd) := l_mmat_situ;
        t_mmat_ppre_upd(l_contador_upd) := l_mmat_ppre;

        l_contador_upd := l_contador_upd + 1;
    end if;

    -- verifica se atingiu a quantidade de registros por transação
    if  (l_contador_trans >= pkg_util.c_limit_trans) then

        -- atualiza os registro e devolve as variáveis reinicializadas
        pkg_mgr_imp_producao_aux.p_update_tabela_matricula( t_mmat_sequ_upd, t_mmat_mtus_upd, t_mmat_medi_upd
                                                          , t_mmat_situ_upd, t_mmat_ppre_upd, t_mmat_asit_upd
                                                          , l_contador_upd);

        pkg_mgr_imp_producao_aux.p_insert_tabela_matricula( p_mver_sequ, t_mmat_malu_ins, t_mmat_vdis_ins
                                                          , t_mmat_mtus_ins, t_mmat_medi_ins, t_mmat_situ_ins
                                                          , t_mmat_ppre_ins, t_mmat_asit_ins, l_contador_ins);

        l_contador_trans := 1;
    else
        l_contador_trans := l_contador_trans + 1;
    end if;
end loop;

pkg_mgr_imp_producao_aux.p_update_tabela_matricula( t_mmat_sequ_upd, t_mmat_mtus_upd, t_mmat_medi_upd
												  , t_mmat_situ_upd, t_mmat_ppre_upd, t_mmat_asit_upd
                                                  , l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_matricula( p_mver_sequ, t_mmat_malu_ins, t_mmat_vdis_ins
                                                  , t_mmat_mtus_ins, t_mmat_medi_ins, t_mmat_situ_ins
                                                  , t_mmat_ppre_ins, t_mmat_asit_ins, l_contador_ins);

-- vincula possíveis matrículas já existentes com o registro gerado
pkg_mgr_imp_producao_aux.p_vinc_mmat_matricula(p_migr_sequ);

end p_importa_matricula;

procedure p_importa_convalidacao( p_migr_sequ	mgr_migracao.migr_sequ%type
								, p_mver_sequ	mgr_versao.mver_sequ%type) is

-- tabelas utilizadas no insert
t_mavl_malu_ins     pkg_util.tb_number;
t_mavl_vdis_ins     pkg_util.tb_varchar2_10;
t_mavl_seme_ins     pkg_util.tb_varchar2_10;
t_mavl_cdis_ins     pkg_util.tb_varchar2_255;
t_mavl_capr_ins     pkg_util.tb_varchar2_50;
t_mavl_carg_ins     pkg_util.tb_number;
t_mavl_dcur_ins     pkg_util.tb_varchar2_255;
t_mavl_meci_ins     pkg_util.tb_number;
t_mavl_tipo_ins     pkg_util.tb_varchar2_5;
t_mavl_nota_ins     pkg_util.tb_number;
t_mavl_conc_ins     pkg_util.tb_varchar2_50;
t_mavl_semr_ins     pkg_util.tb_varchar2_10;

-- tabelas utilizadas no update
t_mavl_sequ_upd     pkg_util.tb_number;
t_mavl_seme_upd     pkg_util.tb_varchar2_10;
t_mavl_capr_upd     pkg_util.tb_varchar2_50;
t_mavl_carg_upd     pkg_util.tb_number;
t_mavl_dcur_upd     pkg_util.tb_varchar2_255;
t_mavl_meci_upd     pkg_util.tb_number;
t_mavl_tipo_upd     pkg_util.tb_varchar2_5;
t_mavl_nota_upd     pkg_util.tb_number;
t_mavl_conc_upd     pkg_util.tb_varchar2_50;
t_mavl_semr_upd     pkg_util.tb_varchar2_10;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

l_mavl_sequ     mgr_aluno_validacao.mavl_sequ%type;
l_mavl_nota     mgr_aluno_validacao.mavl_nota%type;
l_mavl_conc     mgr_aluno_validacao.mavl_conc%type;

cursor c_malu(pc_migr_sequ	mgr_migracao.migr_sequ%type) is
	SELECT DISTINCT a.malu_chav
         , b.mcur_chav
	  FROM mgr_aluno a
         , mgr_curso b
	 WHERE a.malu_atua = 'S'
       AND b.mcur_sequ = a.malu_mcur
	   AND EXISTS(  SELECT 1
					  FROM mgr_versao x
					 WHERE x.mver_migr = pc_migr_sequ
					   AND x.mver_sequ = a.malu_mver);

cursor c_vali( pc_migr_sequ     	mgr_migracao.migr_sequ%type
			 , pc_seme_inic_acad	varchar2
			 , pc_malu_chav			mgr_aluno.malu_chav%type
             , pc_mcur_chav         mgr_curso.mcur_chav%type) is
	SELECT DISTINCT 
		   ohia_malu mavl_malu
		 , ohia_dgio mavl_vdis
		 , ohiv_cdis mavl_cdis
		 , SUBSTR(MAX(ohia_seme), 1, 6) mavl_semr
		 , SUBSTR(MAX(ohiv_csem), 1, 6) mavl_seme
		 , MAX(ohiv_capr) mavl_capr
		 , MAX(ohiv_ccar) mavl_carg
		 , NVL(MAX(ohiv_ccur), 'Sem curso cadastrado no Olimpo') mavl_dcur
		 , NVL(MAX(ohiv_ccgi), 1) mavl_meci
		 , DECODE(MAX(ohia_smed), 'CC', 'C', 'N') mavl_tipo
		 , (SELECT MAX(mavl_sequ)
			  FROM mgr_aluno_validacao
			 WHERE mavl_malu = ohia_malu
			   AND mavl_vdis = ohia_dgio
			   AND mavl_cdis = ohiv_cdis) mavl_sequ
	  FROM oli_historico_aluno
		 , oli_historico_aluno_conv
	 WHERE ohia_atua = 'S'
	   AND ohia_seme >= pc_seme_inic_acad
	   AND ohia_alun = pc_malu_chav
       AND ohia_curs = pc_mcur_chav
	   AND ohia_smed IN ('AE', 'CC')
	   AND ohia_dgio IS NOT NULL
	   AND EXISTS (SELECT 1
					 FROM mgr_versao x
					WHERE x.mver_migr = pc_migr_sequ
					  AND x.mver_sequ = ohia_mver)
	   AND ohiv_ohia = ohia_sequ
     GROUP BY ohia_malu, ohia_dgio, ohiv_cdis
	 ORDER BY ohia_malu, ohia_dgio;

begin
-- atualiza o mmat_atu para N nos registros desta versão
pkg_mgr_imp_producao_aux.p_update_inicio_aluno_val(p_migr_sequ);

pkg_mgr_imp_producao_aux.p_update_tabela_aluno_vali(    t_mavl_sequ_upd, t_mavl_seme_upd, t_mavl_capr_upd
                                                      , t_mavl_carg_upd, t_mavl_dcur_upd, t_mavl_meci_upd
                                                      , t_mavl_tipo_upd, t_mavl_nota_upd, t_mavl_conc_upd
													  , t_mavl_semr_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_aluno_vali(    p_mver_sequ, t_mavl_malu_ins, t_mavl_vdis_ins
                                                      , t_mavl_seme_ins, t_mavl_cdis_ins, t_mavl_capr_ins
                                                      , t_mavl_carg_ins, t_mavl_dcur_ins, t_mavl_meci_ins
                                                      , t_mavl_tipo_ins, t_mavl_nota_ins, t_mavl_conc_ins
													  , t_mavl_semr_ins, l_contador_ins);

l_contador_trans := 1;

-- retorna todos os alunos
for r_c_malu in c_malu(p_migr_sequ) loop

    -- retorna todas as disciplinas do aluno
	for r_c_vali in c_vali( p_migr_sequ, f_seme_ini_imp_academico, r_c_malu.malu_chav
                          , r_c_malu.mcur_chav) loop
	
        if  (pkg_mgr_imp_producao_aux.mgr_is_number(r_c_vali.mavl_capr) = 'OK') then

            l_mavl_nota := TO_NUMBER(REPLACE(r_c_vali.mavl_capr, '.', ','));
            l_mavl_conc := null;
        else
            l_mavl_nota := null;
            l_mavl_conc := r_c_vali.mavl_capr;
        end if;

		-- para decidir se vamos de insert ou update
		if	(r_c_vali.mavl_sequ IS NULL) then
            
            t_mavl_malu_ins(l_contador_ins) := r_c_vali.mavl_malu;
            t_mavl_vdis_ins(l_contador_ins) := r_c_vali.mavl_vdis;
            t_mavl_seme_ins(l_contador_ins) := r_c_vali.mavl_seme;
            t_mavl_cdis_ins(l_contador_ins) := r_c_vali.mavl_cdis;
            t_mavl_capr_ins(l_contador_ins) := r_c_vali.mavl_capr;
            t_mavl_carg_ins(l_contador_ins) := r_c_vali.mavl_carg;
            t_mavl_dcur_ins(l_contador_ins) := r_c_vali.mavl_dcur;
            t_mavl_meci_ins(l_contador_ins) := r_c_vali.mavl_meci;
            t_mavl_tipo_ins(l_contador_ins) := r_c_vali.mavl_tipo;
            t_mavl_nota_ins(l_contador_ins) := l_mavl_nota;
            t_mavl_conc_ins(l_contador_ins) := l_mavl_conc;
			t_mavl_semr_ins(l_contador_ins) := r_c_vali.mavl_semr;

            l_contador_ins := l_contador_ins + 1;
		else
        
            t_mavl_sequ_upd(l_contador_upd) := r_c_vali.mavl_sequ;
            t_mavl_seme_upd(l_contador_upd) := r_c_vali.mavl_seme;
            t_mavl_capr_upd(l_contador_upd) := r_c_vali.mavl_capr;
            t_mavl_carg_upd(l_contador_upd) := r_c_vali.mavl_carg;
            t_mavl_dcur_upd(l_contador_upd) := r_c_vali.mavl_dcur;
            t_mavl_meci_upd(l_contador_upd) := r_c_vali.mavl_meci;
            t_mavl_tipo_upd(l_contador_upd) := r_c_vali.mavl_tipo;
            t_mavl_nota_upd(l_contador_upd) := l_mavl_nota;
            t_mavl_conc_upd(l_contador_upd) := l_mavl_conc;
			t_mavl_semr_upd(l_contador_upd) := r_c_vali.mavl_semr;

            l_contador_upd := l_contador_upd + 1;
		end if;

        -- verifica se atingiu a quantidade de registros por transação
        if  (l_contador_trans >= pkg_util.c_limit_trans) then

            pkg_mgr_imp_producao_aux.p_update_tabela_aluno_vali(    t_mavl_sequ_upd, t_mavl_seme_upd, t_mavl_capr_upd
                                                                  , t_mavl_carg_upd, t_mavl_dcur_upd, t_mavl_meci_upd
                                                                  , t_mavl_tipo_upd, t_mavl_nota_upd, t_mavl_conc_upd
																  , t_mavl_semr_upd, l_contador_upd);

            pkg_mgr_imp_producao_aux.p_insert_tabela_aluno_vali(    p_mver_sequ, t_mavl_malu_ins, t_mavl_vdis_ins
                                                                  , t_mavl_seme_ins, t_mavl_cdis_ins, t_mavl_capr_ins
                                                                  , t_mavl_carg_ins, t_mavl_dcur_ins, t_mavl_meci_ins
                                                                  , t_mavl_tipo_ins, t_mavl_nota_ins, t_mavl_conc_ins
                                                                  , t_mavl_semr_ins, l_contador_ins);

            l_contador_trans := 1;
        else
            l_contador_trans := l_contador_trans + 1;
        end if;		
	end loop;
end loop;

pkg_mgr_imp_producao_aux.p_update_tabela_aluno_vali(    t_mavl_sequ_upd, t_mavl_seme_upd, t_mavl_capr_upd
                                                      , t_mavl_carg_upd, t_mavl_dcur_upd, t_mavl_meci_upd
                                                      , t_mavl_tipo_upd, t_mavl_nota_upd, t_mavl_conc_upd
                                                      , t_mavl_semr_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_aluno_vali(    p_mver_sequ, t_mavl_malu_ins, t_mavl_vdis_ins
                                                      , t_mavl_seme_ins, t_mavl_cdis_ins, t_mavl_capr_ins
                                                      , t_mavl_carg_ins, t_mavl_dcur_ins, t_mavl_meci_ins
                                                      , t_mavl_tipo_ins, t_mavl_nota_ins, t_mavl_conc_ins
                                                      , t_mavl_semr_ins, l_contador_ins);

-- vincula possíveis convalidações já existentes com o registro gerado
pkg_mgr_imp_producao_aux.p_vinc_mavl_alun_validacao(p_migr_sequ);

end p_importa_convalidacao;							 

procedure p_alimenta_grade_aluno(   p_migr_sequ     mgr_migracao.migr_sequ%type) is

t_malu_sequ     pkg_util.tb_number;
t_malu_mgcu     pkg_util.tb_number;

cursor c_mgcu(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.malu_sequ
         , MAX(c.ohia_mgcu)
      FROM mgr_aluno a
         , mgr_curso b
         , oli_historico_aluno c
     WHERE a.malu_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.malu_mver)
       AND b.mcur_sequ = a.malu_mcur
       AND c.ohia_alun = a.malu_chav
       AND c.ohia_curs = b.mcur_chav
       AND c.ohia_diis = 'N'
	   -- para garantir que foi gerada uma grade para o curso do aluno
	   -- pela modelagem do Olimpo e o processo de importação do Gioconda (junção de disciplinas e cursos)
	   -- não temos como saber se o aluno está na grade certa
	   -- sendo assim, para alguns casos provavelmente não vamos vincular o aluno a uma grade de formatura
	   AND EXISTS (SELECT 1
	                 FROM mgr_grade_curso z
					WHERE z.mgcu_sequ = c.ohia_mgcu
					  AND z.mgcu_mcur = a.malu_mcur)
     GROUP BY a.malu_sequ;

begin

open c_mgcu(p_migr_sequ);
loop
    fetch c_mgcu bulk collect into t_malu_sequ, t_malu_mgcu
    limit pkg_util.c_limit_trans;
    exit when t_malu_sequ.count = 0;

    forall i in t_malu_sequ.first..t_malu_sequ.last
        UPDATE mgr_aluno
           SET malu_mgcu = t_malu_mgcu(i)
         WHERE malu_sequ = t_malu_sequ(i);
    COMMIT;
end loop;
close c_mgcu;

end p_alimenta_grade_aluno;

procedure atualiza_mtus_mgcu(   t_mtus_sequ     in out nocopy pkg_util.tb_number
                              , t_mtus_mgcu     in out nocopy pkg_util.tb_number
                              , l_cont          in out nocopy pls_integer) is

begin

if  (t_mtus_sequ.count > 0) then

    forall i in t_mtus_sequ.first..t_mtus_sequ.last
        UPDATE mgr_turma_semestre
           SET mtus_mgcu = t_mtus_mgcu(i)
         WHERE mtus_sequ = t_mtus_sequ(i);
    COMMIT;
end if;

t_mtus_sequ.delete;
t_mtus_mgcu.delete;
l_cont := 1;

end atualiza_mtus_mgcu;

procedure p_alimenta_grade_turma_seme(  p_migr_sequ     mgr_migracao.migr_sequ%type) is

t_mtus_sequ     pkg_util.tb_number;
t_mtus_mgcu     pkg_util.tb_number;

l_ult_turm      mgr_turma_semestre.mtus_sequ%type;
l_cont          pls_integer;

cursor c_mtus_mgcu( pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.mtus_sequ
         , b.ohia_mgcu mtus_mgcu
         , COUNT(1) qtd
      FROM mgr_turma_semestre a
         , oli_historico_aluno b
     WHERE a.mtus_atua = 'S'
       AND EXISTS(  SELECT 1
                      FROM mgr_versao x
                     WHERE x.mver_migr = pc_migr_sequ
                       AND x.mver_sequ = a.mtus_mver)
       AND b.ohia_mtus = a.mtus_sequ
       AND EXISTS (SELECT 1
	                 FROM mgr_grade_curso z
					WHERE z.mgcu_sequ = b.ohia_mgcu
					  AND z.mgcu_mcur = a.mtus_mcur)
     GROUP BY a.mtus_sequ, b.ohia_mgcu
     ORDER BY a.mtus_sequ, qtd DESC;
	 
cursor c_mtus_mgcu_alun( pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.mtus_sequ
         , d.malu_mgcu mtus_mgcu
         , COUNT(1) qtd
      FROM mgr_turma_semestre a
         , mgr_aluno_turma c
         , mgr_aluno d
     WHERE a.mtus_atua = 'S'
       AND EXISTS(  SELECT 1
                      FROM mgr_versao x
                     WHERE x.mver_migr = pc_migr_sequ
                       AND x.mver_sequ = a.mtus_mver)
       AND a.mtus_mgcu IS NULL
       AND c.malt_mtus = a.mtus_sequ
       AND d.malu_sequ = c.malt_malu
       AND EXISTS (SELECT 1
                     FROM mgr_grade_curso z
					WHERE z.mgcu_sequ = d.malu_mgcu
					  AND z.mgcu_mcur = d.malu_mcur)
     GROUP BY a.mtus_sequ, d.malu_mgcu
     ORDER BY a.mtus_sequ, qtd DESC;
	 
cursor c_mtus_turma( pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.mtus_sequ
         , b.ohia_mgcu mtus_mgcu
         , COUNT(1) qtd
      FROM mgr_turma_semestre a
         , oli_historico_aluno b
     WHERE a.mtus_atua = 'S'
       AND EXISTS(  SELECT 1
                      FROM mgr_versao x
                     WHERE x.mver_migr = pc_migr_sequ
                       AND x.mver_sequ = a.mtus_mver)
       AND b.ohia_mtus = a.mtus_sequ
	   AND EXISTS (SELECT 1
                     FROM oli_turma z
                    WHERE z.tmacod = b.ohia_turs
                      AND z.gracod = b.ohia_grad)
       AND EXISTS (SELECT 1
	                 FROM mgr_grade_curso z
					WHERE z.mgcu_sequ = b.ohia_mgcu
					  AND z.mgcu_mcur = a.mtus_mcur)
     GROUP BY a.mtus_sequ, b.ohia_mgcu
     ORDER BY a.mtus_sequ, qtd DESC;
	 
cursor c_mtus_alun_dupl(pc_migr_sequ     mgr_migracao.migr_sequ%type) is
	SELECT a.mtus_sequ
         , e.malu_mgcu mtus_mgcu
         , COUNT(1) qtd
      FROM mgr_turma_semestre a
         , mgr_aluno_turma c
         , mgr_aluno d
         , mgr_aluno e
     WHERE 1 = 1
       AND a.mtus_atua = 'S'
       AND EXISTS(  SELECT 1
                      FROM mgr_versao x
                     WHERE x.mver_migr = pc_migr_sequ
                       AND x.mver_sequ = a.mtus_mver)
       AND a.mtus_mgcu IS NULL
       AND c.malt_mtus = a.mtus_sequ
       AND d.malu_sequ = c.malt_malu
       AND EXISTS (SELECT 1
                     FROM mgr_grade_curso z
					WHERE z.mgcu_sequ = e.malu_mgcu
					  AND z.mgcu_mcur = e.malu_mcur)
       AND e.malu_alun = d.malu_alun
     GROUP BY a.mtus_sequ, e.malu_mgcu
     ORDER BY a.mtus_sequ, qtd DESC;

begin
-- inicializa as variáveis
l_ult_turm := -1;

atualiza_mtus_mgcu( t_mtus_sequ, t_mtus_mgcu, l_cont);

-- o cursor irá retornar todas as turmas e a grade curso para as turmas
-- ordenando pela grade que mais se repete para a turma e esta que iremos utilizar
for r_c_mtus in c_mtus_mgcu(p_migr_sequ) loop

    -- se for diferente da última turma então é a grade com maior repetencia para esta nova turma
    if  (l_ult_turm != r_c_mtus.mtus_sequ) and
        (r_c_mtus.mtus_mgcu IS NOT NULL) then

        -- salva a nova turma em uma variável para controlar quando irá trocar o código da turma
        l_ult_turm := r_c_mtus.mtus_sequ;

        -- salva os valores para fazer o update
        t_mtus_sequ(l_cont) := r_c_mtus.mtus_sequ;
        t_mtus_mgcu(l_cont) := r_c_mtus.mtus_mgcu;

        -- quando atingir a quantidade limite por transação então atualiza a tabela
        if  (l_cont >= pkg_util.c_limit_trans) then

            atualiza_mtus_mgcu( t_mtus_sequ, t_mtus_mgcu, l_cont);
        else
            l_cont := l_cont + 1;
        end if;
    end if;
end loop;

atualiza_mtus_mgcu( t_mtus_sequ, t_mtus_mgcu, l_cont);
l_ult_turm := -1;

-- retorna a grade baseado no aluno
for r_c_mtus in c_mtus_mgcu_alun(p_migr_sequ) loop

    -- se for diferente da última turma então é a grade com maior repetencia para esta nova turma
    if  (l_ult_turm != r_c_mtus.mtus_sequ) and
        (r_c_mtus.mtus_mgcu IS NOT NULL) then

        -- salva a nova turma em uma variável para controlar quando irá trocar o código da turma
        l_ult_turm := r_c_mtus.mtus_sequ;

        -- salva os valores para fazer o update
        t_mtus_sequ(l_cont) := r_c_mtus.mtus_sequ;
        t_mtus_mgcu(l_cont) := r_c_mtus.mtus_mgcu;

        -- quando atingir a quantidade limite por transação então atualiza a tabela
        if  (l_cont >= pkg_util.c_limit_trans) then

            atualiza_mtus_mgcu( t_mtus_sequ, t_mtus_mgcu, l_cont);
        else
            l_cont := l_cont + 1;
        end if;
    end if;
end loop;

-- se sobrou algo nas tabelas atualiza
atualiza_mtus_mgcu( t_mtus_sequ, t_mtus_mgcu, l_cont);
l_ult_turm := -1;

-- o cursor irá retornar todas as turmas e a grade curso para as turmas
-- considerando a grade matriz da turma que foi cadastrada no Olimpo
for r_c_mtus_turma in c_mtus_turma(p_migr_sequ) loop

    -- se for diferente da última turma então é a grade com maior repetencia para esta nova turma
    if  (l_ult_turm != r_c_mtus_turma.mtus_sequ) and
        (r_c_mtus_turma.mtus_mgcu IS NOT NULL) then

        -- salva a nova turma em uma variável para controlar quando irá trocar o código da turma
        l_ult_turm := r_c_mtus_turma.mtus_sequ;

        -- salva os valores para fazer o update
        t_mtus_sequ(l_cont) := r_c_mtus_turma.mtus_sequ;
        t_mtus_mgcu(l_cont) := r_c_mtus_turma.mtus_mgcu;

        -- quando atingir a quantidade limite por transação então atualiza a tabela
        if  (l_cont >= pkg_util.c_limit_trans) then

            atualiza_mtus_mgcu( t_mtus_sequ, t_mtus_mgcu, l_cont);
        else
            l_cont := l_cont + 1;
        end if;
    end if;
end loop;

-- se sobrou algo nas tabelas atualiza
atualiza_mtus_mgcu( t_mtus_sequ, t_mtus_mgcu, l_cont);
l_ult_turm := -1;

-- retorna a grade da turma baseada nos alunos considerando uma possível
-- duplicidade no cadastro do aluno
for r_c_mtus_alun_dupl in c_mtus_alun_dupl(p_migr_sequ) loop

    -- se for diferente da última turma então é a grade com maior repetencia para esta nova turma
    if  (l_ult_turm != r_c_mtus_alun_dupl.mtus_sequ) and
        (r_c_mtus_alun_dupl.mtus_mgcu IS NOT NULL) then

        -- salva a nova turma em uma variável para controlar quando irá trocar o código da turma
        l_ult_turm := r_c_mtus_alun_dupl.mtus_sequ;

        -- salva os valores para fazer o update
        t_mtus_sequ(l_cont) := r_c_mtus_alun_dupl.mtus_sequ;
        t_mtus_mgcu(l_cont) := r_c_mtus_alun_dupl.mtus_mgcu;

        -- quando atingir a quantidade limite por transação então atualiza a tabela
        if  (l_cont >= pkg_util.c_limit_trans) then

            atualiza_mtus_mgcu( t_mtus_sequ, t_mtus_mgcu, l_cont);
        else
            l_cont := l_cont + 1;
        end if;
    end if;
end loop;

-- se sobrou algo nas tabelas atualiza
atualiza_mtus_mgcu( t_mtus_sequ, t_mtus_mgcu, l_cont);

end p_alimenta_grade_turma_seme;

procedure p_seta_atua_turma_sem_aluno( p_migr_sequ     mgr_migracao.migr_sequ%type) is

t_mtus_sequ     pkg_util.tb_number;

cursor c_turm( pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.mtus_sequ
      FROM mgr_turma_semestre a
     WHERE a.mtus_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao z
                    WHERE z.mver_migr = pc_migr_sequ
                      AND z.mver_sequ = a.mtus_mver)
       AND NOT EXISTS( SELECT 1
                         FROM mgr_aluno_turma x
                        WHERE x.malt_mtus = a.mtus_sequ
                        UNION ALL
                       SELECT 1
                         FROM mgr_matricula y
                        WHERE y.mmat_mtus = a.mtus_sequ
                        UNION ALL
                       SELECT 1
                         FROM oli_historico_aluno w
                        WHERE w.ohia_mtus = a.mtus_sequ);

begin
-- O Olimpo não tem uma relação muito clara entre turmas e semestre
-- por isso, no início do processo importamos turmas "a mais".
-- agora temos esse processo para excluí-las
open c_turm(p_migr_sequ);
loop
    fetch c_turm bulk collect into t_mtus_sequ
    limit pkg_util.c_limit_trans;
    exit when t_mtus_sequ.count = 0;

    forall i in t_mtus_sequ.first..t_mtus_sequ.last
        UPDATE mgr_turma_semestre SET
		       mtus_atua = 'N'
			 , mtus_datu = SYSDATE
         WHERE mtus_sequ = t_mtus_sequ(i);
    COMMIT;
end loop;
close c_turm;
end p_seta_atua_turma_sem_aluno;

procedure p_alimenta_desc_grade_curso(  p_migr_sequ     mgr_migracao.migr_sequ%type) is

t_mtus_segi     pkg_util.tb_varchar2_10;
t_mgcu_sequ     pkg_util.tb_number;

cursor c_desc_gcur(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT MIN(b.mtus_segi) mtus_segi
         , a.mgcu_sequ
      FROM mgr_grade_curso a
         , mgr_turma_semestre b
     WHERE a.mgcu_atua = 'S'
       AND EXISTS(SELECT 1
                    FROM mgr_versao x
                   WHERE x.mver_migr = pc_migr_sequ
                     AND x.mver_sequ = a.mgcu_mver)
       AND b.mtus_mgcu = a.mgcu_sequ
     GROUP BY a.mgcu_sequ;

cursor c_desc_alun(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT MIN(d.mtus_segi) mtus_segi
         , a.mgcu_sequ
      FROM mgr_grade_curso a
         , mgr_aluno b
         , mgr_aluno_turma c
         , mgr_turma_semestre d
     WHERE a.mgcu_atua = 'S'
       AND EXISTS(SELECT 1
                    FROM mgr_versao x
                   WHERE x.mver_migr = pc_migr_sequ
                     AND x.mver_sequ = a.mgcu_mver)
       AND b.malu_mgcu = a.mgcu_sequ
       AND c.malt_malu = b.malu_sequ
       AND d.mtus_sequ = c.malt_mtus
       AND NOT EXISTS( SELECT 1
                         FROM mgr_turma_semestre y
                        WHERE y.mtus_mgcu = a.mgcu_sequ)
     GROUP BY a.mgcu_sequ;

begin

open c_desc_gcur(p_migr_sequ);
loop
    fetch c_desc_gcur bulk collect into t_mtus_segi, t_mgcu_sequ
    limit pkg_util.c_limit_trans;
    exit when t_mgcu_sequ.count = 0;

    forall i in t_mgcu_sequ.first..t_mgcu_sequ.last
        UPDATE mgr_grade_curso
           SET mgcu_desc = mgcu_desc || ' - ' || t_mtus_segi(i) || ' - ' || t_mgcu_sequ(i)
         WHERE mgcu_sequ = t_mgcu_sequ(i);
    COMMIT;
end loop;

open c_desc_alun(p_migr_sequ);
loop
    fetch c_desc_alun bulk collect into t_mtus_segi, t_mgcu_sequ
    limit pkg_util.c_limit_trans;
    exit when t_mgcu_sequ.count = 0;

    forall i in t_mgcu_sequ.first..t_mgcu_sequ.last
        UPDATE mgr_grade_curso
           SET mgcu_desc = mgcu_desc || ' - ' || t_mtus_segi(i) || ' - ' || t_mgcu_sequ(i)
         WHERE mgcu_sequ = t_mgcu_sequ(i);
    COMMIT;
end loop;
close c_desc_alun;

end p_alimenta_desc_grade_curso;

procedure p_importa_formando(   p_migr_sequ     mgr_migracao.migr_sequ%type
                              , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- tabelas utilizadas no insert
t_mfor_malt_ins     pkg_util.tb_number;
t_mfor_malu_ins     pkg_util.tb_number;
t_mfor_nome_ins     pkg_util.tb_varchar2_150;
t_mfor_nasc_ins     pkg_util.tb_date;
t_mfor_natu_ins     pkg_util.tb_varchar2_150;
t_mfor_ntuf_ins     pkg_util.tb_varchar2_5;
t_mfor_iden_ins     pkg_util.tb_varchar2_50;
t_mfor_sexo_ins     pkg_util.tb_varchar2_1;
t_mfor_livr_ins     pkg_util.tb_varchar2_50;
t_mfor_pagi_ins     pkg_util.tb_varchar2_50;
t_mfor_fseq_ins     pkg_util.tb_varchar2_50;
t_mfor_dcol_ins     pkg_util.tb_date;
t_mfor_pcpf_ins     pkg_util.tb_varchar2_50;
t_mfor_ncio_ins     pkg_util.tb_varchar2_150;
t_mfor_npai_ins     pkg_util.tb_varchar2_150;
t_mfor_nmae_ins     pkg_util.tb_varchar2_150;
t_mfor_exin_ins     pkg_util.tb_varchar2_150;
t_mfor_meci_ins     pkg_util.tb_number;
t_mfor_asig_ins     pkg_util.tb_varchar2_10;
t_mfor_idoe_ins     pkg_util.tb_varchar2_50;
t_mfor_idem_ins     pkg_util.tb_date;
t_mfor_sfor_ins     pkg_util.tb_varchar2_1;
t_mfor_seco_ins     pkg_util.tb_varchar2_10;
t_mfor_opro_ins     pkg_util.tb_varchar2_50;
t_mfor_ipro_ins     pkg_util.tb_varchar2_50;
t_mfor_dexp_ins     pkg_util.tb_date;
t_mfor_curs_ins     pkg_util.tb_varchar2_5;
t_mfor_dcon_ins     pkg_util.tb_date;
t_mfor_mgcu_ins     pkg_util.tb_number;

-- tabelas utilizadas no update
t_mfor_malt_upd     pkg_util.tb_number;
t_mfor_nome_upd     pkg_util.tb_varchar2_150;
t_mfor_nasc_upd     pkg_util.tb_date;
t_mfor_natu_upd     pkg_util.tb_varchar2_150;
t_mfor_ntuf_upd     pkg_util.tb_varchar2_5;
t_mfor_iden_upd     pkg_util.tb_varchar2_50;
t_mfor_sexo_upd     pkg_util.tb_varchar2_1;
t_mfor_livr_upd     pkg_util.tb_varchar2_50;
t_mfor_pagi_upd     pkg_util.tb_varchar2_50;
t_mfor_fseq_upd     pkg_util.tb_varchar2_50;
t_mfor_dcol_upd     pkg_util.tb_date;
t_mfor_pcpf_upd     pkg_util.tb_varchar2_50;
t_mfor_ncio_upd     pkg_util.tb_varchar2_150;
t_mfor_npai_upd     pkg_util.tb_varchar2_150;
t_mfor_nmae_upd     pkg_util.tb_varchar2_150;
t_mfor_exin_upd     pkg_util.tb_varchar2_150;
t_mfor_meci_upd     pkg_util.tb_number;
t_mfor_asig_upd     pkg_util.tb_varchar2_10;
t_mfor_idoe_upd     pkg_util.tb_varchar2_50;
t_mfor_idem_upd     pkg_util.tb_date;
t_mfor_sfor_upd     pkg_util.tb_varchar2_1;
t_mfor_seco_upd     pkg_util.tb_varchar2_10;
t_mfor_opro_upd     pkg_util.tb_varchar2_50;
t_mfor_ipro_upd     pkg_util.tb_varchar2_50;
t_mfor_dexp_upd     pkg_util.tb_date;
t_mfor_curs_upd     pkg_util.tb_varchar2_5;
t_mfor_dcon_upd     pkg_util.tb_date;
t_mfor_mgcu_upd     pkg_util.tb_number;
t_mfor_sequ_upd     pkg_util.tb_number;

-- Contadores
l_contador_ins      pls_integer;
l_contador_upd      pls_integer;
l_contador_trans    pls_integer;

l_malt_sequ         mgr_aluno_turma.malt_sequ%type;
l_mfor_sequ         mgr_formando.mfor_sequ%type;

cursor c_mfor(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.malu_sequ mfor_malu
         , b.mpes_nome mfor_nome
         , b.mpes_dnas mfor_nasc
         , b.mpes_natu mfor_natu
         , b.mpes_ntuf mfor_ntuf
         , b.mpes_iden mfor_iden
         , b.mpes_sexo mfor_sexo
         , c.ahadiplivro mfor_livr
         , c.ahadipfolhas mfor_pagi
         , c.ahadipfolhas mfor_fseq
         , c.ahadatacolacao mfor_dcol
         , b.mpes_pcpf mfor_pcpf
         , b.mpes_naci mfor_ncio
         , b.mpes_npai mfor_npai
         , b.mpes_nmae mfor_nmae
         , d.insdesc mfor_exin
         , (SELECT MAX(y.codigo_gioconda)
              FROM oli_juncao_instituicao y
             WHERE y.inscod = d.inscod) mfor_meci
         , a.malu_asig mfor_asig
         , b.mpes_ideo mfor_idoe
         , b.mpes_idem mfor_idem
         , 'S' mfor_sfor
         , (SELECT MAX(z.msem_seme)
              FROM mgr_aluno_turma w
                 , mgr_semestre z
             WHERE w.malt_malu = a.malu_sequ
               AND z.msem_sequ = w.malt_msem) mfor_seco
         , c.ahadipreg mfor_opro
         , c.ahadipprocesso mfor_ipro
         , c.ahadipdata mfor_dexp
         , e.mcur_curs mfor_curs
         , c.ahadataconclusao mfor_dcon
         , a.malu_mgcu mfor_mgcu
         , (SELECT MAX(t.mfor_sequ)
              FROM mgr_formando t
             WHERE t.mfor_malu = a.malu_sequ
               AND t.mfor_curs = e.mcur_curs) mfor_sequ
      FROM mgr_aluno a
         , mgr_pessoa b
         , oli_alunhabi c
         , oli_institui d
         , mgr_curso e
     WHERE a.malu_atua = 'S'
       AND a.malu_stat = '5'
       AND a.malu_diis = 'N'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.malu_mver)
       AND b.mpes_sequ = a.malu_mpes
       AND e.mcur_sequ = a.malu_mcur
       AND c.alucod(+) = TO_NUMBER(a.malu_chav)
       AND c.espcod(+) = TO_NUMBER(e.mcur_chav)
       AND d.inscod(+) = c.inscod;

begin

pkg_mgr_imp_producao_aux.p_update_inicio_formando(  p_migr_sequ);

pkg_mgr_imp_producao_aux.p_update_tabela_formando(  t_mfor_malt_upd, t_mfor_nome_upd, t_mfor_nasc_upd
                                                  , t_mfor_natu_upd, t_mfor_ntuf_upd, t_mfor_iden_upd
                                                  , t_mfor_sexo_upd, t_mfor_livr_upd, t_mfor_pagi_upd
                                                  , t_mfor_fseq_upd, t_mfor_dcol_upd, t_mfor_pcpf_upd
                                                  , t_mfor_ncio_upd, t_mfor_npai_upd, t_mfor_nmae_upd
                                                  , t_mfor_exin_upd, t_mfor_meci_upd, t_mfor_asig_upd
                                                  , t_mfor_idoe_upd, t_mfor_idem_upd, t_mfor_sfor_upd
                                                  , t_mfor_seco_upd, t_mfor_opro_upd, t_mfor_ipro_upd
                                                  , t_mfor_dexp_upd, t_mfor_curs_upd, t_mfor_dcon_upd
                                                  , t_mfor_mgcu_upd, t_mfor_sequ_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_formando(  p_mver_sequ, t_mfor_malt_ins, t_mfor_malu_ins
                                                  , t_mfor_nome_ins, t_mfor_nasc_ins, t_mfor_natu_ins
                                                  , t_mfor_ntuf_ins, t_mfor_iden_ins, t_mfor_sexo_ins
                                                  , t_mfor_livr_ins, t_mfor_pagi_ins, t_mfor_fseq_ins
                                                  , t_mfor_dcol_ins, t_mfor_pcpf_ins, t_mfor_ncio_ins
                                                  , t_mfor_npai_ins, t_mfor_nmae_ins, t_mfor_exin_ins
                                                  , t_mfor_meci_ins, t_mfor_asig_ins, t_mfor_idoe_ins
                                                  , t_mfor_idem_ins, t_mfor_sfor_ins, t_mfor_seco_ins
                                                  , t_mfor_opro_ins, t_mfor_ipro_ins, t_mfor_dexp_ins
                                                  , t_mfor_curs_ins, t_mfor_dcon_ins, t_mfor_mgcu_ins
                                                  , l_contador_ins);

for r_c_mfor in c_mfor(p_migr_sequ) loop

    SELECT MAX(a.malt_sequ)
      INTO l_malt_sequ
      FROM mgr_semestre b
         , mgr_aluno_turma a
     WHERE b.msem_seme = r_c_mfor.mfor_seco
       AND a.malt_malu = r_c_mfor.mfor_malu
       AND a.malt_msem = b.msem_sequ;

    if  (r_c_mfor.mfor_sequ IS NULL) then

        t_mfor_malt_ins(l_contador_ins) := l_malt_sequ;
        t_mfor_malu_ins(l_contador_ins) := r_c_mfor.mfor_malu;
        t_mfor_nome_ins(l_contador_ins) := r_c_mfor.mfor_nome;
        t_mfor_nasc_ins(l_contador_ins) := r_c_mfor.mfor_nasc;
        t_mfor_natu_ins(l_contador_ins) := r_c_mfor.mfor_natu;
        t_mfor_ntuf_ins(l_contador_ins) := r_c_mfor.mfor_ntuf;
        t_mfor_iden_ins(l_contador_ins) := r_c_mfor.mfor_iden;
        t_mfor_sexo_ins(l_contador_ins) := r_c_mfor.mfor_sexo;
        t_mfor_livr_ins(l_contador_ins) := r_c_mfor.mfor_livr;
        t_mfor_pagi_ins(l_contador_ins) := r_c_mfor.mfor_pagi;
        t_mfor_fseq_ins(l_contador_ins) := r_c_mfor.mfor_fseq;
        t_mfor_dcol_ins(l_contador_ins) := r_c_mfor.mfor_dcol;
        t_mfor_pcpf_ins(l_contador_ins) := r_c_mfor.mfor_pcpf;
        t_mfor_ncio_ins(l_contador_ins) := r_c_mfor.mfor_ncio;
        t_mfor_npai_ins(l_contador_ins) := r_c_mfor.mfor_npai;
        t_mfor_nmae_ins(l_contador_ins) := r_c_mfor.mfor_nmae;
        t_mfor_exin_ins(l_contador_ins) := r_c_mfor.mfor_exin;
        t_mfor_meci_ins(l_contador_ins) := r_c_mfor.mfor_meci;
        t_mfor_asig_ins(l_contador_ins) := r_c_mfor.mfor_asig;
        t_mfor_idoe_ins(l_contador_ins) := r_c_mfor.mfor_idoe;
        t_mfor_idem_ins(l_contador_ins) := r_c_mfor.mfor_idem;
        t_mfor_sfor_ins(l_contador_ins) := r_c_mfor.mfor_sfor;
        t_mfor_seco_ins(l_contador_ins) := r_c_mfor.mfor_seco;
        t_mfor_opro_ins(l_contador_ins) := r_c_mfor.mfor_opro;
        t_mfor_ipro_ins(l_contador_ins) := r_c_mfor.mfor_ipro;
        t_mfor_dexp_ins(l_contador_ins) := r_c_mfor.mfor_dexp;
        t_mfor_curs_ins(l_contador_ins) := r_c_mfor.mfor_curs;
        t_mfor_dcon_ins(l_contador_ins) := r_c_mfor.mfor_dcon;
        t_mfor_mgcu_ins(l_contador_ins) := r_c_mfor.mfor_mgcu;

        l_contador_ins := l_contador_ins + 1;
    else

        t_mfor_malt_upd(l_contador_upd) := l_malt_sequ;
        t_mfor_nome_upd(l_contador_upd) := r_c_mfor.mfor_nome;
        t_mfor_nasc_upd(l_contador_upd) := r_c_mfor.mfor_nasc;
        t_mfor_natu_upd(l_contador_upd) := r_c_mfor.mfor_natu;
        t_mfor_ntuf_upd(l_contador_upd) := r_c_mfor.mfor_ntuf;
        t_mfor_iden_upd(l_contador_upd) := r_c_mfor.mfor_iden;
        t_mfor_sexo_upd(l_contador_upd) := r_c_mfor.mfor_sexo;
        t_mfor_livr_upd(l_contador_upd) := r_c_mfor.mfor_livr;
        t_mfor_pagi_upd(l_contador_upd) := r_c_mfor.mfor_pagi;
        t_mfor_fseq_upd(l_contador_upd) := r_c_mfor.mfor_fseq;
        t_mfor_dcol_upd(l_contador_upd) := r_c_mfor.mfor_dcol;
        t_mfor_pcpf_upd(l_contador_upd) := r_c_mfor.mfor_pcpf;
        t_mfor_ncio_upd(l_contador_upd) := r_c_mfor.mfor_ncio;
        t_mfor_npai_upd(l_contador_upd) := r_c_mfor.mfor_npai;
        t_mfor_nmae_upd(l_contador_upd) := r_c_mfor.mfor_nmae;
        t_mfor_exin_upd(l_contador_upd) := r_c_mfor.mfor_exin;
        t_mfor_meci_upd(l_contador_upd) := r_c_mfor.mfor_meci;
        t_mfor_asig_upd(l_contador_upd) := r_c_mfor.mfor_asig;
        t_mfor_idoe_upd(l_contador_upd) := r_c_mfor.mfor_idoe;
        t_mfor_idem_upd(l_contador_upd) := r_c_mfor.mfor_idem;
        t_mfor_sfor_upd(l_contador_upd) := r_c_mfor.mfor_sfor;
        t_mfor_seco_upd(l_contador_upd) := r_c_mfor.mfor_seco;
        t_mfor_opro_upd(l_contador_upd) := r_c_mfor.mfor_opro;
        t_mfor_ipro_upd(l_contador_upd) := r_c_mfor.mfor_ipro;
        t_mfor_dexp_upd(l_contador_upd) := r_c_mfor.mfor_dexp;
        t_mfor_curs_upd(l_contador_upd) := r_c_mfor.mfor_curs;
        t_mfor_dcon_upd(l_contador_upd) := r_c_mfor.mfor_dcon;
        t_mfor_mgcu_upd(l_contador_upd) := r_c_mfor.mfor_mgcu;
        t_mfor_sequ_upd(l_contador_upd) := r_c_mfor.mfor_sequ;

        l_contador_upd := l_contador_upd + 1;
    end if;

    -- verifica se atingiu a quantidade de registros por transação
    if  (l_contador_trans >= pkg_util.c_limit_trans) then

        pkg_mgr_imp_producao_aux.p_update_tabela_formando(  t_mfor_malt_upd, t_mfor_nome_upd, t_mfor_nasc_upd
                                                          , t_mfor_natu_upd, t_mfor_ntuf_upd, t_mfor_iden_upd
                                                          , t_mfor_sexo_upd, t_mfor_livr_upd, t_mfor_pagi_upd
                                                          , t_mfor_fseq_upd, t_mfor_dcol_upd, t_mfor_pcpf_upd
                                                          , t_mfor_ncio_upd, t_mfor_npai_upd, t_mfor_nmae_upd
                                                          , t_mfor_exin_upd, t_mfor_meci_upd, t_mfor_asig_upd
                                                          , t_mfor_idoe_upd, t_mfor_idem_upd, t_mfor_sfor_upd
                                                          , t_mfor_seco_upd, t_mfor_opro_upd, t_mfor_ipro_upd
                                                          , t_mfor_dexp_upd, t_mfor_curs_upd, t_mfor_dcon_upd
                                                          , t_mfor_mgcu_upd, t_mfor_sequ_upd, l_contador_upd);

        pkg_mgr_imp_producao_aux.p_insert_tabela_formando(  p_mver_sequ, t_mfor_malt_ins, t_mfor_malu_ins
                                                          , t_mfor_nome_ins, t_mfor_nasc_ins, t_mfor_natu_ins
                                                          , t_mfor_ntuf_ins, t_mfor_iden_ins, t_mfor_sexo_ins
                                                          , t_mfor_livr_ins, t_mfor_pagi_ins, t_mfor_fseq_ins
                                                          , t_mfor_dcol_ins, t_mfor_pcpf_ins, t_mfor_ncio_ins
                                                          , t_mfor_npai_ins, t_mfor_nmae_ins, t_mfor_exin_ins
                                                          , t_mfor_meci_ins, t_mfor_asig_ins, t_mfor_idoe_ins
                                                          , t_mfor_idem_ins, t_mfor_sfor_ins, t_mfor_seco_ins
                                                          , t_mfor_opro_ins, t_mfor_ipro_ins, t_mfor_dexp_ins
                                                          , t_mfor_curs_ins, t_mfor_dcon_ins, t_mfor_mgcu_ins
                                                          , l_contador_ins);

        l_contador_trans := 1;
    else
        l_contador_trans := l_contador_trans + 1;
    end if;	
end loop;

pkg_mgr_imp_producao_aux.p_update_tabela_formando(  t_mfor_malt_upd, t_mfor_nome_upd, t_mfor_nasc_upd
                                                  , t_mfor_natu_upd, t_mfor_ntuf_upd, t_mfor_iden_upd
                                                  , t_mfor_sexo_upd, t_mfor_livr_upd, t_mfor_pagi_upd
                                                  , t_mfor_fseq_upd, t_mfor_dcol_upd, t_mfor_pcpf_upd
                                                  , t_mfor_ncio_upd, t_mfor_npai_upd, t_mfor_nmae_upd
                                                  , t_mfor_exin_upd, t_mfor_meci_upd, t_mfor_asig_upd
                                                  , t_mfor_idoe_upd, t_mfor_idem_upd, t_mfor_sfor_upd
                                                  , t_mfor_seco_upd, t_mfor_opro_upd, t_mfor_ipro_upd
                                                  , t_mfor_dexp_upd, t_mfor_curs_upd, t_mfor_dcon_upd
                                                  , t_mfor_mgcu_upd, t_mfor_sequ_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_formando(  p_mver_sequ, t_mfor_malt_ins, t_mfor_malu_ins
                                                  , t_mfor_nome_ins, t_mfor_nasc_ins, t_mfor_natu_ins
                                                  , t_mfor_ntuf_ins, t_mfor_iden_ins, t_mfor_sexo_ins
                                                  , t_mfor_livr_ins, t_mfor_pagi_ins, t_mfor_fseq_ins
                                                  , t_mfor_dcol_ins, t_mfor_pcpf_ins, t_mfor_ncio_ins
                                                  , t_mfor_npai_ins, t_mfor_nmae_ins, t_mfor_exin_ins
                                                  , t_mfor_meci_ins, t_mfor_asig_ins, t_mfor_idoe_ins
                                                  , t_mfor_idem_ins, t_mfor_sfor_ins, t_mfor_seco_ins
                                                  , t_mfor_opro_ins, t_mfor_ipro_ins, t_mfor_dexp_ins
                                                  , t_mfor_curs_ins, t_mfor_dcon_ins, t_mfor_mgcu_ins
                                                  , l_contador_ins);

pkg_mgr_imp_producao_aux.p_vincula_formando(    p_migr_sequ);

end p_importa_formando;

procedure p_importa_ativ_comp(  p_migr_sequ     mgr_migracao.migr_sequ%type
                              , p_mver_sequ     mgr_versao.mver_sequ%type
                              , p_migr_sepa     mgr_migracao.migr_sepa%type) is

t_maco_carg_ins     pkg_util.tb_number;
t_maco_chav_ins     pkg_util.tb_varchar2_150;
t_maco_data_ins     pkg_util.tb_date;
t_maco_desc_ins     pkg_util.tb_varchar2_150;
t_maco_hora_ins     pkg_util.tb_number;
t_maco_malu_ins     pkg_util.tb_number;
t_maco_msem_ins     pkg_util.tb_number;
t_maco_vali_ins     pkg_util.tb_varchar2_1;

t_maco_carg_upd     pkg_util.tb_number;
t_maco_data_upd     pkg_util.tb_date;
t_maco_desc_upd     pkg_util.tb_varchar2_150;
t_maco_hora_upd     pkg_util.tb_number;
t_maco_msem_upd     pkg_util.tb_number;
t_maco_vali_upd     pkg_util.tb_varchar2_1;
t_maco_sequ_upd     pkg_util.tb_number;

-- contadores
l_contador_ins      pls_integer;
l_contador_upd      pls_integer;
l_contador_trans    pls_integer;

cursor c_ativ(  pc_migr_sequ     mgr_migracao.migr_sequ%type
              , pc_migr_sepa     mgr_migracao.migr_sepa%type) is
    SELECT NVL(b.aevtermino, b.aevinicio) maco_data
         , b.aevdesc maco_desc
         , DECODE(b.aevabono, 'S', b.aevcargahoraria, null) maco_hora
         , b.aevcargahoraria maco_carg
         , a.malu_sequ maco_malu
         , d.msem_sequ maco_msem
         , b.aevabono maco_vali
         , TO_CHAR(b.alucod || pc_migr_sepa || b.espcod || pc_migr_sepa || b.aevnum) maco_chav
         , (SELECT MAX(y.maco_sequ)
              FROM mgr_atividade_complementar y
             WHERE y.maco_chav = TO_CHAR(b.alucod || pc_migr_sepa || b.espcod || pc_migr_sepa || b.aevnum)) maco_sequ
      FROM mgr_aluno a
         , oli_aluneven b
         , mgr_curso c
         , mgr_semestre d
     WHERE a.malu_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.malu_mver)
       AND c.mcur_sequ = a.malu_mcur
       AND b.alucod = a.malu_chav
       AND b.espcod = c.mcur_chav
       AND d.msem_chav = b.pelcod;

begin

pkg_mgr_imp_producao_aux.p_update_inicio_ativ_comp(  p_migr_sequ);

pkg_mgr_imp_producao_aux.p_update_tabela_ativ_comp( t_maco_carg_upd, t_maco_data_upd, t_maco_desc_upd
                                                  , t_maco_hora_upd, t_maco_msem_upd, t_maco_vali_upd
                                                  , t_maco_sequ_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_ativ_comp( p_mver_sequ, t_maco_carg_ins, t_maco_chav_ins
                                                  , t_maco_data_ins, t_maco_desc_ins, t_maco_hora_ins
                                                  , t_maco_malu_ins, t_maco_msem_ins, t_maco_vali_ins
                                                  , l_contador_ins);

for r_c_ativ in c_ativ(p_migr_sequ, p_migr_sepa) loop

    if  (r_c_ativ.maco_sequ IS NULL) then

        t_maco_carg_ins(l_contador_ins) := r_c_ativ.maco_carg;
        t_maco_chav_ins(l_contador_ins) := r_c_ativ.maco_chav;
        t_maco_data_ins(l_contador_ins) := r_c_ativ.maco_data;
        t_maco_desc_ins(l_contador_ins) := r_c_ativ.maco_desc;
        t_maco_hora_ins(l_contador_ins) := r_c_ativ.maco_hora;
        t_maco_malu_ins(l_contador_ins) := r_c_ativ.maco_malu;
        t_maco_msem_ins(l_contador_ins) := r_c_ativ.maco_msem;
        t_maco_vali_ins(l_contador_ins) := r_c_ativ.maco_vali;

        l_contador_ins := l_contador_ins + 1;
    else

        t_maco_carg_upd(l_contador_upd) := r_c_ativ.maco_carg;
        t_maco_data_upd(l_contador_upd) := r_c_ativ.maco_data;
        t_maco_desc_upd(l_contador_upd) := r_c_ativ.maco_desc;
        t_maco_hora_upd(l_contador_upd) := r_c_ativ.maco_hora;
        t_maco_msem_upd(l_contador_upd) := r_c_ativ.maco_msem;
        t_maco_vali_upd(l_contador_upd) := r_c_ativ.maco_vali;
        t_maco_sequ_upd(l_contador_upd) := r_c_ativ.maco_sequ;

        l_contador_upd := l_contador_upd + 1;
    end if;

    -- verifica se atingiu a quantidade de registros por transação
    if  (l_contador_trans >= pkg_util.c_limit_trans) then

        pkg_mgr_imp_producao_aux.p_update_tabela_ativ_comp( t_maco_carg_upd, t_maco_data_upd, t_maco_desc_upd
                                                          , t_maco_hora_upd, t_maco_msem_upd, t_maco_vali_upd
                                                          , t_maco_sequ_upd, l_contador_upd);

        pkg_mgr_imp_producao_aux.p_insert_tabela_ativ_comp( p_mver_sequ, t_maco_carg_ins, t_maco_chav_ins
                                                          , t_maco_data_ins, t_maco_desc_ins, t_maco_hora_ins
                                                          , t_maco_malu_ins, t_maco_msem_ins, t_maco_vali_ins
                                                          , l_contador_ins);

        l_contador_trans := 1;
    else
        l_contador_trans := l_contador_trans + 1;
    end if;	
end loop;

pkg_mgr_imp_producao_aux.p_update_tabela_ativ_comp( t_maco_carg_upd, t_maco_data_upd, t_maco_desc_upd
                                                  , t_maco_hora_upd, t_maco_msem_upd, t_maco_vali_upd
                                                  , t_maco_sequ_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_ativ_comp( p_mver_sequ, t_maco_carg_ins, t_maco_chav_ins
                                                  , t_maco_data_ins, t_maco_desc_ins, t_maco_hora_ins
                                                  , t_maco_malu_ins, t_maco_msem_ins, t_maco_vali_ins
                                                  , l_contador_ins);

end p_importa_ativ_comp;

procedure p_form_ingr_transferencia(    p_migr_sequ     mgr_migracao.migr_sequ%type) is

t_malu_sequ     pkg_util.tb_number;
t_malu_meci     pkg_util.tb_number;
t_malu_clas     pkg_util.tb_number;
t_malu_desv     pkg_util.tb_varchar2_255;
t_malu_nobj     pkg_util.tb_number;
t_malu_nred     pkg_util.tb_number;

cursor c_tran(    pc_migr_sequ    mgr_migracao.migr_sequ%type) is
    SELECT a.malu_sequ
         , SUBSTR(e.vesdesc, 1, 255) malu_desv
         , (SELECT MAX(x.codigo_gioconda)
              FROM oli_juncao_instituicao x
             WHERE x.inscod = e.inscod) malu_meci
         , b.acrclassvest malu_clas
         , (SELECT MAX(w.ptvpontos)
              FROM oli_provvest z
                 , oli_ptosvest w
             WHERE z.vescod = b.vescod
               AND w.alucod = b.alucod
               AND w.prvcod = z.prvcod
               AND w.espcod = c.mcur_chav) malu_nobj
          , (SELECT MIN(w.ptvpontos)
              FROM oli_provvest z
                 , oli_ptosvest w
             WHERE z.vescod = b.vescod
               AND w.alucod = b.alucod
               AND w.prvcod = z.prvcod
               AND w.espcod = c.mcur_chav) malu_nred
      FROM mgr_aluno a
         , mgr_curso c
         , oli_aluncurs b
         , oli_vestibul e
         , mgr_sede f
     WHERE a.malu_atua = 'S'
       AND a.malu_fing = 'T'
       AND EXISTS( SELECT 1
                     FROM mgr_versao y
                    WHERE y.mver_migr = pc_migr_sequ
                      AND y.mver_sequ = a.malu_mver)
       AND c.mcur_sequ = a.malu_mcur
       AND b.alucod = a.malu_chav
       AND b.espcod = c.mcur_chav
       AND e.vescod(+) = b.vescod
       AND f.msed_sequ = a.malu_msed;

begin
-- retorna as informações dos alunos que estão como forma de ingresso Transferência
open c_tran(p_migr_sequ);
loop
    fetch c_tran bulk collect into  t_malu_sequ, t_malu_desv, t_malu_meci
                                  , t_malu_clas, t_malu_nobj, t_malu_nred
    limit pkg_util.c_limit_trans;
    exit when t_malu_clas.count = 0;

    forall i in t_malu_clas.first..t_malu_clas.last
        UPDATE mgr_aluno
           SET malu_meci = t_malu_meci(i)
             , malu_desv = t_malu_desv(i)
             , malu_clas = t_malu_clas(i)
             , malu_nobj = t_malu_nobj(i)
             , malu_nred = t_malu_nred(i)
         WHERE malu_sequ = t_malu_sequ(i);
    COMMIT;
end loop;
close c_tran;

end p_form_ingr_transferencia;

procedure p_form_ingr_vestibular(    p_migr_sequ     mgr_migracao.migr_sequ%type) is

t_malu_sequ     pkg_util.tb_number;
t_malu_nred     pkg_util.tb_number;
t_malu_nobj     pkg_util.tb_number;
t_malu_desv     pkg_util.tb_varchar2_255;
t_malu_asig     pkg_util.tb_varchar2_10;
t_malu_meci     pkg_util.tb_number;
t_malu_clas     pkg_util.tb_number;

cursor c_vest(    pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.malu_sequ
         , d.cvenotaredacao malu_nred
         , d.cvenotaprova1 malu_nobj
         , e.vesdesc malu_desv
         , (SELECT MAX(x.msem_seme)
              FROM mgr_semestre x
             WHERE e.vestermino BETWEEN x.msem_dini AND x.msem_dfim) malu_asig
         , pkg_mgr_imp_producao_aux.f_retorna_mec_ies_iunicod(f.msed_chav) malu_meci
         , NVL(d.cveclasconsop1, d.cveclasgeral) malu_clas
      FROM mgr_aluno a
         , mgr_curso c
         , oli_aluncurs b
         , oli_candvest d
         , oli_vestibul e
         , mgr_sede f
     WHERE a.malu_atua = 'S'
       AND a.malu_fing = 'V'
       AND EXISTS( SELECT 1
                     FROM mgr_versao y
                    WHERE y.mver_migr = pc_migr_sequ
                      AND y.mver_sequ = a.malu_mver)
       AND c.mcur_sequ = a.malu_mcur
       AND b.alucod = a.malu_chav
       AND b.espcod = c.mcur_chav
       AND d.alucod = b.alucod
       AND d.espcod = b.espcod
       AND e.vescod = d.vescod
       AND f.msed_sequ = a.malu_msed
     UNION ALL
    SELECT a.malu_sequ
         , null malu_nred
         , null malu_nobj
         , e.vesdesc malu_desv
         , (SELECT MAX(x.msem_seme)
              FROM mgr_semestre x
             WHERE e.vestermino BETWEEN x.msem_dini AND x.msem_dfim) malu_asig
         , pkg_mgr_imp_producao_aux.f_retorna_mec_ies_iunicod(f.msed_chav) malu_meci
         , null malu_clas
      FROM mgr_aluno a
         , mgr_curso c
         , oli_aluncurs b
         , oli_vestibul e
         , mgr_sede f
     WHERE a.malu_atua = 'S'
       AND a.malu_fing = 'V'
       AND EXISTS( SELECT 1
                     FROM mgr_versao y
                    WHERE y.mver_migr = pc_migr_sequ
                      AND y.mver_sequ = a.malu_mver)
       AND c.mcur_sequ = a.malu_mcur
       AND b.alucod = a.malu_chav
       AND b.espcod = c.mcur_chav
       AND NOT EXISTS( SELECT 1
                         FROM oli_candvest d
                        WHERE d.alucod = b.alucod
                          AND d.espcod = b.espcod)
       AND e.vescod = b.vescod
       AND f.msed_sequ = a.malu_msed;

begin

open c_vest(p_migr_sequ);
loop
    fetch c_vest bulk collect into  t_malu_sequ, t_malu_nred, t_malu_nobj
                                  , t_malu_desv, t_malu_asig, t_malu_meci
                                  , t_malu_clas
    limit pkg_util.c_limit_trans;
    exit when t_malu_clas.count = 0;

    forall i in t_malu_clas.first..t_malu_clas.last
        UPDATE mgr_aluno
           SET malu_nred = t_malu_nred(i)
             , malu_nobj = t_malu_nobj(i)
             , malu_desv = t_malu_desv(i)
             , malu_asig = NVL(t_malu_asig(i), malu_asig)
             , malu_meci = t_malu_meci(i)
             , malu_clas = t_malu_clas(i)
         WHERE malu_sequ = t_malu_sequ(i);
    COMMIT;
end loop;
close c_vest;

end p_form_ingr_vestibular;

procedure p_form_ingr_enem( p_migr_sequ     mgr_migracao.migr_sequ%type) is

t_malu_sequ     pkg_util.tb_number;
t_malu_nred     pkg_util.tb_number;
t_malu_nobj     pkg_util.tb_number;
t_malu_desv     pkg_util.tb_varchar2_255;
t_malu_asig     pkg_util.tb_varchar2_10;
t_malu_meci     pkg_util.tb_number;
t_malu_clas     pkg_util.tb_number;

cursor c_enem( pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.malu_sequ
         , NVL(d.cvenotaenemsubjetiva, d.cvenotaredacao) malu_nred
         , nvl(d.cvenotaenemobjetiva, d.cvenotaprova1) malu_nobj
         , e.vesdesc malu_desv
         , (SELECT MAX(x.msem_seme)
              FROM mgr_semestre x
             WHERE e.vestermino BETWEEN x.msem_dini AND x.msem_dfim) malu_asig
         , pkg_mgr_imp_producao_aux.f_retorna_mec_ies_iunicod(f.msed_chav) malu_meci
         , NVL(d.cveclasconsop1, d.cveclasgeral) malu_clas
      FROM mgr_aluno a
         , mgr_curso c
         , oli_aluncurs b
         , oli_candvest d
         , oli_vestibul e
         , mgr_sede f
     WHERE a.malu_atua = 'S'
       AND a.malu_fing = 'E'
       AND EXISTS( SELECT 1
                     FROM mgr_versao y
                    WHERE y.mver_migr = pc_migr_sequ
                      AND y.mver_sequ = a.malu_mver)
       AND c.mcur_sequ = a.malu_mcur
       AND b.alucod = a.malu_chav
       AND b.espcod = c.mcur_chav
       AND d.alucod = b.alucod
       AND d.espcod = b.espcod
       AND e.vescod = d.vescod
       AND f.msed_sequ = a.malu_msed
     UNION ALL
    SELECT a.malu_sequ
         , null malu_nred
         , null malu_nobj
         , e.vesdesc malu_desv
         , (SELECT MAX(x.msem_seme)
              FROM mgr_semestre x
             WHERE e.vestermino BETWEEN x.msem_dini AND x.msem_dfim) malu_asig
         , pkg_mgr_imp_producao_aux.f_retorna_mec_ies_iunicod(f.msed_chav) malu_meci
         , null malu_clas
      FROM mgr_aluno a
         , mgr_curso c
         , oli_aluncurs b
         , oli_vestibul e
         , mgr_sede f
     WHERE a.malu_atua = 'S'
       AND a.malu_fing = 'E'
       AND EXISTS( SELECT 1
                     FROM mgr_versao y
                    WHERE y.mver_migr = pc_migr_sequ
                      AND y.mver_sequ = a.malu_mver)
       AND c.mcur_sequ = a.malu_mcur
       AND b.alucod = a.malu_chav
       AND b.espcod = c.mcur_chav
       AND NOT EXISTS( SELECT 1
                         FROM oli_candvest d
                        WHERE d.alucod = b.alucod
                          AND d.espcod = b.espcod)
       AND e.vescod = b.vescod
       AND f.msed_sequ = a.malu_msed;

begin

open c_enem(p_migr_sequ);
loop
    fetch c_enem bulk collect into  t_malu_sequ, t_malu_nred, t_malu_nobj
                                  , t_malu_desv, t_malu_asig, t_malu_meci
                                  , t_malu_clas
    limit pkg_util.c_limit_trans;
    exit when t_malu_sequ.count = 0;

    forall i in t_malu_sequ.first..t_malu_sequ.last
        UPDATE mgr_aluno
           SET malu_nred = t_malu_nred(i)
             , malu_nobj = t_malu_nobj(i)
             , malu_desv = t_malu_desv(i)
             , malu_asig = NVL(t_malu_asig(i), malu_asig)
             , malu_meci = t_malu_meci(i)
             , malu_clas = t_malu_clas(i)
         WHERE malu_sequ = t_malu_sequ(i);
    COMMIT;
end loop;
close c_enem;

end p_form_ingr_enem;

procedure p_form_ingr_segunda_graduacao(    p_migr_sequ     mgr_migracao.migr_sequ%type) is

t_malu_sequ     pkg_util.tb_number;
t_malu_meci     pkg_util.tb_number;
t_malu_trcu     pkg_util.tb_varchar2_255;
t_malu_regi     pkg_util.tb_varchar2_50;
t_malu_livr     pkg_util.tb_varchar2_50;
t_malu_pagi     pkg_util.tb_varchar2_50;
t_malu_dreg     pkg_util.tb_date;
t_malu_trre     pkg_util.tb_number;

cursor c_segu(    pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT malu_sequ
         , NVL(meci_hist, NVL(meci_disc, meci_curs)) malu_meci
         , NVL(curs_hist, curs_disc) malu_trcu
         , malu_regi
         , malu_livr
         , malu_pagi
         , malu_dreg
         , trre_curs malu_trre
      FROM (
        SELECT a.malu_sequ
             , (SELECT MAX(x.codigo_gioconda)
                  FROM oli_juncao_instituicao x
                 WHERE x.inscod = b.inscoddipreg) trre_curs
             , (SELECT MAX(x.codigo_gioconda)
                  FROM oli_juncao_instituicao x
                 WHERE x.inscod = b.inscod) meci_curs
             , (SELECT MAX(x.codigo_gioconda)
                  FROM oli_temphist w
                     , oli_juncao_instituicao x
                 WHERE w.tmhalucod = b.alucod
                   AND w.tmhespcod = b.espcod
                   AND x.inscod = w.tmhdisinstituicao) meci_hist
             , (SELECT MAX(x.codigo_gioconda)
                  FROM oli_disccomp z
                     , oli_juncao_instituicao x
                 WHERE z.alucod = b.alucod
                   AND z.espcod = b.espcod
                   AND x.inscod = z.inscod) meci_disc
             , (SELECT MAX(w.tmhdiscurso)
                  FROM oli_temphist w
                 WHERE w.tmhalucod = b.alucod
                   AND w.tmhespcod = b.espcod) curs_hist
             , (SELECT MAX(z.dcocurso)
                  FROM oli_disccomp z
                 WHERE z.alucod = b.alucod
                   AND z.espcod = b.espcod) curs_disc
             , b.acrdipreg malu_regi
             , b.acrdiplivro malu_livr
             , b.acrdipfolhas malu_pagi
             , b.acrdipdata malu_dreg
          FROM mgr_aluno a
             , mgr_curso c
             , oli_aluncurs b
         WHERE a.malu_atua = 'S'
           AND a.malu_fing = 'S'
           AND EXISTS( SELECT 1
                         FROM mgr_versao y
                        WHERE y.mver_migr = pc_migr_sequ
                          AND y.mver_sequ = a.malu_mver)
           AND c.mcur_sequ = a.malu_mcur
           AND b.alucod = a.malu_chav
           AND b.espcod = c.mcur_chav);

begin

open c_segu(p_migr_sequ);
loop
    fetch c_segu bulk collect into  t_malu_sequ, t_malu_meci, t_malu_trcu
                                  , t_malu_regi, t_malu_livr, t_malu_pagi
                                  , t_malu_dreg, t_malu_trre
    limit pkg_util.c_limit_trans;
    exit when t_malu_sequ.count = 0;

    forall i in t_malu_sequ.first..t_malu_sequ.last
        UPDATE mgr_aluno
           SET malu_meci = t_malu_meci(i)
             , malu_regi = t_malu_regi(i)
             , malu_livr = t_malu_livr(i)
             , malu_pagi = t_malu_pagi(i)
             , malu_dreg = t_malu_dreg(i)
             , malu_trcu = t_malu_trcu(i)
             , malu_trre = t_malu_trre(i)
         WHERE malu_sequ = t_malu_sequ(i);
    COMMIT;
end loop;
close c_segu;

end p_form_ingr_segunda_graduacao;

procedure p_form_ingr_historico_escolar(    p_migr_sequ     mgr_migracao.migr_sequ%type) is

t_malu_sequ     pkg_util.tb_number;
t_malu_meci     pkg_util.tb_number;
t_malu_nred     pkg_util.tb_number;

cursor c_hist(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.malu_sequ
         , pkg_mgr_imp_producao_aux.f_retorna_mec_ies_iunicod(f.msed_chav) malu_meci
         , e.cvenotaredacao malu_nred
      FROM mgr_aluno a
         , mgr_curso c
         , oli_aluncurs b
         , oli_candvest e
         , mgr_sede f
     WHERE a.malu_atua = 'S'
       AND a.malu_fing = 'R'
       AND EXISTS( SELECT 1
                     FROM mgr_versao y
                    WHERE y.mver_migr = pc_migr_sequ
                      AND y.mver_sequ = a.malu_mver)
       AND c.mcur_sequ = a.malu_mcur
       AND b.alucod = a.malu_chav
       AND b.espcod = c.mcur_chav
       AND f.msed_sequ = a.malu_msed
       AND e.alucod(+) = b.alucod;

begin

open c_hist(p_migr_sequ);
loop
    fetch c_hist bulk collect into t_malu_sequ, t_malu_meci, t_malu_nred
    limit pkg_util.c_limit_trans;
    exit when t_malu_nred.count = 0;

    forall i in t_malu_nred.first..t_malu_nred.last
        UPDATE mgr_aluno
           SET malu_meci = t_malu_meci(i)
             , malu_nred = t_malu_nred(i)
         WHERE malu_sequ = t_malu_sequ(i);
    COMMIT;
end loop;
close c_hist;

end p_form_ingr_historico_escolar;

procedure p_form_ingr_busca_nota(   p_migr_sequ     mgr_migracao.migr_sequ%type) is

t_malu_sequ     pkg_util.tb_number;
t_malu_nobj     pkg_util.tb_number;
t_malu_nred     pkg_util.tb_number;

cursor c_nota(   pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.malu_sequ
         , MAX(e.ptvpontos) malu_nobj
         , MIN(e.ptvpontos) malu_nred
      FROM mgr_aluno a
         , mgr_curso c
         , oli_aluncurs b
         , oli_provvest d
         , oli_ptosvest e
     WHERE a.malu_atua = 'S'
       AND a.malu_nred IS NULL
       AND a.malu_nobj IS NULL
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.malu_mver)
       AND c.mcur_sequ = a.malu_mcur
       AND b.alucod = TO_NUMBER(a.malu_chav)
       AND b.espcod = TO_NUMBER(c.mcur_chav)
       AND d.vescod = b.vescod
       AND e.alucod = b.alucod
       AND e.espcod = b.espcod
       AND e.prvcod = d.prvcod
     GROUP BY a.malu_sequ;

begin

open c_nota(p_migr_sequ);
loop
    fetch c_nota bulk collect into t_malu_sequ, t_malu_nobj, t_malu_nred
    limit pkg_util.c_limit_trans;
    exit when t_malu_nred.count = 0;

    forall i in t_malu_nred.first..t_malu_nred.last
        UPDATE mgr_aluno
           SET malu_nobj = t_malu_nobj(i)
             , malu_nred = t_malu_nred(i)
         WHERE malu_sequ = t_malu_sequ(i);
end loop;
close c_nota;

end p_form_ingr_busca_nota;

procedure p_alimenta_forma_ingresso(    p_migr_sequ     mgr_migracao.migr_sequ%type) is

begin

-- Forma de ingresso Transferência
p_form_ingr_transferencia(  p_migr_sequ);

-- Forma de ingresso Vestibular
p_form_ingr_vestibular( p_migr_sequ);

-- Forma de ingresso ENEM
p_form_ingr_enem(   p_migr_sequ);

-- Forma de ingresso Segunda Graduação
p_form_ingr_segunda_graduacao(  p_migr_sequ);

-- Forma de ingresso Histórico Escolar
p_form_ingr_historico_escolar(  p_migr_sequ);

-- Verifica os registros que ficaram sem nota e tenta por outro caminho encontrar as notas
p_form_ingr_busca_nota( p_migr_sequ);

end p_alimenta_forma_ingresso;

procedure p_importa_grad_seme_prof_disc( p_migr_sequ     mgr_migracao.migr_sequ%type
                                       , p_mver_sequ     mgr_versao.mver_sequ%type
                                       , p_migr_sepa     mgr_migracao.migr_sepa%type) is

-- tabelas utilizadas no update
t_mgpd_sequ_upd     pkg_util.tb_number;
t_mgpd_stat_upd     pkg_util.tb_varchar2_1;

-- tabelas utilizadas no insert
t_mgpd_mgse_ins     pkg_util.tb_number;
t_mgpd_mpro_ins     pkg_util.tb_number;
t_mgpd_stat_ins     pkg_util.tb_varchar2_1;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

cursor c_dipr(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT w.mgpd_mgse
         , w.mgpd_mpro
         , (SELECT MAX(mgpd_sequ)
              FROM mgr_grade_seme_prof_disc y
             WHERE y.mgpd_mgse = w.mgpd_mgse
               AND y.mgpd_mpro = w.mgpd_mpro) mgpd_sequ
      FROM (
            SELECT d.mpro_sequ mgpd_mpro
                 , c.mgse_sequ mgpd_mgse
              FROM oli_historico_aluno a 
                 , oli_discprof b
                 , mgr_grade_semestre c
                 , mgr_professor d
             WHERE a.ohia_atua = 'S'
               AND b.tmacod = a.ohia_turs
               AND b.discod = a.ohia_disc
               AND b.dmpsituacao = 'A'
               AND c.mgse_mtus = a.ohia_mtus
               AND c.mgse_vdis = a.ohia_dgio
               AND EXISTS(  SELECT 1
                              FROM mgr_versao x
                             WHERE x.mver_migr = pc_migr_sequ
                               AND x.mver_sequ = c.mgse_mver)
               AND d.mpro_chav = TO_CHAR(b.prfcod)
             UNION ALL
            SELECT d.mpro_sequ mgpd_mpro
                 , c.mgse_sequ mgpd_mgse
              FROM oli_historico_aluno a
                 , oli_discprof b
                 , mgr_grade_semestre c
                 , mgr_professor d
             WHERE a.ohia_atua = 'S'
               AND b.tmacod = a.ohia_turs
               AND b.discod = a.ohia_mdis
               AND b.dmpsituacao = 'A'
               AND c.mgse_mtus = a.ohia_mtus
               AND c.mgse_vdis = a.ohia_dgio
               AND EXISTS(  SELECT 1
                              FROM mgr_versao x
                             WHERE x.mver_migr = pc_migr_sequ
                               AND x.mver_sequ = c.mgse_mver)
               AND d.mpro_chav = TO_CHAR(b.prfcod)) w
     GROUP BY w.mgpd_mgse, w.mgpd_mpro;
    
begin

pkg_mgr_imp_producao_aux.p_upda_inic_grad_seme_prof_dis(    p_migr_sequ);

pkg_mgr_imp_producao_aux.p_upda_tabe_grad_seme_prof_dis(    t_mgpd_sequ_upd, t_mgpd_stat_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_inse_tabe_grad_seme_prof_dis(    p_mver_sequ, t_mgpd_mgse_ins, t_mgpd_mpro_ins
                                                          , t_mgpd_stat_ins, l_contador_ins);

for r_c_dipr in c_dipr(p_migr_sequ) loop

    -- se já existe o registro na tabela então é update
    if  (r_c_dipr.mgpd_sequ is not null) then

        -- alimenta as variáveis table utilizadas no update
        t_mgpd_sequ_upd(l_contador_upd) := r_c_dipr.mgpd_sequ;
        t_mgpd_stat_upd(l_contador_upd) := '1';

        l_contador_upd := l_contador_upd + 1;
    else

        -- alimenta as variáveis table utilizadas no insert
        t_mgpd_mgse_ins(l_contador_ins) := r_c_dipr.mgpd_mgse;
        t_mgpd_mpro_ins(l_contador_ins) := r_c_dipr.mgpd_mpro;
        t_mgpd_stat_ins(l_contador_ins) := '1';

        l_contador_ins := l_contador_ins + 1;
    end if;

    -- verifica se atingiu a quantidade de registros por transação
    if  (l_contador_trans >= pkg_util.c_limit_trans) then

        -- atualiza os registro e devolve as variáveis reinicializadas
        pkg_mgr_imp_producao_aux.p_upda_tabe_grad_seme_prof_dis(    t_mgpd_sequ_upd, t_mgpd_stat_upd, l_contador_upd);

        pkg_mgr_imp_producao_aux.p_inse_tabe_grad_seme_prof_dis(    p_mver_sequ, t_mgpd_mgse_ins, t_mgpd_mpro_ins
                                                                  , t_mgpd_stat_ins, l_contador_ins);

        l_contador_trans := 1;
    else
        l_contador_trans := l_contador_trans + 1;
    end if;
end loop;

pkg_mgr_imp_producao_aux.p_upda_tabe_grad_seme_prof_dis(    t_mgpd_sequ_upd, t_mgpd_stat_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_inse_tabe_grad_seme_prof_dis(    p_mver_sequ, t_mgpd_mgse_ins, t_mgpd_mpro_ins
                                                          , t_mgpd_stat_ins, l_contador_ins);

pkg_mgr_imp_producao_aux.p_vincula_grade_seme_prof_disc(    p_migr_sequ);

end p_importa_grad_seme_prof_disc;

procedure p_alim_tab_temp_convenios is

t_alucod        pkg_util.tb_number;
t_cmeperc       pkg_util.tb_number;
t_peju_codi     pkg_util.tb_number;
t_coti_conv     pkg_util.tb_number;
t_concod        pkg_util.tb_number;
t_espcod        pkg_util.tb_number;
t_malt_sequ     pkg_util.tb_number;
t_malu_mcur     pkg_util.tb_number;
t_malu_msed     pkg_util.tb_number;
t_mcur_curs     pkg_util.tb_varchar2_5;
t_menano        pkg_util.tb_number;
t_dtin_conv     pkg_util.tb_date;
t_dtfi_conv     pkg_util.tb_date;
t_menini        pkg_util.tb_number;
t_menfim        pkg_util.tb_number;
t_msed_sede     pkg_util.tb_varchar2_5;
t_msem_seme     pkg_util.tb_varchar2_10;
t_msem_sequ     pkg_util.tb_number;
t_mtus_peri     pkg_util.tb_number;
t_msed_sequ     pkg_util.tb_number;

-- convênios e financeiro apenas entre 2013/1 e 2016/2
cursor c_conv_temp( pc_seme_inic_fina   varchar2
                  , pc_seme_fim_fina    varchar2) is
    SELECT b.alucod
         , b.cmepercentual
         , a.codigo_peju_gioconda
         , a.cod_tipo_convenio
         , a.concod
         , b.espcod
         , k.malt_sequ
         , e.malu_mcur
         , e.malu_msed
         , c.mcur_curs
         , h.menano
         , f.msed_sede
         , i.msem_seme
         , i.msem_sequ
         , l.mtus_peri
         , f.msed_sequ
         , MIN(h.menmes) mes_inicio_conv
         , MAX(h.menmes) mes_fim_conv
         , MIN(h.mendatavctaluno) data_inicio_conv
         , MAX(h.mendatavctaluno) data_fim_conv
      FROM oli_convenio_juncao a
         , oli_convmens b
         , mgr_curso c
         , mgr_aluno e
         , mgr_sede f
         , oli_mensalid h
         , mgr_semestre i
         , oli_perileti_uni j
         , mgr_aluno_turma k
         , mgr_turma_semestre l
     WHERE a.gerar_gioconda = 'S'
       AND b.concod = a.concod
       AND c.mcur_chav = b.espcod
       AND e.malu_chav = b.alucod
       AND e.malu_mcur = c.mcur_sequ
       AND e.malu_atua = 'S'
       AND f.msed_sequ = e.malu_msed
       AND h.menano = b.menano
       AND h.menmes = b.menmes
       AND h.iunicodempresa = b.iunicodempresa
       AND h.mendatavctaluno BETWEEN i.msem_dini AND i.msem_dfim
	   AND i.msem_seme BETWEEN pc_seme_inic_fina AND pc_seme_fim_fina
       AND j.pelcod = i.msem_chav
       AND k.malt_msem = i.msem_sequ
       AND k.malt_malu = e.malu_sequ
       AND l.mtus_sequ = k.malt_mtus
     GROUP BY b.alucod
         , b.cmepercentual
         , a.codigo_peju_gioconda
         , a.cod_tipo_convenio
         , a.concod
         , b.espcod
         , k.malt_sequ
         , e.malu_mcur
         , e.malu_msed
         , c.mcur_curs
         , h.menano
         , f.msed_sede
         , i.msem_seme
         , i.msem_sequ
         , l.mtus_peri
         , f.msed_sequ;

begin

EXECUTE IMMEDIATE ' TRUNCATE TABLE OLI_CONVENIO_TEMP ';

open c_conv_temp(f_seme_ini_imp_financeiro, f_seme_fim_imp_financeiro);
loop
    fetch c_conv_temp bulk collect into t_alucod, t_cmeperc, t_peju_codi
                                      , t_coti_conv, t_concod, t_espcod
                                      , t_malt_sequ, t_malu_mcur, t_malu_msed
                                      , t_mcur_curs, t_menano, t_msed_sede
                                      , t_msem_seme, t_msem_sequ, t_mtus_peri
                                      , t_msed_sequ, t_menini, t_menfim
                                      , t_dtin_conv, t_dtfi_conv
    limit pkg_util.c_limit_trans;
    exit when t_alucod.count = 0;

    forall i in t_alucod.first..t_alucod.last
        INSERT INTO oli_convenio_temp(
               alucod, cmepercentual, codigo_peju_gioconda
             , cod_tipo_convenio, concod, espcod
             , malt_sequ, malu_mcur, malu_msed
             , mcur_curs, menano, msed_sede
             , msem_seme, msem_sequ, mtus_peri
             , msed_sequ, mes_inicio_conv, mes_fim_conv
             , data_inicio_conv, data_fim_conv
        ) VALUES (
               t_alucod(i), t_cmeperc(i), t_peju_codi(i)
             , t_coti_conv(i), t_concod(i), t_espcod(i)
             , t_malt_sequ(i), t_malu_mcur(i), t_malu_msed(i)
             , t_mcur_curs(i), t_menano(i), t_msed_sede(i)
             , t_msem_seme(i), t_msem_sequ(i), t_mtus_peri(i)
             , t_msed_sequ(i), t_menini(i), t_menfim(i)
             , t_dtin_conv(i), t_dtfi_conv(i)
        );
    COMMIT;    
end loop;
close c_conv_temp;
/*
 aqui são feitas algumas correções quanto a pessoa jurídica, de acordo com e-mail enviado pela Marcia ao Décio
 no dia 09/11/2016, tudo que estiver com a pessoa jurica 9800408 e não for IG deve ser alterado para a seguinte tabela

    BR - ASSEVIM    - 9800275
    BN - FAMEBLU II - 9800280
    BL - FAMEBLU I  - 9800412
    TB - FAVINCI    - 9800274
    GM - FAMEG      - 9800418
    RS - FAMESUL    - 921969
    IG - MATRIZ     - 9800408
*/

UPDATE oli_convenio_temp
   SET codigo_peju_gioconda = 9800275
 WHERE codigo_peju_gioconda = 9800408
   AND msed_sede = 'BR';
COMMIT;

UPDATE oli_convenio_temp
   SET codigo_peju_gioconda = 9800280
 WHERE codigo_peju_gioconda = 9800408
   AND msed_sede = 'BN';
COMMIT;
  
UPDATE oli_convenio_temp
   SET codigo_peju_gioconda = 9800412
 WHERE codigo_peju_gioconda = 9800408
   AND msed_sede = 'BL';
COMMIT;
  
UPDATE oli_convenio_temp
   SET codigo_peju_gioconda = 9800274
 WHERE codigo_peju_gioconda = 9800408
   AND msed_sede = 'TB';
COMMIT;
  
UPDATE oli_convenio_temp
   SET codigo_peju_gioconda = 9800418
 WHERE codigo_peju_gioconda = 9800408
   AND msed_sede = 'GM';
COMMIT;

UPDATE oli_convenio_temp
   SET codigo_peju_gioconda = 921969
 WHERE codigo_peju_gioconda = 9800408
   AND msed_sede = 'RS';
COMMIT;

end p_alim_tab_temp_convenios;

procedure p_importa_convenio_tipo(  p_migr_sequ     mgr_migracao.migr_sequ%type
                                  , p_mver_sequ     mgr_versao.mver_sequ%type) is

t_mcti_coti     pkg_util.tb_number;
t_mcti_sequ     pkg_util.tb_number;

cursor c_mcti_upd(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.mcti_sequ
      FROM mgr_convenio_tipo a
     WHERE EXISTS(  SELECT 1
                      FROM mgr_versao y
                     WHERE y.mver_migr = pc_migr_sequ
                       AND y.mver_sequ = a.mcti_mver)
       AND EXISTS(  SELECT 1
                      FROM oli_convenio_temp x
                     WHERE x.cod_tipo_convenio = a.mcti_coti);

cursor c_mcti(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT DISTINCT a.cod_tipo_convenio
      FROM oli_convenio_temp a
     WHERE NOT EXISTS(  SELECT 1
                          FROM mgr_versao y
                             , mgr_convenio_tipo x
                         WHERE y.mver_migr = pc_migr_sequ
                           AND x.mcti_mver = mver_sequ
                           AND x.mcti_coti = a.cod_tipo_convenio);

begin
-- precisa ser passada a versão
if  (p_mver_sequ is not null) then

    -- atualiza os registros para controle do que será atualizado
    pkg_mgr_imp_producao_aux.p_update_inic_convenio_tipo(p_migr_sequ);

    -- retorna todos os registros da tabela que já existem e estão sendo importados novamente
    open c_mcti_upd(p_migr_sequ);
    loop
        fetch c_mcti_upd bulk collect into  t_mcti_sequ
        limit pkg_util.c_limit_trans;
        exit when t_mcti_sequ.count = 0;

        forall i in t_mcti_sequ.first..t_mcti_sequ.last
            UPDATE mgr_convenio_tipo
               SET mcti_atua = 'S'
                 , mcti_datu = sysdate
             WHERE mcti_sequ = t_mcti_sequ(i);
        COMMIT;
    end loop;
    close c_mcti_upd;

    -- retorna todos os tipos que ainda não existem para a migração
    open c_mcti(p_migr_sequ);
    loop
        fetch c_mcti bulk collect into  t_mcti_coti
        limit pkg_util.c_limit_trans;
        exit when t_mcti_coti.count = 0;

        -- gera a sequencia da mgr_convenio_tipo
        for i in t_mcti_coti.first..t_mcti_coti.last loop

            t_mcti_sequ(i) := FGET_SEQU('SEQU_MGR_CONVENIO_TIPO', 'MCTI_SEQU', 'MGR_CONVENIO_TIPO');
        end loop;

        -- insere os registros
        forall i in t_mcti_coti.first..t_mcti_coti.last
            INSERT INTO mgr_convenio_tipo(
                   mcti_sequ, mcti_coti, mcti_datu
                 , mcti_atua, mcti_mver
            ) VALUES (
                   t_mcti_sequ(i), t_mcti_coti(i), sysdate
                 , 'S', p_mver_sequ
            );
        COMMIT;
    end loop;
    close c_mcti;
    
    pkg_mgr_imp_producao_aux.p_vincula_convenio_tipo;
    
end if;

end p_importa_convenio_tipo;

procedure p_importa_convenio_tipo_sese( p_migr_sequ     mgr_migracao.migr_sequ%type
                                      , p_mver_sequ     mgr_versao.mver_sequ%type) is

t_mcts_sequ     pkg_util.tb_number;
t_mcts_mses     pkg_util.tb_number;
t_mcts_mcti     pkg_util.tb_number;

cursor c_mcts_upd(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT y.mcts_sequ
      FROM mgr_convenio_tipo_sese y
     WHERE EXISTS(  SELECT 1
                      FROM oli_convenio_temp a
                         , mgr_semestre_sede b
                         , mgr_convenio_tipo c
                         , mgr_versao x
                     WHERE b.mses_sequ = y.mcts_mses
					   AND b.mses_atua = 'S'
                       AND c.mcti_sequ = y.mcts_mcti
                       AND c.mcti_atua = 'S'
                       AND a.mtus_peri = b.mses_eper
                       AND a.cod_tipo_convenio = c.mcti_coti
                       AND x.mver_migr = pc_migr_sequ
                       AND x.mver_sequ = c.mcti_mver);

cursor c_mcts(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT b.mses_sequ
         , c.mcti_sequ
      FROM oli_convenio_temp a
         , mgr_semestre_sede b
         , mgr_convenio_tipo c
     WHERE b.mses_msem = a.msem_sequ
	   AND b.mses_atua = 'S'
       AND b.mses_msed = a.msed_sequ
       AND b.mses_eper = a.mtus_peri
       AND c.mcti_coti = a.cod_tipo_convenio
       AND c.mcti_atua = 'S'
       AND EXISTS(  SELECT 1
                      FROM mgr_versao x
                     WHERE x.mver_migr = pc_migr_sequ
                       AND x.mver_sequ = c.mcti_mver)
       AND NOT EXISTS(  SELECT 1
                          FROM mgr_convenio_tipo_sese y
                         WHERE y.mcts_mses = b.mses_sequ
                           AND y.mcts_mcti = c.mcti_sequ)
     GROUP BY b.mses_sequ, c.mcti_sequ;

begin
-- faz o update inicial no campo de controle para sabermos quais registros foram atualizados
pkg_mgr_imp_producao_aux.p_update_inic_conv_tipo_sese(p_migr_sequ);

-- retorna primeiro os registros que já existem na tabela apenas para marcar que foram atualizados
open c_mcts_upd(p_migr_sequ);
loop
    fetch c_mcts_upd bulk collect into  t_mcts_sequ
    limit pkg_util.c_limit_trans;
    exit when t_mcts_sequ.count = 0;

    forall i in t_mcts_sequ.first..t_mcts_sequ.last
        UPDATE mgr_convenio_tipo_sese
           SET mcts_atua = 'S'
             , mcts_datu = sysdate
         WHERE mcts_sequ = t_mcts_sequ(i);
    commit;
end loop;
close c_mcts_upd;

-- retorna os registros que precisam ser inseridos
open c_mcts(p_migr_sequ);
loop
    fetch c_mcts bulk collect into  t_mcts_mses, t_mcts_mcti
    limit pkg_util.c_limit_trans;
    exit when t_mcts_mses.count = 0;

    for i in t_mcts_mses.first..t_mcts_mses.last loop

        t_mcts_sequ(i) := FGET_SEQU('SEQU_MGR_CONVENIO_TIPO_SESE', 'MCTS_SEQU', 'MGR_CONVENIO_TIPO_SESE');
    end loop;

    forall i in t_mcts_mses.first..t_mcts_mses.last
        INSERT INTO mgr_convenio_tipo_sese(
               mcts_sequ, mcts_mses, mcts_mcti
             , mcts_atua, mcts_datu, mcts_mver
        ) VALUES (
               t_mcts_sequ(i), t_mcts_mses(i), t_mcts_mcti(i)
             , 'S', sysdate, p_mver_sequ
        );
    COMMIT;
end loop;
close c_mcts;

-- faz o vínculo dos convenios que já existem no GIOCONDA
pkg_mgr_imp_producao_aux.p_vincula_convenio_tipo_sese(p_migr_sequ);

end p_importa_convenio_tipo_sese;

procedure p_importa_convenio_sese(  p_migr_sequ     mgr_migracao.migr_sequ%type
                                  , p_mver_sequ     mgr_versao.mver_sequ%type) is

t_mcos_mcts     pkg_util.tb_number;
t_mcos_peju     pkg_util.tb_number;
t_mcos_perc     pkg_util.tb_number;
t_mcos_sequ     pkg_util.tb_number;

cursor c_mcos_upd(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.mcos_sequ
      FROM mgr_convenio_sese a
     WHERE EXISTS(  SELECT 1
                      FROM mgr_convenio_tipo_sese c
                         , mgr_versao x
                         , mgr_convenio_tipo d
                         , oli_convenio_temp b
                     WHERE c.mcts_sequ = a.mcos_mcts
                       AND c.mcts_atua = 'S'
                       AND x.mver_migr = pc_migr_sequ
                       AND x.mver_sequ = c.mcts_mver
                       AND d.mcti_sequ = c.mcts_mcti
                       AND b.cod_tipo_convenio = d.mcti_coti
                       AND b.codigo_peju_gioconda = a.mcos_peju
                       AND b.cmepercentual = a.mcos_perc
                       AND EXISTS (SELECT 1
                                     FROM mgr_semestre_sede y
                                    WHERE y.mses_sequ = c.mcts_mses
                                      AND y.mses_msed = b.msed_sequ
                                      AND y.mses_msem = b.msem_sequ
                                      AND y.mses_eper = b.mtus_peri));

cursor c_mcos(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.codigo_peju_gioconda
         , a.cmepercentual
         , c.mcts_sequ
      FROM mgr_convenio_tipo_sese c
         , mgr_convenio_tipo d
         , oli_convenio_temp a
         , mgr_semestre_sede b
     WHERE c.mcts_atua = 'S'
       AND EXISTS(  SELECT 1
                      FROM mgr_versao x
                     WHERE x.mver_migr = pc_migr_sequ
                       AND x.mver_sequ = c.mcts_mver)
       AND d.mcti_sequ = c.mcts_mcti
       AND a.cod_tipo_convenio = d.mcti_coti
       AND EXISTS (SELECT 1
                     FROM mgr_semestre_sede b
                    WHERE b.mses_sequ = c.mcts_mses
                      AND b.mses_msed = a.msed_sequ
                      AND b.mses_msem = a.msem_sequ
                      AND b.mses_eper = a.mtus_peri)
       AND NOT EXISTS(  SELECT 1
                          FROM mgr_convenio_sese y
                         WHERE y.mcos_peju = a.codigo_peju_gioconda
                           AND y.mcos_perc = a.cmepercentual
                           AND y.mcos_mcts = c.mcts_sequ)
     GROUP BY a.codigo_peju_gioconda
         , a.cmepercentual
         , c.mcts_sequ;

begin
-- faz o update no campo de controle, para sabermos no fim do processo o que foi atualizado
pkg_mgr_imp_producao_aux.p_update_inic_convenio_sese(p_migr_sequ);

-- traz os registros que já existem na tabela mgr apenas para atualizar o campo de controle
open c_mcos_upd(p_migr_sequ);
loop
    fetch c_mcos_upd bulk collect into  t_mcos_sequ
    limit pkg_util.c_limit_trans;
    exit when t_mcos_sequ.count = 0;

    forall i in t_mcos_sequ.first..t_mcos_sequ.last
        UPDATE mgr_convenio_sese
           SET mcos_atua = 'S'
             , mcos_datu = sysdate
         WHERE mcos_sequ = t_mcos_sequ(i);
    COMMIT;
end loop;
close c_mcos_upd;

-- traz todos os registros que ainda não existem na tabela mgr
open c_mcos(p_migr_sequ);
loop
    fetch c_mcos bulk collect into  t_mcos_peju, t_mcos_perc, t_mcos_mcts
    limit pkg_util.c_limit_trans;
    exit when t_mcos_peju.count = 0;

    for i in t_mcos_peju.first..t_mcos_peju.last loop

        t_mcos_sequ(i) := FGET_SEQU('SEQU_MGR_CONVENIO_SESE', 'MCOS_SEQU', 'MGR_CONVENIO_SESE');
    end loop;

    forall i in t_mcos_peju.first..t_mcos_peju.last
        INSERT INTO mgr_convenio_sese(
               mcos_sequ, mcos_peju, mcos_perc
             , mcos_mcts, mcos_atua, mcos_datu
             , mcos_mver
        ) VALUES (
               t_mcos_sequ(i), t_mcos_peju(i), t_mcos_perc(i)
             , t_mcos_mcts(i), 'S', sysdate
             , p_mver_sequ
        );
    COMMIT;
end loop;
close c_mcos;

pkg_mgr_imp_producao_aux.p_vincula_convenio_sese(p_migr_sequ);

end p_importa_convenio_sese;

procedure p_importa_convenio_alse(  p_migr_sequ     mgr_migracao.migr_sequ%type
                                  , p_mver_sequ     mgr_versao.mver_sequ%type) is

t_mcal_malt     pkg_util.tb_number;
t_mcal_mcos     pkg_util.tb_number;
t_mcal_pfim     pkg_util.tb_number;
t_mcal_pini     pkg_util.tb_number;
t_mcal_sequ     pkg_util.tb_number;

cursor c_mcal_upd(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.mcal_sequ
         , CASE WHEN b.data_inicio_conv BETWEEN
                        TO_DATE('01/01'|| TO_CHAR(b.data_inicio_conv, 'YYYY'), 'DD/MM/YYYY')
                    AND TO_DATE('30/06'|| TO_CHAR(b.data_inicio_conv, 'YYYY'), 'DD/MM/YYYY')
                    THEN b.mes_inicio_conv
                    ELSE b.mes_inicio_conv - 6
           END AS mcal_pini
         , CASE WHEN b.data_fim_conv BETWEEN
                        TO_DATE('01/01'|| TO_CHAR(b.data_fim_conv, 'YYYY'), 'DD/MM/YYYY')
                    AND TO_DATE('30/06'|| TO_CHAR(b.data_fim_conv, 'YYYY'), 'DD/MM/YYYY')
                    THEN b.mes_fim_conv
                    ELSE b.mes_fim_conv - 6
           END AS mcal_pfim
      FROM mgr_convenio_alse a
         , mgr_convenio_sese c
         , mgr_convenio_tipo_sese d
         , mgr_convenio_tipo e
         , oli_convenio_temp b
     WHERE c.mcos_sequ = a.mcal_mcos
       AND c.mcos_atua = 'S'
       AND d.mcts_sequ = c.mcos_mcts
       AND e.mcti_sequ = d.mcts_mcti
       AND b.cod_tipo_convenio = e.mcti_coti
       AND b.codigo_peju_gioconda = c.mcos_peju
       AND b.cmepercentual = c.mcos_perc
       AND b.malt_sequ = a.mcal_malt
       AND EXISTS(  SELECT 1
                      FROM mgr_semestre_sede y
                     WHERE y.mses_sequ = d.mcts_mses
                       AND y.mses_msem = b.msem_sequ
                       AND y.mses_msed = b.msed_sequ
                       AND y.mses_eper = b.mtus_peri)
       AND EXISTS(  SELECT 1
                      FROM mgr_versao x
                     WHERE x.mver_migr = pc_migr_sequ
                       AND x.mver_sequ = a.mcal_mver);

cursor c_mcal(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT b.malt_sequ
     , CASE WHEN b.data_inicio_conv BETWEEN
                    TO_DATE('01/01'|| TO_CHAR(b.data_inicio_conv, 'YYYY'), 'DD/MM/YYYY')
                AND TO_DATE('30/06'|| TO_CHAR(b.data_inicio_conv, 'YYYY'), 'DD/MM/YYYY')
                THEN b.mes_inicio_conv
                ELSE b.mes_inicio_conv - 6
       END AS mcal_pini
     , CASE WHEN b.data_fim_conv BETWEEN
                    TO_DATE('01/01'|| TO_CHAR(b.data_fim_conv, 'YYYY'), 'DD/MM/YYYY')
                AND TO_DATE('30/06'|| TO_CHAR(b.data_fim_conv, 'YYYY'), 'DD/MM/YYYY')
                THEN b.mes_fim_conv
                ELSE b.mes_fim_conv - 6
       END AS mcal_pfim
     , a.mcos_sequ
  FROM mgr_convenio_sese a
     , mgr_convenio_tipo_sese c
     , mgr_convenio_tipo d
     , oli_convenio_temp b
 WHERE a.mcos_atua = 'S'
   AND EXISTS(  SELECT 1
                  FROM mgr_versao x
                 WHERE x.mver_sequ = a.mcos_mver
                   AND x.mver_migr = pc_migr_sequ)
   AND c.mcts_sequ = a.mcos_mcts
   AND d.mcti_sequ = c.mcts_mcti
   AND b.cod_tipo_convenio = d.mcti_coti
   AND b.codigo_peju_gioconda = a.mcos_peju
   AND b.cmepercentual = a.mcos_perc
   AND EXISTS(  SELECT 1
                  FROM mgr_semestre_sede y
                 WHERE y.mses_sequ = c.mcts_mses
                   AND y.mses_msem = b.msem_sequ
                   AND y.mses_msed = b.msed_sequ
                   AND y.mses_eper = b.mtus_peri)
   AND NOT EXISTS(  SELECT 1
                      FROM mgr_convenio_alse y
                     WHERE y.mcal_malt = b.malt_sequ
                       AND y.mcal_mcos = a.mcos_sequ);

begin
-- faz o update inicial para controle do que será atualizado
pkg_mgr_imp_producao_aux.p_update_inic_convenio_alse(p_migr_sequ);

-- retorna os registros que já existem para atualizar o que for necessário
open c_mcal_upd(p_migr_sequ);
loop
    fetch c_mcal_upd bulk collect into t_mcal_sequ, t_mcal_pini, t_mcal_pfim
    limit pkg_util.c_limit_trans;
    exit when t_mcal_sequ.count = 0;

    forall i in t_mcal_sequ.first..t_mcal_sequ.last
        UPDATE mgr_convenio_alse
           SET mcal_atua = 'S'
             , mcal_datu = sysdate
             , mcal_pini = t_mcal_pini(i)
             , mcal_pfim = t_mcal_pfim(i)
         WHERE mcal_sequ = t_mcal_sequ(i);
    COMMIT;
end loop;
close c_mcal_upd;

-- retorna os registros que precisam ser inseridos
open c_mcal(p_migr_sequ);
loop
    fetch c_mcal bulk collect into  t_mcal_malt, t_mcal_pini, t_mcal_pfim
                                  , t_mcal_mcos
    limit pkg_util.c_limit_trans;
    exit when t_mcal_mcos.count = 0;

    for i in t_mcal_mcos.first..t_mcal_mcos.last loop

        t_mcal_sequ(i) := FGET_SEQU('SEQU_MGR_CONVENIO_ALSE', 'MCAL_SEQU', 'MGR_CONVENIO_ALSE');
    end loop;

    forall i in t_mcal_mcos.first..t_mcal_mcos.last
        INSERT INTO mgr_convenio_alse(
               mcal_sequ, mcal_malt, mcal_pini
             , mcal_pfim, mcal_mcos, mcal_atua
             , mcal_datu, mcal_mver
        ) VALUES (
               t_mcal_sequ(i), t_mcal_malt(i), t_mcal_pini(i)
             , t_mcal_pfim(i), t_mcal_mcos(i), 'S'
             , sysdate, p_mver_sequ
        );
    COMMIT;
end loop;
close c_mcal;

pkg_mgr_imp_producao_aux.p_vincula_convenio_alse(p_migr_sequ);

end p_importa_convenio_alse;

procedure p_importa_mensalidade(p_migr_sequ     mgr_migracao.migr_sequ%type
                              , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- tabelas utilizadas nos updates
t_mmen_sequ_upd     pkg_util.tb_number;
t_mmen_valo_upd     pkg_util.tb_number;
t_mmen_dven_upd     pkg_util.tb_date;
t_mmen_dpag_upd     pkg_util.tb_date;
t_mmen_vpag_upd     pkg_util.tb_number;
t_mmen_seqb_upd     pkg_util.tb_varchar2_150;
t_mmen_tbai_upd     pkg_util.tb_varchar2_1;
t_mmen_obse_upd     pkg_util.tb_varchar2_4000;
t_mmen_nnum_upd     pkg_util.tb_varchar2_50;
t_mmen_dref_upd     pkg_util.tb_date;
t_mmen_conb_upd     pkg_util.tb_varchar2_150;

-- tabelas utilizadas nos inserts
t_mmen_chav_ins     pkg_util.tb_varchar2_150;
t_mmen_malu_ins     pkg_util.tb_number;
t_mmen_msef_ins     pkg_util.tb_number;
t_mmen_valo_ins     pkg_util.tb_number;
t_mmen_dven_ins     pkg_util.tb_date;
t_mmen_dpag_ins     pkg_util.tb_date;
t_mmen_vpag_ins     pkg_util.tb_number;
t_mmen_seqb_ins     pkg_util.tb_varchar2_150;
t_mmen_tbai_ins     pkg_util.tb_varchar2_1;
t_mmen_obse_ins     pkg_util.tb_varchar2_4000;
t_mmen_nnum_ins     pkg_util.tb_varchar2_50;
t_mmen_dref_ins     pkg_util.tb_date;
t_mmen_conb_ins     pkg_util.tb_varchar2_150;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

-- outras variáveis
l_mmen_obse         mgr_mensalidade.mmen_obse%type;
l_mmen_tbai         mgr_mensalidade.mmen_tbai%type;

cursor c_mens(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.almnum mmen_chav
         , c.malu_sequ mmen_malu
         , d.msef_sequ mmen_msef
         , a.almvalormensalidade mmen_valo
         , a.almdatavencto mmen_dven
         , NVL(b.tradataacerto, NVL(a.almdatabaixa, TRUNC(b.tradatahora))) mmen_dpag
         , DECODE(b.tranum, NULL, NULL, NVL(a.almvalormensalidade, 0) + NVL(a.almvalorjuros, 0) - NVL(a.almvalordesconto, 0)) mmen_vpag
         , b.tranum mmen_seqb
         , (SELECT ROUND(NVL(SUM(v.cmepercentual), 0), 2)
              FROM oli_convmens v
             WHERE v.alucod = a.alucod
               AND v.menano = a.menano
               AND v.menmes = a.menmes) perc_conv
         -- caso tenha sido gerado um carne (agrupamento de vários débitos) então prioriza esta informação
         , NVL((SELECT MAX(y.carnumbloqueto)
              FROM oli_carnmens x
                 , oli_carne y
             WHERE x.almnum = a.almnum
               AND y.carnum = x.carnum) ,
               a.almnumbloqueto) mmen_nnum
         , DECODE(b.tratipo, 'C', 'Recebimento (crédito)'
                       , 'R', 'Retirada de caixa'
                       , 'B', 'Baixa de títulos via arquivo retorno'
                       , 'V', 'Baixa por conversão do sistema antigo'
                       , 'A', 'Acerto de Rematricula'
                       , 'P', 'Carne Unificado'
                       , 'O', 'Proposta de Acerto'
                       , 'I', 'Baixa de registro de arquivo retorno no tratamento da inconsistência'
                       , NULL) form_pgto
         , (SELECT MAX(m.mmen_sequ)
              FROM mgr_mensalidade m
             WHERE m.mmen_malu = c.malu_sequ
               AND m.mmen_chav = TO_CHAR(a.almnum)) mmen_sequ
         , a.menano
         , a.menmes
         , TO_DATE('01/' || a.menmes || '/' || a.menano, 'dd/mm/yyyy') mmen_dref
         , (SELECT MAX(p.pccvalor)
              FROM oli_paraccob p
             WHERE p.caccod = a.caccod
               AND p.pccdesc = 'COD_CEDENTE') cart_cobr
      FROM mgr_aluno c
         , mgr_curso i
         , oli_alunmens a
         , oli_trancaix b
         , mgr_semestre_financeiro d
     WHERE c.malu_atua = 'S'
       AND EXISTS(  SELECT 1
                      FROM mgr_versao w
                     WHERE w.mver_migr = pc_migr_sequ
                       AND w.mver_sequ = c.malu_mver)
       AND i.mcur_sequ = c.malu_mcur
       AND a.alucod = TO_NUMBER(c.malu_chav)
       AND a.espcod = TO_NUMBER(i.mcur_chav)
       AND a.menano BETWEEN 2013 AND 2016
       AND b.tranum(+) = a.tranum
	   AND d.msef_atua = 'S'
       AND TO_DATE('01/' || a.menmes || '/' || a.menano, 'dd/mm/yyyy') -- monta a data usando mês e ano da mensalidade
                    BETWEEN d.msef_dini AND d.msef_dfim;

begin

pkg_mgr_imp_producao_aux.p_update_inicio_mensalidade(   p_migr_sequ);

pkg_mgr_imp_producao_aux.p_update_tabela_mensalidade(   t_mmen_sequ_upd, t_mmen_valo_upd, t_mmen_dven_upd
                                                      , t_mmen_dpag_upd, t_mmen_vpag_upd, t_mmen_seqb_upd
                                                      , t_mmen_tbai_upd, t_mmen_obse_upd, t_mmen_nnum_upd
                                                      , t_mmen_dref_upd, t_mmen_conb_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_mensalidade(   p_mver_sequ, t_mmen_chav_ins, t_mmen_malu_ins
                                                      , t_mmen_msef_ins, t_mmen_valo_ins, t_mmen_dven_ins
                                                      , t_mmen_dpag_ins, t_mmen_vpag_ins, t_mmen_seqb_ins
                                                      , t_mmen_tbai_ins, t_mmen_obse_ins, t_mmen_nnum_ins
                                                      , t_mmen_dref_ins, t_mmen_conb_ins, l_contador_ins);

for r_c_mens in c_mens(p_migr_sequ) loop

    -- a observação vai pelo menos conter o mês e ano da mensalidade para conferência posterior
    l_mmen_obse := 'Competência da mensalidade ' || r_c_mens.menmes || '/' || r_c_mens.menano || pkg_util.c_enter;

    -- como padrão sempre será Normal o tipo de pagamento
    l_mmen_tbai := '1';

    -- se tiver um percentual de convênio colocamos na observação e setamos o tipo de baixa como convênio parcial
    if  (r_c_mens.perc_conv > 0) then

        l_mmen_obse := l_mmen_obse || ' Convênio de ' || r_c_mens.perc_conv || '% para esta mensalidade.' || pkg_util.c_enter;

        l_mmen_tbai := '3';
    end if;

    -- se tem forma de pagamento também inclui na observação
    if  (r_c_mens.form_pgto is not null) then

        l_mmen_obse := l_mmen_obse || ' Forma de pagamento da mensalidade: ' || r_c_mens.form_pgto || pkg_util.c_enter;
    end if;

    -- se já existe o registro na tabela então é update
    if  (r_c_mens.mmen_sequ is not null) then

        -- alimenta as variáveis table utilizadas no update
        t_mmen_sequ_upd(l_contador_upd) := r_c_mens.mmen_sequ;
        t_mmen_valo_upd(l_contador_upd) := r_c_mens.mmen_valo;
        t_mmen_dven_upd(l_contador_upd) := r_c_mens.mmen_dven;
        t_mmen_dpag_upd(l_contador_upd) := r_c_mens.mmen_dpag;
        t_mmen_vpag_upd(l_contador_upd) := r_c_mens.mmen_vpag;
        t_mmen_seqb_upd(l_contador_upd) := r_c_mens.mmen_seqb;
        t_mmen_tbai_upd(l_contador_upd) := l_mmen_tbai;
        t_mmen_obse_upd(l_contador_upd) := l_mmen_obse;
        t_mmen_nnum_upd(l_contador_upd) := r_c_mens.mmen_nnum;
        t_mmen_dref_upd(l_contador_upd) := r_c_mens.mmen_dref;
        t_mmen_conb_upd(l_contador_upd) := r_c_mens.cart_cobr;

        l_contador_upd := l_contador_upd + 1;
    else

        -- alimenta as variáveis table utilizadas no insert
        t_mmen_chav_ins(l_contador_ins) := r_c_mens.mmen_chav;
        t_mmen_malu_ins(l_contador_ins) := r_c_mens.mmen_malu;
        t_mmen_msef_ins(l_contador_ins) := r_c_mens.mmen_msef;
        t_mmen_valo_ins(l_contador_ins) := r_c_mens.mmen_valo;
        t_mmen_dven_ins(l_contador_ins) := r_c_mens.mmen_dven;
        t_mmen_dpag_ins(l_contador_ins) := r_c_mens.mmen_dpag;
        t_mmen_vpag_ins(l_contador_ins) := r_c_mens.mmen_vpag;
        t_mmen_seqb_ins(l_contador_ins) := r_c_mens.mmen_seqb;
        t_mmen_tbai_ins(l_contador_ins) := l_mmen_tbai;
        t_mmen_obse_ins(l_contador_ins) := l_mmen_obse;
        t_mmen_nnum_ins(l_contador_ins) := r_c_mens.mmen_nnum;
        t_mmen_dref_ins(l_contador_ins) := r_c_mens.mmen_dref;
        t_mmen_conb_ins(l_contador_ins) := r_c_mens.cart_cobr;

        l_contador_ins := l_contador_ins + 1;
    end if;

    -- verifica se atingiu a quantidade de registros por transação
    if  (l_contador_trans >= pkg_util.c_limit_trans) then

        -- atualiza os registro e devolve as variáveis reinicializadas
        pkg_mgr_imp_producao_aux.p_update_tabela_mensalidade(   t_mmen_sequ_upd, t_mmen_valo_upd, t_mmen_dven_upd
                                                              , t_mmen_dpag_upd, t_mmen_vpag_upd, t_mmen_seqb_upd
                                                              , t_mmen_tbai_upd, t_mmen_obse_upd, t_mmen_nnum_upd
                                                              , t_mmen_dref_upd, t_mmen_conb_upd, l_contador_upd);

        -- insere os registro e devolve as variáveis reinicializadas
        pkg_mgr_imp_producao_aux.p_insert_tabela_mensalidade(   p_mver_sequ, t_mmen_chav_ins, t_mmen_malu_ins
                                                              , t_mmen_msef_ins, t_mmen_valo_ins, t_mmen_dven_ins
                                                              , t_mmen_dpag_ins, t_mmen_vpag_ins, t_mmen_seqb_ins
                                                              , t_mmen_tbai_ins, t_mmen_obse_ins, t_mmen_nnum_ins
                                                              , t_mmen_dref_ins, t_mmen_conb_ins, l_contador_ins);

        l_contador_trans := 1;
    else
        l_contador_trans := l_contador_trans + 1;
    end if;
end loop;

pkg_mgr_imp_producao_aux.p_update_tabela_mensalidade(   t_mmen_sequ_upd, t_mmen_valo_upd, t_mmen_dven_upd
                                                      , t_mmen_dpag_upd, t_mmen_vpag_upd, t_mmen_seqb_upd
                                                      , t_mmen_tbai_upd, t_mmen_obse_upd, t_mmen_nnum_upd
                                                      , t_mmen_dref_upd, t_mmen_conb_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_mensalidade(   p_mver_sequ, t_mmen_chav_ins, t_mmen_malu_ins
                                                      , t_mmen_msef_ins, t_mmen_valo_ins, t_mmen_dven_ins
                                                      , t_mmen_dpag_ins, t_mmen_vpag_ins, t_mmen_seqb_ins
                                                      , t_mmen_tbai_ins, t_mmen_obse_ins, t_mmen_nnum_ins
                                                      , t_mmen_dref_ins, t_mmen_conb_ins, l_contador_ins);

end p_importa_mensalidade;

procedure p_importa_mensalidade_conv(   p_migr_sequ     mgr_migracao.migr_sequ%type
                                      , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- tabelas para update
t_mmco_sequ_upd     pkg_util.tb_number;
t_mmco_perc_upd     pkg_util.tb_number;
t_mmco_valo_upd     pkg_util.tb_number;
t_mmco_dref_upd     pkg_util.tb_date;

-- tabelas para insert
t_mmco_malu_ins     pkg_util.tb_number;
t_mmco_msef_ins     pkg_util.tb_number;
t_mmco_perc_ins     pkg_util.tb_number;
t_mmco_valo_ins     pkg_util.tb_number;
t_mmco_dref_ins     pkg_util.tb_date;
t_mmco_chav_ins     pkg_util.tb_varchar2_150;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

cursor c_menc(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.cmenum mmco_chav
         , b.malu_sequ mmco_malu
         , c.msef_sequ mmco_msef
         , TO_DATE('01/' || a.menmes || '/' || a.menano, 'dd/mm/yyyy') mmco_dref
         , ROUND(a.cmevalor, 2) mmco_valo
         , ROUND(a.cmepercentual, 2) mmco_perc
         , (SELECT MAX(m.mmco_sequ)
              FROM mgr_mensalidade_conv m
             WHERE m.mmco_malu = b.malu_sequ
               AND m.mmco_chav = TO_CHAR(a.cmenum)) mmco_sequ
      FROM mgr_aluno b
         , mgr_curso d
         , oli_convmens a
         , mgr_semestre_financeiro c
     WHERE b.malu_atua = 'S'
       AND EXISTS(  SELECT 1
                      FROM mgr_versao w
                     WHERE w.mver_migr = pc_migr_sequ
                       AND w.mver_sequ = b.malu_mver)
       AND d.mcur_sequ = b.malu_mcur
       AND a.alucod = b.malu_chav
       AND a.espcod = d.mcur_chav
       AND a.menano BETWEEN 2013 AND 2016
	   AND c.msef_atua = 'S'
       AND TO_DATE('01/' || a.menmes || '/' || a.menano, 'dd/mm/yyyy') -- monta a data usando mês e ano da mensalidade
                    BETWEEN c.msef_dini AND c.msef_dfim;

begin

pkg_mgr_imp_producao_aux.p_update_inicio_mens_conv( p_migr_sequ);

pkg_mgr_imp_producao_aux.p_update_tabela_mens_conv( t_mmco_sequ_upd, t_mmco_perc_upd, t_mmco_valo_upd
                                                  , t_mmco_dref_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_mens_conv( p_mver_sequ, t_mmco_malu_ins, t_mmco_msef_ins
                                                  , t_mmco_perc_ins, t_mmco_valo_ins, t_mmco_dref_ins
                                                  , t_mmco_chav_ins, l_contador_ins);

l_contador_trans := 1;

for r_c_menc in c_menc(p_migr_sequ) loop

    -- se já existe o registro na tabela então é update
    if  (r_c_menc.mmco_sequ is not null) then

        -- alimenta as variáveis table utilizadas no update
        t_mmco_sequ_upd(l_contador_upd) := r_c_menc.mmco_sequ;
        t_mmco_perc_upd(l_contador_upd) := r_c_menc.mmco_perc;
        t_mmco_valo_upd(l_contador_upd) := r_c_menc.mmco_valo;
        t_mmco_dref_upd(l_contador_upd) := r_c_menc.mmco_dref;

        l_contador_upd := l_contador_upd + 1;
    else

        -- alimenta as variáveis table utilizadas no insert
        t_mmco_malu_ins(l_contador_ins) := r_c_menc.mmco_malu;
        t_mmco_msef_ins(l_contador_ins) := r_c_menc.mmco_msef;
        t_mmco_perc_ins(l_contador_ins) := r_c_menc.mmco_perc;
        t_mmco_valo_ins(l_contador_ins) := r_c_menc.mmco_valo;
        t_mmco_dref_ins(l_contador_ins) := r_c_menc.mmco_dref;
        t_mmco_chav_ins(l_contador_ins) := r_c_menc.mmco_chav;

        l_contador_ins := l_contador_ins + 1;
    end if;

    -- verifica se atingiu a quantidade de registros por transação
    if  (l_contador_trans >= pkg_util.c_limit_trans) then

        -- atualiza os registro e devolve as variáveis reinicializadas
        pkg_mgr_imp_producao_aux.p_update_tabela_mens_conv( t_mmco_sequ_upd, t_mmco_perc_upd, t_mmco_valo_upd
                                                          , t_mmco_dref_upd, l_contador_upd);

        -- insere os registro e devolve as variáveis reinicializadas
        pkg_mgr_imp_producao_aux.p_insert_tabela_mens_conv( p_mver_sequ, t_mmco_malu_ins, t_mmco_msef_ins
                                                          , t_mmco_perc_ins, t_mmco_valo_ins, t_mmco_dref_ins
                                                          , t_mmco_chav_ins, l_contador_ins);

        l_contador_trans := 1;
    else
        l_contador_trans := l_contador_trans + 1;
    end if;
end loop;

pkg_mgr_imp_producao_aux.p_update_tabela_mens_conv( t_mmco_sequ_upd, t_mmco_perc_upd, t_mmco_valo_upd
                                                  , t_mmco_dref_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_mens_conv( p_mver_sequ, t_mmco_malu_ins, t_mmco_msef_ins
                                                  , t_mmco_perc_ins, t_mmco_valo_ins, t_mmco_dref_ins
                                                  , t_mmco_chav_ins, l_contador_ins);

pkg_mgr_imp_producao_aux.p_vincula_mens_conv(p_migr_sequ);

end p_importa_mensalidade_conv;

procedure p_gera_mens_convenio_cem_perc(    p_migr_sequ     mgr_migracao.migr_sequ%type
                                          , p_mver_sequ     mgr_versao.mver_sequ%type) is

t_mmen_sequ     pkg_util.tb_number;

t_mmen_chav     pkg_util.tb_varchar2_150;
t_mmen_malu     pkg_util.tb_number;
t_mmen_msef     pkg_util.tb_number;
t_mmen_valo     pkg_util.tb_number;
t_mmen_dven     pkg_util.tb_date;
t_mmen_dpag     pkg_util.tb_date;
t_mmen_vpag     pkg_util.tb_number;
t_mmen_seqb     pkg_util.tb_varchar2_150;
t_mmen_tbai     pkg_util.tb_varchar2_1;
t_mmen_obse     pkg_util.tb_varchar2_4000;
t_mmen_nnum     pkg_util.tb_varchar2_50;
t_mmen_dref     pkg_util.tb_date;
t_mmen_conb     pkg_util.tb_varchar2_150;

t_mmco_mmen     pkg_util.tb_number;
t_mmco_sequ     pkg_util.tb_number;

l_contador      pls_integer;

l_dt_venc_pag   date;
l_mmen_obse     mgr_mensalidade.mmen_obse%type;

cursor c_atua_mens( pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT DISTINCT b.mmen_sequ
      FROM mgr_versao c
         , mgr_mensalidade_conv a
         , mgr_mensalidade b
     WHERE c.mver_migr = pc_migr_sequ
       AND a.mmco_mver = c.mver_sequ
       AND a.mmco_atua = 'S'
       AND b.mmen_sequ = a.mmco_mmen
       AND b.mmen_gera = 'S';

cursor c_conv(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.mmco_malu
         , a.mmco_msef
         , SUM(a.mmco_perc) mmco_perc
         , SUM(a.mmco_valo) mmco_valo
         , b.menano
         , b.menmes
         , b.alucod
         , a.mmco_dref
      FROM mgr_mensalidade_conv a
         , oli_convmens b
     WHERE a.mmco_atua = 'S'
       AND a.mmco_mmen IS NULL
       AND EXISTS( SELECT 1
                     FROM mgr_versao y
                    WHERE y.mver_migr = pc_migr_sequ
                      AND y.mver_sequ = a.mmco_mver)
       AND b.cmenum = a.mmco_chav
       AND NOT EXISTS( SELECT 1
                         FROM mgr_mensalidade x
                        WHERE x.mmen_sequ = a.mmco_mmen)
     GROUP BY a.mmco_malu, a.mmco_msef, b.menano, b.menmes, b.alucod, a.mmco_dref;

cursor c_vinc(  pc_mver_sequ     mgr_versao.mver_sequ%type) is
    SELECT a.mmen_sequ
         , b.mmco_sequ
      FROM mgr_mensalidade a
         , mgr_mensalidade_conv b
         , oli_convmens c
     WHERE a.mmen_mver = pc_mver_sequ
       AND a.mmen_atua = 'S'
       AND a.mmen_gera = 'S'
       AND b.mmco_malu = a.mmen_malu
       AND b.mmco_msef = a.mmen_msef
       AND TO_DATE('01/' || c.menmes || '/' || c.menano, 'dd/mm/yyyy') = a.mmen_dref
       AND b.mmco_mmen IS NULL
       AND c.cmenum = b.mmco_chav;

begin

-- retorna todos os registros que já foram gerados em importações anteriores e atualiza os que forem necessários
-- só irá retornar aqui os registros que tenham sido gerados pela rotina e que o convênio 100% que o gerou tenha
-- sido alterado nesta importação
open c_atua_mens(p_migr_sequ);
loop
    fetch c_atua_mens bulk collect into t_mmen_sequ
    limit pkg_util.c_limit_trans;
    exit when t_mmen_sequ.count = 0;

    forall i in t_mmen_sequ.first..t_mmen_sequ.last
        UPDATE mgr_mensalidade
           SET mmen_atua = 'S'
         WHERE mmen_sequ = t_mmen_sequ(i);
    commit;
end loop;
close c_atua_mens;

pkg_mgr_imp_producao_aux.p_insert_tabela_mensalidade(   p_mver_sequ, t_mmen_chav, t_mmen_malu
                                                      , t_mmen_msef, t_mmen_valo, t_mmen_dven
                                                      , t_mmen_dpag, t_mmen_vpag, t_mmen_seqb
                                                      , t_mmen_tbai, t_mmen_obse, t_mmen_nnum
                                                      , t_mmen_dref, t_mmen_conb, l_contador
                                                      , 'S');

-- retorna todos os convênios que não possuem uma mensalidade para o mês/ano/aluno e curso correspondente
-- existem alguns casos de mensalidades que deveriam ter sido geradas no Olimpo porém não foram, estes estamos
-- gerando apenas para histórico
for r_c_conv in c_conv(p_migr_sequ) loop

    -- se a soma dos convênios for igual ou maior que 100%, exitem alguns casos em que os convênios somam mais de 100%
    -- um deles é quando há uma bolsa e o aluno tem uma redução de carga horária, no Olimpo eles lançavam um convênio
    -- para fazer esta redução
    if  (r_c_conv.mmco_perc >= 100) then

        -- convênio total
        t_mmen_tbai(l_contador) := '2';
        l_mmen_obse := 'Convênio 100%';
    else
        -- convênio parcial
        t_mmen_tbai(l_contador) := '3';
        l_mmen_obse := 'Convênio ' || TO_CHAR(r_c_conv.mmco_perc) || '%';
    end if;

    -- formata a data que será utilizada tanto para o vencimento quanto para o pagamento
    l_dt_venc_pag := TO_DATE('10/' || r_c_conv.menmes || '/' || r_c_conv.menano, 'dd/mm/yyyy');

    t_mmen_chav(l_contador) := null; -- como é gerado pela rotina não tem uma chav
    t_mmen_conb(l_contador) := null;
    t_mmen_malu(l_contador) := r_c_conv.mmco_malu;
    t_mmen_msef(l_contador) := r_c_conv.mmco_msef;
    t_mmen_valo(l_contador) := r_c_conv.mmco_valo;
    t_mmen_dven(l_contador) := l_dt_venc_pag;
    t_mmen_dpag(l_contador) := l_dt_venc_pag;
    t_mmen_vpag(l_contador) := 0; -- Conforme alinhado iremos deixar o valor pago como zerado, assim como será feito no título que será gerado
    t_mmen_seqb(l_contador) := null;
    t_mmen_obse(l_contador) := l_mmen_obse;
    t_mmen_nnum(l_contador) := null;
    t_mmen_dref(l_contador) := TO_DATE('01/' || r_c_conv.menmes || '/' || r_c_conv.menano, 'dd/mm/yyyy');

    if  (l_contador >= pkg_util.c_limit_trans) then

        pkg_mgr_imp_producao_aux.p_insert_tabela_mensalidade(   p_mver_sequ, t_mmen_chav, t_mmen_malu
                                                              , t_mmen_msef, t_mmen_valo, t_mmen_dven
                                                              , t_mmen_dpag, t_mmen_vpag, t_mmen_seqb
                                                              , t_mmen_tbai, t_mmen_obse, t_mmen_nnum
                                                              , t_mmen_dref, t_mmen_conb, l_contador
                                                              , 'S');
    else

        l_contador := l_contador + 1;
    end if;
end loop;

pkg_mgr_imp_producao_aux.p_insert_tabela_mensalidade(   p_mver_sequ, t_mmen_chav, t_mmen_malu
                                                      , t_mmen_msef, t_mmen_valo, t_mmen_dven
                                                      , t_mmen_dpag, t_mmen_vpag, t_mmen_seqb
                                                      , t_mmen_tbai, t_mmen_obse, t_mmen_nnum
                                                      , t_mmen_dref, t_mmen_conb, l_contador
                                                      , 'S');

-- retorna todos os registros de convênio que não tenham ainda sido vínculados a uma mensalidade
-- serve para víncular os registros gerados acima com os registros que os originaram
open c_vinc(p_mver_sequ);
loop
    fetch c_vinc bulk collect into t_mmco_mmen, t_mmco_sequ
    limit pkg_util.c_limit_trans;
    exit when t_mmco_mmen.count = 0;

    forall i in t_mmco_mmen.first..t_mmco_mmen.last
        UPDATE mgr_mensalidade_conv
           SET mmco_mmen = t_mmco_mmen(i)
         WHERE mmco_sequ = t_mmco_sequ(i);
    commit;
end loop;

close c_vinc;

end p_gera_mens_convenio_cem_perc;

procedure p_importa_requerimento(   p_migr_sequ     mgr_migracao.migr_sequ%type
                                  , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- tabelas utilizadas no update
t_mreq_sequ_upd     pkg_util.tb_number;
t_mreq_valo_upd     pkg_util.tb_number;
t_mreq_dven_upd     pkg_util.tb_date;
t_mreq_dpag_upd     pkg_util.tb_date;
t_mreq_vpag_upd     pkg_util.tb_number;
t_mreq_seqb_upd     pkg_util.tb_varchar2_150;
t_mreq_obse_upd     pkg_util.tb_varchar2_4000;
t_mreq_nnum_upd     pkg_util.tb_varchar2_50;
t_mreq_dref_upd     pkg_util.tb_date;
t_mreq_conb_upd     pkg_util.tb_varchar2_150;
t_mreq_serv_upd     pkg_util.tb_number;

-- tabelas utilizadas no insert
t_mreq_chav_ins     pkg_util.tb_varchar2_150;
t_mreq_malu_ins     pkg_util.tb_number;
t_mreq_msem_ins     pkg_util.tb_number;
t_mreq_valo_ins     pkg_util.tb_number;
t_mreq_dven_ins     pkg_util.tb_date;
t_mreq_dpag_ins     pkg_util.tb_date;
t_mreq_vpag_ins     pkg_util.tb_number;
t_mreq_seqb_ins     pkg_util.tb_varchar2_150;
t_mreq_obse_ins     pkg_util.tb_varchar2_4000;
t_mreq_nnum_ins     pkg_util.tb_varchar2_50;
t_mreq_dref_ins     pkg_util.tb_date;
t_mreq_conb_ins     pkg_util.tb_varchar2_150;
t_mreq_serv_ins     pkg_util.tb_number;

-- contador
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

l_mreq_obse         mgr_requerimento.mreq_obse%type;

cursor c_requ(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT TO_CHAR(c.salnum) mreq_chav
         , a.malu_sequ mreq_malu
         , e.msef_sequ mreq_msem
         , c.salvlrtotal mreq_valo
         , NVL(c.saldatavencimento, TO_DATE('10/' || c.menmes || '/' || c.menano, 'dd/mm/yyyy')) mreq_dven
         , NVL(f.tradataacerto, TRUNC(f.tradatahora)) mreq_dpag
         , DECODE(f.tradatahora, NULL, NULL, NVL(c.salvlrtotal, 0) + NVL(c.saljuros, 0) - NVL(c.saldesconto, 0)) mreq_vpag
         , c.tranum mreq_seqb
         , DECODE(f.tratipo, 'C', 'Recebimento (crédito)'
                           , 'R', 'Retirada de caixa'
                           , 'B', 'Baixa de títulos via arquivo retorno'
                           , 'V', 'Baixa por conversão do sistema antigo'
                           , 'A', 'Acerto de Rematricula'
                           , 'P', 'Carne Unificado'
                           , 'O', 'Proposta de Acerto'
                           , 'I', 'Baixa de registro de arquivo retorno no tratamento da inconsistência'
                           , null) baix_serv
         , d.serdesc desc_serv
         , c.salobservacao obse_serv
         , TO_CHAR(c.menmes) || '/' || TO_CHAR(c.menano) comp_serv
         , TO_DATE('01/' || c.menmes || '/' || c.menano, 'dd/mm/yyyy') mreq_dref
         -- caso tenha sido gerado um carne (agrupamento de vários débitos) então prioriza esta informação
         , NVL((SELECT MAX(y.carnumbloqueto)
              FROM oli_carnserv x
                 , oli_carne y
             WHERE x.salnum = c.salnum
               AND y.carnum = x.carnum),
               c.salnumbloqueto) mreq_nnum
         , (SELECT MAX(z.mreq_sequ)
              FROM mgr_requerimento z
             WHERE z.mreq_chav = TO_CHAR(c.salnum)) mreq_sequ
         , (SELECT MAX(p.pccvalor)
              FROM oli_paraccob p
             WHERE p.caccod = f.caccod
               AND p.pccdesc = 'COD_CEDENTE') cart_cobr_b 
         , (SELECT MAX(p.pccvalor)
              FROM oli_paraccob p
             WHERE p.caccod = c.caccod
               AND p.pccdesc = 'COD_CEDENTE') cart_cobr
         , d.sercod
      FROM mgr_aluno a
         , mgr_curso b
         , oli_servalun c
         , oli_servicos d
         , mgr_semestre_financeiro e
         , oli_trancaix f
     WHERE a.malu_atua = 'S'
       AND EXISTS(  SELECT 1
                      FROM mgr_versao x
                     WHERE x.mver_migr = pc_migr_sequ
                       AND x.mver_sequ = a.malu_mver)
       AND b.mcur_sequ = a.malu_mcur
       AND c.alucod = a.malu_chav
       AND c.espcod = b.mcur_chav
       AND c.saldatasol BETWEEN PKG_UTIL_DATA.INICIO_DIA(TO_DATE('01/01/2013', 'DD/MM/YYYY')) 
						    AND PKG_UTIL_DATA.FIM_DIA(TO_DATE('31/12/2016', 'DD/MM/YYYY'))
       AND d.sercod = c.sercod
	   AND e.msef_atua = 'S'
       AND c.saldatasol BETWEEN e.msef_dini AND e.msef_dfim
       AND f.tranum(+) = c.tranum;

begin

pkg_mgr_imp_producao_aux.p_update_inicio_requerimento(  p_migr_sequ);

pkg_mgr_imp_producao_aux.p_update_tabela_requerimento(  t_mreq_sequ_upd, t_mreq_valo_upd, t_mreq_dven_upd
                                                      , t_mreq_dpag_upd, t_mreq_vpag_upd, t_mreq_seqb_upd
                                                      , t_mreq_obse_upd, t_mreq_nnum_upd, t_mreq_dref_upd
                                                      , t_mreq_conb_upd, t_mreq_serv_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_requerimento(  p_mver_sequ, t_mreq_chav_ins, t_mreq_malu_ins
                                                      , t_mreq_msem_ins, t_mreq_valo_ins, t_mreq_dven_ins
                                                      , t_mreq_dpag_ins, t_mreq_vpag_ins, t_mreq_seqb_ins
                                                      , t_mreq_obse_ins, t_mreq_nnum_ins, t_mreq_dref_ins
                                                      , t_mreq_conb_ins, t_mreq_serv_ins, l_contador_ins);

for r_c_requ in c_requ(p_migr_sequ) loop

    l_mreq_obse := SUBSTR(  'Serviço: ' || r_c_requ.desc_serv || pkg_util.c_enter ||
                            'Competência: ' || r_c_requ.comp_serv || pkg_util.c_enter, 1, 4000);

    if  (r_c_requ.baix_serv is not null) then

        l_mreq_obse := SUBSTR(l_mreq_obse || 'Baixa: ' || r_c_requ.baix_serv || pkg_util.c_enter, 1, 4000);
    end if;

    if  (r_c_requ.obse_serv is not null) then

        l_mreq_obse := SUBSTR(l_mreq_obse || 'Obs.: ' || r_c_requ.obse_serv || pkg_util.c_enter, 1, 4000);
    end if;

    -- se já existe o registro na tabela então é update
    if  (r_c_requ.mreq_sequ is not null) then

        -- alimenta as variáveis table utilizadas no update
        t_mreq_sequ_upd(l_contador_upd) := r_c_requ.mreq_sequ;
        t_mreq_valo_upd(l_contador_upd) := r_c_requ.mreq_valo;
        t_mreq_dven_upd(l_contador_upd) := r_c_requ.mreq_dven;
        t_mreq_dpag_upd(l_contador_upd) := r_c_requ.mreq_dpag;
        t_mreq_vpag_upd(l_contador_upd) := r_c_requ.mreq_vpag;
        t_mreq_seqb_upd(l_contador_upd) := r_c_requ.mreq_seqb;
        t_mreq_obse_upd(l_contador_upd) := l_mreq_obse;
        t_mreq_nnum_upd(l_contador_upd) := r_c_requ.mreq_nnum;
        t_mreq_dref_upd(l_contador_upd) := r_c_requ.mreq_dref;
        t_mreq_conb_upd(l_contador_upd) := NVL(r_c_requ.cart_cobr_b, r_c_requ.cart_cobr);
        t_mreq_serv_upd(l_contador_upd) := r_c_requ.sercod;

        l_contador_upd := l_contador_upd + 1;
    else

        -- alimenta as variáveis table utilizadas no insert
        t_mreq_chav_ins(l_contador_ins) := r_c_requ.mreq_chav;
        t_mreq_malu_ins(l_contador_ins) := r_c_requ.mreq_malu;
        t_mreq_msem_ins(l_contador_ins) := r_c_requ.mreq_msem;
        t_mreq_valo_ins(l_contador_ins) := r_c_requ.mreq_valo;
        t_mreq_dven_ins(l_contador_ins) := r_c_requ.mreq_dven;
        t_mreq_dpag_ins(l_contador_ins) := r_c_requ.mreq_dpag;
        t_mreq_vpag_ins(l_contador_ins) := r_c_requ.mreq_vpag;
        t_mreq_seqb_ins(l_contador_ins) := r_c_requ.mreq_seqb;
        t_mreq_obse_ins(l_contador_ins) := l_mreq_obse;
        t_mreq_nnum_ins(l_contador_ins) := r_c_requ.mreq_nnum;
        t_mreq_dref_ins(l_contador_ins) := r_c_requ.mreq_dref;
        t_mreq_conb_ins(l_contador_ins) := NVL(r_c_requ.cart_cobr_b, r_c_requ.cart_cobr);
        t_mreq_serv_ins(l_contador_ins) := r_c_requ.sercod;

        l_contador_ins := l_contador_ins + 1;
    end if;

    -- verifica se atingiu a quantidade de registros por transação
    if  (l_contador_trans >= pkg_util.c_limit_trans) then

        -- atualiza os registro e devolve as variáveis reinicializadas
        pkg_mgr_imp_producao_aux.p_update_tabela_requerimento(  t_mreq_sequ_upd, t_mreq_valo_upd, t_mreq_dven_upd
                                                              , t_mreq_dpag_upd, t_mreq_vpag_upd, t_mreq_seqb_upd
                                                              , t_mreq_obse_upd, t_mreq_nnum_upd, t_mreq_dref_upd
                                                              , t_mreq_conb_upd, t_mreq_serv_upd, l_contador_upd);

        -- insere os registro e devolve as variáveis reinicializadas
        pkg_mgr_imp_producao_aux.p_insert_tabela_requerimento(  p_mver_sequ, t_mreq_chav_ins, t_mreq_malu_ins
                                                              , t_mreq_msem_ins, t_mreq_valo_ins, t_mreq_dven_ins
                                                              , t_mreq_dpag_ins, t_mreq_vpag_ins, t_mreq_seqb_ins
                                                              , t_mreq_obse_ins, t_mreq_nnum_ins, t_mreq_dref_ins
                                                              , t_mreq_conb_ins, t_mreq_serv_ins, l_contador_ins);

        l_contador_trans := 1;
    else
        l_contador_trans := l_contador_trans + 1;
    end if;
end loop;

pkg_mgr_imp_producao_aux.p_update_tabela_requerimento(  t_mreq_sequ_upd, t_mreq_valo_upd, t_mreq_dven_upd
                                                      , t_mreq_dpag_upd, t_mreq_vpag_upd, t_mreq_seqb_upd
                                                      , t_mreq_obse_upd, t_mreq_nnum_upd, t_mreq_dref_upd
                                                      , t_mreq_conb_upd, t_mreq_serv_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_requerimento(  p_mver_sequ, t_mreq_chav_ins, t_mreq_malu_ins
                                                      , t_mreq_msem_ins, t_mreq_valo_ins, t_mreq_dven_ins
                                                      , t_mreq_dpag_ins, t_mreq_vpag_ins, t_mreq_seqb_ins
                                                      , t_mreq_obse_ins, t_mreq_nnum_ins, t_mreq_dref_ins
                                                      , t_mreq_conb_ins, t_mreq_serv_ins, l_contador_ins);

end p_importa_requerimento;

procedure p_importa_renegociacao( p_migr_sequ     mgr_migracao.migr_sequ%type
                                , p_mver_sequ     mgr_versao.mver_sequ%type) is

-- tabelas utilizadas no update
t_mren_sequ_upd     pkg_util.tb_number;
t_mren_valo_upd     pkg_util.tb_number;
t_mren_qpar_upd     pkg_util.tb_number;
t_mren_dref_upd     pkg_util.tb_date;

t_mren_chav_ins     pkg_util.tb_varchar2_150;
t_mren_malu_ins     pkg_util.tb_number;
t_mren_msem_ins     pkg_util.tb_number;
t_mren_valo_ins     pkg_util.tb_number;
t_mren_qpar_ins     pkg_util.tb_number;
t_mren_dref_ins     pkg_util.tb_date;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

-- busca todas as renegociações cuja a origem é algo que nos interesse (mensalidade, acerto ou serviço)
cursor c_rene(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT TO_CHAR(c.acenum) mren_chav
         , a.malu_sequ mren_malu
         , (SELECT MAX(e.msef_sequ)
		      FROM mgr_semestre_financeiro e
			 WHERE TO_DATE('01/' || c.menmesmensvencer || '/' || c.menanomensvencer) 
                BETWEEN e.msef_dini AND e.msef_dfim
			   AND e.msef_atua = 'S') mren_msem
         , (SELECT SUM(x.fpavalororiginal)
              FROM oli_acerfpgt x
             WHERE x.acenum = c.acenum) mren_valo
         , '01/' || TO_CHAR(c.menmesmensvencer) || '/' || TO_CHAR(c.menanomensvencer) mren_dref
         , c.aceqtdeparcelas mren_qpar
         , (SELECT MAX(y.mren_sequ)
              FROM mgr_renegociacao y
             WHERE y.mren_chav = TO_CHAR(c.acenum)) mren_sequ
      FROM mgr_aluno a
         , mgr_curso b
         , oli_acerto c
     WHERE a.malu_atua = 'S'
       AND b.mcur_sequ = a.malu_mcur
       AND EXISTS( SELECT 1
                     FROM mgr_versao w
                    WHERE w.mver_migr = pc_migr_sequ
                      AND w.mver_sequ = a.malu_mver)
       AND EXISTS(
                  -- se tem algum serviço (requerimentos) em acerto (renegociação)
                  SELECT 1
                    FROM oli_servalun x
                       , oli_acerserv y
                   WHERE x.alucod = a.malu_chav
                     AND x.espcod = b.mcur_chav
                     AND y.salnum = x.salnum
                     AND y.acenum = c.acenum
                   UNION ALL
                  -- se tem alguma mensalidade em acerto (renegociação)
                  SELECT 1
                    FROM oli_acermens y
                       , oli_alunmens x
                   WHERE y.acenum = c.acenum
                     AND x.almnum = y.almnum
                     AND x.alucod = a.malu_chav
                     AND x.espcod = b.mcur_chav
                   UNION ALL
                  -- se tem algum acerto (renegociação) em acerto (renegociação)
                  SELECT 1
                    FROM oli_aceralun x
                       , oli_acerpchq y
                   WHERE x.alucod = a.malu_chav
                     AND x.espcod = b.mcur_chav
                     AND x.acenum = c.acenum
                     AND y.acenum = x.acenum
                   UNION ALL
                  -- se tem algum acerto (renegociação) que está faltando o registro da nota promissória (oli_acernota)
                  -- ou cheque calção (oli_acercheq)
                  SELECT 1
                    FROM oli_aceralun x
                       , oli_acerto y
                       , oli_cheqrece z
                   WHERE x.alucod = a.malu_chav
                     AND x.espcod = b.mcur_chav
                     AND x.acenum = c.acenum
                     AND y.acenum = x.acenum
                     AND z.tranumpago = y.tranum)
       AND c.acesituacao = 'P'
       AND c.menanomensvencer >= 2013
	   AND EXISTS (SELECT 1
	                 FROM oli_acerfpgt d
					WHERE d.acenum = c.acenum
					  AND d.fpatipo = 'E');

begin

pkg_mgr_imp_producao_aux.p_update_inicio_renegociacao(  p_migr_sequ);

pkg_mgr_imp_producao_aux.p_update_tabela_renegociacao(  t_mren_sequ_upd, t_mren_valo_upd, t_mren_qpar_upd
                                                      , t_mren_dref_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_renegociacao(  p_mver_sequ, t_mren_chav_ins, t_mren_malu_ins
                                                      , t_mren_msem_ins, t_mren_valo_ins, t_mren_qpar_ins
                                                      , t_mren_dref_ins, l_contador_ins);

for r_c_rene in c_rene(p_migr_sequ) loop

    -- se já existe o registro na tabela então é update
    if  (r_c_rene.mren_sequ is not null) then

        -- alimenta as variáveis table utilizadas no update
        t_mren_sequ_upd(l_contador_upd) := r_c_rene.mren_sequ;
        t_mren_valo_upd(l_contador_upd) := r_c_rene.mren_valo;
        t_mren_qpar_upd(l_contador_upd) := r_c_rene.mren_qpar;
        t_mren_dref_upd(l_contador_upd) := r_c_rene.mren_dref;

        l_contador_upd := l_contador_upd + 1;
    else

        -- alimenta as variáveis table utilizadas no insert
        t_mren_chav_ins(l_contador_ins) := r_c_rene.mren_chav;
        t_mren_malu_ins(l_contador_ins) := r_c_rene.mren_malu;
        t_mren_msem_ins(l_contador_ins) := r_c_rene.mren_msem;
        t_mren_valo_ins(l_contador_ins) := r_c_rene.mren_valo;
        t_mren_qpar_ins(l_contador_ins) := r_c_rene.mren_qpar;
        t_mren_dref_ins(l_contador_ins) := r_c_rene.mren_dref;

        l_contador_ins := l_contador_ins + 1;
    end if;

    -- verifica se atingiu a quantidade de registros por transação
    if  (l_contador_trans >= pkg_util.c_limit_trans) then

        -- atualiza os registro e devolve as variáveis reinicializadas
        pkg_mgr_imp_producao_aux.p_update_tabela_renegociacao(  t_mren_sequ_upd, t_mren_valo_upd, t_mren_qpar_upd
                                                              , t_mren_dref_upd, l_contador_upd);

        -- insere os registro e devolve as variáveis reinicializadas
        pkg_mgr_imp_producao_aux.p_insert_tabela_renegociacao(  p_mver_sequ, t_mren_chav_ins, t_mren_malu_ins
                                                               , t_mren_msem_ins, t_mren_valo_ins, t_mren_qpar_ins
                                                               , t_mren_dref_ins, l_contador_ins);

        l_contador_trans := 1;
    else
        l_contador_trans := l_contador_trans + 1;
    end if;
end loop;

pkg_mgr_imp_producao_aux.p_update_tabela_renegociacao(  t_mren_sequ_upd, t_mren_valo_upd, t_mren_qpar_upd
                                                      , t_mren_dref_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_renegociacao(  p_mver_sequ, t_mren_chav_ins, t_mren_malu_ins
                                                      , t_mren_msem_ins, t_mren_valo_ins, t_mren_qpar_ins
                                                      , t_mren_dref_ins, l_contador_ins);

end p_importa_renegociacao;

procedure p_importa_renegociacao_valor( p_migr_sequ     mgr_migracao.migr_sequ%type
                                      , p_mver_sequ     mgr_versao.mver_sequ%type
                                      , p_migr_sepa     mgr_migracao.migr_sepa%type) is

-- tabelas utilizadas para update
t_mrev_sequ_upd     pkg_util.tb_number;
t_mrev_valo_upd     pkg_util.tb_number;
t_mrev_parc_upd     pkg_util.tb_number;
t_mrev_dven_upd     pkg_util.tb_date;
t_mrev_dpag_upd     pkg_util.tb_date;
t_mrev_vpag_upd     pkg_util.tb_number;
t_mrev_seqb_upd     pkg_util.tb_varchar2_150;
t_mrev_obse_upd     pkg_util.tb_varchar2_4000;
t_mrev_nnum_upd     pkg_util.tb_varchar2_50;
t_mrev_dref_upd     pkg_util.tb_date;
t_mrev_mren_upd     pkg_util.tb_number;
t_mrev_conb_upd     pkg_util.tb_varchar2_150;
t_mrev_msem_upd     pkg_util.tb_number;

-- tabelas utilizadas no insert
t_mrev_chav_ins     pkg_util.tb_varchar2_150;
t_mrev_valo_ins     pkg_util.tb_number;
t_mrev_parc_ins     pkg_util.tb_number;
t_mrev_dven_ins     pkg_util.tb_date;
t_mrev_dpag_ins     pkg_util.tb_date;
t_mrev_vpag_ins     pkg_util.tb_number;
t_mrev_seqb_ins     pkg_util.tb_varchar2_150;
t_mrev_obse_ins     pkg_util.tb_varchar2_4000;
t_mrev_nnum_ins     pkg_util.tb_varchar2_50;
t_mrev_dref_ins     pkg_util.tb_date;
t_mrev_mren_ins     pkg_util.tb_number;
t_mrev_conb_ins     pkg_util.tb_varchar2_150;
t_mrev_msem_ins     pkg_util.tb_number;

-- contadores
l_contador_upd      pls_integer;
l_contador_ins      pls_integer;
l_contador_trans    pls_integer;

l_mrev_obse         mgr_renegociacao_valor.mrev_obse%type;
l_mrev_nnum         mgr_renegociacao_valor.mrev_nnum%type;

cursor c_reva(  pc_migr_sequ        mgr_migracao.migr_sequ%type
              , pc_migr_sepa        mgr_migracao.migr_sepa%type) is
    -- neste primeiro UNION é retornado as entradas, todo acerto no Olimpo exige pelo menos a entrada
    -- o campo chav da tabela concatenamos com o nome da tabela que o originou pois acerto + parcela pode se repetir
    SELECT TO_CHAR(a.acenum || pc_migr_sepa || b.fpanum || pc_migr_sepa || 'OLI_ACERFPGT') mrev_chav
         , b.fpavalororiginal mrev_valo
         , 0 mrev_parc
         , TRUNC(a.acedatavalidade) mrev_dven
         , NVL(d.tradataacerto, NVL(TRUNC(d.tradatahora), TRUNC(a.acedatavalidade))) mrev_dpag
         , DECODE(NVL(d.tradatahora, a.acedatavalidade), NULL, NULL, b.fpavalororiginal) mrev_vpag
         , a.tranum mrev_seqb
         , DECODE(d.tratipo, 'C', 'Recebimento (crédito)'
                           , 'R', 'Retirada de caixa'
                           , 'B', 'Baixa de títulos via arquivo retorno'
                           , 'V', 'Baixa por conversão do sistema antigo'
                           , 'A', 'Acerto de Rematricula'
                           , 'P', 'Carne Unificado'
                           , 'O', 'Proposta de Acerto'
                           , 'I', 'Baixa de registro de arquivo retorno no tratamento da inconsistência'
                           , null) tipo_baix
         , a.aceobservacao obse_acer
         , b.fpaobservacoes obse_parc
         , b.fpanumbloqueto nnum_parc
         , null nnum_cheq
         , TRUNC(NVL(TRUNC(d.tradatahora), TRUNC(a.acedatavalidade)), 'MONTH') mrev_dref
         , c.mren_sequ mrev_mren
         , (SELECT MAX(u.mrev_sequ)
              FROM mgr_renegociacao_valor u
             WHERE u.mrev_chav = TO_CHAR(a.acenum || pc_migr_sepa || b.fpanum || pc_migr_sepa || 'OLI_ACERFPGT')) mrev_sequ
         , (SELECT MAX(p.pccvalor)
              FROM oli_paraccob p
             WHERE p.caccod = a.caccod
               AND p.pccdesc = 'COD_CEDENTE') cart_cobr
         , (SELECT MAX(p.pccvalor)
              FROM oli_paraccob p
             WHERE p.caccod = d.caccod
               AND p.pccdesc = 'COD_CEDENTE') cart_cobr_b
         , (SELECT MAX(e.msef_sequ)
		      FROM mgr_semestre_financeiro e
			 WHERE TO_DATE('01/' || a.menmesmensvencer || '/' || a.menanomensvencer) BETWEEN e.msef_dini AND e.msef_dfim
			   AND e.msef_atua = 'S') msem_sequ
      FROM mgr_renegociacao c
         , oli_acerto a
         , oli_acerfpgt b
         , oli_trancaix d
     WHERE c.mren_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = c.mren_mver)
       AND a.acenum = c.mren_chav
       AND a.acesituacao = 'P'
       AND b.acenum = a.acenum
       AND b.fpatipo IN ('E', 'C')
       AND d.tranum(+) = a.tranum
     UNION ALL
    -- nesta parte do cursor são retornadas as parcelas onde foi deixado uma nota promissória como garantia
    SELECT TO_CHAR(a.acenum || pc_migr_sepa || c.pcanum || pc_migr_sepa || 'OLI_ACERNOTA') mrev_chav
         , c.pcavalor
         , c.pcanum
         , c.pcadatavencto
         , NVL(e.tradataacerto, NVL(TRUNC(e.tradatahora), TRUNC(c.pcadatapagto)))
         , DECODE(NVL(e.tradatahora, c.pcadatapagto), NULL, NULL, c.pcavalorpago)
         , c.tranum
         , DECODE(e.tratipo, 'C', 'Recebimento (crédito)'
                           , 'R', 'Retirada de caixa'
                           , 'B', 'Baixa de títulos via arquivo retorno'
                           , 'V', 'Baixa por conversão do sistema antigo'
                           , 'A', 'Acerto de Rematricula'
                           , 'P', 'Carne Unificado'
                           , 'O', 'Proposta de Acerto'
                           , 'I', 'Baixa de registro de arquivo retorno no tratamento da inconsistência'
                           , null) tipo_baix
         , a.aceobservacao obse_acer
         , null 
         , NVL((SELECT MAX(p.carnumbloqueto)
              FROM oli_carnpcau q
                 , oli_carne p
             WHERE q.chrnum = c.chrnum
               AND q.pcanum = c.pcanum
               AND p.carnum = q.carnum),
                c.pcanumbloqueto) nnum_parc
         , (SELECT MAX(p.carnumbloqueto)
              FROM oli_carncheq i
                 , oli_carne p
             WHERE i.chrnum = b.chrnum
               AND p.carnum = i.carnum) nnum_cheq
         , TRUNC(c.pcadatavencto, 'MONTH') mrev_dref
         , f.mren_sequ mrev_mren
         , (SELECT MAX(u.mrev_sequ)
              FROM mgr_renegociacao_valor u
             WHERE u.mrev_chav = TO_CHAR(a.acenum || pc_migr_sepa || c.pcanum || pc_migr_sepa || 'OLI_ACERNOTA')) mrev_sequ
         , (SELECT MAX(p.pccvalor)
              FROM oli_paraccob p
             WHERE p.caccod = c.caccod
               AND p.pccdesc = 'COD_CEDENTE') cart_cobr
         , (SELECT MAX(p.pccvalor)
              FROM oli_paraccob p
             WHERE p.caccod = e.caccod
               AND p.pccdesc = 'COD_CEDENTE') cart_cobr_b
         , (SELECT MAX(g.msef_sequ)
		      FROM mgr_semestre_financeiro g
			 WHERE TRUNC(c.pcadatavencto, 'MONTH') BETWEEN g.msef_dini AND g.msef_dfim
			   AND g.msef_atua = 'S') msem_sequ
      FROM mgr_renegociacao f
         , oli_acerto a
         , oli_acernota d
         , oli_cheqrece b
         , oli_cheqpcau c
         , oli_trancaix e
     WHERE f.mren_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = f.mren_mver)
       AND a.acenum = f.mren_chav
       -- garante que só irá atras de parcelas se elas existirem, há um problema em alguns registros onde 
       -- só existe a entrada mas por algum motivo foi gerado um registro de parcela para esta entrada
       AND EXISTS( SELECT 1
                     FROM oli_acerfpgt w
                    WHERE w.acenum = a.acenum
                      AND w.fpatipo != 'E')
       AND d.acenum = a.acenum
       AND b.chrnum = d.chrnum 
       AND c.chrnum = d.chrnum
       AND e.tranum(+) = c.tranum
     UNION ALL
    -- aqui são retornadas as parcelas que tiveram um cheque como garantia 
    SELECT TO_CHAR(a.acenum || pc_migr_sepa || c.pcanum || pc_migr_sepa || d.chrnum || pc_migr_sepa || 'OLI_ACERCHEQ') mrev_chav
         , c.pcavalor
         , c.pcanum
         , c.pcadatavencto
         , NVL(e.tradataacerto, NVL(TRUNC(e.tradatahora), c.pcadatapagto))
         , DECODE(NVL(e.tradatahora, c.pcadatapagto), NULL, NULL, c.pcavalorpago)
         , c.tranum
         , DECODE(e.tratipo, 'C', 'Recebimento (crédito)'
                           , 'R', 'Retirada de caixa'
                           , 'B', 'Baixa de títulos via arquivo retorno'
                           , 'V', 'Baixa por conversão do sistema antigo'
                           , 'A', 'Acerto de Rematricula'
                           , 'P', 'Carne Unificado'
                           , 'O', 'Proposta de Acerto'
                           , 'I', 'Baixa de registro de arquivo retorno no tratamento da inconsistência'
                           , NULL) tipo_baix
         , a.aceobservacao obse_acer
         , NULL 
         , NVL((SELECT MAX(p.carnumbloqueto)
              FROM oli_carnpcau q
                 , oli_carne p
             WHERE q.chrnum = c.chrnum
               AND q.pcanum = c.pcanum
               AND p.carnum = q.carnum),
               c.pcanumbloqueto) nnum_parc
         , (SELECT MAX(p.carnumbloqueto)
              FROM oli_carncheq i
                 , oli_carne p
             WHERE i.chrnum = b.chrnum
               AND p.carnum = i.carnum) nnum_cheq
         , TRUNC(c.pcadatavencto, 'MONTH') mrev_dref
         , f.mren_sequ mrev_mren
         , (SELECT MAX(u.mrev_sequ)
              FROM mgr_renegociacao_valor u
             WHERE u.mrev_chav = TO_CHAR(a.acenum || pc_migr_sepa || c.pcanum || pc_migr_sepa || d.chrnum || pc_migr_sepa || 'OLI_ACERCHEQ')) mrev_sequ
         , (SELECT MAX(p.pccvalor)
              FROM oli_paraccob p
             WHERE p.caccod = c.caccod
               AND p.pccdesc = 'COD_CEDENTE') cart_cobr
         , (SELECT MAX(p.pccvalor)
              FROM oli_paraccob p
             WHERE p.caccod = e.caccod
               AND p.pccdesc = 'COD_CEDENTE') cart_cobr_b
         , (SELECT MAX(g.msef_sequ)
		      FROM mgr_semestre_financeiro g
			 WHERE TRUNC(c.pcadatavencto, 'MONTH') BETWEEN g.msef_dini AND g.msef_dfim
			   AND g.msef_atua = 'S') msem_sequ
      FROM mgr_renegociacao f
         , oli_acerto a
         , oli_acercheq d
         , oli_cheqrece b
         , oli_cheqpcau c
         , oli_trancaix e
     WHERE f.mren_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = f.mren_mver)
       AND a.acenum = f.mren_chav
       -- garante que só irá atras de parcelas se elas existirem, há um problema em alguns registros onde 
        -- só existe a entrada mas por algum motivo foi gerado um registro de parcela para esta entrada
       AND EXISTS( SELECT 1
                     FROM oli_acerfpgt w
                    WHERE w.acenum = a.acenum
                      AND w.fpatipo != 'E')
       AND d.acenum = a.acenum
       AND b.chrnum = d.chrnum 
       AND c.chrnum = d.chrnum
       AND e.tranum(+) = c.tranum
     UNION ALL
    -- aqui retorna as parcelas ou pagamentos da entrada em que não foi inserido registro de cheque ou nota como garantia
    SELECT TO_CHAR(a.acenum || pc_migr_sepa || c.pcanum || pc_migr_sepa || 'OLI_CHEQPCAU') mrev_chav
         , c.pcavalor
         , c.pcanum
         , c.pcadatavencto
         , NVL(e.tradataacerto, NVL(TRUNC(e.tradatahora), c.pcadatapagto))
         , DECODE(NVL(e.tradatahora, c.pcadatapagto), NULL, NULL, c.pcavalorpago)
         , c.tranum
         , DECODE(e.tratipo, 'C', 'Recebimento (crédito)'
                           , 'R', 'Retirada de caixa'
                           , 'B', 'Baixa de títulos via arquivo retorno'
                           , 'V', 'Baixa por conversão do sistema antigo'
                           , 'A', 'Acerto de Rematricula'
                           , 'P', 'Carne Unificado'
                           , 'O', 'Proposta de Acerto'
                           , 'I', 'Baixa de registro de arquivo retorno no tratamento da inconsistência'
                           , NULL) tipo_baix
         , a.aceobservacao obse_acer
         , NULL 
         , NVL((SELECT MAX(p.carnumbloqueto)
              FROM oli_carnpcau q
                 , oli_carne p
             WHERE q.chrnum = c.chrnum
               AND q.pcanum = c.pcanum
               AND p.carnum = q.carnum),
               c.pcanumbloqueto) nnum_parc
         , (SELECT MAX(p.carnumbloqueto)
              FROM oli_carncheq i
                 , oli_carne p
             WHERE i.chrnum = b.chrnum
               AND p.carnum = i.carnum) nnum_cheq
         , TRUNC(c.pcadatavencto, 'MONTH') mrev_dref
         , f.mren_sequ mrev_mren
         , (SELECT MAX(u.mrev_sequ)
              FROM mgr_renegociacao_valor u
             WHERE u.mrev_chav = TO_CHAR(a.acenum || pc_migr_sepa || c.pcanum || pc_migr_sepa || 'OLI_CHEQPCAU')) mrev_sequ
         , (SELECT MAX(p.pccvalor)
              FROM oli_paraccob p
             WHERE p.caccod = c.caccod
               AND p.pccdesc = 'COD_CEDENTE') cart_cobr
         , (SELECT MAX(p.pccvalor)
              FROM oli_paraccob p
             WHERE p.caccod = e.caccod
               AND p.pccdesc = 'COD_CEDENTE') cart_cobr_b
         , (SELECT MAX(g.msef_sequ)
		      FROM mgr_semestre_financeiro g
			 WHERE TRUNC(c.pcadatavencto, 'MONTH') BETWEEN g.msef_dini AND g.msef_dfim
			   AND g.msef_atua = 'S') msem_sequ
      FROM mgr_renegociacao f
         , oli_acerto a
         , oli_cheqrece b
         , oli_cheqpcau c
         , oli_trancaix e
     WHERE f.mren_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = f.mren_mver)
       AND a.acenum = f.mren_chav
        -- garante que só irá atras de parcelas se elas existirem, há um problema em alguns registros onde 
        -- só existe a entrada mas por algum motivo foi gerado um registro de parcela para esta entrada
       AND EXISTS( SELECT 1
                     FROM oli_acerfpgt w
                    WHERE w.acenum = a.acenum
                      AND w.fpatipo != 'E')
       AND b.tranumentrada = a.tranum
       AND c.chrnum = b.chrnum
       AND e.tranum(+) = c.tranum
       AND NOT EXISTS( SELECT 1
                         FROM oli_acercheq y
                        WHERE y.acenum = a.acenum
                        UNION ALL
                       SELECT 1
                         FROM oli_acernota z
                        WHERE z.acenum = a.acenum);

begin

pkg_mgr_imp_producao_aux.p_update_inicio_rene_valor(    p_migr_sequ);

pkg_mgr_imp_producao_aux.p_update_tabela_rene_valor(    t_mrev_sequ_upd, t_mrev_valo_upd, t_mrev_parc_upd
                                                      , t_mrev_dven_upd, t_mrev_dpag_upd, t_mrev_vpag_upd
                                                      , t_mrev_seqb_upd, t_mrev_obse_upd, t_mrev_nnum_upd
                                                      , t_mrev_dref_upd, t_mrev_mren_upd, t_mrev_conb_upd
                                                      , t_mrev_msem_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_rene_valor(   p_mver_sequ, t_mrev_valo_ins, t_mrev_parc_ins
                                                     , t_mrev_chav_ins, t_mrev_dven_ins, t_mrev_dpag_ins
                                                     , t_mrev_vpag_ins, t_mrev_seqb_ins, t_mrev_obse_ins
                                                     , t_mrev_nnum_ins, t_mrev_dref_ins, t_mrev_mren_ins
                                                     , t_mrev_conb_ins, t_mrev_msem_ins, l_contador_ins);

for r_c_reva in c_reva(p_migr_sequ, p_migr_sepa) loop

    l_mrev_obse := null;

    if  (r_c_reva.tipo_baix is not null) then

        l_mrev_obse := SUBSTR(l_mrev_obse || ' Tipo de baixa: ' || r_c_reva.tipo_baix || pkg_util.c_enter, 1, 4000);
    end if;
    
    if  (r_c_reva.obse_acer is not null) then

        l_mrev_obse := SUBSTR(l_mrev_obse || ' Obs. renegociacao: ' || r_c_reva.obse_acer || pkg_util.c_enter, 1, 4000);
    end if;

    if  (r_c_reva.obse_parc is not null) then

        l_mrev_obse := SUBSTR(l_mrev_obse || ' Obs. parcela: ' || r_c_reva.obse_parc || pkg_util.c_enter, 1, 4000);
    end if;

    l_mrev_nnum := NVL(r_c_reva.nnum_parc, r_c_reva.nnum_cheq);

    -- se já existe o registro na tabela então é update
    if  (r_c_reva.mrev_sequ is not null) then

        -- alimenta as variáveis table utilizadas no update
        t_mrev_sequ_upd(l_contador_upd) := r_c_reva.mrev_sequ;
        t_mrev_valo_upd(l_contador_upd) := r_c_reva.mrev_valo;
        t_mrev_parc_upd(l_contador_upd) := r_c_reva.mrev_parc;
        t_mrev_dven_upd(l_contador_upd) := r_c_reva.mrev_dven;
        t_mrev_dpag_upd(l_contador_upd) := r_c_reva.mrev_dpag;
        t_mrev_vpag_upd(l_contador_upd) := r_c_reva.mrev_vpag;
        t_mrev_seqb_upd(l_contador_upd) := r_c_reva.mrev_seqb;
        t_mrev_obse_upd(l_contador_upd) := l_mrev_obse;
        t_mrev_nnum_upd(l_contador_upd) := l_mrev_nnum;
        t_mrev_dref_upd(l_contador_upd) := r_c_reva.mrev_dref;
        t_mrev_mren_upd(l_contador_upd) := r_c_reva.mrev_mren;
        t_mrev_conb_upd(l_contador_upd) := NVL(r_c_reva.cart_cobr_b, r_c_reva.cart_cobr);
        t_mrev_msem_upd(l_contador_upd) := r_c_reva.msem_sequ;

        l_contador_upd := l_contador_upd + 1;
    else

        -- alimenta as variáveis table utilizadas no insert
        t_mrev_valo_ins(l_contador_ins) := r_c_reva.mrev_valo;
        t_mrev_parc_ins(l_contador_ins) := r_c_reva.mrev_parc;
        t_mrev_chav_ins(l_contador_ins) := r_c_reva.mrev_chav;
        t_mrev_dven_ins(l_contador_ins) := r_c_reva.mrev_dven;
        t_mrev_dpag_ins(l_contador_ins) := r_c_reva.mrev_dpag;
        t_mrev_vpag_ins(l_contador_ins) := r_c_reva.mrev_vpag;
        t_mrev_seqb_ins(l_contador_ins) := r_c_reva.mrev_seqb;
        t_mrev_obse_ins(l_contador_ins) := l_mrev_obse;
        t_mrev_nnum_ins(l_contador_ins) := l_mrev_nnum;
        t_mrev_dref_ins(l_contador_ins) := r_c_reva.mrev_dref;
        t_mrev_mren_ins(l_contador_ins) := r_c_reva.mrev_mren;
        t_mrev_conb_ins(l_contador_ins) := NVL(r_c_reva.cart_cobr_b, r_c_reva.cart_cobr);
        t_mrev_msem_ins(l_contador_ins) := r_c_reva.msem_sequ;

        l_contador_ins := l_contador_ins + 1;
    end if;

    -- verifica se atingiu a quantidade de registros por transação
    if  (l_contador_trans >= pkg_util.c_limit_trans) then

        -- atualiza os registro e devolve as variáveis reinicializadas
        pkg_mgr_imp_producao_aux.p_update_tabela_rene_valor(    t_mrev_sequ_upd, t_mrev_valo_upd, t_mrev_parc_upd
                                                              , t_mrev_dven_upd, t_mrev_dpag_upd, t_mrev_vpag_upd
                                                              , t_mrev_seqb_upd, t_mrev_obse_upd, t_mrev_nnum_upd
                                                              , t_mrev_dref_upd, t_mrev_mren_upd, t_mrev_conb_upd
                                                              , t_mrev_msem_upd, l_contador_upd);

        -- insere os registro e devolve as variáveis reinicializadas
        pkg_mgr_imp_producao_aux.p_insert_tabela_rene_valor(   p_mver_sequ, t_mrev_valo_ins, t_mrev_parc_ins
                                                             , t_mrev_chav_ins, t_mrev_dven_ins, t_mrev_dpag_ins
                                                             , t_mrev_vpag_ins, t_mrev_seqb_ins, t_mrev_obse_ins
                                                             , t_mrev_nnum_ins, t_mrev_dref_ins, t_mrev_mren_ins
                                                             , t_mrev_conb_ins, t_mrev_msem_ins, l_contador_ins);

        l_contador_trans := 1;
    else
        l_contador_trans := l_contador_trans + 1;
    end if;
end loop;

pkg_mgr_imp_producao_aux.p_update_tabela_rene_valor(    t_mrev_sequ_upd, t_mrev_valo_upd, t_mrev_parc_upd
                                                      , t_mrev_dven_upd, t_mrev_dpag_upd, t_mrev_vpag_upd
                                                      , t_mrev_seqb_upd, t_mrev_obse_upd, t_mrev_nnum_upd
                                                      , t_mrev_dref_upd, t_mrev_mren_upd, t_mrev_conb_upd
                                                      , t_mrev_msem_upd, l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_rene_valor(   p_mver_sequ, t_mrev_valo_ins, t_mrev_parc_ins
                                                     , t_mrev_chav_ins, t_mrev_dven_ins, t_mrev_dpag_ins
                                                     , t_mrev_vpag_ins, t_mrev_seqb_ins, t_mrev_obse_ins
                                                     , t_mrev_nnum_ins, t_mrev_dref_ins, t_mrev_mren_ins
                                                     , t_mrev_conb_ins, t_mrev_msem_ins, l_contador_ins);

pkg_mgr_imp_producao_aux.p_ajuste_valor_pago_rene_valo( p_migr_sequ);

end p_importa_renegociacao_valor;

procedure p_vincula_renegociacao_origem(    p_migr_sequ     mgr_migracao.migr_sequ%type
                                          , p_migr_sepa     mgr_migracao.migr_sepa%type) is

t_sequ_orig     pkg_util.tb_number;
t_sequ_rene     pkg_util.tb_number;

cursor c_reme(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.mren_sequ
         , d.mmen_sequ
      FROM mgr_renegociacao a
         , mgr_aluno e
         , mgr_curso f
         , oli_acermens b
         , oli_alunmens c
         , mgr_mensalidade d
     WHERE a.mren_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.mren_mver)
       AND e.malu_sequ = a.mren_malu
       AND f.mcur_sequ = e.malu_mcur
       AND b.acenum = a.mren_chav
       AND c.almnum = b.almnum
       AND c.alucod = e.malu_chav
       AND c.espcod = f.mcur_chav
       AND d.mmen_chav = TO_CHAR(c.almnum)
       AND d.mmen_mren IS NULL;

cursor c_rerq(  pc_migr_sequ     mgr_migracao.migr_sequ%type) is
    SELECT a.mren_sequ
         , f.mreq_sequ
      FROM mgr_renegociacao a
         , mgr_aluno b
         , mgr_curso c
         , oli_acerserv d
         , oli_servalun e
         , mgr_requerimento f
     WHERE a.mren_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.mren_mver)
       AND b.malu_sequ = a.mren_malu
       AND c.mcur_sequ = b.malu_mcur
       AND d.acenum = a.mren_chav
       AND e.salnum = d.salnum
       AND e.alucod = b.malu_chav
       AND e.espcod = c.mcur_chav
       AND f.mreq_chav = TO_CHAR(e.salnum)
       AND f.mreq_mren IS NULL;

cursor c_rere(  pc_migr_sequ     mgr_migracao.migr_sequ%type
              , pc_migr_sepa     mgr_migracao.migr_sepa%type) is
    SELECT a.mren_sequ
         , g.mrev_sequ
      FROM mgr_renegociacao a
         , mgr_aluno b
         , mgr_curso c
         , oli_aceralun d
         , oli_acerpchq e
         , oli_cheqpcau f
         , oli_acercheq h
         , mgr_renegociacao_valor g
     WHERE a.mren_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.mren_mver)
       AND b.malu_sequ = a.mren_malu
       AND c.mcur_sequ = b.malu_mcur
       AND d.acenum = a.mren_chav
       AND d.alucod = b.malu_chav
       AND d.espcod = c.mcur_chav
       AND e.acenum = d.acenum
       AND f.chrnum = e.chrnum
       AND f.pcanum = e.pcanum
       AND h.chrnum = f.chrnum
       AND g.mrev_chav = TO_CHAR(h.acenum || pc_migr_sepa || f.pcanum || pc_migr_sepa || h.chrnum || pc_migr_sepa || 'OLI_ACERCHEQ')
       AND g.mrev_rene IS NULL
     UNION ALL
    SELECT a.mren_sequ
         , g.mrev_sequ
      FROM mgr_renegociacao a
         , mgr_aluno b
         , mgr_curso c
         , oli_aceralun d
         , oli_acerpchq e
         , oli_cheqpcau f
         , oli_acernota h
         , mgr_renegociacao_valor g
     WHERE a.mren_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.mren_mver)
       AND b.malu_sequ = a.mren_malu
       AND c.mcur_sequ = b.malu_mcur
       AND d.acenum = a.mren_chav
       AND d.alucod = b.malu_chav
       AND d.espcod = c.mcur_chav
       AND e.acenum = d.acenum
       AND f.chrnum = e.chrnum
       AND f.pcanum = e.pcanum
       AND h.chrnum = f.chrnum
       AND g.mrev_chav = TO_CHAR(h.acenum || pc_migr_sepa || f.pcanum || pc_migr_sepa || 'OLI_ACERNOTA')
       AND g.mrev_rene IS NULL;

cursor c_rech(   pc_migr_sequ     mgr_migracao.migr_sequ%type
              , pc_migr_sepa     mgr_migracao.migr_sepa%type) is
    SELECT a.mren_sequ
         , g.mrev_sequ
      FROM mgr_renegociacao a
         , mgr_aluno b
         , mgr_curso c
         , oli_aceralun d
         , oli_acerpchq e
         , oli_cheqpcau f
         , oli_cheqrece h
         , oli_acerto i
         , oli_acernota j
         , mgr_renegociacao_valor g
     WHERE a.mren_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.mren_mver)
       AND b.malu_sequ = a.mren_malu
       AND c.mcur_sequ = b.malu_mcur
       AND d.acenum = a.mren_chav
       AND d.alucod = b.malu_chav
       AND d.espcod = c.mcur_chav
       AND e.acenum = d.acenum
       AND f.chrnum = e.chrnum
       AND f.pcanum = e.pcanum
       AND h.chrnum = f.chrnum
       AND i.tranum = h.tranumentrada
       AND j.acenum = i.acenum
       AND g.mrev_chav = TO_CHAR(i.acenum || pc_migr_sepa || f.pcanum || pc_migr_sepa || 'OLI_ACERNOTA')
       AND g.mrev_rene IS NULL
     UNION ALL
    SELECT a.mren_sequ
         , g.mrev_sequ
      FROM mgr_renegociacao a
         , mgr_aluno b
         , mgr_curso c
         , oli_aceralun d
         , oli_acerpchq e
         , oli_cheqpcau f
         , oli_cheqrece h
         , oli_acerto i
         , oli_acercheq j
         , mgr_renegociacao_valor g
     WHERE a.mren_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.mren_mver)
       AND b.malu_sequ = a.mren_malu
       AND c.mcur_sequ = b.malu_mcur
       AND d.acenum = a.mren_chav
       AND d.alucod = b.malu_chav
       AND d.espcod = c.mcur_chav
       AND e.acenum = d.acenum
       AND f.chrnum = e.chrnum
       AND f.pcanum = e.pcanum
       AND h.chrnum = f.chrnum
       AND i.tranum = h.tranumentrada
       AND j.acenum = i.acenum
       AND g.mrev_chav = TO_CHAR(i.acenum || pc_migr_sepa || f.pcanum || pc_migr_sepa || j.chrnum || pc_migr_sepa || 'OLI_ACERCHEQ')
       AND g.mrev_rene IS NULL
     UNION ALL
    SELECT a.mren_sequ
         , i.mrev_sequ
      FROM mgr_renegociacao a
         , mgr_aluno b
         , mgr_curso c
         , oli_aceralun d
         , oli_acerto e
         , oli_cheqrece f
         , oli_cheqpcau g
         , oli_acerto h
         , oli_acernota j
         , mgr_renegociacao_valor i
     WHERE a.mren_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.mren_mver)
       AND b.malu_sequ = a.mren_malu
       AND c.mcur_sequ = b.malu_mcur
       AND d.acenum = a.mren_chav
       AND d.alucod = b.malu_chav
       AND d.espcod = c.mcur_chav
       AND e.acenum = d.acenum
       AND f.tranumpago = e.tranum
       AND g.chrnum = f.chrnum
       AND h.tranum = f.tranumentrada
       AND j.acenum = h.acenum
       AND i.mrev_chav = TO_CHAR(h.acenum || pc_migr_sepa || g.pcanum || pc_migr_sepa || 'OLI_ACERNOTA')
       AND i.mrev_rene IS NULL
     UNION ALL
    SELECT a.mren_sequ
         , i.mrev_sequ
      FROM mgr_renegociacao a
         , mgr_aluno b
         , mgr_curso c
         , oli_aceralun d
         , oli_acerto e
         , oli_cheqrece f
         , oli_cheqpcau g
         , oli_acerto h
         , oli_acercheq j
         , mgr_renegociacao_valor i
     WHERE a.mren_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.mren_mver)
       AND b.malu_sequ = a.mren_malu
       AND c.mcur_sequ = b.malu_mcur
       AND d.acenum = a.mren_chav
       AND d.alucod = b.malu_chav
       AND d.espcod = c.mcur_chav
       AND e.acenum = d.acenum
       AND f.tranumpago = e.tranum
       AND g.chrnum = f.chrnum
       AND h.tranum = f.tranumentrada
       AND j.acenum = h.acenum   
       AND i.mrev_chav = TO_CHAR(h.acenum || pc_migr_sepa || g.pcanum || pc_migr_sepa || j.chrnum || pc_migr_sepa || 'OLI_ACERCHEQ')
       AND i.mrev_rene IS NULL;

begin
-- faz o vínculo com as mensalidades que fazem parte das renegociações
open c_reme(p_migr_sequ);
loop
    fetch c_reme bulk collect into  t_sequ_rene, t_sequ_orig
    limit pkg_util.c_limit_trans;
    exit when t_sequ_rene.count = 0;

    forall i in t_sequ_rene.first..t_sequ_rene.last
        UPDATE mgr_mensalidade
           SET mmen_mren = t_sequ_rene(i)
         WHERE mmen_sequ = t_sequ_orig(i);
    COMMIT;
end loop;
close c_reme;
-- faz o vínculo com os requerimentos que fazem parte das renegociações
open c_rerq(p_migr_sequ);
loop
    fetch c_rerq bulk collect into  t_sequ_rene, t_sequ_orig
    limit pkg_util.c_limit_trans;
    exit when t_sequ_rene.count = 0;

    forall i in t_sequ_rene.first..t_sequ_rene.last
        UPDATE mgr_requerimento
           SET mreq_mren = t_sequ_rene(i)
         WHERE mreq_sequ = t_sequ_orig(i);
    COMMIT;
end loop;
close c_rerq;
-- faz o vínculo com as parcelas de renegociações que fazem parte de outras renegociações
open c_rere(p_migr_sequ, p_migr_sepa);
loop
    fetch c_rere bulk collect into  t_sequ_rene, t_sequ_orig
    limit pkg_util.c_limit_trans;
    exit when t_sequ_rene.count = 0;

    forall i in t_sequ_rene.first..t_sequ_rene.last
        UPDATE mgr_renegociacao_valor
           SET mrev_rene = t_sequ_rene(i)
         WHERE mrev_sequ = t_sequ_orig(i);
    COMMIT;
end loop;
close c_rere;
-- faz o vínculo com as parcelas de renegociações que fazem parte de outras renegociações
-- este utilizo um outro caminho para chegar até a origem pois parece estar faltando registro 
-- nas tabelas de ligação
open c_rech(p_migr_sequ, p_migr_sepa);
loop
    fetch c_rech bulk collect into  t_sequ_rene, t_sequ_orig
    limit pkg_util.c_limit_trans;
    exit when t_sequ_rene.count = 0;

    forall i in t_sequ_rene.first..t_sequ_rene.last
        UPDATE mgr_renegociacao_valor
           SET mrev_rene = t_sequ_rene(i)
         WHERE mrev_sequ = t_sequ_orig(i);
    COMMIT;
end loop;
close c_rech;

end p_vincula_renegociacao_origem;

procedure p_importa_credito_aluno(  p_migr_sequ     mgr_migracao.migr_sequ%type
                                  , p_mver_sequ     mgr_versao.mver_sequ%type
                                  , p_migr_sepa     mgr_migracao.migr_sepa%type) is

t_mcra_valo_ins     pkg_util.tb_number;
t_mcra_data_ins     pkg_util.tb_date;
t_mcra_obse_ins     pkg_util.tb_varchar2_4000;
t_mcra_seqb_ins     pkg_util.tb_varchar2_150;
t_mcra_oper_ins     pkg_util.tb_varchar2_1;
t_mcra_malu_ins     pkg_util.tb_number;
t_mcra_chav_ins     pkg_util.tb_varchar2_150;

t_mcra_sequ_upd     pkg_util.tb_number;
t_mcra_valo_upd     pkg_util.tb_number;
t_mcra_data_upd     pkg_util.tb_date;
t_mcra_obse_upd     pkg_util.tb_varchar2_4000;
t_mcra_seqb_upd     pkg_util.tb_varchar2_150;
t_mcra_oper_upd     pkg_util.tb_varchar2_1;

-- contadores
l_contador_ins      pls_integer;
l_contador_upd      pls_integer;
l_contador_trans    pls_integer;

-- buscamos tudo o que está na mgr_aluno, que em outras palavras são todos
-- que nos interessam
cursor c_cred(  pc_migr_sequ     mgr_migracao.migr_sequ%type
              , pc_migr_sepa     mgr_migracao.migr_sepa%type) is
    SELECT TO_CHAR(h.hdecod) || pc_migr_sepa || 'OLI_HISTDEVO' mcra_chav
         , a.malu_sequ mcra_malu
         , TRUNC(h.hdedata) mcra_data
         , h.hdevalor mcra_valo
         , h.hdeobs mcra_obse
         , NULL  mcra_seqb
         , 'C' mcra_oper
         , (SELECT MAX(y.mcra_sequ)
              FROM mgr_credito_aluno y
             WHERE y.mcra_chav = TO_CHAR(h.hdecod) || pc_migr_sepa || 'OLI_HISTDEVO') mcra_sequ
      FROM mgr_aluno a
         , mgr_curso b
         , oli_histdevo h
     WHERE a.malu_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.malu_mver)
       AND b.mcur_sequ = a.malu_mcur
       AND h.alucod = a.malu_chav
       AND h.espcod = b.mcur_chav
     UNION ALL
    SELECT TO_CHAR(p.tranum) || pc_migr_sepa || TO_CHAR(p.ptcnum) || pc_migr_sepa || 'OLI_PAGACAIX' mcra_chav
         , a.malu_sequ mcra_malu
         , TRUNC(t.tradatahora) mcra_data
         , ABS(p.ptcvalor) * -1 mcra_valo
         , p.ptctextodesconto mcra_obse
         , p.tranum mcra_seqb
         , 'D' mcra_oper
         , (SELECT MAX(y.mcra_sequ)
              FROM mgr_credito_aluno y
             WHERE y.mcra_chav = TO_CHAR(p.tranum) || pc_migr_sepa || TO_CHAR(p.ptcnum) || pc_migr_sepa || 'OLI_PAGACAIX') mcra_sequ
      FROM mgr_aluno a
         , mgr_curso b
         , oli_pagacaix p
         , oli_trancaix t
     WHERE a.malu_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.malu_mver)
       AND b.mcur_sequ = a.malu_mcur
       AND p.alucod = a.malu_chav
       AND p.espcod = b.mcur_chav
       AND p.tranum = t.tranum
	   -- outros
       AND p.ptcformapagto = 'O'
	   -- devolução de crédito
       AND p.ptctipooutros = 'E'
	   -- que não seja baixa de título via arquivo retorno
       AND t.tratipo <> 'B'
     UNION ALL
    SELECT TO_CHAR(c.crdcod) || pc_migr_sepa || 'OLI_CREDALUN' mcra_chav
         , a.malu_sequ mcra_malu
         , TRUNC(c.crddata) mcra_data
         , ABS(c.crdvalor) * -1 mcra_valo
         , c.crdobs mcra_obse
         , c.tranum mcra_seqb
         , 'D' mcra_oper 
         , (SELECT MAX(y.mcra_sequ)
              FROM mgr_credito_aluno y
             WHERE y.mcra_chav = TO_CHAR(c.crdcod) || pc_migr_sepa || 'OLI_CREDALUN') mcra_sequ
      FROM mgr_aluno a
         , mgr_curso b
         , oli_credalun c
     WHERE a.malu_atua = 'S'
       AND EXISTS( SELECT 1
                     FROM mgr_versao x
                    WHERE x.mver_migr = pc_migr_sequ
                      AND x.mver_sequ = a.malu_mver)
       AND b.mcur_sequ = a.malu_mcur
       AND c.alucod = a.malu_chav
       AND c.espcod = b.mcur_chav;

begin

pkg_mgr_imp_producao_aux.p_update_inicio_credito_alun(  p_migr_sequ);

pkg_mgr_imp_producao_aux.p_update_tabela_credito_alun(  t_mcra_sequ_upd, t_mcra_valo_upd, t_mcra_data_upd
                                                      , t_mcra_obse_upd, t_mcra_seqb_upd, t_mcra_oper_upd
                                                      , l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_credito_alun(  p_mver_sequ, t_mcra_valo_ins, t_mcra_data_ins
                                                      , t_mcra_obse_ins, t_mcra_seqb_ins, t_mcra_oper_ins
                                                      , t_mcra_malu_ins, t_mcra_chav_ins, l_contador_ins);

for r_c_cred in c_cred(p_migr_sequ, p_migr_sepa) loop

    -- se já existe o registro na tabela então é update
    if  (r_c_cred.mcra_sequ is not null) then

        -- alimenta as variáveis table utilizadas no update
        t_mcra_sequ_upd(l_contador_upd) := r_c_cred.mcra_sequ;
        t_mcra_valo_upd(l_contador_upd) := r_c_cred.mcra_valo;
        t_mcra_data_upd(l_contador_upd) := r_c_cred.mcra_data;
        t_mcra_obse_upd(l_contador_upd) := r_c_cred.mcra_obse;
        t_mcra_seqb_upd(l_contador_upd) := r_c_cred.mcra_seqb;
        t_mcra_oper_upd(l_contador_upd) := r_c_cred.mcra_oper;

        l_contador_upd := l_contador_upd + 1;
    else

        -- alimenta as variáveis table utilizadas no insert
        t_mcra_valo_ins(l_contador_ins) := r_c_cred.mcra_valo;
        t_mcra_data_ins(l_contador_ins) := r_c_cred.mcra_data;
        t_mcra_obse_ins(l_contador_ins) := r_c_cred.mcra_obse;
        t_mcra_seqb_ins(l_contador_ins) := r_c_cred.mcra_seqb;
        t_mcra_oper_ins(l_contador_ins) := r_c_cred.mcra_oper;
        t_mcra_malu_ins(l_contador_ins) := r_c_cred.mcra_malu;
        t_mcra_chav_ins(l_contador_ins) := r_c_cred.mcra_chav;

        l_contador_ins := l_contador_ins + 1;
    end if;

    -- verifica se atingiu a quantidade de registros por transação
    if  (l_contador_trans >= pkg_util.c_limit_trans) then

        pkg_mgr_imp_producao_aux.p_update_tabela_credito_alun(  t_mcra_sequ_upd, t_mcra_valo_upd, t_mcra_data_upd
                                                              , t_mcra_obse_upd, t_mcra_seqb_upd, t_mcra_oper_upd
                                                              , l_contador_upd);

        pkg_mgr_imp_producao_aux.p_insert_tabela_credito_alun(  p_mver_sequ, t_mcra_valo_ins, t_mcra_data_ins
                                                              , t_mcra_obse_ins, t_mcra_seqb_ins, t_mcra_oper_ins
                                                              , t_mcra_malu_ins, t_mcra_chav_ins, l_contador_ins);

        l_contador_trans := 1;
    else
        l_contador_trans := l_contador_trans + 1;
    end if;

end loop;

pkg_mgr_imp_producao_aux.p_update_tabela_credito_alun(  t_mcra_sequ_upd, t_mcra_valo_upd, t_mcra_data_upd
                                                      , t_mcra_obse_upd, t_mcra_seqb_upd, t_mcra_oper_upd
                                                      , l_contador_upd);

pkg_mgr_imp_producao_aux.p_insert_tabela_credito_alun(  p_mver_sequ, t_mcra_valo_ins, t_mcra_data_ins
                                                      , t_mcra_obse_ins, t_mcra_seqb_ins, t_mcra_oper_ins
                                                      , t_mcra_malu_ins, t_mcra_chav_ins, l_contador_ins);

-- verifica se existem alunos onde serão gerados 2 ou mais alunos no Gioconda para o mesmo aluno no Olimpo 
-- caso seja identificado algum, o valor de crédito de ambos precisa ser somado e se for zero não é necessário
-- importação para o Gioconda, ficará apenas para consultas na tabela MGR
pkg_mgr_imp_producao_aux.p_verifica_alunos_cred_zero(   p_migr_sequ);

end p_importa_credito_aluno;

procedure p_executa_importacao( p_migr_sequ     mgr_migracao.migr_sequ%type
                              , p_mver_sequ     mgr_versao.mver_sequ%type) is

l_migr_sepa     mgr_migracao.migr_sepa%type;
l_desc_erro     mgr_log_execucao.mlex_erro%type;
l_desc_etap     varchar2(255);
l_cont          pls_integer;
l_cont_mtus     pls_integer;

begin
-- verifica se foi passado de parâmetro a sequência da migração e da versão
-- estas informações são necessárias para que possamos iniciar a importação
if  (p_migr_sequ is not null) and
    (p_mver_sequ is not null) then

    -- busca o separador que será utilizado nas chaves compostas
    SELECT MAX(migr_sepa)
      INTO l_migr_sepa
      FROM mgr_migracao
     WHERE migr_sequ = p_migr_sequ;

    pkg_mgr_imp_producao_aux.p_altera_info_conexao;
 
    begin
        -- descrição da etapa
        l_desc_etap := 'Alimentação das tabelas temporárias';

        -- passado P no parâmetro para limpar qualquer outro tempo de execução que exista desta versão e insirir um novo
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'P', l_desc_etap);
        p_alim_tabelas_temporarias;
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
    exception
        when others then
        -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
        l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

        -- salva a descrição do erro na tabela de log
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
    end;
	
    begin
        -- descrição da etapa
        l_desc_etap := 'Carga da tabela mgr_semestre';

        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
        p_importa_semestre(p_migr_sequ, p_mver_sequ);
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
    exception
        when others then
        -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
        l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

        -- salva a descrição do erro na tabela de log
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
    end;

    begin
        -- descrição da etapa
        l_desc_etap := 'Carga da tabela mgr_semestre_financeiro';

        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
        p_importa_semestre_financeiro(p_migr_sequ, p_mver_sequ);
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
    exception
        when others then
        -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
        l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

        -- salva a descrição do erro na tabela de log
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
    end;

    begin
        -- descrição da etapa
        l_desc_etap := 'Carga da tabela mgr_cidade';

        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
        p_importa_cidade(p_migr_sequ, p_mver_sequ);
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
   exception
        when others then
        -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
        l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

        -- salva a descrição do erro na tabela de log
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
    end;

    begin
        -- descrição da etapa
        l_desc_etap := 'Carga da tabela mgr_sede';

        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
        p_importa_sede(p_migr_sequ, p_mver_sequ);
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
   exception
        when others then
        -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
        l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

        -- salva a descrição do erro na tabela de log
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
    end;

    begin
        -- descrição da etapa
        l_desc_etap := 'Carga da tabela mgr_curso';

        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
        p_importa_curso(p_migr_sequ, p_mver_sequ);
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
    exception
        when others then
        -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
        l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

        -- salva a descrição do erro na tabela de log
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
    end;
    
    begin
        -- descrição da etapa
        l_desc_etap := 'Carga da tabela mgr_turma_semestre';

        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
        p_importa_turma_semestre(p_migr_sequ, p_mver_sequ, l_migr_sepa);
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
   exception
        when others then
        -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
        l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

        -- salva a descrição do erro na tabela de log
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
    end;

    begin
        -- descrição da etapa
        l_desc_etap := 'Carga da tabela mgr_semestre_sede';

        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
        p_importa_semestre_sede(p_migr_sequ, p_mver_sequ, l_migr_sepa);
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
   exception
        when others then
        -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
        l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

        -- salva a descrição do erro na tabela de log
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
    end;

    begin
        -- descrição da etapa
        l_desc_etap := 'Carga da tabela mgr_pessoa';

        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
        p_importa_pessoa(p_migr_sequ, p_mver_sequ);
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
   exception
        when others then
        -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
        l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

        -- salva a descrição do erro na tabela de log
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
    end;

    begin
        -- descrição da etapa
        l_desc_etap := 'Carga da tabela mgr_aluno';

        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
        p_importa_aluno(p_migr_sequ, p_mver_sequ);
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
    exception
        when others then
        -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
        l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

        -- salva a descrição do erro na tabela de log
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
    end;
    
    begin
        -- descrição da etapa
        l_desc_etap := 'Carga da tabela mgr_aluno_turma';

        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
        p_importa_aluno_turma(p_migr_sequ, p_mver_sequ);
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
    exception
        when others then
        -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
        l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

        -- salva a descrição do erro na tabela de log
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
    end;

	begin
        -- descrição da etapa
        l_desc_etap := 'Carga da tabela oli_historico_aluno';

        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
        p_importa_historico_aluno(p_migr_sequ, p_mver_sequ, l_migr_sepa);
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
    exception
        when others then
        -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
        l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

        -- salva a descrição do erro na tabela de log
        pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
    end;

    SELECT COUNT(1)
     INTO l_cont
     FROM oli_historico_aluno
    WHERE ohia_atua = 'S'
      AND EXISTS (SELECT 1
                    FROM mgr_versao
                   WHERE mver_migr = p_migr_sequ
                     AND mver_sequ = ohia_mver)
      AND ohia_dgio IS NULL;

	SELECT COUNT(1)
     INTO l_cont_mtus
     FROM oli_historico_aluno
    WHERE ohia_atua = 'S'
      AND EXISTS (SELECT 1
                    FROM mgr_versao
                   WHERE mver_migr = p_migr_sequ
                     AND mver_sequ = ohia_mver)
      AND ohia_seme >= pkg_mgr_olimpo.f_seme_ini_imp_academico
      AND ohia_turs IS NOT NULL
      AND ohia_mtus IS NULL;

	-- só pode continuar se os dois estiverem zerados
    if  (l_cont = 0 and l_cont_mtus = 0) then

        begin
            -- descrição da etapa
            l_desc_etap := 'Carga da tabela mgr_grade e mgr_grade_curso';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_importa_grade(p_migr_sequ, p_mver_sequ, l_migr_sepa);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;

        begin
            -- descrição da etapa
            l_desc_etap := 'Carga da tabela mgr_grade_semestre';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_importa_grade_semestre(p_migr_sequ, p_mver_sequ);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;

        begin
            -- descrição da etapa
            l_desc_etap := 'Carga da tabela mgr_pessoa com os dados dos professores';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_importa_pessoa_professor(p_migr_sequ, p_mver_sequ);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);    
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;

        begin
            -- descrição da etapa
            l_desc_etap := 'Carga da tabela mgr_professor';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_importa_professor(p_migr_sequ, p_mver_sequ);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);    
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;

        begin
            -- descrição da etapa
            l_desc_etap := 'Carga da tabela mgr_matricula';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_importa_matricula(p_migr_sequ, p_mver_sequ);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;

        begin
            -- descrição da etapa
            l_desc_etap := 'Carga da tabela mgr_grade_seme_prof_disc';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_importa_grad_seme_prof_disc(p_migr_sequ, p_mver_sequ, l_migr_sepa);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;

        begin
            -- descrição da etapa
            l_desc_etap := 'Carga da tabela mgr_aluno_validacao';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_importa_convalidacao(p_migr_sequ, p_mver_sequ);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;

        begin
            -- descrição da etapa
            l_desc_etap := 'Atualizando a grade de formatura do aluno';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_alimenta_grade_aluno(p_migr_sequ);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;

        begin
            -- descrição da etapa
            l_desc_etap := 'Vinculo da grade com a turma';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_alimenta_grade_turma_seme(p_migr_sequ);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;

        begin
            -- descrição da etapa
            l_desc_etap := 'Setando mtus_atua para N em turmas sem vínculos de alunos';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_seta_atua_turma_sem_aluno(p_migr_sequ);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;
    
        begin
            -- descrição da etapa
            l_desc_etap := 'Descrição da grade curso';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_alimenta_desc_grade_curso(p_migr_sequ);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;
		
        begin
            -- descrição da etapa
            l_desc_etap := 'Carga da tabela mgr_formando';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_importa_formando(p_migr_sequ, p_mver_sequ);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;

        begin
            -- descrição da etapa
            l_desc_etap := 'Carga da tabela mgr_atividade_complementar';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_importa_ativ_comp(p_migr_sequ, p_mver_sequ, l_migr_sepa);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;

        begin
            -- descrição da etapa
            l_desc_etap := 'Alimentando os campos referente a forma de ingresso';

            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
            p_alimenta_forma_ingresso(p_migr_sequ);
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
        exception
            when others then
            -- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
            l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

            -- salva a descrição do erro na tabela de log
            pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
        end;
	end if;
	
	begin
		-- descrição da etapa
		l_desc_etap := 'Alimentando a tabela temporária dos convenios';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		p_alim_tab_temp_convenios;
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;

	begin
		-- descrição da etapa
		l_desc_etap := 'Carga da tabela mgr_convenio_tipo';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		p_importa_convenio_tipo(p_migr_sequ, p_mver_sequ);
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;

	begin
		-- descrição da etapa
		l_desc_etap := 'Carga da tabela mgr_convenio_tipo_sese';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		p_importa_convenio_tipo_sese(p_migr_sequ, p_mver_sequ);
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;

	begin
		-- descrição da etapa
		l_desc_etap := 'Carga da tabela mgr_convenio_sese';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		p_importa_convenio_sese(p_migr_sequ, p_mver_sequ);
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;

	begin
		-- descrição da etapa
		l_desc_etap := 'Carga da tabela mgr_convenio_alse';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		p_importa_convenio_alse(p_migr_sequ, p_mver_sequ);
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;
 
	begin
		-- descrição da etapa
		l_desc_etap := 'Carga da tabela mgr_mensalidade';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		p_importa_mensalidade(p_migr_sequ, p_mver_sequ);
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;

	begin
		-- descrição da etapa
		l_desc_etap := 'Carga da tabela mgr_mensalidade_conv';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		p_importa_mensalidade_conv(p_migr_sequ, p_mver_sequ);
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;

	begin
		-- descrição da etapa
		l_desc_etap := 'Gerando registros de mensalidade para convênvios 100%';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		p_gera_mens_convenio_cem_perc(p_migr_sequ, p_mver_sequ);
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;

	begin
		-- descrição da etapa
		l_desc_etap := 'Carga da tabela mgr_requerimento';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		p_importa_requerimento(p_migr_sequ, p_mver_sequ);
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;

	begin
		-- descrição da etapa
		l_desc_etap := 'Carga da tabela mgr_renegociacao';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		p_importa_renegociacao(p_migr_sequ, p_mver_sequ);
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;

	begin
		-- descrição da etapa
		l_desc_etap := 'Carga da tabela mgr_renegociacao_valor';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		p_importa_renegociacao_valor(p_migr_sequ, p_mver_sequ, l_migr_sepa);
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;

	begin
		-- descrição da etapa
		l_desc_etap := 'Fazendo vínculo das renegociações com os registros de origem';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		p_vincula_renegociacao_origem(p_migr_sequ, l_migr_sepa);
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;

	begin
		-- descrição da etapa
		l_desc_etap := 'Carga da tabela mgr_credito_aluno';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		p_importa_credito_aluno(p_migr_sequ, p_mver_sequ, l_migr_sepa);
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;

    begin
		-- descrição da etapa
		l_desc_etap := 'Alimentando a observação dos títulos referente a carne';

		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'I', l_desc_etap);
		pkg_mgr_imp_producao_aux.p_alimenta_observacao_carne(p_migr_sequ, l_migr_sepa);
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, null, '1', 'F', l_desc_etap);
	exception
		when others then
		-- caso aconteça algum erro formata o mesmo para que seja atualizado no registro de log
		l_desc_erro := pkg_util.f_formata_erro_call_stack('Erro na etapa de ' || l_desc_etap);

		-- salva a descrição do erro na tabela de log
		pkg_mgr_imp_producao.p_controla_log_execucao(   p_mver_sequ, l_desc_erro, '1', 'F', l_desc_etap);
	end;
end if;

end p_executa_importacao;

end pkg_mgr_olimpo;
/
declare

begin

pkg_mgr_olimpo.p_alimenta_forma_ingresso(3);

pkg_mgr_imp_producao.p_alimenta_form_ingr_aluno(3);

end;
/