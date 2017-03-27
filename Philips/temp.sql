exec pls_pp_cta_gerar_lote_pag(69, 1, 'dlehmkuhl');

execute immediate 'truncate table decbuh';

insert 	into decbuh (ds_conteudo) 
select 	nr_seq_prestador || ' - ' || nr_seq_evento
from	pls_pp_lote_prest_event;
commit;

exec pls_pp_filtro_ocor_fin_pck.gerencia_selecao_ocor_fin( 69, 1, 'dlehmkuhl');


pls_pp_lote_prest_event

pls_pp_rp_ofin_selecao
pls_pp_rp_cta_selecao

pls_pp_prestador_tmp

--#decioAqui

------- FAZER --------
************* Ver para tabela PLS_TISS_TERMO_CRED_DEB ir na versão
************* Ver para alimentar a tabela pls_pp_lote_prest_event


exec pls_pp_lanc_programado_pck.gerar_lancamento_programado(69, 'P', 'FIXO', 'dlehmkuhl', 1);

exec pls_pp_cta_gerar_lote_pag(69, 1, 'dlehmkuhl');

exec pls_pp_cta_desfazer_lote_pag(69, 1, 'dlehmkuhl');


exec pls_pp_cta_desfazer_lote_pag(89, 1, 'dlehmkuhl');


Recebemos sua solicitação e estamos encaminhando para análise.
Qualquer dúvida estamos a disposição.


Recebemos sua solicitação e estamos dando prioridade a ela.
Qualquer dúvida estamos a disposição.


William, encaminho a OS para vossa análise.
Qualquer consideração estou a disposição.


Os índices abaixo foram criados no dicionário de dados e na base Wheb conforme solicitado

PLS_CONTA_GLOSA -> nr_seq_proc_partic, nr_seq_motivo_glosa ---- PLSCOGL_I3

PLS_CONTA_GLOSA -> nr_seq_conta_proc, nr_seq_motivo_glosa ---- PLSCOGL_I4

PLS_CONTA_GLOSA -> nr_seq_conta_mat, nr_seq_motivo_glosa ---- PLSCOGL_I5

PLS_CONTA_GLOSA -> nr_seq_conta, nr_seq_motivo_glosa ---- PLSCOGL_I6

Versao.wheb e Depois33.sql

Para quem não atualizou a versão, apenas baixar o versao.wheb. Para quem já atualizou apenas executar o Depois35.sql

Melhoria de performance quanto a classificação de regras dos itens assistenciais do SIP.

Boa tarde Edson.

Acredito que esta OS seja dos teus grupos.
Qualquer coisa estou a disposição.


Boa tarde Jessica.

Para darmos mais agilidade quanto a solução desta OS necessitamos do trace do processo.
Para tal, utilize as teclas Ctrl + Shift + Alt + F11 e digite um identificador sem caracteres especiais ou espaços. Exemplo: trace_acao_consistir_conta.
Em seguida, execute o processo de consistência e ao final do processo pressione novamente as teclas Ctrl + Shift + Alt + F11.
Este identificador deve ser repassado para o pessoal responsável pelo banco de dados para que os mesmos apliquem um tkprof do trace gerado.
Ao final, eles lhe devolverão um arquivo de trace que deve ser encaminhado para a Philips.
Qualquer dúvida estamos a disposição.


OS 991735 é a da INFRA

PLS_PP_CTA_GERAR_LOTE_PAG
PLS_PP_CTA_DESFAZER_LOTE_PAG

-- Rotinas do novo pagamento
--> pls_filtro_regra_event_cta_pck
--> pls_pp_lote_pagamento_pck
--> pls_pp_filtro_prod_medica_pck
--> pls_pp_filtro_ocor_fin_pck
--> pls_pp_lanc_programado_pck
--> pls_pp_tit_pag_rec_pck


--> pls_pp_cta_gerar_lote_pag
--> pls_pp_cta_desfazer_lote_pag


Em levantamento na rotina atual, até este momento foram definidos os seguintes processos:

- Criar uma package para trabalhar com os lançamentos programados (pls_pp_lanc_programado_pck)
- Criar uma tabela temporária com todos os prestadores ativos que podem ter algum registro no lote
- Alimentar campos acessórios desta tabela com dados que podem vir a ser utilizados durante a geração do lote.
  Exemplos são: prestador matriz, prestador de pagamento, prestador terceiro, se é ou não cooperado, etc.
- Criar uma trigger para a tabela PLS_PP_LANC_PROGRAMADO que tem como objetivo alimentar os campos dt_referencia


