create or replace
procedure pls_gerar_trib_prest_venc(	nr_seq_vencimento_p		number,
					nm_usuario_p			varchar2) is

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Finalidade: Gerar os valores de tributos
-------------------------------------------------------------------------------------------------------------------
Locais de chamada direta:
[ X ]  Objetos do dicionário [  ] Tasy (Delphi/Java) [  ] Portal [  ]  Relatórios [ ] Outros:
 ------------------------------------------------------------------------------------------------------------------
Pontos de atenção:
-------------------------------------------------------------------------------------------------------------------
Referências:
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

ds_irrelevante_w		varchar2(4000);
ds_venc_w			varchar2(2000);
ds_erro_w			varchar2(255);
ie_tipo_tributacao_w		varchar2(255);
ie_pago_prev_w			varchar2(255);
ds_emp_retencao_w		varchar2(255);
ds_emp_retencao_ret_w		varchar2(255);
ie_proximo_pgto_eve_w		varchar2(255);
cd_variacao_w			varchar2(50);
ie_periodicidade_w		varchar2(50);
ie_cnpj_w			varchar2(50);
cd_cnpj_raiz_w			varchar2(50);
cd_conta_contabil_w		varchar2(20);
cd_darf_w			varchar2(20);
ie_tipo_tributo_w		varchar2(15);
cd_beneficiario_w		varchar2(14);
cd_cgc_w			varchar2(14);
ie_forma_retencao_inss_ir_w	varchar2(10)	:= null;
cd_pessoa_fisica_w		varchar2(10);
cd_tributo_pf_w			varchar2(10);
cd_pessoa_fisica_pf_w		varchar2(10);
ie_tipo_contrat_a_maior_w	varchar2(10);
cd_darf_nf_w			varchar2(10);
ie_tipo_data_w			varchar2(5);
ie_seq_calculo_inss_w		varchar2(5);
ie_irpf_w			varchar2(3);
ie_apuracao_piso_w		varchar2(3);
ie_filantropia_w		varchar2(3);
ie_tipo_contratacao_w		varchar2(2);
ie_saldo_negativo_w		varchar2(2);
ie_saldo_negativo_venc_w	varchar2(2);
ie_saldo_negativo_prest_w	varchar2(2);
ie_saldo_negativo_param_w	varchar2(2);
ie_inss_tipo_contrat_w		varchar2(1)	:= 'N';
ie_vencimento_w			varchar2(1);
ie_acumulativo_w		varchar2(1);
ie_vencimento_pf_w		varchar2(1);
ie_restringe_estab_w		varchar2(1);
ie_pago_prev_nf_w		varchar2(1);
ie_periodicidade_nf_w		varchar2(1);
ie_valor_base_trib_nf_w		varchar2(1);
ie_recalculou_inss_w		varchar2(1) 	:= 'N';
ie_proximo_pgto_w		varchar2(1)	:= 'N';
ie_data_tributos_w		varchar2(1);
pr_aliquota_w			number(15,4);
pr_base_calculo_w		number(15,4);
pr_aliquota_irpf_w		number(15,4);
vl_nao_retido_w			number(15,2)	:= 0;
vl_menor_minimo_w		number(15,2)	:= 0;
vl_total_trib_w			number(15,2)	:= 0;
vl_inss_w			number(15,2)	:= 0;
vl_base_inss_retido_w		number(15,2)	:= 0;
vl_base_inss_retido_orig_w	number(15,2)	:= 0;
vl_tributo_w			number(15,2);
vl_base_calculo_w		number(15,2);
vl_minimo_tributo_w		number(15,2);
vl_base_retido_outro_w		number(15,2);
vl_trib_acum_w			number(15,2);
vl_pago_w			number(15,2);
vl_base_calculo_paga_w		number(15,2);
vl_soma_trib_nao_retido_w	number(15,2);
vl_soma_base_nao_retido_w	number(15,2);
vl_soma_trib_adic_w		number(15,2);
vl_soma_base_adic_w		number(15,2);
vl_tributo_a_reter_w		number(15,2);
vl_minimo_base_w		number(15,2);
vl_trib_adic_w			number(15,2);
vl_base_a_reter_w		number(15,2);
vl_trib_nao_retido_w		number(15,2);
vl_base_adic_w			number(15,2);
vl_base_nao_retido_w		number(15,2);
vl_teto_base_w			number(15,2);
vl_trib_anterior_w		number(15,2);
vl_vencimento_w			number(15,2);
vl_reducao_w			number(15,2);
vl_desc_dependente_w		number(15,2);
vl_total_base_w			number(15,2);
vl_base_pago_adic_base_w	number(15,2);
vl_base_tributo_pf_w		number(15,2);
vl_tributo_pf_w			number(15,2);
vl_tributo_ret_w		number(15,2);
vl_base_calculo_ret_w		number(15,2);
vl_evento_w			number(15,2);
nr_seq_pag_prest_w		number(15,2);
vl_pagamento_w			number(15,2);
vl_base_calculo_a_maior_w	number(15,2);
vl_estornado_base_maior_w	number(15,2);
vl_saldo_a_maior_w		number(15,2);
vl_base_restante_w		number(15,2);
vl_pag_prest_venc_trib_w	number(15,2);
vl_base_calculo_nf_w		number(15,2);
vl_tributo_nf_w			number(15,2);
vl_reducao_base_nf_w		number(15,2);
vl_trib_nao_retido_nf_w		number(15,2);
vl_base_nao_retido_nf_w		number(15,2);
vl_trib_adic_nf_w		number(15,2);
vl_base_adic_nf_w		number(15,2);
vl_reducao_nf_w			number(15,2);
vl_trib_inss_w			number(15,2);
vl_desconto_event_w		number(15,2);
vl_tributo_irpf_w		number(15,2);
vl_total_eventos_w		number(15,2);
vl_itens_w			number(15,2);
vl_trib_aux_w			number(15,2)	:= 0;
vl_total_desconto_w		number(15,2);
vl_total_prod_w			number(15,2);
vl_gerado_w			number(15,2);
vl_gerado_ret_w			number(15,2);
vl_desc_base_w			number(15,2);
qt_lote_ret_trib_w		number(15);
nr_seq_alt_w			number(10);
cd_tributo_w			number(10);
nr_seq_venc_trib_w		number(10);
cd_cond_pagto_w			number(10);
nr_seq_trans_reg_w		number(10);
nr_seq_trans_baixa_w		number(10);
cd_conta_financ_w		number(10);
nr_seq_prestador_w		number(10);
qt_imposto_mes_w		number(10);
cd_tributo_ret_w		number(10);
nr_seq_regra_trib_w		number(10);
ie_ordem_w			number(10);
nr_seq_venc_trib_a_maior_w	number(10);
nr_seq_classe_w			number(10);
nr_seq_pag_prest_venc_trib_w	number(10);
cd_tributo_nf_w			number(10);
ie_loop_w			number(10) := 0;
pr_fator_w			number(7,6);
tx_tributo_nf_w			number(7,4);
qt_venc_w			number(5);
cd_estabelecimento_w		number(5);
qt_registro_w			number(5);
cd_tipo_baixa_neg_w		number(5);
cd_empresa_w			number(4);
cont_w				number(3);
ie_sequencia_w			number(3)	:= 999;
qt_dependente_w			number(2);
dt_emissao_w			date;
dt_vencimento_w			date;
dt_venc_titulo_w		date;
dt_tributo_w			date;
dt_referencia_w			date;
dt_inicio_vigencia_w		date;
dt_fim_vigencia_w		date;
dt_ref_tributo_w		date;
dt_competencia_w		date;
dt_calculo_w			date;
vl_base_ret_outro_anterior_w	number(15,2);
ie_trib_saldo_tit_nf_w		parametros_contas_pagar.ie_trib_saldo_tit_nf%type;
ie_venc_pls_pag_prod_w		tributo.ie_venc_pls_pag_prod%type;
ie_agrupado_w			varchar2(255);
nr_seq_pag_item_w		pls_pagamento_item.nr_sequencia%type;
nr_seq_regra_irpf_w		regra_calculo_irpf.nr_sequencia%type;
vl_equivalencia_base_w		number(15,4);
vl_evento_trib_w		number(15,4);
vl_tx_evento_trib_w		number(15,4);
vl_evento_tot_w			number(15,4);
vl_base_estorno_inss_w		pls_pag_prest_venc_trib.vl_base_calculo%type	:= 0;
nr_seq_tipo_prestador_w		pls_tipo_prestador.nr_sequencia%type;
ie_data_ref_tributo_w		varchar2(2);
dt_imposto_w			date;
nr_seq_pessoa_trib_w		pessoa_fisica_trib.nr_sequencia%type;
nr_seq_lote_w			pls_lote_pagamento.nr_sequencia%type;
nr_seq_lote_pgto_w		pessoa_fisica_trib.nr_seq_lote_pgto%type;
vl_ir_anterior_w		number(15,4);

cursor C01 is
	select	cd_tributo,
		ie_vencimento,
		ie_tipo_tributo,
		ie_apuracao_piso,
		ie_cnpj,
		ie_restringe_estab,
		ie_venc_pls_pag_prod
	from	tributo	a
	where	ie_conta_pagar	= 'S'
	and	ie_situacao	= 'A'
	and	((ie_pf_pj = 'A') or
		((ie_pf_pj = 'PF') and (cd_pessoa_fisica_w is not null)) or
		((ie_pf_pj = 'PJ') and (cd_cgc_w is not null)))
	and	((nvl(ie_tipo_tributacao_w, 'X') <> '0') or (nvl(ie_super_simples, 'S') = 'S'))
	and	not exists	(select	1
				from	nota_fiscal_trib y,
					nota_fiscal x
				where	x.nr_sequencia = y.nr_sequencia
				and	x.nr_seq_pgto_prest = nr_seq_pag_prest_w
				and	y.cd_tributo = a.cd_tributo)
	order	by decode(ie_tipo_tributo, 'INSS', 1, 2);

