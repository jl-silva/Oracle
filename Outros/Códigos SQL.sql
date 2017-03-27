'BÁSICO'
--UNION--------------------------------------UNION--------------------------------------UNION--------------------------------------UNION-------------------

	SELECT	SUM(vl_item)
	FROM	(SELECT	SUM(vl_proc) vl_item
		FROM	procedimento
		WHERE	....
		UNION ALL
		SELECT	SUM(vl_mat) vl_item
		FROM	material
		WHERE	....)

--UPDATE--------------------------------------UPDATE--------------------------------------UPDATE--------------------------------------UPDATE-------------------

	UPDATE	tabela
	SET	campo	= valor
	WHERE	restricao

--ALTERAÇÕES_CRIAÇÕES_DELETAÇÕES--------------------------------------ALTERAÇÕES_CRIAÇÕES_DELETAÇÕES--------------------------------------ALTERAÇÕES_CRIAÇÕES_DELETAÇÕES-------------------

	commit	 - Finalizar
	rollback - Voltar

--TIMESTAMP--------------------------------------TIMESTAMP--------------------------------------TIMESTAMP--------------------------------------TIMESTAMP-------------------

	-- SELECT QUE RETORNA OS VALORES QUE EXISTIAM NAQUELE OBJETO  NA DATA ESTIPULADA, SÓ É CONFIANTE A DATA ATÉ 3 DIAS A MENOS DO SYSDATE
	select	CAMPO
	from	TABELA as of timestamp TO_TIMESTAMP('11/09/2013 10:00:00','DD/MM/YYYY HH24:MI:SS')
	where	RESTRICAO

--TABLES--------------------------------------TABLES--------------------------------------TABLES--------------------------------------TABLES-------------------

	-- CRIAR TABELA, ATRIBUTOS
	CREATE TABLE philip (	nr		NUMBER(10)	NOT NULL,
				ds		VARCHAR2(4000)	NOT NULL,
				nr_seq_integr	NUMBER(10));

	-- CRIAR CHAVE PRIMÁRIA
	ALTER TABLE philip ADD (CONSTRAINT philip_pk PRIMARY KEY (nr));

	-- CRIAR CHAVA ESTRANGEIRA
	ALTER TABLE philip ADD (CONSTRAINT philip_fk FOREIGN KEY (nr_seq_integr) REFERENCES TABELA(CAMPO_DA_TABELA_CORRESPONDENTE));

	-- CRIAR SEQUENCE INDEPEDENTE
	CREATE SEQUENCE philip_seq;

	-- INSERIR VALOR NA TABELA
	INSERT INTO philip (nr, ds, nr_seq_integr)
	VALUES(philip_seq.nextval, '1º Registro', null);

	-- RETORNAR OS REGISTROS DA TABELA
	SELECT * FROM philip;

	-- DELETAR TODOS OS REGISTROS NA TABELA
	DELETE philip;

	-- DELETAR REGISTROS ESPECÍFICOS DA TABELA
	DELETE FROM philip
	WHERE nr = 1;

	-- ADICIONAR CAMPO NA TABELA 
	ALTER TABLE philip
	ADD ie_tipo NUMBER(1);

	-- EXCLUIR CAMPO NA TABELA 
	ALTER TABLE philip
	DROP COLUMN ie_tipo

	-- EXCLUIR TABELA
	DROP TABLE philip;
	
	-- EXCLUIR SEQUENCE
	DROP SEQUENCE philip_seq;

--NOVO CURSOR--------------------------------------NOVO CURSOR--------------------------------------NOVO CURSOR--------------------------------------NOVO CURSOR-------------------

	-- DECLARAÇÃO
	cursor C01	( nm_parametro	tipo) is
		select	
		from	
		where	
		order by 

	-- EXECUÇÃO
	for	r_c01_w	in	C01( nm_parametro_p ) loop
		...
	end loop;

'TASY'
--PARÂMETROS_TASY--------------------------------------PARÂMETROS_TASY--------------------------------------PARÂMETROS_TASY--------------------------------------PARÂMETROS_TASY-------------------

	INSERT INTO FUNCAO_PARAM_USUARIO (  CD_ESTABELECIMENTO, CD_FUNCAO, DS_OBSERVACAO, 
					    DT_ATUALIZACAO, NM_USUARIO, NM_USUARIO_PARAM,
					    NR_SEQ_INTERNO, NR_SEQUENCIA, VL_PARAMETRO )
	VALUES	( 1, 1208, NULL, sysdate, 'pitdelling', 'pitdelling', FUNCAO_PARAM_USUARIO_seq.nextval, 1, 'S');