exec pls_pp_cta_desfazer_lote_pag(1, 1, 'dlehmkuhl');
exec pls_pp_cta_gerar_lote_pag(1, 1, 'dlehmkuhl');


insert into pls_pp_lote (cd_estabelecimento, dt_atualizacao, dt_atualizacao_nrec,
dt_mes_competencia, dt_referencia_inicio, dt_referencia_fim,
ie_exibe_portal, ie_recurso_proprio, ie_status,
ie_tipo_dt_referencia, ie_tipo_lote, nm_usuario,
nm_usuario_nrec, nr_seq_regra_periodo, nr_sequencia
) values ( 1, sysdate, sysdate,
to_date('01/12/2015', 'dd/mm/yyyy'), to_date('01/12/2015', 'dd/mm/yyyy'),
to_date('31/12/2015', 'dd/mm/yyyy'),
'N', 'N', 'P',
'1', 'N', 'dlehmkuhl',
'dlehmkuhl', 1, pls_pp_lote_seq.nextval);


pls_gerar_w_analise_item_proc -> rotina que preciso conversar com o Alex sobre limites em variáveis table

select pls_pp_filtro_prod_medica_pck.obter_incidencia_regra_selecao(null, 1) x from dual

exec pls_pp_cta_gerar_lote_pag(	10, 1, 'dlehmkuhl');


-- nova regra de vínculo de eventos a itens
exec pls_pp_cta_evento_combinada(null, 879310, 1, 'dlehmkuhl');
exec pls_pp_cta_evento_combinada(126984, null, 1, 'dlehmkuhl');
-- package que gerencia a nova rotina
pls_filtro_regra_event_cta_pck
-- rotina antiga
pls_obter_evento_item


-- Ocorrências combinadas para a importação XML
exec pls_oc_cta_gerar_combinada_imp( null, 85, null, null, null, null, null, null, null, null, 1, 'dutpadel');
exec pls_oc_cta_gerar_combinada_imp( null, 742, null, null, null, null, null, null, null, null, 1, 'dutpadel');
-- rotinas envolvidas no novo processo
pls_oc_cta_selecao_imp
pls_ocor_imp_pck
pls_oc_cta_gerar_combinada_imp


-- Rotinas envolvidas nas novas regras e critérios de preço
exec pls_filtro_regra_preco_cta_pck.gerencia_regra_filtro('P', null, 79658, null, null, null, null, null, null, 1, 'dlehmkuhl');
pls_entao_regra_preco_cta_pck
select * from pls_cp_cta_selecao where nr_id_transacao = 5014
select * from pls_cp_cta_selecao
select * from pls_cp_cta_entao

exec tasy_trace(0, 'analise_8332654_1');
exec pls_oc_cta_gerar_combinada('CC', 'A', null, null, null, null, null, null, 8332654, null, null, null, null, null, 1, 'wheb.opsxxx');
exec tasy_trace(1, 'analise_8332654_1');

exec wheb_profiler_pck.start_profiler;
exec pls_oc_cta_gerar_combinada('CC', 'A', null, null, null, null, null, null, 8332654, null, null, null, null, null, 1, 'wheb.opsxxx');
exec wheb_profiler_pck.stop_profiler;

exec utl_recomp.recomp_parallel(10,'TASY');

exec PLS_GERENCIA_UPD_OBJ_PCK.ATUALIZAR_OBJETOS('Tasy', 'PLS_ESTRUTURA_MATERIAL_TM');

exec wheb_profiler_pck.start_profiler;
exec teste_performance;
exec wheb_profiler_pck.stop_profiler;

exec wheb_profiler_pck.start_profiler;
exec pls_oc_cta_gerar_combinada('CC', 'A', null, null, null, null, null, null, 8332654, null, null, null, null, null, 1, 'wheb.opsxxx');
exec wheb_profiler_pck.stop_profiler;

exec pls_gerencia_upd_obj_pck.marcar_para_atualizacao('PLS_GRUPO_PARTIC_TM', nvl(wheb_usuario_pck.get_nm_usuario, 'versao'));
commit;
exec PLS_GERENCIA_UPD_OBJ_PCK.ATUALIZAR_OBJETOS('Tasy', 'PLS_GRUPO_PARTIC_TM');