cursor C02 is
	select 	b.cd_tributo,
		b.vl_base_calculo,
		b.vl_tributo,
		b.dt_inicio_vigencia,
		b.dt_fim_vigencia,
		b.cd_pessoa_fisica,
		a.ie_vencimento,
		b.ds_emp_retencao,
		b.ie_tipo_data,
		nvl(b.ie_pago_prev_lote_pag_ops, 'P'),
		b.nr_sequencia,
		b.nr_seq_lote_pgto
	from	tributo			a,
		pessoa_fisica_trib	b
	where	b.cd_tributo 		= a.cd_tributo
	and	b.cd_pessoa_fisica 	= cd_pessoa_fisica_w
	and	((b.cd_estabelecimento	= cd_estabelecimento_w) or (b.cd_estabelecimento is null))
	and	decode(b.ie_tipo_data, 'E', trunc(dt_emissao_w, 'month'), 'V', dt_venc_titulo_w) between trunc(b.dt_inicio_vigencia, 'month') and dt_fim_vigencia;

cursor C03 is
	/* Obter o valor base para o tributo conforme regras */
	select	vl_evento,
		ie_tipo_contratacao,
		ie_ordem,
		nr_seq_pag_item
	from	(
		select	nvl(sum(a.vl_item),0) + decode(ie_valor_base_trib_nf_w,'S',nvl(sum(a.vl_glosa),0),0) vl_evento,
			null ie_tipo_contratacao,
			9999 ie_ordem,
			decode(ie_agrupado_w, 'S', 0, a.nr_sequencia) nr_seq_pag_item
		from	pls_evento_tributo	c,
			pls_pagamento_item	a,
			pls_pagamento_prestador	b
		where	a.nr_seq_evento		= c.nr_seq_evento
		and	a.nr_seq_pagamento	= b.nr_sequencia
		and	c.cd_tributo		= cd_tributo_w
		and	nvl(c.ie_situacao,'N')	= 'A'
		and	b.nr_sequencia		= nr_seq_pag_prest_w
		and	nvl(a.ie_apropriar_total, 'N')	= 'N'
		and	((pls_obter_se_prestador_grupo(c.nr_seq_grupo_prestador,b.nr_seq_prestador) = 'S') or (c.nr_seq_grupo_prestador is null))
		and	((b.nr_seq_prestador = c.nr_seq_prestador) or (c.nr_seq_prestador is null))
		and	((c.nr_seq_tipo_prestador =	(select	max(x.nr_seq_tipo_prestador)
							from	pls_prestador	x
							where	x.nr_sequencia	= b.nr_seq_prestador)) or (c.nr_seq_tipo_prestador is null))
		and	(ie_tipo_tributo_w <> 'INSS' or ie_inss_tipo_contrat_w = 'N')
		and	dt_competencia_w	between nvl(c.dt_inicio_vigencia, dt_competencia_w - 1) and nvl(c.dt_fim_vigencia, dt_competencia_w + 1)
		group by decode(ie_agrupado_w, 'S', 0, a.nr_sequencia)
		union all
		select	nvl(sum(a.vl_item),0) + decode(ie_valor_base_trib_nf_w, 'S', nvl(sum(a.vl_glosa), 0),0) vl_evento,
			a.ie_tipo_contratacao ie_tipo_contratacao, /* Precisa agora buscar nos eventos financeiros os tipos de contratação, devido à importação */
			decode(a.ie_tipo_contratacao,null,999, 'CE', 1, 'CA', 2, 'CI', 3, 'I', 4) ie_ordem,
			decode(ie_agrupado_w, 'S', 0, a.nr_sequencia) nr_seq_pag_item
		from	pls_evento		d,
			pls_evento_tributo	c,
			pls_pagamento_item	a,
			pls_pagamento_prestador	b
		where	a.nr_seq_evento		= c.nr_seq_evento
		and	a.nr_seq_pagamento	= b.nr_sequencia
		and	a.nr_seq_evento		= d.nr_sequencia
		and	d.ie_tipo_evento	= 'F' -- ebcabral - 07/10/2013 - OS 653841 / Alterado para apenas trazer o valor dos itens de eventos que não são de produção médica. Pois os itens de eventos de produção médica, são obtidos no select de baixo obtendo a informação da conta médica.
		--and	((a.nr_tit_pagar_origem is not null) or (a.nr_tit_receber_origem is not null))
		and	c.cd_tributo		= cd_tributo_w
		and	nvl(c.ie_situacao,'N')	= 'A'
		and	b.nr_sequencia		= nr_seq_pag_prest_w
		and	nvl(a.ie_apropriar_total, 'N')	= 'N'
		and	((pls_obter_se_prestador_grupo(c.nr_seq_grupo_prestador,b.nr_seq_prestador) = 'S') or (c.nr_seq_grupo_prestador is null))
		and	((b.nr_seq_prestador = c.nr_seq_prestador) or (c.nr_seq_prestador is null))
		and	((c.nr_seq_tipo_prestador =	(select	max(x.nr_seq_tipo_prestador)
							from	pls_prestador	x
							where	x.nr_sequencia	= b.nr_seq_prestador)) or (c.nr_seq_tipo_prestador is null))
		and	ie_tipo_tributo_w	= 'INSS'
		and	ie_inss_tipo_contrat_w  = 'S'
		and	dt_competencia_w	between nvl(c.dt_inicio_vigencia, dt_competencia_w - 1) and nvl(c.dt_fim_vigencia, dt_competencia_w + 1)
		group by a.ie_tipo_contratacao,
			decode(ie_agrupado_w, 'S', 0, a.nr_sequencia)
		union all
		/* Para INSS a alíquota varia conforme o tipo de contratação */
		select	( vl_total_prod_w - vl_total_desconto_w) *
			(dividir_sem_round((nvl(sum(d.vl_liberado),0) + decode(ie_valor_base_trib_nf_w, 'S', nvl(sum(d.vl_glosa), 0), 0)) , vl_total_prod_w)),
			--nvl(sum(d.vl_liberado),0) + decode(ie_valor_base_trib_nf_w,'S',nvl(sum(d.vl_glosa),0),0),
			nvl(d.ie_tipo_contratacao, 'S') ie_tipo_contratacao,
			decode(d.ie_tipo_contratacao,null,ie_sequencia_w, 'CE', 1, 'CA', 2, 'CI', 3, 'I', 4) ie_ordem,
			decode(ie_agrupado_w, 'S', 0, a.nr_sequencia) nr_seq_pag_item
		from	pls_segurado		e,
			pls_evento_tributo	c,
			pls_conta_medica_resumo	d,
			pls_pagamento_item	a,
			pls_pagamento_prestador	b
		where	a.nr_sequencia		= d.nr_seq_pag_item
		and	a.nr_seq_evento		= c.nr_seq_evento
		and	e.nr_sequencia		= d.nr_seq_segurado(+)
		and	b.nr_sequencia		= a.nr_seq_pagamento
		and	c.cd_tributo		= cd_tributo_w
		and	nvl(c.ie_situacao,'N')	= 'A'
		and	b.nr_sequencia		= nr_seq_pag_prest_w
		and	((pls_obter_se_prestador_grupo(c.nr_seq_grupo_prestador,b.nr_seq_prestador) = 'S') or (c.nr_seq_grupo_prestador is null))
		and	((b.nr_seq_prestador = c.nr_seq_prestador) or (c.nr_seq_prestador is null))
		and	((c.nr_seq_tipo_prestador =	(select	max(x.nr_seq_tipo_prestador)
							from	pls_prestador	x
							where	x.nr_sequencia	= b.nr_seq_prestador)) or (c.nr_seq_tipo_prestador is null))
		and	ie_tipo_tributo_w	= 'INSS'
		and	ie_inss_tipo_contrat_w  = 'S'

		and	((d.ie_situacao is null) or (d.ie_situacao != 'I'))
		and	dt_competencia_w	between nvl(c.dt_inicio_vigencia, dt_competencia_w - 1) and nvl(c.dt_fim_vigencia, dt_competencia_w + 1)
		group by d.ie_tipo_contratacao,
			decode(ie_agrupado_w, 'S', 0, a.nr_sequencia))
	where	vl_evento <> 0
	order by ie_ordem;