--AJUSTE DE BASE--------------------------------------AJUSTE DE BASE--------------------------------------AJUSTE DE BASE--------------------------------------AJUSTE DE BASE-------------------

	-- 1º CONSISTIR BASE
	exec tasy_consistir_base;

	-- 2º VERIFICAR QUAIS SÃO AS INCONSISTÊNCIAS DA BASE
	select * from consiste_base_v;

	-- 3º VERIFICAR QUAL O TIPO DE INCONSISTÊNCIA NA PROCEDURE   >>>>'TASY_CONSISTIR_BASE'<<<<
	'A) INTEGRIDADE INEXISTENTE'
		/* ERRO */
			* Verificar se existe na tabela INDICE
			* Verificar se existe na tabela INTEGRIDADE_REFERENCIAL
		/* SOLUÇÃO */
			* Deletar lá, se houver lá e não aqui.
			* Criar lá, se aqui tiver e lá não. (Caso seja INTEGRIDADE_REFERENCIAL, acessar 'Dicionário de Dados Philips' > 'Tabelas' > 'Gerador de Script' > Escolhe a tabela com erro na base do cliente > Checar o 'Integridade Ref.' > BT - 'Gerar Script' > Rodar lá)
			
	-- 4º VERIFICAR O @VALIDA
	execute valida_objetos_sistema;
	select count(*) from objetos_invalidos_v;

--TASY VERSÃO--------------------------------------TASY VERSÃO--------------------------------------TASY VERSÃO--------------------------------------TASY VERSÃO-------------------

	-- SELECT NORMAL
	select CAMPO from TABELA;

	-- SELECT TASY_VERSAO
	select CAMPO from tasy_versao.TABELA;

--INTERFACE--------------------------------------INTERFACE--------------------------------------INTERFACE--------------------------------------INTERFACE-------------------

	-- CRIAR INTERFACE
	insert into interface select * from tasy_versao.interface where cd_interface in (CD_INTERFACE(s));
	commit;

	insert into interface_reg select * from tasy_versao.interface_reg where cd_interface in (CD_INTERFACE(s));
	commit;

	insert into interface_atributo select * from tasy_versao.interface_atributo where cd_interface in (CD_INTERFACE(s));
	commit;

--SENHA--------------------------------------SENHA--------------------------------------SENHA--------------------------------------SENHA--------------------------------------SENHA--------------------

	update usuario set ds_senha = 'abc123',
	dt_alteracao_senha = null where nm_usuario = 'jlsilva'