exec pls_gerencia_upd_obj_pck.marcar_para_atualizacao('PLS_ESTRUTURA_OCOR_TM', nvl(wheb_usuario_pck.get_nm_usuario, 'versao'));
commit;
exec PLS_GERENCIA_UPD_OBJ_PCK.ATUALIZAR_OBJETOS('Tasy', 'PLS_ESTRUTURA_OCOR_TM');


---------------------------------------------------------------------- OSs RADAR -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

OS projeto view materializada: 682830
OS para habilitar criação de contexto: 860492
OS Décio Tecnologia tabela temporária objeto inconsistente - 938888

---------------------------------------------------------------------- FIM OSs RADAR -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------- ÚTEIS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- tratamentos de nulos para referência
PLS_REGRA_ORIGEM_PROCED->DT_INICIO_VIGENCIA_REF - cd_expressao = 685963
PLS_REGRA_ORIGEM_PROCED->DT_FIM_VIGENCIA_REF - cd_expressao = 685967

tkprof um_parse.trc um_parse.txt

-- tempo de execução
tkprof x1.trc x1.txt SORT=(EXEELA) AGGREGATE=YES

tkprof x9.trc x9.txt

tkprof x2.trc x2_1.txt SORT = (PRSDSK, EXEDSK, FCHDSK) AGGREGATE=YES

tkprof x2.trc x2.txt SORT=(EXEELA, EXECPU, EXECNT) AGGREGATE=YES


\\whebs03\icones$\Iconshock_super_vista\IS_supervista_general_05237209110372902907002\png\NORMAL\64\
\\whebs03\icones$\Iconshock_super_vista\IS_supervista_medical_64863281216279180808002\png\NORMAL\64\

Fones da Rio Preto
(17) 3202 1259
(17) 3202 1240

Gustavo Teiko - 91780166
Anderson Teiko - 91957524

Número minha cadeira: 01832

---------------------------------------------------------------------- FIM ÚTEIS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------- COMANDOS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
begin 
tasy.pls_analise_cta_pck.ie_atu_nr_seq_agrup_analise := 'N';
tasy.pls_util_cta_pck.ie_grava_log_w := 'N';
tasy.wheb_usuario_pck.set_nm_usuario('wheb.ops');
tasy.pls_util_cta_pck.ie_grava_log_w := 'N';
end;
/
exec tasy_trace(0, 'analise_7627610_1');
exec pls_consistir_analise(7627610, 5, 1, 'wheb.ops');
exec tasy_trace(1, 'analise_7627610_1');

exec tasy_trace(0, 'ocorrencia_combinada345-101');
exec pls_cta_processar_lote(4, '6,', null, 'wheb.ops', 1);
exec tasy_trace(1, 'ocorrencia_combinada345-101');

exec tasy_trace(0, 'qtde_exec');
exec pls_regra_qtd_execucao_pck.pls_gerencia_regra_qtd_exec(null, null, 2, null, null, 'wheb.ops', 1);
exec tasy_trace(1, 'qtde_exec');

exec pls_gerencia_autogerado_pck.pls_define_se_autogerado(null, null, 3, null, 'wheb.ops', 1);
exec pls_oc_cta_gerar_combinada('CC', 'A', 40089, null, null, null, null, null, null, null, null, null, null, null, 1, 'wheb.opsxxx');
exec pls_simult_concor_pck.atu_pls_combinacao_item_tm(null, 'dlehmkuhl');
-- se precisar passar alguns parâmetros a mais
exec pls_gerencia_upd_obj_pck.marcar_para_atualizacao(	'PLS_ESTRUTURA_MATERIAL_TM', 'dlehmkuhl', 'nr_seq_estrutura_p=,nr_seq_material_p=56398');

-- atualização de objetos
exec dbms_output.put_line('Atualizando objetos. Aguarde, esta operação pode levar alguns minutos!');
begin
declare

begin

pls_gerencia_upd_obj_pck.marcar_para_atualizacao('PLS_ESTRUTURA_MATERIAL_TM', nvl(wheb_usuario_pck.get_nm_usuario, 'versao'));
commit;
pls_gerencia_upd_obj_pck.atualizar_objetos(nvl(wheb_usuario_pck.get_nm_usuario, 'versao'), 'PLS_ESTRUTURA_MATERIAL_TM');
commit;
end;
end;
/

-- deixa a validação de materiais habilitados para o prestador mais rápida
create materialized view pls_prestador_mat_vm
refresh complete
as 
 select * from pls_prestador_mat_v;
 