/* Obter valores retidos de INSS com alíquota a maior para estornar */
cursor C04 is
	select	a.nr_sequencia,
		a.vl_base_calculo
	from	pls_lote_pagamento		e,
		pls_prestador			d,
		pls_pagamento_prestador		c,
		pls_pag_prest_vencimento	b,
		pls_pag_prest_venc_trib		a
	where	a.nr_seq_vencimento		= b.nr_sequencia
	and	b.nr_seq_pag_prestador		= c.nr_sequencia
	and	c.nr_seq_prestador		= d.nr_sequencia
	and	e.nr_sequencia			= c.nr_seq_lote
	and	d.cd_pessoa_fisica		= cd_pessoa_fisica_w
	and	a.cd_tributo			= cd_tributo_w
	and	ie_data_ref_tributo_w		= 'C' /*Competência */
	and	e.dt_mes_competencia between trunc(dt_tributo_w,'month') and fim_dia(last_day(dt_tributo_w))
	and	a.pr_tributo	> pr_aliquota_w
	and	b.nr_sequencia	<> nr_seq_vencimento_p /* não buscar do mesmo pagamento */
	and	vl_base_restante_w > 0
	and	a.nr_seq_trib_estornado is null
	and	(select	nvl(sum(x.vl_base_calculo),0)
		from	pls_pag_prest_venc_trib x
		where	x.nr_seq_trib_estornado	= a.nr_sequencia) < a.vl_base_calculo
	union all
	select	a.nr_sequencia,
		a.vl_base_calculo
	from	pls_lote_pagamento		e,
		pls_prestador			d,
		pls_pagamento_prestador		c,
		pls_pag_prest_vencimento	b,
		pls_pag_prest_venc_trib		a
	where	a.nr_seq_vencimento		= b.nr_sequencia
	and	b.nr_seq_pag_prestador		= c.nr_sequencia
	and	c.nr_seq_prestador		= d.nr_sequencia
	and	e.nr_sequencia			= c.nr_seq_lote
	and	d.cd_pessoa_fisica		= cd_pessoa_fisica_w
	and	a.cd_tributo			= cd_tributo_w
	and	ie_data_ref_tributo_w		= 'V' /* Vencimento */
	and	b.dt_vencimento between trunc(dt_tributo_w,'month') and fim_dia(last_day(dt_tributo_w))
	and	a.pr_tributo	> pr_aliquota_w
	and	b.nr_sequencia	<> nr_seq_vencimento_p /* não buscar do mesmo pagamento */
	and	vl_base_restante_w > 0
	and	a.nr_seq_trib_estornado is null
	and	(select	nvl(sum(x.vl_base_calculo),0)
		from	pls_pag_prest_venc_trib x
		where	x.nr_seq_trib_estornado	= a.nr_sequencia) < a.vl_base_calculo;

cursor C05 is
	select	b.cd_tributo,
		b.vl_base_calculo,
		b.vl_tributo,
		b.tx_tributo,
		b.vl_reducao_base,
		b.vl_trib_nao_retido,
		b.vl_base_nao_retido,
		b.vl_trib_adic,
		b.vl_base_adic,
		b.vl_reducao,
		b.cd_darf,
		b.ie_pago_prev,
		b.ie_periodicidade
	from	nota_fiscal_trib	b,
		nota_fiscal		a
	where	a.nr_sequencia		= b.nr_sequencia
	and	a.nr_seq_pgto_prest	= nr_seq_pag_prest_w
	and	a.ie_situacao <> '3'
	and	not exists	(select	1
				from	pls_pagamento_nota	x
				where	x.nr_seq_nota_fiscal	= a.nr_sequencia);

cursor C06 is
	select	b.cd_tributo,
		b.vl_base_calculo,
		b.vl_tributo,
		b.tx_tributo,
		b.vl_reducao_base,
		b.vl_trib_nao_retido,
		b.vl_base_nao_retido,
		b.vl_trib_adic,
		b.vl_base_adic,
		b.vl_reducao,
		b.cd_darf,
		b.ie_pago_prev,
		b.ie_periodicidade,
		b.cd_variacao
	from	nota_fiscal_trib	b,
		nota_fiscal		a,
		pls_pagamento_nota	c
	where	a.nr_sequencia		= b.nr_sequencia
	and	a.nr_sequencia		= c.nr_seq_nota_fiscal
	and	c.nr_seq_pagamento	= nr_seq_pag_prest_w
	and	a.ie_situacao <> '3';

cursor C07 is
	select	a.vl_base_calculo,
		a.pr_tributo,
		a.nr_sequencia,
		a.vl_imposto,
		b.cd_tributo,
		a.ie_tipo_contratacao
	from	tributo b,
		pls_pag_prest_venc_trib a
	where	a.nr_seq_vencimento	= nr_seq_vencimento_p
	and	a.cd_tributo		= b.cd_tributo
	and	b.ie_tipo_tributo	= 'INSS'
	and	a.ie_pago_prev		= 'V'
	and	ie_inss_tipo_contrat_w	= 'S'
	and	vl_base_inss_retido_w	<> 0
	and	a.vl_base_calculo	> 0
	order 	by a.pr_tributo;

cursor c08 (	nr_seq_vencimento_cp	pls_pag_prest_venc_trib.nr_seq_vencimento%type,
		cd_tributo_cp		pls_pag_prest_venc_trib.cd_tributo%type,
		ie_tipo_contratacao_cp	pls_pag_prest_venc_trib.ie_tipo_contratacao%type) is
	select	nr_sequencia,
		vl_base_calculo,
		vl_imposto
	from	pls_pag_prest_venc_trib
	where	nr_seq_vencimento	= nr_seq_vencimento_cp
	and	cd_tributo		= cd_tributo_cp
	and	nvl(ie_tipo_contratacao, '-1') = nvl(ie_tipo_contratacao_cp, '-1')
	and	vl_base_calculo > 0;

cursor c09 (	nr_seq_vencimento_cp	pls_pag_prest_venc_trib.nr_seq_vencimento%type ) is
	select	z.nr_sequencia,
		z.vl_base_calculo,
		z.vl_imposto,
		x.vl_evento_origem vl_evento,
		x.nr_sequencia nr_seq_item_trib,
		z.cd_tributo
	from	pls_pag_prest_venc_trib z,
		pls_pag_item_trib	x
	where	z.nr_sequencia		= x.nr_seq_venc_trib
	and	z.nr_seq_vencimento	= nr_seq_vencimento_cp
	and	z.vl_base_calculo	> 0;

begin
select	decode(count(1), 0, 'N', 'S')
into	ie_inss_tipo_contrat_w
from	tributo_conta_pagar	a
where	a.ie_tipo_contratacao is not null
and	rownum <= 1;

select	a.vl_vencimento,
	c.cd_estabelecimento,
	a.dt_vencimento,
	nvl(c.dt_ref_tributo, c.dt_mes_competencia),
	d.cd_cgc,
	d.cd_pessoa_fisica,
	b.nr_seq_prestador,
	nvl(c.dt_mes_competencia, a.dt_vencimento),
	obter_cnpj_raiz(d.cd_cgc),
	b.nr_sequencia,
	b.vl_pagamento,
	e.cd_empresa,
	a.ie_proximo_pgto,
	a.ie_saldo_negativo,
	c.dt_mes_competencia,
	d.nr_seq_tipo_prestador,
	c.nr_sequencia
into	vl_vencimento_w,
	cd_estabelecimento_w,
	dt_venc_titulo_w,
	dt_emissao_w,
	cd_cgc_w,
	cd_pessoa_fisica_w,
	nr_seq_prestador_w,
	dt_tributo_w,
	cd_cnpj_raiz_w,
	nr_seq_pag_prest_w,
	vl_pagamento_w,
	cd_empresa_w,
	ie_proximo_pgto_w,
	ie_saldo_negativo_venc_w,
	dt_competencia_w,
	nr_seq_tipo_prestador_w,
	nr_seq_lote_w
from	estabelecimento 		e,
	pls_prestador			d,
	pls_periodo_pagamento		p,
	pls_lote_pagamento		c,
	pls_pagamento_prestador		b,
	pls_pag_prest_vencimento	a
where	c.cd_estabelecimento	= e.cd_estabelecimento
and	a.nr_seq_pag_prestador	= b.nr_sequencia
and	b.nr_seq_prestador	= d.nr_sequencia
and	b.nr_seq_lote		= c.nr_sequencia
and	p.nr_sequencia		= c.nr_seq_periodo
and	a.nr_sequencia		= nr_seq_vencimento_p;

select	nvl(sum(vl_item), 0)
into	vl_itens_w
from	pls_pagamento_item
where	nr_seq_pagamento	= nr_seq_pag_prest_w
and	vl_item			> 0;

select	nvl(max(ie_saldo_negativo), 'PP'),
	nvl(max(ie_forma_retencao_inss_ir), 'ME'),
	nvl(max(ie_seq_calculo_inss), 'O'),
	nvl(max(ie_data_tributos), 'R')
into	ie_saldo_negativo_param_w,
	ie_forma_retencao_inss_ir_w,
	ie_seq_calculo_inss_w,
	ie_data_tributos_w
from	pls_parametro_pagamento
where	cd_estabelecimento	= cd_estabelecimento_w;

select	decode(ie_data_tributos_w, 'R', nvl(dt_venc_titulo_w,dt_tributo_w), sysdate)
into	dt_calculo_w
from	dual;

select	nvl(max(ie_saldo_negativo), 'CP')
into	ie_saldo_negativo_prest_w
from	pls_prestador_pagto
where	nr_seq_prestador	= nr_seq_prestador_w;

if	(ie_saldo_negativo_venc_w is not null) and
	(ie_saldo_negativo_venc_w <> 'CP') then /* Se no vencimento não estiver como conforme prestador, pega do vencimento */
	ie_saldo_negativo_w	:= ie_saldo_negativo_venc_w;
elsif	(ie_saldo_negativo_prest_w = 'CP') then /* Se no prestador não tratar ou estiver conforme parâmetro, pega regra geral */
	ie_saldo_negativo_w	:= ie_saldo_negativo_param_w;
else
	ie_saldo_negativo_w	:= ie_saldo_negativo_prest_w;
end if;

select	max(decode(count(1), 0, 'N', 'PP'))
into	ie_proximo_pgto_eve_w
from	pls_evento		b,
	pls_pagamento_item 	a
where	b.nr_sequencia 		= a.nr_seq_evento
and	b.ie_natureza		= 'D'
and	((b.ie_saldo_negativo	= 'PP') or
	(b.ie_saldo_negativo = 'CP' and ie_saldo_negativo_prest_w = 'PP') or
	(b.ie_saldo_negativo = 'CP' and ie_saldo_negativo_prest_w = 'CP' and ie_saldo_negativo_param_w = 'PP'))