--EXPORTAÇÃO DE UM XML--------------------------------------EXPORTAÇÃO DE UM XML--------------------------------------EXPORTAÇÃO DE UM XML--------------------------------------EXPORTAÇÃO DE UM XML-------------------

	declare

	-- ESTES DOIS DELETES IRÃO EXCLUIR TODO O CONTEÚDO DO PROJETO XML MANTENDO APENAS O PROJETO VAZIO
	begin
	begin
	delete	xml_atributo
	where	nr_seq_elemento in (	select	nr_sequencia
					from	xml_elemento
					where	nr_seq_projeto = 101099);
	exception
	when others then
		null;
	end;

	commit;

	begin
	delete	xml_elemento
	where	nr_seq_projeto = 101099;
	exception
	when others then
		null;
	end;

	commit;

	/* ESTE UPDATE DEVE SER REALIZADO POIS APÓS GERAR OS INSERTS PELO SQL DEVELOPER DEVE SER SUBSTITUIDO O 'to_timestamp' e seu conteúdo por sysdate, e assim ficará simples realizar a substituição destes.
	update	xml_elemento
	set	dt_atualizacao          	= sysdate,
		dt_atualizacao_nrec	= sysdate	
	where	nr_seq_projeto 	= 101099
	/
	commit
	/
	*/

	/* ESTE SELECT DEVE SER EXECUTADO NO  SQL DEVELOPER, CLICAR COM O BOTÃO DIREITO SOBRE OS RESULTADOS, 'Exportar dados > Insert', então será gerado todos os inserts da tabela 'xml_elemento'.
	select	*
	from	xml_elemento
	where	nr_seq_projeto = 101099
	*/

	-- SUBSTITUIR TODOS OS 'to_timestamp' POR 'sysdate'
	-- SUBSTITUIR TODOS OS ' "xml_elemento" ' por xml_elemento

	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (23517,1,101099,'inclusaoPrestador','inclusaoPrestador',null,'select	substr(cd_classificacao, 1, 1) cd_classificacao,
		substr(cd_cpf_cnpj, 1, 14) cd_cpf_cnpj,
		substr(cd_cnes, 1, 7) cd_cnes,
		substr(sg_uf, 1, 2) sg_uf,
		substr(cd_municipio_ibge, 1, 6) cd_municipio,
		substr(trim(ds_razao_social), 1 , 60) ds_razao,
		substr(ie_relacao_operadora, 1, 1) ie_relac,
		substr(ie_tipo_contratualizacao, 1, 1) ie_contrat,
		substr(cd_ans_int, 1, 6) cd_ans,
		to_char(dt_contratualizacao, ''dd/mm/yyyy'') dt_contrat,
		to_char(dt_inicio_servico, ''dd/mm/yyyy'') dt_servico,
		substr(ie_disponibilidade_serv, 1, 1) ie_disp,
		substr(ie_urgencia_emergencia, 1, 1) ie_urg,
		nr_sequencia nr_seq_rps_pres
	from	pls_rps_prestador
	where	nr_sequencia	= :nr_seq_item',null,'jtonon',sysdate,'S','dhoffman',sysdate,'E','N','S',null,null,null,null);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (23518,1,101099,'vinculacao','vinculacao',null,'select	to_char(nr_seq_prestador_rps) nr_seq_prestador_rps
	from	pls_rps_prest_plano
	where	nr_seq_prestador_rps	= :nr_seq_rps_pres
	and	:ie_urg 		= ''S''
	and	:cd_classificacao in (1,2,3)
	and	:nr_seq_rps_pres is not null
	group by nr_seq_prestador_rps
	union all
	select	null nr_seq_prestador_rps
	from	pls_rps_prest_plano
	where	((:nr_seq_rps_pres is null) or
		(:ie_urg <> ''S'') or
		(:cd_classificacao not in (1,2,3)))
	and	rownum <= 1',null,'jtonon',sysdate,'S','dhoffman',sysdate,'E','S','S',null,null,null,null);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (23512,1,101099,'vinculacaoPrestadorRede','vinculacaoPrestadorRede',null,'select	b.nr_sequencia nr_seq_item
	from	pls_rps_prestador	b,
		pls_lote_rps		a
	where	a.nr_sequencia	= b.nr_seq_lote
	and	a.nr_sequencia	= :nr_seq_lote
	and	a.ie_tipo_lote	= ''RPV''',null,'dhoffman',sysdate,'S','dhoffman',sysdate,'E','S','S',null,null,null,null);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (23513,1,101099,'identificacao','identificacao',null,'select	substr(a.cd_cpf_cnpj, 1, 14) cd_cpf_cnpj,
		substr(a.cd_cnes, 1, 7) cd_cnes,
		substr(a.cd_municipio_ibge, 1, 6) cd_municipio
	from	pls_rps_prestador	a
	where	a.nr_sequencia	= :nr_seq_item',null,'dhoffman',sysdate,'S','dhoffman',sysdate,'E','S','S',null,null,null,null);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (23510,1,101099,'alteracaoPrestador','alteracaoPrestador',null,'select	b.nr_sequencia nr_seq_item
	from	pls_rps_prestador	b,
		pls_lote_rps		a
	where	a.nr_sequencia	= b.nr_seq_lote
	and	a.nr_sequencia	= :nr_seq_lote
	and	a.ie_tipo_lote	= ''RPA''',null,'dhoffman',sysdate,'S','dhoffman',sysdate,'E','S','S',null,null,null,null);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (23504,1,101099,'operadora','operadora',null,'select	substr(a.cd_ans, 1, 6) cd_ans,
		substr(a.cd_cgc_operadora, 1, 14) cd_cgc
	from	pls_lote_rps	a
	where	a.nr_sequencia	= :nr_seq_lote',null,'dhoffman',sysdate,'S','dhoffman',sysdate,'E','S','S',null,null,null,null);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (23507,1,101099,'solicitacao','solicitacao',null,'select	substr(a.nr_nosso_numero, 1, 17) nr_nosso_numero,
		a.ie_isencao_onus
	from	pls_lote_rps		b,
		pls_rps_solicitacao	a
	where	b.nr_sequencia	= a.nr_seq_lote
	and	a.nr_seq_lote	= :nr_seq_lote
	union all
	select	null nr_nosso_numero,
		null ie_isencao_onus
	from	pls_lote_rps	a
	where	a.nr_sequencia	= :nr_seq_lote
	and	a.ie_tipo_lote	= ''RPE''',null,'dhoffman',sysdate,'S','dhoffman',sysdate,'E','S','S',null,null,null,null);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (23511,1,101099,'exclusaoPrestador','exclusaoPrestador',null,'select	b.nr_sequencia nr_seq_item
	from	pls_rps_prestador	b,
		pls_lote_rps		a
	where	a.nr_sequencia	= b.nr_seq_lote
	and	a.nr_sequencia	= :nr_seq_lote
	and	a.ie_tipo_lote	= ''RPE''',null,'dhoffman',sysdate,'S','dhoffman',sysdate,'E','S','S',null,null,null,null);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (40589,1,101099,'numeroRegistroPlanoVinculadoElemento','numeroRegistroPlanoVinculadoElemento',null,'select	max(nvl(nr_registro_plano,'''')) nr_registro_plano,
		max(nvl(cd_plano,'''')) cd_plano
	from	pls_rps_prest_plano
	where	nr_seq_prestador_rps	= :nr_seq_prestador_rps
	and	:nr_seq_prestador_rps is not null
	union all
	select	'''' nr_registro_plano,
		'''' 
	from	dual
	where	:nr_seq_prestador_rps is null',null,'jtonon',sysdate,'S','jtonon',sysdate,'E','S','S',null,null,0,0);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (40551,1,101099,'numeroRegistroPlanoVinculadoElemento','numeroRegistroPlanoVinculadoElemento',null,'select	max(nvl(nr_registro_plano,'''')) nr_registro_plano,
		max(nvl(cd_plano,'''')) cd_plano
	from	pls_rps_prest_plano
	where	nr_seq_prestador_rps	= :nr_seq_prestador_rps
	and	:nr_seq_prestador_rps is not null',null,'pitdelling',sysdate,'S','jtonon',sysdate,'E','S','S',null,null,0,0);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (23514,1,101099,'prestador','prestador',null,'select	substr(cd_classificacao, 1, 1) cd_classificacao,
		substr(cd_cpf_cnpj, 1, 14) cd_cpf_cnpj,
		substr(cd_cnes, 1, 7) cd_cnes,
		substr(sg_uf, 1, 2) sg_uf,
		substr(cd_municipio_ibge, 1, 6) cd_municipio,
		substr(trim(ds_razao_social), 1 , 60) ds_razao,
		substr(ie_relacao_operadora, 1, 1) ie_relac,
		substr(ie_tipo_contratualizacao, 1, 1) ie_contrat,
		substr(cd_ans_int, 1, 6) cd_ans,
		to_char(dt_contratualizacao, ''dd/mm/yyyy'') dt_contrat,
		to_char(dt_inicio_servico, ''dd/mm/yyyy'') dt_servico,
		substr(ie_disponibilidade_serv, 1, 1) ie_disp,
		substr(ie_urgencia_emergencia, 1, 1) ie_urg,
		nr_sequencia nr_seq_rps_pres
	from	pls_rps_prestador
	where	nr_sequencia	= :nr_seq_item',null,'jtonon',sysdate,'S','dhoffman',sysdate,'E','S','S',null,null,null,null);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (23520,1,101099,'identificacao','identificacao',null,'select	substr(a.cd_cpf_cnpj, 1, 14) cd_cpf_cnpj,
		substr(a.cd_cnes, 1, 7) cd_cnes,
		substr(a.cd_municipio_ibge, 1, 6) cd_municipio
	from	pls_rps_prestador	a
	where	a.nr_sequencia	= :nr_seq_item',null,'dhoffman',sysdate,'S','dhoffman',sysdate,'E','S','S',null,null,null,null);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (23521,1,101099,'alterarDados','alterarDados',null,'select	substr(a.cd_classificacao, 1, 1) cd_classificacao,
		substr(a.cd_cpf_cnpj, 1, 14) cd_cpf_cnpj,
		substr(a.cd_cnes, 1, 7) cd_cnes,
		substr(a.sg_uf, 1, 2) sg_uf,
		substr(a.cd_municipio_ibge, 1, 6) cd_municipio,
		substr(trim(a.ds_razao_social), 1 , 60) ds_razao,
		substr(a.ie_relacao_operadora, 1, 1) ie_relac,
		substr(a.ie_tipo_contratualizacao, 1, 1) ie_contrat,
		substr(a.cd_ans_int, 1, 6) cd_ans,
		to_char(a.dt_contratualizacao, ''dd/mm/yyyy'') dt_contrat,
		to_char(a.dt_inicio_servico, ''dd/mm/yyyy'') dt_servico,
		substr(a.ie_disponibilidade_serv, 1, 1) ie_disp,
		substr(a.ie_urgencia_emergencia, 1, 1) ie_urg,
		nr_sequencia nr_seq_rps_pres
	from	pls_rps_prestador	a
	where	a.nr_sequencia	= :nr_seq_item',null,'jtonon',sysdate,'S','dhoffman',sysdate,'E','S','S',null,null,null,null);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (40349,1,101099,'vinculacao','vinculacao',null,'select	nr_seq_prestador_rps
	from	pls_rps_prest_plano
	where	nr_seq_prestador_rps	= :nr_seq_rps_pres
	and	:ie_urg 		= ''S''
	and	:nr_seq_rps_pres is not null
	group by nr_seq_prestador_rps',null,'jtonon',sysdate,'S','jtonon',sysdate,'E','S','S',null,null,null,null);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (23523,1,101099,'vinculacao','vinculacao',null,'select	max(nvl(nr_registro_plano,'''')) nr_registro_plano,
		max(nvl(cd_plano,'''')) cd_plano
	from	pls_rps_prest_plano
	where	nr_seq_prestador_rps	= :nr_seq_rps_pres
	and	:nr_seq_rps_pres is not null
	union all
	select	'''' nr_registro_plano,
		'''' 
	from	dual
	where	:nr_seq_rps_pres is null',null,'jtonon',sysdate,'S','dhoffman',sysdate,'E','S','S',null,null,null,null);
	Insert into xml_elemento (NR_SEQUENCIA,NR_SEQ_APRESENTACAO,NR_SEQ_PROJETO,NM_ELEMENTO,DS_ELEMENTO,DS_CABECALHO,DS_SQL,DS_GRUPO,NM_USUARIO,DT_ATUALIZACAO,IE_CRIAR_NULO,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,IE_TIPO_ELEMENTO,IE_CRIAR_ELEMENTO,IE_TIPO_COMPLEXO,DS_SQL_2,DS_NAMESPACE,QT_MIN_OCOR,QT_MAX_OCOR) values (23509,1,101099,'inclusaoPrestador','inclusaoPrestador',null,'select	b.nr_sequencia nr_seq_item
	from	pls_rps_prestador	b,
		pls_lote_rps		a
	where	a.nr_sequencia	= b.nr_seq_lote
	and	a.nr_sequencia	= :nr_seq_lote
	and	a.ie_tipo_lote	= ''RPI''',null,'dhoffman',sysdate,'S','dhoffman',sysdate,'E','S','S',null,null,null,null);

	commit;

	/* ESTE UPDATE DEVE SER REALIZADO POIS APÓS GERAR OS INSERTS PELO SQL DEVELOPER DEVE SER SUBSTITUIDO O 'to_timestamp' e seu conteúdo por sysdate, e assim ficará simples realizar a substituição destes.
	update	xml_atributo
	set	dt_atualizacao          	= sysdate,
		dt_atualizacao_nrec	= sysdate
	where	nr_seq_elemento in (	select	nr_sequencia
					from	xml_elemento
					where	nr_seq_projeto = 101099)
	/

	commit
	/
	*/

	/* ESTE SELECT DEVE SER EXECUTADO NO  SQL DEVELOPER, CLICAR COM O BOTÃO DIREITO SOBRE OS RESULTADOS, 'Exportar dados > Insert', então será gerado todos os inserts da tabela 'xml_atributo'.
	select	*
	from	xml_atributo
	where	nr_seq_elemento in (	select	nr_sequencia
					from	xml_elemento
					where	nr_seq_projeto = 101099)
	*/

	-- SUBSTITUIR TODOS OS 'to_timestamp' POR 'sysdate'
	-- SUBSTITUIR TODOS OS ' "xml_atributo" ' por xml_atributo

	delete from xml_atributo where nr_sequencia = 97913;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97913,23517,11,'dataInicioPrestacaoServico','DT_SERVICO','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'DATAINICIOPRESTACAOSERVICO');
	delete from xml_atributo where nr_sequencia = 97914;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97914,23517,12,'disponibilidadeServico','IE_DISP','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'DISPONIBILIDADESERVICO');
	delete from xml_atributo where nr_sequencia = 97915;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97915,23517,13,'urgenciaEmergencia','IE_URG','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'URGENCIAEMERGENCIA');
	delete from xml_atributo where nr_sequencia = 97916;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97916,23517,14,'vinculacao',null,'S','S',null,null,'dhoffman',sysdate,'jtonon',sysdate,23518,'S',null,'N','S',null,null,'VINCULACAO');
	delete from xml_atributo where nr_sequencia = 97916;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97909,23517,7,'relacaoOperadora','IE_RELAC','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'RELACAOOPERADORA');
	delete from xml_atributo where nr_sequencia = 97910;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97910,23517,8,'tipoContratualizacao','IE_CONTRAT','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'TIPOCONTRATUALIZACAO');
	delete from xml_atributo where nr_sequencia = 97911;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97911,23517,9,'registroANSOperadoraIntermediaria','CD_ANS','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'REGISTROANSOPERADORAINTERMEDIARIA');
	delete from xml_atributo where nr_sequencia = 97903;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97903,23517,1,'classificacao','CD_CLASSIFICACAO','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CLASSIFICACAO');
	delete from xml_atributo where nr_sequencia = 97904;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97904,23517,2,'cnpjCpf','CD_CPF_CNPJ','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CNPJCPF');
	delete from xml_atributo where nr_sequencia = 97905;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97905,23517,3,'cnes','CD_CNES','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CNES');
	delete from xml_atributo where nr_sequencia = 97906;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97906,23517,4,'uf','SG_UF','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'UF');
	delete from xml_atributo where nr_sequencia = 97907;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97907,23517,5,'codigoMunicipioIBGE','CD_MUNICIPIO','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CODIGOMUNICIPIOIBGE');
	delete from xml_atributo where nr_sequencia = 97908;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97908,23517,6,'razaoSocial','DS_RAZAO','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','N',null,null,'RAZAOSOCIAL');
	delete from xml_atributo where nr_sequencia = 97912;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97912,23517,10,'dataContratualizacao','DT_CONTRAT','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'DATACONTRATUALIZACAO');
	delete from xml_atributo where nr_sequencia = 172218;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (172218,23518,1,'numeroRegistroPlanoVinculacao',null,'N','N',null,null,'jtonon',sysdate,'jtonon',sysdate,40551,'N',null,'N','S',null,null,'NUMEROREGISTROPLANOVINCULACAO');
	delete from xml_atributo where nr_sequencia = 97893;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97893,23512,1,'prestador',null,'S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,23514,'S',null,'N','S',null,null,'PRESTADOR');
	delete from xml_atributo where nr_sequencia = 172274;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (172274,23512,4,'vinculacao',null,'S','S',null,null,'jtonon',sysdate,'jtonon',sysdate,40349,'S',null,'N','S',null,null,'VINCULACAO');
	delete from xml_atributo where nr_sequencia = 97890;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97890,23513,1,'cnpjCpf','CD_CPF_CNPJ','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CNPJCPF');
	delete from xml_atributo where nr_sequencia = 97891;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97891,23513,2,'cnes','CD_CNES','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CNES');
	delete from xml_atributo where nr_sequencia = 97892;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97892,23513,3,'codigoMunicipioIBGE','CD_MUNICIPIO','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CODIGOMUNICIPIOIBGE');
	delete from xml_atributo where nr_sequencia = 97892;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97923,23510,2,'alterarDados',null,'S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,23521,'S',null,'N','S',null,null,'ALTERARDADOS');
	delete from xml_atributo where nr_sequencia = 97902;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97902,23510,1,'identificacao',null,'S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,23520,'S',null,'N','S',null,null,'IDENTIFICACAO');
	delete from xml_atributo where nr_sequencia = 97879;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97879,23504,1,'registroANS','CD_ANS','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'REGISTROANS');
	delete from xml_atributo where nr_sequencia = 97880;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97880,23504,2,'cnpjOperadora','CD_CGC','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CNPJOPERADORA');
	delete from xml_atributo where nr_sequencia = 97881;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97881,23504,3,'solicitacao',null,'S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,23507,'S',null,'N','S',null,null,'SOLICITACAO');
	delete from xml_atributo where nr_sequencia = 97882;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97882,23507,1,'nossoNumero','NR_NOSSO_NUMERO','S','N',null,null,'dhoffman',sysdate,'jtonon',sysdate,null,'S',null,'N','S',null,null,'NOSSONUMERO');
	delete from xml_atributo where nr_sequencia = 97883;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97883,23507,2,'isencaoOnus','IE_ISENCAO_ONUS','S','N',null,null,'dhoffman',sysdate,'jtonon',sysdate,null,'S',null,'N','S',null,null,'ISENCAOONUS');
	delete from xml_atributo where nr_sequencia = 97884;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97884,23507,3,'inclusaoPrestador',null,'N','N',null,null,'dhoffman',sysdate,'jtonon',sysdate,23509,'S',null,'N','S',null,null,'INCLUSAOPRESTADOR');
	delete from xml_atributo where nr_sequencia = 97885;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97885,23507,4,'alteracaoPrestador',null,'N','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,23510,'S',null,'N','S',null,null,'ALTERACAOPRESTADOR');
	delete from xml_atributo where nr_sequencia = 97886;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97886,23507,5,'exclusaoPrestador',null,'N','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,23511,'S',null,'N','S',null,null,'EXCLUSAOPRESTADOR');
	delete from xml_atributo where nr_sequencia = 97887;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97887,23507,6,'vinculacaoPrestadorRede',null,'N','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,23512,'S',null,'N','S',null,null,'VINCULACAOPRESTADORREDE');
	delete from xml_atributo where nr_sequencia = 97889;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97889,23511,1,'identificacao',null,'S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,23513,'S',null,'N','S',null,null,'IDENTIFICACAO');
	delete from xml_atributo where nr_sequencia = 172935;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (172935,40589,2,'codigoPlanoOperadoraVinculacao','CD_PLANO','S','N',null,null,'jtonon',sysdate,'pitdelling',sysdate,null,'S',null,'N','S',null,null,'CODIGOPLANOOPERADORAVINCULACAO');
	delete from xml_atributo where nr_sequencia = 172934;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (172934,40589,1,'numeroRegistroPlanoVinculacao','NR_REGISTRO','S','N',null,null,'jtonon',sysdate,'pitdelling',sysdate,null,'S',null,'N','S',null,null,'NUMEROREGISTROPLANOVINCULACAO');
	delete from xml_atributo where nr_sequencia = 172768;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (172768,40551,1,'numeroRegistroPlanoVinculacao','NR_REGISTRO','S','N',null,null,'jtonon',sysdate,'jtonon',sysdate,null,'S',null,'N','S',null,null,'NUMEROREGISTROPLANOVINCULACAO');
	delete from xml_atributo where nr_sequencia = 172770;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (172770,40551,2,'codigoPlanoOperadoraVinculacao','CD_PLANO','S','N',null,null,'jtonon',sysdate,'jtonon',sysdate,null,'S',null,'N','S',null,null,'CODIGOPLANOOPERADORAVINCULACAO');
	delete from xml_atributo where nr_sequencia = 97894;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97894,23514,1,'cnpjCpf','CD_CPF_CNPJ','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CNPJCPF');
	delete from xml_atributo where nr_sequencia = 97895;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97895,23514,2,'cnes','CD_CNES','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CNES');
	delete from xml_atributo where nr_sequencia = 97896;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97896,23514,3,'codigoMunicipioIBGE','CD_MUNICIPIO','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CODIGOMUNICIPIOIBGE');
	delete from xml_atributo where nr_sequencia = 97920;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97920,23520,1,'cnpjCpf','CD_CPF_CNPJ','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CNPJCPF');
	delete from xml_atributo where nr_sequencia = 97921;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97921,23520,2,'cnes','CD_CNES','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CNES');
	delete from xml_atributo where nr_sequencia = 97922;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97922,23520,3,'codigoMunicipioIBGE','CD_MUNICIPIO','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CODIGOMUNICIPIOIBGE');
	delete from xml_atributo where nr_sequencia = 97925;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97925,23521,2,'cnpjCpf','CD_CPF_CNPJ','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CNPJCPF');
	delete from xml_atributo where nr_sequencia = 97931;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97931,23521,3,'cnes','CD_CNES','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CNES');
	delete from xml_atributo where nr_sequencia = 97932;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97932,23521,4,'uf','SG_UF','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'UF');
	delete from xml_atributo where nr_sequencia = 97924;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97924,23521,1,'classificacao','CD_CLASSIFICACAO','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CLASSIFICACAO');
	delete from xml_atributo where nr_sequencia = 97933;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97933,23521,5,'codigoMunicipioIBGE','CD_MUNICIPIO','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'CODIGOMUNICIPIOIBGE');
	delete from xml_atributo where nr_sequencia = 97934;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97934,23521,6,'razaoSocial','DS_RAZAO','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','N',null,null,'RAZAOSOCIAL');
	delete from xml_atributo where nr_sequencia = 97935;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97935,23521,7,'relacaoOperadora','IE_RELAC','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'RELACAOOPERADORA');
	delete from xml_atributo where nr_sequencia = 97936;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97936,23521,8,'tipoContratualizacao','IE_CONTRAT','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'TIPOCONTRATUALIZACAO');
	delete from xml_atributo where nr_sequencia = 97937;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97937,23521,9,'registroANSOperadoraIntermediaria','CD_ANS','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'REGISTROANSOPERADORAINTERMEDIARIA');
	delete from xml_atributo where nr_sequencia = 97938;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97938,23521,10,'dataContratualizacao','DT_CONTRAT','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'DATACONTRATUALIZACAO');
	delete from xml_atributo where nr_sequencia = 97938;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97939,23521,11,'dataInicioPrestacaoServico','DT_SERVICO','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'DATAINICIOPRESTACAOSERVICO');
	delete from xml_atributo where nr_sequencia = 97940;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97940,23521,12,'disponibilidadeServico','IE_DISP','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'DISPONIBILIDADESERVICO');
	delete from xml_atributo where nr_sequencia = 97941;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97941,23521,13,'urgenciaEmergencia','IE_URG','S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,null,'S',null,'N','S',null,null,'URGENCIAEMERGENCIA');
	delete from xml_atributo where nr_sequencia = 97942;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97942,23521,14,'vinculacao',null,'S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,23523,'S',null,'N','S',null,null,'VINCULACAO');
	delete from xml_atributo where nr_sequencia = 172276;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (172276,40349,1,'numeroRegistroPlanoVinculacao',null,'N','N',null,null,'jtonon',sysdate,'pitdelling',sysdate,40589,'N',null,'N','S',null,null,'NUMEROREGISTROPLANOVINCULACAO');
	delete from xml_atributo where nr_sequencia = 172262;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (172262,23523,1,'codigoPlanoOperadoraVinculacao','CD_PLANO','S','S',null,null,'jtonon',sysdate,'jtonon',sysdate,null,'S',null,'N','S',null,null,'CODIGOPLANOOPERADORAVINCULACAO');
	delete from xml_atributo where nr_sequencia = 172263;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (172263,23523,1,'numeroRegistroPlanoVinculacao','NR_REGISTRO','S','S',null,null,'jtonon',sysdate,'jtonon',sysdate,null,'S',null,'N','S',null,null,'NUMEROREGISTROPLANOVINCULACAO');
	delete from xml_atributo where nr_sequencia = 97901;
	Insert into xml_atributo (NR_SEQUENCIA,NR_SEQ_ELEMENTO,NR_SEQ_APRESENTACAO,NM_ATRIBUTO_XML,NM_ATRIBUTO,IE_CRIAR_NULO,IE_OBRIGATORIO,IE_TIPO_ATRIBUTO,DS_MASCARA,NM_USUARIO_NREC,DT_ATUALIZACAO_NREC,NM_USUARIO,DT_ATUALIZACAO,NR_SEQ_ATRIB_ELEM,IE_CRIAR_ATRIBUTO,DS_CABECALHO,IE_CONTROLE_PB,IE_REMOVER_ESPACO_BRANCO,DS_NAMESPACE,NM_TABELA_DEF_BANCO,NM_ATRIBUTO_XML_PESQUISA) values (97901,23509,1,'inclusaoPrestador',null,'S','S',null,null,'dhoffman',sysdate,'dhoffman',sysdate,23517,'S',null,'N','S',null,null,'INCLUSAOPRESTADOR');

	commit;

	end;
	/