create index pls_prestador_mat_vm_i1 on pls_prestador_mat_vm(nr_seq_material, nr_seq_prestador);
create index pls_prestador_mat_vm_i3 on pls_prestador_mat_vm(dt_inicio_vigencia, dt_fim_vigencia);
create index pls_prestador_mat_vm_i4 on pls_prestador_mat_vm(ie_tipo_atendimento);

-- geração da análise
exec tasy_trace(0, 'geracao_analise34848');
begin pls_util_cta_pck.ie_grava_log_w := 'N'; end;
/
exec pls_gerar_analise_lote(34848, 'N', 'N', 1, 'wheb.ops', null, null, null);
exec tasy_trace(1, 'geracao_analise34848');

begin
declare
nr_seq_log_exec_w pls_cta_log_exec.nr_sequencia%type;
begin

pls_cta_processo_pck.executa_processo(	null, null, null, 463036, null, null, null, null,
					'14,18', null, 'dlehmkuhl', 1, nr_seq_log_exec_w);
end;
end;
/

exec pls_posicionar_sequence_cache('PLS_SELECAO_OCOR_CTA', 'NR_SEQUENCIA', 'N', 1000);
exec pls_cria_pls_parametro_v(null);
exec sql_pck.executa_sql_dinamico('update decbuh set ds = ''que coisa bonita, legal'' where nr_sequencia in (401,402,341,342)');


begin
declare
ds_sql_w 		varchar2(1000);
qt_registro_w 		pls_integer;
nm_tablespace_index_w	varchar2(100);
begin
	select	Obter_Tablespace_Index(null) 
	into	nm_tablespace_index_w
	from 	dual;
	
	select	count(1)
	into	qt_registro_w
	from	user_tab_columns
	where	table_name = 'PLS_GRAU_CLASSIF_ITEM'
	and	column_name = 'VL_PORTE';	

	if	(qt_registro_w > 0) then	
		exec_sql_dinamico('Tasy','alter table PLS_GRAU_CLASSIF_ITEM drop column VL_PORTE');
	end if;	
exception
when others then
	null;
end;
commit;
end;
/
---------------------------------------------------------------------- FIM COMANDOS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------- SQLS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select nr_seq_analise, qtde_proc, qtde_mat, (qtde_proc + qtde_mat) qt_item
from (
select a.nr_sequencia nr_seq_analise,
       (select count(1) from pls_conta_proc_v z where z.nr_seq_analise = a.nr_sequencia) qtde_proc,
       (select count(1) from pls_conta_mat_v z where z.nr_seq_analise = a.nr_sequencia) qtde_mat
from   pls_analise_conta a
where  a.dt_analise between to_date('01/03/2015') and to_date('31/03/2015')
)
order by qt_item desc

--select count(1) from (
select a.nr_seq_ocorrencia,
       a.nr_seq_regra,
       a.dt_inicio_processo,
       a.dt_fim_processo,
       a.ds_tempo_execucao,
       a.nr_id_transacao,
       a.nr_sequencia,
       a.nr_seq_lote,
       a.nm_usuario
  from pls_oc_cta_log_ocor a
  where 1 = 1
  and   a.nm_usuario = 'wheb.ops'
  and   a.dt_inicio_processo between to_date('12/05/2014 13:00:09', 'dd/mm/yyyy hh24:mi:ss') and to_date('12/05/2014 23:59:59', 'dd/mm/yyyy hh24:mi:ss')
  --and   a.nr_seq_lote is not null  
  --and a.nr_seq_conta is not null
  --and   a.nr_seq_regra = 7
  --and a.nr_seq_lote = 29882
 order by a.nr_sequencia desc
 --order by a.ds_tempo_execucao desc
 --)
   
select b.nr_seq_ocorrencia, a.nr_sequencia 
from tasy.PLS_OC_CTA_FILTRO a,
     tasy.PLS_OC_CTA_COMBINADA b
where a.ie_valida_todo_atend = 'S'
and   b.nr_sequencia = a.nr_seq_oc_cta_comb

select obter_valor_dominio(5174, a.ie_status) ds_status,
       count(1)
from   PLS_XML_ARQUIVO a
where  a.ie_status in ('FIN', 'IMP', 'VAL', 'ERR')  
--and    a.dt_inicio_importacao between (SYSDATE - ((1/24/60) * 10)) and sysdate 
group by a.ie_status

select max(ds_senha)
from   pls_usuario_web
where  nm_usuario_web = 'XML0030';

select count(1), 'qtde_proc' id from pls_conta_proc_v where nr_seq_lote_conta = 56279
union all
select count(1), 'qtde_mat' id from pls_conta_mat_v where nr_seq_lote_conta = 56279