and	a.nr_seq_pagamento 	= nr_seq_pag_prest_w
group by vl_item
having	vl_item < 0;

if	(ie_saldo_negativo_w = 'PP') and
	(ie_proximo_pgto_eve_w = 'PP') then
	ie_proximo_pgto_w	:= 'S';
end if;

select	max(ie_tipo_tributacao)
into	ie_tipo_tributacao_w
from	pessoa_juridica
where	cd_cgc	= cd_cgc_w;

if	(ie_seq_calculo_inss_w = 'O') then
	ie_sequencia_w	:= 999;
else
	ie_sequencia_w	:= 0;
end if;

open C02;
loop
fetch C02 into
	cd_tributo_pf_w,
	vl_base_tributo_pf_w,
	vl_tributo_pf_w,
	dt_inicio_vigencia_w,
	dt_fim_vigencia_w,
	cd_pessoa_fisica_pf_w,
	ie_vencimento_pf_w,
	ds_emp_retencao_w,
	ie_tipo_Data_w,
	ie_pago_prev_w,
	nr_seq_pessoa_trib_w,
	nr_seq_lote_pgto_w;
exit when C02%notfound;
	begin

	select	trunc(decode(ie_tipo_data_w, 'E', dt_emissao_w, 'V', dt_venc_titulo_w), 'month')
	into	dt_imposto_w
	from	dual;

	select	count(1)
	into	qt_registro_w
	from	pls_pag_prest_venc_trib		d,
		pls_pag_prest_vencimento	c,
		pls_pagamento_prestador		b,
		pls_prestador			a
	where	a.nr_sequencia			= b.nr_seq_prestador
	and	c.nr_seq_pag_prestador		= b.nr_sequencia
	and	d.nr_seq_vencimento		= c.nr_sequencia
	and	d.cd_tributo			= cd_tributo_pf_w
	and	a.cd_pessoa_fisica		= cd_pessoa_fisica_pf_w
	and	b.ie_cancelamento is null
	and	trunc(d.dt_imposto,'month')	= dt_imposto_w
	and	d.ie_pago_prev			= ie_pago_prev_w
	and	b.nr_sequencia <> nr_seq_pag_prest_w
	and	rownum 				<= 1;

	if	(qt_registro_w > 0) then
		select	count(1)
		into	qt_registro_w
		from	pessoa_fisica_trib
		where	nr_sequencia = nr_seq_pessoa_trib_w
		and	nr_seq_lote_pgto is not null;
	end if;

	if	(qt_registro_w = 0) then
		insert into pls_pag_prest_venc_trib (
			nr_sequencia,
			cd_tributo,
			dt_atualizacao,
			dt_atualizacao_nrec,
			ie_pago_prev,
			nm_usuario,
			nm_usuario_nrec,
			dt_imposto,
			nr_seq_vencimento,
			pr_tributo,
			vl_base_adic,
			vl_base_calculo,
			vl_base_nao_retido,
			vl_imposto,
			vl_nao_retido,
			vl_trib_adic,
			vl_base_producao)
		values	(pls_pag_prest_venc_trib_seq.nextval,
			cd_tributo_pf_w,
			sysdate,
			sysdate,
			ie_pago_prev_w,
			nm_usuario_p,
			nm_usuario_p,
			trunc(decode(ie_tipo_data_w, 'E' , dt_emissao_w, 'V', dt_venc_titulo_w), 'dd'),
			nr_seq_vencimento_p,
			0,
			0,
			vl_base_tributo_pf_w,
			0,
			vl_tributo_pf_w,
			0,
			0,
			0);

		update	pessoa_fisica_trib
		set	nr_seq_lote_pgto	= nr_seq_lote_w
		where	nr_sequencia		= nr_seq_pessoa_trib_w;
	end if;
	end;
end loop;
close C02;

/* OS 207298 -  Tratar valores retidos  do prestador */
select	count(1)
into	qt_imposto_mes_w
from	pls_prestador_tributo
where	nr_seq_prestador		= nr_seq_prestador_w
and	trunc(dt_referencia, 'month')	= trunc(dt_emissao_w, 'month')
and	rownum 				<= 1;

if 	(qt_imposto_mes_w > 0) then
	select	trunc(dt_referencia, 'dd'),
		cd_tributo,
		vl_tributo,
		vl_base_calculo,
		ds_emp_retencao
	into	dt_ref_tributo_w,
		cd_tributo_ret_w,
		vl_tributo_ret_w,
		vl_base_calculo_ret_w,
		ds_emp_retencao_ret_w
	from	pls_prestador_tributo
	where	nr_seq_prestador		= nr_seq_prestador_w
	and	trunc(dt_referencia,'month')	= trunc(dt_emissao_w, 'month');

	insert into pls_pag_prest_venc_trib
		(nr_sequencia,
		nr_seq_vencimento,
		cd_tributo,
		ie_pago_prev,
		dt_atualizacao,
		nm_usuario,
		dt_atualizacao_nrec,
		nm_usuario_nrec,
		dt_imposto,
		vl_base_calculo,
		vl_imposto,
		vl_nao_retido,
		vl_base_nao_retido,
		vl_trib_adic,
		vl_base_adic,
		pr_tributo,
		vl_base_producao)
	values	(pls_pag_prest_venc_trib_seq.NextVal,
		nr_seq_vencimento_p,
		cd_tributo_ret_w,
		'R',
		sysdate,
		nm_usuario_p,
		sysdate,
		nm_usuario_p,
		dt_ref_tributo_w,
		vl_base_calculo_ret_w,
		0,
		0,
		0,
		0,
		0,
		0,
		0);
end if;

vl_trib_acum_w	:= 0;

/* Mudar o pagamento vinculado as notas */
update	nota_fiscal	a
set	nr_seq_pgto_prest	= nr_seq_pag_prest_w
where	nr_seq_pgto_prest is null
and	exists	(select	1
		from	pls_pagamento_nota x
		where	x.nr_seq_nota_fiscal 	= a.nr_sequencia
		and	x.nr_seq_pagamento	= nr_seq_pag_prest_w);

/* Tratar impostos da nota vinculada - Quando vinculado antes da geração dos vencimentos */
open C05;
loop
fetch C05 into
	cd_tributo_nf_w,
	vl_base_calculo_nf_w,
	vl_tributo_nf_w,
	tx_tributo_nf_w,
	vl_reducao_base_nf_w,
	vl_trib_nao_retido_nf_w,
	vl_base_nao_retido_nf_w,
	vl_trib_adic_nf_w,
	vl_base_adic_nf_w,
	vl_reducao_nf_w,
	cd_darf_nf_w,
	ie_pago_prev_nf_w,
	ie_periodicidade_nf_w;
exit when C05%notfound;
	begin

	insert into pls_pag_prest_venc_trib
		(nr_sequencia,
		nr_seq_vencimento,
		cd_tributo,
		ie_pago_prev,
		dt_atualizacao,
		nm_usuario,
		dt_atualizacao_nrec,
		nm_usuario_nrec,
		dt_imposto,
		vl_base_calculo,
		vl_imposto,
		vl_nao_retido,
		vl_base_nao_retido,
		vl_trib_adic,
		vl_base_adic,
		pr_tributo,
		ie_periodicidade,
		vl_base_producao)
	values	(pls_pag_prest_venc_trib_seq.NextVal,
		nr_seq_vencimento_p,
		cd_tributo_nf_w,
		nvl(ie_pago_prev_nf_w,'V'),
		sysdate,
		nm_usuario_p,
		sysdate,
		nm_usuario_p,
		dt_emissao_w,
		vl_base_calculo_nf_w,
		vl_tributo_nf_w,
		vl_trib_nao_retido_nf_w,
		vl_base_nao_retido_nf_w,
		vl_trib_adic_nf_w,
		vl_base_adic_nf_w,
		tx_tributo_nf_w,
		ie_periodicidade_nf_w,
		decode(ie_forma_retencao_inss_ir_w, 'LM', vl_base_nao_retido_nf_w, vl_base_adic_nf_w));

	vl_trib_acum_w	:= vl_trib_acum_w + vl_tributo_nf_w;
	end;
end loop;
close C05;

open C01;
loop
fetch C01 into
	cd_tributo_w,
	ie_vencimento_w,
	ie_tipo_tributo_w,
	ie_apuracao_piso_w,
	ie_cnpj_w,
	ie_restringe_estab_w,
	ie_venc_pls_pag_prod_w;
exit when c01%notfound;
	begin

	-- OS 531858 - Obter se "Calcula trib valor bruto pgto"
	pls_obter_regra_prest_trib(nr_seq_prestador_w,cd_tributo_w,ie_valor_base_trib_nf_w);

	select	nvl(sum(d.vl_liberado), 0) + decode(ie_valor_base_trib_nf_w, 'S', nvl(sum(d.vl_glosa), 0),0)
	into	vl_total_prod_w
	from	pls_segurado	e,
		pls_evento_tributo	c,
		pls_conta_medica_resumo	d,
		pls_pagamento_item	a,
		pls_pagamento_prestador	b
	where	a.nr_sequencia		= d.nr_seq_pag_item
	and	a.nr_seq_evento		= c.nr_seq_evento
	and	e.nr_sequencia		= d.nr_seq_segurado(+)
	and	b.nr_sequencia		= a.nr_seq_pagamento
	and	c.cd_tributo		= cd_tributo_w
	and	nvl(c.ie_situacao,'N')	= 'A'
	and	b.nr_sequencia		= nr_seq_pag_prest_w
	and	nvl(a.ie_apropriar_total, 'N')	= 'N'
	and	((pls_obter_se_prestador_grupo(c.nr_seq_grupo_prestador,b.nr_seq_prestador) = 'S') or (c.nr_seq_grupo_prestador is null))
	and	((b.nr_seq_prestador = c.nr_seq_prestador) or (c.nr_seq_prestador is null))
	and	((c.nr_seq_tipo_prestador	=	(select	max(x.nr_seq_tipo_prestador)
							from	pls_prestador  x
							where	x.nr_sequencia  = b.nr_seq_prestador)) or
								(c.nr_seq_tipo_prestador is null))
	and	ie_tipo_tributo_w	= 'INSS'
	and	ie_inss_tipo_contrat_w	= 'S'
	and	dt_competencia_w	between nvl(c.dt_inicio_vigencia, dt_competencia_w - 1) and nvl(c.dt_fim_vigencia, dt_competencia_w + 1);

	select	nvl(sum(a.vl_item), 0) + decode(ie_valor_base_trib_nf_w, 'S', nvl(sum(a.vl_glosa), 0), 0)
	into	vl_total_desconto_w
	from	pls_evento		f,
		pls_evento_tributo	c,
		pls_pagamento_item	a,
		pls_pagamento_prestador	b
	where	a.nr_seq_evento		= c.nr_seq_evento
	and	a.nr_seq_pagamento	= b.nr_sequencia
	and	f.nr_sequencia		= c.nr_seq_evento
	and	c.cd_tributo		= cd_tributo_w
	and	nvl(c.ie_situacao,'N')	= 'A'
	and	b.nr_sequencia		= nr_seq_pag_prest_w
	and	nvl(a.ie_apropriar_total, 'N')	= 'N'
	and	((pls_obter_se_prestador_grupo(c.nr_seq_grupo_prestador,b.nr_seq_prestador) = 'S') or (c.nr_seq_grupo_prestador is null))
	and	((b.nr_seq_prestador = c.nr_seq_prestador) or (c.nr_seq_prestador is null))
	and	((c.nr_seq_tipo_prestador	=	(select	max(x.nr_seq_tipo_prestador)
							from	pls_prestador  x
							where	x.nr_sequencia	= b.nr_seq_prestador)) or
								(c.nr_seq_tipo_prestador is null))
	and	ie_tipo_tributo_w	= 'INSS'
	and	ie_inss_tipo_contrat_w	= 'S'
	and	nvl(f.ie_desc_trib_tipo_contrat, 'N') = 'S'
	and	dt_competencia_w	between nvl(c.dt_inicio_vigencia, dt_competencia_w - 1) and nvl(c.dt_fim_vigencia, dt_competencia_w + 1);

	vl_total_desconto_w	:= abs(vl_total_desconto_w);

	ie_agrupado_w	:= 'S';

	open C03;
	loop
	fetch C03 into
		vl_evento_w,
		ie_tipo_contratacao_w,
		ie_ordem_w,
		nr_seq_pag_item_w;
	exit when C03%notfound;
		begin
		vl_base_calculo_w	:= vl_evento_w + abs(vl_base_estorno_inss_w);

		if	(ie_tipo_tributo_w IN ('IR','IRPF')) then

			if	(ie_proximo_pgto_w = 'S') and
				(vl_itens_w < 0) then
				vl_base_calculo_w	:= 0;
			end if;

			vl_total_eventos_w	:= vl_base_calculo_w;
		end if;

		pr_aliquota_w	:= 0;

		if	(vl_evento_w > 0) then

			obter_dados_trib_tit_pagar(	cd_tributo_w,
							cd_estabelecimento_w,
							cd_cgc_w,
							cd_pessoa_fisica_w,
							cd_beneficiario_w,
							pr_aliquota_w,
							cd_cond_pagto_w,
							cd_conta_financ_w,
							nr_seq_trans_reg_w,
							nr_seq_trans_baixa_w,
							vl_minimo_base_w,
							vl_minimo_tributo_w,
							ie_acumulativo_w,
							vl_teto_base_w,
							vl_desc_dependente_w,
							cd_darf_w,
							dt_calculo_w,
							cd_variacao_w,
							ie_periodicidade_w,
							null,
							null,
							null,
							null,
							ie_tipo_contratacao_w,
							null,
							nr_seq_regra_trib_w,
							null,
							0,
							nr_seq_classe_w,
							cd_tipo_baixa_neg_w,
							vl_base_calculo_w,
							'S',
							null,
							null,
							nr_seq_tipo_prestador_w);

			select	nvl(max(pr_base_calculo),0)
			into	pr_base_calculo_w
			from 	tributo_conta_pagar
			where	nr_sequencia	= nr_seq_regra_trib_w;

			if	(nvl(pr_base_calculo_w,0) <> 0) and
				(ie_tipo_tributo_w = 'ISS') then	-- Diether 19/06/2012, OS 459634, incluido este tratamento wheb não recomenda
				vl_base_calculo_w	:= vl_base_calculo_w * dividir_sem_round(pr_base_calculo_w, 100);
			end if;

			if	(pr_aliquota_w > 0) then

				vl_tributo_w	:= vl_base_calculo_w * pr_aliquota_w / 100;

				if	(ie_vencimento_w = 'V') then
					dt_vencimento_w	:= nvl(dt_venc_titulo_w,sysdate);
				elsif	(ie_vencimento_w = 'C') then
					dt_vencimento_w	:= nvl(dt_venc_titulo_w,nvl(dt_emissao_w,sysdate));
				else
					dt_vencimento_w	:= nvl(dt_emissao_w,sysdate);
				end if;

				if	(ie_venc_pls_pag_prod_w is not null) then
					if	(ie_venc_pls_pag_prod_w = 'C') then
						dt_vencimento_w	:= dt_emissao_w;
					else
						dt_vencimento_w	:= dt_venc_titulo_w;
					end if;
				end if;

				if	(ie_tipo_tributo_w in ('PISCOFINSCSLL','COFINS','COFINSST','CSLL','PIS','PISST')) then	/* Edgar ,27/05/2013, OS 592607, PIS/COFINS/CSLL não retem pela competência, mas sim pelo pagamento, portanto, deve seguir as regras aciam */
					dt_tributo_w	:= dt_venc_titulo_w;
				else
					dt_tributo_w	:= nvl(dt_vencimento_w,dt_competencia_w);
				end if;

				if	(cd_cond_pagto_w is not null) then
					calcular_vencimento(cd_estabelecimento_w, cd_cond_pagto_w, dt_vencimento_w, qt_venc_w, ds_venc_w);
					if	(qt_venc_w = 1) then
						dt_vencimento_w	:= to_date(substr(ds_venc_w,1,10),'dd/mm/yyyy');
					end if;
				end if;

				pls_pag_prod_obter_val_trib(	ie_apuracao_piso_w,
								ie_cnpj_w,
								cd_pessoa_fisica_w,
								cd_cgc_w,
								cd_cnpj_raiz_w,
								ie_restringe_estab_w,
								cd_empresa_w,
								cd_tributo_w,
								dt_tributo_w,
								vl_soma_trib_nao_retido_w,
								vl_soma_base_nao_retido_w,
								vl_soma_trib_adic_w,
								vl_soma_base_adic_w,
								vl_trib_anterior_w,
								vl_total_base_w,
								vl_reducao_w,
								cd_estabelecimento_w,
								nm_usuario_p);

				select	nvl(sum(vl_imposto),0),
					nvl(sum(vl_base_calculo),0)
				into	vl_pago_w,
					vl_base_calculo_paga_w
				from	pls_pag_prest_venc_trib
				where	nr_seq_vencimento	= nr_seq_vencimento_p
				and	cd_tributo		= cd_tributo_w
				and	ie_pago_prev		= 'P';

				select	nvl(sum(decode(b.nr_sequencia,nr_seq_vencimento_p,a.vl_base_calculo,0)),0),
					nvl(sum(decode(b.nr_sequencia,nr_seq_vencimento_p,0,a.vl_base_calculo)),0)					
				into	vl_base_retido_outro_w,
					vl_base_ret_outro_anterior_w /* Eduardo e Francisco 27/12/2013, separamos pois a base anterior retida em outra empresa tem que ser tratada separada*/
				from	pls_pag_prest_venc_trib 	a,
					pls_pag_prest_vencimento 	b,
					pls_pagamento_prestador 	c,
					pls_lote_pagamento		d
				where	exists	(select	1
						from	pls_prestador x,
							pls_pagamento_prestador y,
							pls_pag_prest_vencimento z
						where	z.nr_sequencia = a.nr_seq_vencimento
						and	z.nr_seq_pag_prestador = y.nr_sequencia
						and	y.nr_seq_prestador = x.nr_sequencia
						and	x.cd_pessoa_fisica = cd_pessoa_fisica_w
						union
						select	1
						from	pls_prestador x,
							pls_pagamento_prestador y,
							pls_pag_prest_vencimento z
						where	z.nr_sequencia = a.nr_seq_vencimento
						and	z.nr_seq_pag_prestador = y.nr_sequencia
						and	y.nr_seq_prestador = x.nr_sequencia
						and	x.cd_cgc = cd_cgc_w)
				and	d.nr_sequencia 		= c.nr_seq_lote
				and	c.nr_sequencia		= b.nr_seq_pag_prestador
				and	b.nr_sequencia		= a.nr_seq_vencimento
				and	a.cd_tributo		= cd_tributo_w
				and	trunc(decode(ie_vencimento_w, 'R', d.dt_mes_competencia, a.dt_imposto), 'month') = trunc(dt_tributo_w, 'month') -- Alterado através da OS 490539, pois estava ocasionando geração de imposto de retenção INSS erroneamente.
				and	a.ie_pago_prev		= 'R';

				if	(ie_tipo_tributo_w = 'INSS') and
					(ie_forma_retencao_inss_ir_w = 'SE') and
					((vl_total_base_w + vl_base_calculo_w) >= vl_teto_base_w) then

					vl_base_restante_w	:= vl_base_calculo_w;

					/* Identificar conforme cadastro do tributo se é para considerar competência ou vencimento */
					select	nvl(max(decode(a.ie_venc_pls_pag_prod, 'C','C','V','V',null,
							decode(a.ie_vencimento,'V','V','C','V','C'))),'C')
					into	ie_data_ref_tributo_w
					from	tributo a
					where	a.cd_tributo = cd_tributo_w;

					open C04;
					loop
					fetch C04 into
						nr_seq_venc_trib_a_maior_w,
						vl_base_calculo_a_maior_w;
					exit when C04%notfound;
						begin

						select	nvl(sum(a.vl_base_calculo), 0)
						into	vl_estornado_base_maior_w
						from	pls_pag_prest_venc_trib a
						where	a.nr_seq_trib_estornado	= nr_seq_venc_trib_a_maior_w;

						vl_saldo_a_maior_w	:= vl_base_calculo_a_maior_w + vl_estornado_base_maior_w;

						if	(vl_base_restante_w > 0) then
							/* Estornar o que foi retido a maior*/
							if	(vl_base_restante_w > vl_saldo_a_maior_w) then
								pr_fator_w	:= dividir_sem_round(vl_saldo_a_maior_w, vl_base_calculo_a_maior_w);
							else
								pr_fator_w	:= dividir_sem_round(vl_base_restante_w, vl_saldo_a_maior_w);
							end if;

							vl_base_restante_w	:= vl_base_restante_w - (vl_base_calculo_a_maior_w * pr_fator_w);

							select	pls_pag_prest_venc_trib_seq.nextval
							into	nr_seq_pag_prest_venc_trib_w
							from	dual;

							insert into pls_pag_prest_venc_trib
								(nr_sequencia,
								nr_seq_vencimento,
								cd_tributo,
								dt_atualizacao,
								nm_usuario,
								dt_imposto,
								vl_base_calculo,
								vl_imposto,
								pr_tributo,
								vl_nao_retido,
								vl_base_nao_retido,
								vl_trib_adic,
								vl_base_adic,
								ie_pago_prev,
								vl_reducao,
								vl_desc_base,
								cd_darf,
								dt_atualizacao_nrec,
								nm_usuario_nrec,
								ie_periodicidade,
								cd_variacao,
								nr_seq_trans_reg,
								nr_seq_trans_baixa,
								ie_tipo_contratacao,
								ie_filantropia,
								nr_seq_trib_estornado,
								cd_beneficiario,
								nr_seq_regra,
								vl_base_producao)
							select	nr_seq_pag_prest_venc_trib_w,
								nr_seq_vencimento_p,
								cd_tributo,
								sysdate,
								nm_usuario_p,
								dt_imposto,
								vl_base_calculo * pr_fator_w * -1,
								vl_imposto * pr_fator_w * -1,
								pr_tributo,
								vl_nao_retido * pr_fator_w * -1,
								vl_base_nao_retido * pr_fator_w * -1,
								vl_trib_adic * pr_fator_w * -1,
								vl_base_adic * pr_fator_w * -1,
								'V',
								vl_reducao * pr_fator_w * -1,
								vl_desc_base * pr_fator_w * -1,
								cd_darf,
								sysdate,
								nm_usuario_p,
								ie_periodicidade,
								cd_variacao,
								nr_seq_trans_reg,
								nr_seq_trans_baixa,
								ie_tipo_contratacao,
								ie_filantropia,
								nr_seq_venc_trib_a_maior_w,
								cd_beneficiario,
								nr_seq_regra_trib_w,
								decode(ie_forma_retencao_inss_ir_w, 'LM', vl_base_nao_retido * pr_fator_w * -1, vl_evento_w)
							from	pls_pag_prest_venc_trib	a
							where	a.nr_sequencia	= nr_seq_venc_trib_a_maior_w;

							insert into pls_pag_item_trib
								(nr_sequencia,
								dt_atualizacao,
								nm_usuario,
								dt_atualizacao_nrec,
								nm_usuario_nrec,
								nr_seq_pagamento,
								nr_seq_venc_trib,
								vl_evento,
								ie_tipo_contratacao,
								vl_evento_origem)
							select	pls_pag_item_trib_seq.nextval,
								sysdate,
								nm_usuario_p,
								sysdate,
								nm_usuario_p,
								x.nr_seq_pagamento,
								nr_seq_pag_prest_venc_trib_w,
								x.vl_evento * -1,
								x.ie_tipo_contratacao,
								x.vl_evento_origem * -1
							from	pls_pag_item_trib	x,
								pls_pag_prest_venc_trib	a
							where	a.nr_sequencia	= x.nr_seq_venc_trib
							and	a.nr_sequencia	= nr_seq_venc_trib_a_maior_w;

							select	a.vl_base_calculo * pr_fator_w * -1
							into	vl_base_estorno_inss_w
							from	pls_pag_prest_venc_trib	a
							where	a.nr_sequencia		= nr_seq_venc_trib_a_maior_w;

							select	nvl(max(vl_imposto),0)
							into	vl_pag_prest_venc_trib_w
							from	pls_pag_prest_venc_trib
							where	nr_sequencia	= nr_seq_pag_prest_venc_trib_w;

							vl_trib_acum_w	:= vl_trib_acum_w + vl_pag_prest_venc_trib_w;

							vl_total_base_w := vl_total_base_w + vl_base_estorno_inss_w;
						end if;
						end;
					end loop;
					close C04;
				end if;

				ie_irpf_w	:= 'N';

				if	(ie_tipo_tributo_w in ('IR', 'IRPF')) and
					(cd_pessoa_fisica_w is not null) then
					ie_irpf_w	:= 'S';

					if	(ie_forma_retencao_inss_ir_w <> 'LM') then	-- Calcular Redução base IRPF e saldo menos INSS
						select	nvl(qt_dependente,0)
						into	qt_dependente_w
						from	pessoa_fisica
						where	cd_pessoa_fisica	= cd_pessoa_fisica_w;

						select	nvl(sum(a.vl_imposto),0)
						into	vl_inss_w
						from	tributo b,
							pls_pag_prest_venc_trib a
						where	a.cd_tributo		= b.cd_tributo
						and	b.ie_tipo_tributo	= 'INSS'
						and	a.nr_seq_vencimento	= nr_seq_vencimento_p
						and	a.pr_tributo		<> 0
						and	a.ie_pago_prev	in ('V');
					end if;

					vl_base_calculo_w	:= vl_base_calculo_w - vl_inss_w;
				end if;

				select	nvl(sum(vl_base_calculo),0)
				into	vl_base_pago_adic_base_w
				from	pls_pag_prest_venc_trib
				where	nr_seq_vencimento	= nr_seq_vencimento_p
				and	cd_tributo		= cd_tributo_w
				and	ie_pago_prev		= 'S';

				select	count(1)
				into	qt_lote_ret_trib_w
				from	pls_lote_ret_trib_valor c,
					pls_lote_ret_trib_prest	b,
					pls_lote_retencao_trib	a
				where	b.nr_sequencia 	= c.nr_seq_trib_prest
				and	a.nr_sequencia 	= b.nr_seq_lote
				and	c.nr_titulo is not null
				and	trunc(a.dt_mes_referencia, 'month') = trunc(dt_competencia_w, 'month')
				and	rownum <= 1;

				vl_trib_aux_w := 0;
				/* Se a forma de retenção for mensal, deve acumular todos os valores na base de cálculo */
				if	(ie_forma_retencao_inss_ir_w = 'LM') and
					(ie_tipo_tributo_w <> 'PISCOFINSCSLL') and
					(qt_lote_ret_trib_w = 0) then
					vl_minimo_base_w	:= 9999999999999;
					vl_teto_base_w		:= 9999999999999;

					if	(ie_tipo_tributo_w in ('IR','IRPF')) then
						select	sum(nvl(a.vl_imposto,0))
						into	vl_trib_aux_w
						from	pls_pag_prest_venc_trib a
						where	exists	(select	1
								from	pls_prestador x,
									pls_pagamento_prestador y,
									pls_pag_prest_vencimento z
								where	z.nr_sequencia = a.nr_seq_vencimento
								and	z.nr_seq_pag_prestador = y.nr_sequencia
								and	y.nr_seq_prestador = x.nr_sequencia
								and	x.cd_pessoa_fisica = cd_pessoa_fisica_w
								union
								select	1
								from	pls_prestador x,
									pls_pagamento_prestador y,
									pls_pag_prest_vencimento z
								where	z.nr_sequencia = a.nr_seq_vencimento
								and	z.nr_seq_pag_prestador = y.nr_sequencia
								and	y.nr_seq_prestador = x.nr_sequencia
								and	x.cd_cgc = cd_cgc_w)
						and	a.cd_tributo		= cd_tributo_w
						and	trunc(a.dt_imposto ,'month') = trunc(dt_vencimento_w, 'month');
					end if;

					vl_trib_anterior_w	:= 0;
					ie_acumulativo_w	:= 'S';
				end if;

				/* Se o valor retido em outra empresa entrou em vencimento anterior,
				o mesmo deve ser somado a base de calculo já retida (total) */
				if	(vl_base_ret_outro_anterior_w > 0) then
					vl_total_base_w	:= vl_total_base_w + vl_base_ret_outro_anterior_w;
				end if;
				
				obter_valores_tributo(	ie_acumulativo_w,
							pr_aliquota_w,
							vl_minimo_base_w,
							vl_minimo_tributo_w,
							vl_soma_trib_nao_retido_w,
							vl_soma_trib_adic_w,
							vl_soma_base_nao_retido_w,
							vl_soma_base_adic_w,
							vl_base_calculo_w,
							vl_tributo_w,
							vl_trib_nao_retido_w,
							vl_trib_adic_w,
							vl_base_nao_retido_w,
							vl_base_adic_w,
							vl_teto_base_w,
							vl_trib_anterior_w,
							ie_irpf_w,
							vl_total_base_w,
							vl_reducao_w,
							vl_desc_dependente_w,
							qt_dependente_w,
							vl_base_calculo_paga_w,
							vl_base_pago_adic_base_w,
							vl_base_retido_outro_w,
							obter_outras_reducoes_irpf(cd_pessoa_fisica_w, cd_estabelecimento_w, dt_tributo_w),
							dt_calculo_w,
							nr_seq_regra_irpf_w);
							
				vl_tributo_w	:= nvl(vl_tributo_w, 0) - nvl(vl_trib_aux_w, 0);

				if	((((vl_tributo_w <> 0) or (nvl(ie_tipo_contratacao_w, 'S') = 'S'))) or
					((ie_forma_retencao_inss_ir_w = 'LM') and
					(ie_irpf_w = 'N'))) then

					-- Edgar 27/04/2014, OS 714074, solução paliativa até criarmos a consistência para não permitir desfazer a geração dos vencimentos no pagamento de produção médica
					if	(vl_tributo_w < 0) and
						(vl_base_calculo_w > 0) and
						(ie_tipo_tributo_w in ('IR', 'IRPF')) and
						(vl_inss_w = 0) then
						vl_base_calculo_w	:= vl_total_eventos_w;
						vl_tributo_w		:= vl_total_eventos_w * (pr_aliquota_w / 100);
						vl_reducao_w		:= 0;
						vl_base_adic_w		:= 0;
					end if;

					select	pls_pag_prest_venc_trib_seq.nextval
					into	nr_seq_venc_trib_w
					from	dual;

					insert into pls_pag_prest_venc_trib
						(nr_sequencia,
						nr_seq_vencimento,
						cd_tributo,
						dt_atualizacao,
						nm_usuario,
						dt_imposto,
						vl_base_calculo,
						vl_imposto,
						pr_tributo,
						vl_nao_retido,
						vl_base_nao_retido,
						vl_trib_adic,
						vl_base_adic,
						ie_pago_prev,
						vl_reducao,
						vl_desc_base,
						cd_darf,
						dt_atualizacao_nrec,
						nm_usuario_nrec,
						ie_periodicidade,
						cd_variacao,
						nr_seq_trans_reg,
						nr_seq_trans_baixa,
						ie_tipo_contratacao,
						ie_filantropia,
						cd_beneficiario,
						nr_seq_regra,
						nr_seq_regra_calculo,
						vl_base_producao)
					values	(nr_seq_venc_trib_w,
						nr_seq_vencimento_p,
						cd_tributo_w,
						sysdate,
						nm_usuario_p,
						dt_vencimento_w,
						vl_base_calculo_w,
						vl_tributo_w,
						pr_aliquota_w,
						vl_trib_nao_retido_w,
						vl_base_nao_retido_w,
						vl_trib_adic_w,
						vl_base_adic_w,
						'V',
						vl_reducao_w,
						vl_desc_dependente_w,
						cd_darf_w,
						sysdate,
						nm_usuario_p,
						ie_periodicidade_w,
						cd_variacao_w,
						nr_seq_trans_reg_w,
						nr_seq_trans_baixa_w,
						ie_tipo_contratacao_w,
						ie_filantropia_w,
						cd_beneficiario_w,
						nr_seq_regra_trib_w,
						nr_seq_regra_irpf_w,
						decode(ie_forma_retencao_inss_ir_w, 'LM', vl_base_nao_retido_w, vl_evento_w));

					vl_trib_acum_w	:= vl_trib_acum_w + vl_tributo_w;
				end if;
			end if;
		end if; /* Fim evento */
		end;
	end loop;
	close C03;
	vl_base_estorno_inss_w	:= 0;

	ie_agrupado_w	:= 'N';

	open C03;
	loop
	fetch C03 into
		vl_evento_w,
		ie_tipo_contratacao_w,
		ie_ordem_w,
		nr_seq_pag_item_w;
	exit when C03%notfound;

		for r_c08_w in c08(nr_seq_vencimento_p, cd_tributo_w, ie_tipo_contratacao_w) loop
			insert into pls_pag_item_trib
				(nr_sequencia,
				dt_atualizacao,
				nm_usuario,
				dt_atualizacao_nrec,
				nm_usuario_nrec,
				nr_seq_pagamento,
				nr_seq_venc_trib,
				vl_evento,
				ie_tipo_contratacao,
				vl_evento_origem)
			select	pls_pag_item_trib_seq.nextval,
				sysdate,
				nm_usuario_p,
				sysdate,
				nm_usuario_p,
				nr_seq_pag_item_w,
				r_c08_w.nr_sequencia,
				0,
				ie_tipo_contratacao_w,
				vl_evento_w
			from	dual;
		end loop;
	end loop;
	close C03;

	if	(vl_total_desconto_w = 0) then
		vl_total_desconto_w	:= vl_total_prod_w;
	else
		vl_total_desconto_w	:= abs(vl_total_desconto_w);
	end if;

	if	(ie_tipo_tributo_w = 'INSS') then
		vl_total_desconto_w	:= (vl_total_prod_w - vl_total_desconto_w);

		if	(vl_total_desconto_w > 0) then
			select	sum(a.vl_base_calculo),
				max(a.nr_sequencia)
			into	vl_gerado_w,
				nr_seq_alt_w
			from	pls_pag_prest_venc_trib	a
			where	nr_seq_vencimento	= nr_seq_vencimento_p
			and	ie_tipo_tributo_w	= 'INSS'
			and	a.ie_pago_prev		<> 'R';

			select	sum(a.vl_base_calculo)
			into	vl_gerado_ret_w
			from	pls_pag_prest_venc_trib	a
			where	nr_seq_vencimento	= nr_seq_vencimento_p
			and	ie_tipo_tributo_w	= 'INSS'
			and	a.ie_pago_prev		= 'R';

			if	(vl_gerado_w <> vl_total_desconto_w) and
				(vl_gerado_ret_w > 0) then
				update	pls_pag_prest_venc_trib
				set	vl_base_calculo	= vl_base_calculo - (vl_gerado_w - vl_total_desconto_w)
				where	nr_sequencia	= nr_seq_alt_w;

				select	a.vl_base_calculo
				into	vl_gerado_w
				from	pls_pag_prest_venc_trib	a
				where	nr_sequencia	= nr_seq_alt_w;

				if	(vl_gerado_w < 0) then
					update	pls_pag_prest_venc_trib
					set	vl_base_calculo	= 0,
						vl_imposto	= 0
					where	nr_sequencia	= nr_seq_alt_w;
				end if;
			end if;
		end if;
	end if;

	end;