select count(1), 'qtde_proc' id from pls_conta_proc_v where nr_seq_analise = 7627610
union all
select count(1), 'qtde_mat' id from pls_conta_mat_v where nr_seq_analise = 7627610

select count(1), 'qtde_proc' id from pls_conta_proc_v where nr_seq_protocolo = 30079625
union all
select count(1), 'qtde_mat' id from pls_conta_mat_v where nr_seq_protocolo = 30079625

select nr_sequencia, substr(ds_processo, 0, 100) ds_processo, to_char(dt_inicio, 'dd/mm/yyyy hh24:mi:ss') dt_inicio,
       pls_manipulacao_datas_pck.obter_tempo_execucao_format(dt_inicio, nvl(dt_fim, sysdate)) tempo
from tasy.pls_monitor_tempo_lote
where nr_seq_lote_monitor = 1
and   nr_sequencia >= 49
order by nr_sequencia

select nr_sequencia, ds_comando, dt_inicio, dt_fim, 
       tasy.pls_manipulacao_datas_pck.obter_tempo_execucao_format(dt_inicio, nvl(dt_fim, sysdate)) tempo_execucao,
       ds_observacao
  from tasy.pls_sip_nv_tempo_geracao
 where nr_seq_lote = 33
 order by dt_inicio, dt_fim

 select nr_seq_regra, dt_inicio, dt_fim, 
       tasy.pls_manipulacao_datas_pck.obter_tempo_execucao_format(dt_inicio, nvl(dt_fim, sysdate)) tempo_execucao,
       ds_sql
from tasy.sip_nv_tempo_regra 
where nr_seq_lote = 33
order by dt_inicio, dt_fim

select distinct d.nr_seq_conta, d.ie_tipo_guia 
from    tasy.sip_nv_regra_vinc_it c,
        tasy.sip_nv_dados d
where   d.nr_seq_lote_sip = 33
and     c.nr_seq_sip_nv_dados = d.nr_sequencia
and     c.nr_seq_item_assist between 65 and 82
and     d.ie_tipo_guia != 5
minus
select distinct d.nr_seq_conta, d.ie_tipo_guia 
from    tasy.sip_nv_regra_vinc_it c,
        tasy.sip_nv_dados d
where   d.nr_seq_lote_sip = 33
and     c.nr_seq_sip_nv_dados = d.nr_sequencia
and     c.nr_seq_item_assist between 83 and 87
and     d.ie_tipo_guia != 5

pls_convert_long_to_clob(	'PLS_XML_ARQUIVO',
				'DS_XML',
				'WHERE NR_SEQUENCIA = :NR_SEQUENCIA',
				'NR_SEQUENCIA='||nr_seq_xml_arquivo_p,
				ds_conteudo_w);


INSERT INTO PLS_SELECAO_OCOR_CTA (CD_GUIA_REFERENCIA, DT_ITEM, IE_EXCECAO, IE_EXCECAO_EXCECAO,
                                 IE_EXCECAO_EXCECAO_TEMP, IE_EXCECAO_TEMP, IE_MARCADO_EXCECAO,
                                 IE_TIPO_REGISTRO, IE_VALIDO, IE_VALIDO_TEMP,
                                 NR_ID_TRANSACAO, NR_SEQ_CONTA, NR_SEQ_CONTA_MAT,
                                 NR_SEQ_CONTA_PROC, NR_SEQ_FILTRO, NR_SEQ_SEGURADO,
                                 NR_SEQUENCIA, IE_ORIGEM_PROCED, CD_PROCEDIMENTO,
                                 dt_item_dia_ini, Dt_Item_Dia_Fim, dt_item_hora_ini, dt_item_hora_fim)
select cd_guia_referencia, dt_procedimento, 'N', 'N',
       'N', 'N', 'N',
       'P', 'S', 'N',
       99999894, nr_seq_conta, null,
       nr_sequencia, null, nr_seq_segurado,
       pls_selecao_ocor_cta_seq.nextval, ie_origem_proced, cd_procedimento,
       inicio_dia(dt_procedimento), fim_dia(dt_procedimento),
       pls_tipos_ocor_pck.gerencia_ins_dt_item_sel(dt_procedimento, 'INICIO') x,
       pls_tipos_ocor_pck.gerencia_ins_dt_item_sel(dt_procedimento, 'FIM') x
from   pls_conta_proc_v
where  nr_seq_analise = 8332654

---------------------------------------------------------------------- FIM SQLS --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------