end loop;
close C01;

for r_c09_w in c09(nr_seq_vencimento_p) loop

	vl_equivalencia_base_w := 0;
	vl_tx_evento_trib_w := 0;
	vl_evento_trib_w := 0;

	select	nvl(sum(nvl(vl_evento_origem,0)),0)
	into	vl_evento_tot_w
	from	pls_pag_item_trib
	where	nr_seq_venc_trib	= r_c09_w.nr_sequencia;

	if	(vl_evento_tot_w > 0) then
		vl_equivalencia_base_w := (r_c09_w.vl_base_calculo * r_c09_w.vl_evento) / vl_evento_tot_w;

		if	(r_c09_w.vl_base_calculo > 0) then
			vl_tx_evento_trib_w := (vl_equivalencia_base_w * 100) / r_c09_w.vl_base_calculo;
		end if;

		if	(vl_tx_evento_trib_w > 0) then
			vl_evento_trib_w := r_c09_w.vl_imposto * (vl_tx_evento_trib_w/100);
		end if;
	end if;

	update	pls_pag_item_trib
	set	vl_evento	= nvl(vl_evento_trib_w,0)
	where	nr_sequencia	= r_c09_w.nr_seq_item_trib;
end loop;

select	nvl(sum(c.vl_base_calculo),0),
	nvl(sum(c.vl_base_calculo),0)
into	vl_base_inss_retido_w,
	vl_base_inss_retido_orig_w
from	tributo 			d,
	pls_pag_prest_venc_trib 	c,
	pls_pag_prest_vencimento 	b,
	pls_lote_pagamento		e,
	pls_pagamento_prestador		a
where	a.nr_sequencia			= b.nr_seq_pag_prestador
and	b.nr_sequencia			= c.nr_seq_vencimento
and	a.nr_seq_prestador		= nr_seq_prestador_w
and	a.nr_seq_lote			= e.nr_sequencia
and	b.nr_sequencia			= nr_seq_vencimento_p
and	c.cd_tributo			= d.cd_tributo
and	d.ie_tipo_tributo		= 'INSS'
and	c.ie_pago_prev			= 'R'
and	ie_inss_tipo_contrat_w		= 'S';

-- Edgar 09/08/2012, OS 480670, rotina descontar o INSS retido em outra empresa
vl_base_a_reter_w			:= null;

if	(vl_base_inss_retido_w <> 0) then
	open C07;
	loop
	fetch C07 into
		vl_base_calculo_w,
		pr_aliquota_w,
		nr_seq_venc_trib_w,
		vl_tributo_w,
		cd_tributo_w,
		ie_tipo_contratacao_w;
	exit when C07%notfound;
		begin
		obter_dados_trib_tit_pagar(	cd_tributo_w,
						cd_estabelecimento_w,
						cd_cgc_w,
						cd_pessoa_fisica_w,
						ds_irrelevante_w,
						ds_irrelevante_w,
						ds_irrelevante_w,
						ds_irrelevante_w,
						ds_irrelevante_w,
						ds_irrelevante_w,
						ds_irrelevante_w,
						ds_irrelevante_w,
						ds_irrelevante_w,
						vl_teto_base_w,
						ds_irrelevante_w,
						ds_irrelevante_w,
						dt_tributo_w,
						ds_irrelevante_w,
						ds_irrelevante_w,
						null,
						null,
						null,
						null,
						ie_tipo_contratacao_w,
						null,
						ds_irrelevante_w,
						null,
						0,
						ds_irrelevante_w,
						ds_irrelevante_w,
						vl_base_calculo_w,
						'S',
						null,
						null,
						nr_seq_tipo_prestador_w);

		if	(ie_forma_retencao_inss_ir_w = 'LM') and
			(qt_lote_ret_trib_w = 0) then
			vl_teto_base_w		:= 9999999999999;
		end if;

		if	(vl_base_a_reter_w is null) then
			vl_base_a_reter_w	:= vl_teto_base_w - vl_base_inss_retido_w;
		end if;

		if	(vl_base_a_reter_w < 0) then
			vl_base_calculo_w		:= 0;
		else
			if	(vl_teto_base_w >= vl_base_inss_retido_orig_w) then
				if	(vl_base_calculo_w > vl_base_a_reter_w) then
					vl_base_calculo_w	:= vl_base_a_reter_w;
					vl_base_a_reter_w	:= 0;
					vl_base_inss_retido_w	:= 0;	-- carregada esta variável apenas para fins de saída do cursor
				elsif	(vl_base_calculo_w < vl_base_a_reter_w) then
					vl_base_a_reter_w	:= vl_base_a_reter_w - vl_base_calculo_w;
				end if;
			else
				if	(vl_base_inss_retido_w <= vl_base_calculo_w) then
					vl_base_calculo_w	:= vl_base_calculo_w - vl_base_inss_retido_w;
					vl_base_inss_retido_w	:= 0;

					if	(vl_base_calculo_w >= vl_teto_base_w) then
						vl_base_calculo_w	:= 0;
					end if;
				elsif	(vl_base_inss_retido_w > vl_base_calculo_w) then
					if	(vl_base_inss_retido_w < vl_teto_base_w) then
						vl_base_inss_retido_w	:= vl_base_inss_retido_w - vl_base_calculo_w;
					end if;

					vl_base_calculo_w	:= 0;
				end if;
			end if;
		end if;

		if	(ie_forma_retencao_inss_ir_w = 'LM') and
			(qt_lote_ret_trib_w = 0) then
			update	pls_pag_prest_venc_trib
			set	vl_base_calculo		= vl_base_calculo_w,
				vl_base_nao_retido	= vl_base_calculo_w,
				vl_base_producao	= vl_base_calculo_w
			where	nr_sequencia		= nr_seq_venc_trib_w;
		else
			update	pls_pag_prest_venc_trib
			set	vl_base_calculo		= vl_base_calculo_w,
				vl_imposto		= vl_base_calculo_w * dividir_sem_round(pr_aliquota_w, 100),
				vl_base_producao	= vl_base_calculo_w
			where	nr_sequencia	= nr_seq_venc_trib_w;
		end if;

		ie_recalculou_inss_w	:= 'S';
		vl_trib_acum_w		:= vl_trib_acum_w - (vl_tributo_w -  (vl_base_calculo_w * dividir_sem_round(pr_aliquota_w, 100)));
		end;
	end loop;
	close C07;
end if;

if	(ie_recalculou_inss_w = 'S')  and (ie_forma_retencao_inss_ir_w <> 'LM') then	/* Edgar 08/11/2014, OS 813814, só recalcular o IRPF se não for utilizado o lote de retenção mensal, pois qdo é lote de retenção mensal não calcula o valor do tributo do TNSS, ou seja, deixa o mesmo zerado */
	select	max(a.nr_sequencia),
		max(a.cd_tributo),
		nvl(max(a.vl_desc_base),0),
		nvl(max(a.vl_base_adic),0)
	into	nr_seq_venc_trib_w,
		cd_tributo_w,
		vl_desc_base_w,
		vl_base_adic_w
	from	tributo			b,
		pls_pag_prest_venc_trib a
	where	a.nr_seq_vencimento 	= nr_seq_vencimento_p
	and	b.cd_tributo		= a.cd_tributo
	and	b.ie_tipo_tributo	= 'IR';

	if	(nr_seq_venc_trib_w is not null) then
		select	sum(a.vl_imposto)
		into	vl_trib_inss_w
		from	tributo			b,
			pls_pag_prest_venc_trib a
		where	a.cd_tributo		= b.cd_tributo
		and	a.nr_seq_vencimento 	= nr_seq_vencimento_p
		and	b.ie_tipo_tributo	= 'INSS'
		and	a.pr_tributo		<> 0;

		select	pls_obter_dados_pag_venc_trib(nr_seq_venc_trib_w,'VROM')
		into	vl_ir_anterior_w
		from	dual;

		vl_base_calculo_w	:= vl_total_eventos_w - vl_trib_inss_w - vl_desc_base_w;

		obter_dados_irpf((vl_base_calculo_w + vl_base_adic_w), pr_aliquota_irpf_w, vl_reducao_w, 0, sysdate, nr_seq_regra_irpf_w);

		vl_tributo_irpf_w	:= (((vl_base_calculo_w + vl_base_adic_w) * dividir_sem_round(pr_aliquota_irpf_w, 100)) - vl_reducao_w - nvl(vl_trib_aux_w,0) - vl_ir_anterior_w);

		if	(vl_tributo_irpf_w > 0) then
			obter_dados_trib_tit_pagar(	cd_tributo_w,
							cd_estabelecimento_w,
							cd_cgc_w,
							cd_pessoa_fisica_w,
							cd_beneficiario_w,
							pr_aliquota_w,
							cd_cond_pagto_w,
							cd_conta_financ_w,
							nr_seq_trans_reg_w,
							nr_seq_trans_baixa_w,
							vl_minimo_base_w,
							vl_minimo_tributo_w,
							ie_acumulativo_w,
							vl_teto_base_w,
							vl_desc_dependente_w,
							cd_darf_w,
							dt_tributo_w,
							cd_variacao_w,
							ie_periodicidade_w,
							null,
							null,
							null,
							null,
							ie_tipo_contratacao_w,
							null,
							nr_seq_regra_trib_w,
							null,
							0,
							nr_seq_classe_w,
							cd_tipo_baixa_neg_w,
							vl_base_calculo_w,
							'S',
							null,
							null,
							nr_seq_tipo_prestador_w);
		end if;

		if	(vl_tributo_irpf_w < nvl(vl_minimo_tributo_w, 0)) then
			vl_tributo_irpf_w	:= 0;
		end if;

		update	pls_pag_prest_venc_trib
		set	vl_base_calculo = vl_base_calculo_w + vl_base_adic_w,
			vl_imposto	= vl_tributo_irpf_w,
			pr_tributo	= pr_aliquota_irpf_w,
			vl_reducao	= vl_reducao_w
		where	nr_sequencia 	= nr_seq_venc_trib_w;
	end if;
end if;

begin
select	nvl(ie_trib_saldo_tit_nf,'N')
into	ie_trib_saldo_tit_nf_w
from	parametros_contas_pagar
where	cd_estabelecimento	= cd_estabelecimento_w;
exception
when others then
	wheb_mensagem_pck.exibir_mensagem_abort(189078);
end;

if	(ie_trib_saldo_tit_nf_w = 'S') then
	select	nvl(sum(a.vl_imposto),0)
	into	vl_trib_acum_w
	from	tributo b,
		pls_pag_prest_venc_trib a
	where	a.cd_tributo		= b.cd_tributo
	and	a.ie_pago_prev	 	= 'V'
	and	a.nr_seq_vencimento 	= nr_seq_vencimento_p
	and	nvl(b.ie_saldo_tit_pagar,'S')	= 'S';
else
	-- Edgar 23/01/2014, OS 656420, tratamento para o campo "IE_SOMA_DIMINUI"  do cadastro de tributo
	select	nvl(sum(decode(b.ie_soma_diminui, 'D', a.vl_imposto, 'S', a.vl_imposto * -1, 0)),0)
	into	vl_trib_acum_w
	from	tributo b,
		pls_pag_prest_venc_trib a
	where	a.cd_tributo		= b.cd_tributo
	and	a.ie_pago_prev	 	= 'V'
	and	a.nr_seq_vencimento 	= nr_seq_vencimento_p;
end if;

update	pls_pag_prest_vencimento
set	vl_liquido	= vl_vencimento - vl_ir - vl_imposto_munic - vl_trib_acum_w
where	nr_sequencia	= nr_seq_vencimento_p;

pls_atualizar_desc_trib_pagto(nr_seq_pag_prest_w, nm_usuario_p);

end pls_gerar_trib_prest_venc;
/