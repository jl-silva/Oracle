create or replace context bind_var_sql_pck using sql_pck;
/
create or replace package sql_pck AUTHID CURRENT_USER as
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Finalidade: 	Esta PACKAGE, tem por objetivo centralizar várias funções que são úteis para a manipulação de comandos sql.
	Foi idealizada pelo colaborador Jean Jung.
-------------------------------------------------------------------------------------------------------------------
Locais de chamada direta: 
[ X]  Objetos do dicionário [X] Tasy (Delphi/Java) [ X] Portal [ X]  Relatórios [ ] Outros:
 ------------------------------------------------------------------------------------------------------------------
Pontos de atenção:

Alterações
------------------------------------------------------------------------------------------------------------------
jjung OS 701070  22/04/2014 - 

Alteração:	Alterado a geração da cláusula using para funcionar corretamente quando uma variável
	numérica tivesse valor null.
------------------------------------------------------------------------------------------------------------------
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

b_data 		constant varchar2(10) := 'DATA';
b_data_hora 	constant varchar2(10) := 'DATAHORA';
b_hora 		constant varchar2(10) := 'HORA';
b_number	constant varchar2(10) := 'NUMBER';
b_varchar	constant varchar2(10) := 'VARCHAR';

type t_varchar2_table_bind is table of varchar2(100) index by pls_integer;
type t_dado_bind_row is record (ds_nome		varchar2(100),
				ds_valor	varchar2(100), 
				dt_valor	date,
				vl_valor	number,
				ie_tipo_valor varchar2(10));
type t_dado_bind is table of t_dado_bind_row index by pls_integer;
type t_cursor is ref cursor;

-- é utilizado uma procedure para cada tipo de dado
procedure bind_variable(	ds_nome_bind_p		in varchar2,
				dt_valor_bind_p		in date,
				bind_sql_valor_p	in out sql_pck.t_dado_bind,
				ie_tipo_valor_bind_p	in varchar2 default b_data);

procedure bind_variable(	ds_nome_bind_p		in varchar2,
				vl_valor_bind_p		in number,
				bind_sql_valor_p	in out sql_pck.t_dado_bind,
				ie_tipo_valor_bind_p	in varchar2 default b_number);
				
procedure bind_variable(	ds_nome_bind_p		in varchar2,
				ds_valor_bind_p		in varchar2,
				bind_sql_valor_p	in out sql_pck.t_dado_bind,
				ie_tipo_valor_bind_p	in varchar2 default b_varchar);
	
function executa_sql_cursor(	ds_sql_p		in varchar2,
				bind_sql_valor_p	in out sql_pck.t_dado_bind) 
	return sql_pck.t_cursor;
	
--Criação desse select para realizar comandos SQL com mais de 4 mil caracteres
function executa_sql_big_cursor(	ds_sql_p		in varchar2,
					bind_sql_valor_p	in out sql_pck.t_dado_bind) 
	return sql_pck.t_cursor;
	
procedure executa_sql(	ds_sql_p		in varchar2,
			bind_sql_valor_p	in out sql_pck.t_dado_bind,
			ie_auto_commit_p	in varchar2 default 'S');

end sql_pck;
/
create or replace package body sql_pck as

procedure bind_variable(	ds_nome_bind_p		in varchar2,
				dt_valor_bind_p		in date,
				bind_sql_valor_p	in out sql_pck.t_dado_bind,
				ie_tipo_valor_bind_p	in varchar2 default b_data) is
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Finalidade:	Organizar e facilitar o gerenciamento de binds variables em comandos sql.
	Recebe como entrada os dados do bind a ser inserido se o bind for um date.
-------------------------------------------------------------------------------------------------------------------
Locais de chamada direta:
[X]  Objetos do dicionário [ ] Tasy (Delphi/Java) [  ] Portal [  ]  Relatórios [ ] Outros:
-------------------------------------------------------------------------------------------------------------------
Pontos de atenção:

Alterações:
 ------------------------------------------------------------------------------------------------------------------
 usuario OS XXXXXX 01/01/2000 - 	
 Alteração:	Descrição da alteração.
Motivo:	Descrição do motivo.
 ------------------------------------------------------------------------------------------------------------------
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */	
qt_reg_w	pls_integer;
begin
qt_reg_w := (bind_sql_valor_p.count + 1);
-- acrescenta o bind na variável
bind_sql_valor_p(qt_reg_w).ds_nome := lower(ds_nome_bind_p);
bind_sql_valor_p(qt_reg_w).ds_valor := null;
bind_sql_valor_p(qt_reg_w).dt_valor := dt_valor_bind_p;
bind_sql_valor_p(qt_reg_w).ie_tipo_valor := ie_tipo_valor_bind_p;
bind_sql_valor_p(qt_reg_w).vl_valor := null;

end bind_variable;

procedure bind_variable(	ds_nome_bind_p		in varchar2,
				vl_valor_bind_p		in number,
				bind_sql_valor_p	in out sql_pck.t_dado_bind,
				ie_tipo_valor_bind_p	in varchar2 default b_number) is
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Finalidade:	Organizar e facilitar o gerenciamento de binds variables em comandos sql.
	Recebe como entrada os dados do bind a ser inserido se o bind for um number.
-------------------------------------------------------------------------------------------------------------------
Locais de chamada direta:
[X]  Objetos do dicionário [ ] Tasy (Delphi/Java) [  ] Portal [  ]  Relatórios [ ] Outros:
-------------------------------------------------------------------------------------------------------------------
Pontos de atenção:

Alterações:
 ------------------------------------------------------------------------------------------------------------------
 usuario OS XXXXXX 01/01/2000 - 	
 Alteração:	Descrição da alteração.
Motivo:	Descrição do motivo.
 ------------------------------------------------------------------------------------------------------------------
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */	
qt_reg_w	pls_integer;
begin
qt_reg_w := (bind_sql_valor_p.count + 1);
-- acrescenta o bind na variável
bind_sql_valor_p(qt_reg_w).ds_nome := lower(ds_nome_bind_p);
bind_sql_valor_p(qt_reg_w).ds_valor := null;
bind_sql_valor_p(qt_reg_w).dt_valor := null;
bind_sql_valor_p(qt_reg_w).ie_tipo_valor := ie_tipo_valor_bind_p;
bind_sql_valor_p(qt_reg_w).vl_valor := vl_valor_bind_p;

end bind_variable;

procedure bind_variable(	ds_nome_bind_p		in varchar2,
				ds_valor_bind_p		in varchar2,
				bind_sql_valor_p	in out sql_pck.t_dado_bind,
				ie_tipo_valor_bind_p	in varchar2 default b_varchar) is
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Finalidade:	Organizar e facilitar o gerenciamento de binds variables em comandos sql.
	Recebe como entrada os dados do bind a ser inserido se o bind for um varchar2.
-------------------------------------------------------------------------------------------------------------------
Locais de chamada direta:
[X]  Objetos do dicionário [ ] Tasy (Delphi/Java) [  ] Portal [  ]  Relatórios [ ] Outros:
-------------------------------------------------------------------------------------------------------------------
Pontos de atenção:

Alterações:
 ------------------------------------------------------------------------------------------------------------------
 usuario OS XXXXXX 01/01/2000 - 	
 Alteração:	Descrição da alteração.
Motivo:	Descrição do motivo.
 ------------------------------------------------------------------------------------------------------------------
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */	
qt_reg_w	pls_integer;
begin
qt_reg_w := (bind_sql_valor_p.count + 1);
-- acrescenta o bind na variável
bind_sql_valor_p(qt_reg_w).ds_nome := lower(ds_nome_bind_p);
bind_sql_valor_p(qt_reg_w).ds_valor := ds_valor_bind_p;
bind_sql_valor_p(qt_reg_w).dt_valor := null;
bind_sql_valor_p(qt_reg_w).ie_tipo_valor := ie_tipo_valor_bind_p;
bind_sql_valor_p(qt_reg_w).vl_valor := null;

end bind_variable;

function obter_bind_sql(	ds_sql_p	varchar2) 
	return sql_pck.t_varchar2_table_bind is
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Finalidade:	Recebe um comando sql e devolve o nome das binds contidas nele
-------------------------------------------------------------------------------------------------------------------
Locais de chamada direta:
[X]  Objetos do dicionário [ ] Tasy (Delphi/Java) [  ] Portal [  ]  Relatórios [ ] Outros:
-------------------------------------------------------------------------------------------------------------------
Pontos de atenção:

Alterações:
 ------------------------------------------------------------------------------------------------------------------
 usuario OS XXXXXX 01/01/2000 - 	
 Alteração:	Descrição da alteração.
Motivo:	Descrição do motivo.
 ------------------------------------------------------------------------------------------------------------------
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
qt_registro_w		pls_integer;
tb_bind_w		sql_pck.t_varchar2_table_bind;
-- jjung - Alterado a string de início para utilizar o regexp_str e não considerar binds erroneamente 
-- nas strings da cláusula select, como por exemplo select 'Valor total:' || sum(vl_total) vl_total 
str_inicio_bind_w	varchar2(100) := ':[a-z|A-Z|_|:|0-9]';
ds_sql_temp_w		varchar2(32000);
nr_pos_ini_w		pls_integer;
nr_pos_fim_w		pls_integer;

begin
qt_registro_w := 0;
tb_bind_w.delete;
ds_sql_temp_w := ds_sql_p;
--busca a primeira ocorrência do caracter : que significa que existe um bind
nr_pos_ini_w := regexp_instr(ds_sql_temp_w, str_inicio_bind_w);

-- busca todos os caracteres dois pontos
while (nr_pos_ini_w > 0) loop
	-- elimina todo o comando sql anterior ao caracter :
	ds_sql_temp_w := substr(ds_sql_temp_w, nr_pos_ini_w);
	-- retorna a posição do último caracter da bind buscando desde o início com os dois pontos até algum espaço ou quebra de linha, etc.
	-- a tradução seria: me retorne a posição de qualquer caracter que não for letra, _ : número ou que tenha chegado o fim do arquivo
	nr_pos_fim_w := regexp_instr(ds_sql_temp_w,'[^a-z|A-Z|_|:|0-9]|$');
	
	-- retorna o nome da bind
	-- é usado o menos 1 para desconsiderar o caracter que foi encontrado (espaço em branco, quebra de linha, etc.)
	-- coloca tudo em caixa baixa para facilitar comparações futuras
	tb_bind_w(qt_registro_w) := lower(substr(ds_sql_temp_w, 0, nr_pos_fim_w - 1));
	
	-- elimina todo o comando sql anterior com a última bind
	ds_sql_temp_w := substr(ds_sql_temp_w, nr_pos_fim_w + 1);

	nr_pos_ini_w := regexp_instr(ds_sql_temp_w, str_inicio_bind_w);
	qt_registro_w := qt_registro_w + 1;
end loop;

return tb_bind_w;

end obter_bind_sql;

function obter_index_bind(	bind_sql_valor_p	sql_pck.t_dado_bind,
				nm_bind_p		varchar2) return pls_integer is
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Finalidade:	Faz a pesquisa pelo nome do bind e retorna sua posição caso seja encontrado
-------------------------------------------------------------------------------------------------------------------
Locais de chamada direta:
[X]  Objetos do dicionário [ ] Tasy (Delphi/Java) [  ] Portal [  ]  Relatórios [ ] Outros:
-------------------------------------------------------------------------------------------------------------------
Pontos de atenção:

Alterações:
 ------------------------------------------------------------------------------------------------------------------
 usuario OS XXXXXX 01/01/2000 - 	
 Alteração:	Descrição da alteração.
Motivo:	Descrição do motivo.
 ------------------------------------------------------------------------------------------------------------------
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
nr_posicao_w	pls_integer;
begin
nr_posicao_w := null;
-- percorre todas as binds para verificar se o nome existe
for i in bind_sql_valor_p.first .. bind_sql_valor_p.last loop
	-- se achou a bind retorna a posição
	if	(bind_sql_valor_p(i).ds_nome = nm_bind_p) then
		nr_posicao_w := i;
		exit;
	end if;
end loop;

return nr_posicao_w;

end obter_index_bind;

function obter_using(	bind_sql_comando_p	sql_pck.t_varchar2_table_bind,
			bind_sql_valor_p	sql_pck.t_dado_bind)
			return varchar2 is
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Finalidade:	Recebe os binds identificados no comando SQL e os seus respectivos valores e 
	constrói uma clausula using que será usada nos próximos passos
-------------------------------------------------------------------------------------------------------------------
Locais de chamada direta:
[X]  Objetos do dicionário [ ] Tasy (Delphi/Java) [  ] Portal [  ]  Relatórios [ ] Outros:
-------------------------------------------------------------------------------------------------------------------
Pontos de atenção:

Alterações:
 ------------------------------------------------------------------------------------------------------------------
 usuario OS XXXXXX 01/01/2000 - 	
 Alteração:	Descrição da alteração.
Motivo:	Descrição do motivo.
 ------------------------------------------------------------------------------------------------------------------
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
ds_using_w		varchar2(25000);
nm_bind_w		varchar2(100);
nr_posicao_bind_w	pls_integer;
ds_valor_w		varchar2(500);

begin
ds_using_w := null;
-- se existir algum bind no comando sql
if	(bind_sql_comando_p.count > 0) then
	-- percorre todos os binds identificados no comando SQL e verifica seus respectivos valores
	for i in bind_sql_comando_p.first .. bind_sql_comando_p.last loop
		-- obtém o nome da bind do comando SQL
		nm_bind_w := bind_sql_comando_p(i);
		
		-- pesquisa o bind e se existir retorna a posição
		nr_posicao_bind_w := obter_index_bind(	bind_sql_valor_p, nm_bind_w);
		
		-- verifica se para o bind identificado dentro do comando SQL existe algum valor
		if	(nr_posicao_bind_w is not null) then
		
			if	(ds_using_w is not null) then
				ds_using_w := ds_using_w || ', ';
			end if;
			-- faz os tratamentos de acordo com a necessidade e o tipo de dado
			case bind_sql_valor_p(nr_posicao_bind_w).ie_tipo_valor
				when b_data then
					
					ds_valor_w := to_char(bind_sql_valor_p(nr_posicao_bind_w).dt_valor, 'DD/MM/YYYY');
					ds_using_w := ds_using_w || ' to_date(sys_context(''bind_var_sql_pck'', ''' || nm_bind_w || '''), ''DD/MM/YYYY'')';

				when b_data_hora then
					
					ds_valor_w := to_char(bind_sql_valor_p(nr_posicao_bind_w).dt_valor, 'DD/MM/YYYY HH24:MI:SS');
					ds_using_w := ds_using_w || ' to_date(sys_context(''bind_var_sql_pck'', ''' || nm_bind_w || '''), ''DD/MM/YYYY HH24:MI:SS'')';
				
				when b_hora then
					
					ds_valor_w := to_char(bind_sql_valor_p(nr_posicao_bind_w).dt_valor, 'HH24:MI:SS');
					ds_using_w := ds_using_w || ' to_date(sys_context(''bind_var_sql_pck'', ''' || nm_bind_w || '''), ''HH24:MI:SS'')';
					
				when b_number then
				
					-- tratamento para valores nulos e campos com formatação brasileira (tira primeiro ponto e depois vírgula vira ponto
					ds_valor_w := replace(replace(to_char(bind_sql_valor_p(nr_posicao_bind_w).vl_valor), '.', ''), ',', '.');
					ds_using_w := ds_using_w || 'nvl(sys_context(''bind_var_sql_pck'', ''' || nm_bind_w || '''), to_number(null))';
					
				when b_varchar then
					
					ds_valor_w := replace(bind_sql_valor_p(nr_posicao_bind_w).ds_valor, '''', '''''');
					ds_using_w := ds_using_w || 'sys_context(''bind_var_sql_pck'', ''' || nm_bind_w || ''')';
				else
					null;
			end case;
			-- atribui o valor para o contexto
			dbms_session.set_context( 'bind_var_sql_pck', nm_bind_w, ds_valor_w);
		else
			-- O valor da bind variable #@BIND#@ não foi informado. 
			wheb_mensagem_pck.exibir_mensagem_abort(290121,	'BIND=' || nm_bind_w);
		end if;
	end loop;
end if;
-- se teve valores acima, então acrescenta o using
if	(ds_using_w is not null) then
	ds_using_w := 'using ' || ds_using_w;
end if;

return ds_using_w;

end obter_using;

function executa_sql_cursor(	ds_sql_p		in varchar2,
				bind_sql_valor_p	in out sql_pck.t_dado_bind) 
				return sql_pck.t_cursor is
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Finalidade:	Recebe um comando sql e devolve um cursor pronto para receber um fetch
-------------------------------------------------------------------------------------------------------------------
Locais de chamada direta:
[X]  Objetos do dicionário [ ] Tasy (Delphi/Java) [  ] Portal [  ]  Relatórios [ ] Outros:
-------------------------------------------------------------------------------------------------------------------
Pontos de atenção:

Alterações:
 ------------------------------------------------------------------------------------------------------------------
 usuario OS XXXXXX 01/01/2000 - 	
 Alteração:	Descrição da alteração.
Motivo:	Descrição do motivo.
 ------------------------------------------------------------------------------------------------------------------
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
cursor_w		sql_pck.t_cursor;
tb_bind_w		sql_pck.t_varchar2_table_bind;
ds_using_w		varchar2(25000);

begin
-- retorna todas as binds do comando sql e armazena nesta table
tb_bind_w := obter_bind_sql(ds_sql_p);
-- passa de parâmetro as binds identificadas no comando SQL e o valor das mesmas
ds_using_w := obter_using(tb_bind_w, bind_sql_valor_p);

-- executa o comando SQL e retorna um cursor
-- o replace no ds_sql_p em relação as aspas é para tratar as situações do comando SQL do tipo and ie_situacao = 'A'
begin
	execute immediate 'begin open :cursor_w for ''' || replace(ds_sql_p, '''', '''''') || ''' ' || ds_using_w || '; end; ' using in out cursor_w;
	-- limpeza de memória
	tb_bind_w.delete;
	bind_sql_valor_p.delete;
	dbms_session.free_unused_user_memory;
	-- limpa o contexto
	dbms_session.clear_all_context('bind_var_sql_pck');
exception
when others then
	-- Se deu erro no comando, exibe o erro desta forma:
	-- #@SQLERRM#@:
	--#@COMANDO#@.
	wheb_mensagem_pck.exibir_mensagem_abort(290584,	'SQLERRM=' || sqlerrm(sqlcode) || ';' ||
							'COMANDO=' || substr(ds_sql_p, 1, 4000) || ';');
end;

return cursor_w;

end executa_sql_cursor;

function executa_sql_big_cursor(ds_sql_p		in varchar2,
				bind_sql_valor_p	in out sql_pck.t_dado_bind) 
				return sql_pck.t_cursor is
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Finalidade:	Recebe um comando sql e devolve um cursor pronto para receber um fetch
-------------------------------------------------------------------------------------------------------------------
Locais de chamada direta:
[X]  Objetos do dicionário [ ] Tasy (Delphi/Java) [  ] Portal [  ]  Relatórios [ ] Outros:
-------------------------------------------------------------------------------------------------------------------
Pontos de atenção:

Alterações:
 ------------------------------------------------------------------------------------------------------------------
 usuario OS XXXXXX 01/01/2000 - 	
 Alteração:	Descrição da alteração.
Motivo:	Descrição do motivo.
 ------------------------------------------------------------------------------------------------------------------
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
cursor_w		sql_pck.t_cursor;
tb_bind_w		sql_pck.t_varchar2_table_bind;
ds_sql_clob_w		varchar2(32000); --Foi usado o varchar2 com 32 mil caracteres, pois na versão 10G do oracle não suporte o CLOB no execute immediate
ds_using_w		varchar2(20000);

begin
-- retorna todas as binds do comando sql e armazena nesta table
tb_bind_w := obter_bind_sql(ds_sql_p);
-- passa de parâmetro as binds identificadas no comando SQL e o valor das mesmas
ds_using_w := obter_using(tb_bind_w, bind_sql_valor_p);
--Recebe o comando sql para a variável com 32 mil
ds_sql_clob_w	:= ds_sql_p;

-- executa o comando SQL e retorna um cursor
-- o replace no ds_sql_p em relação as aspas é para tratar as situações do comando SQL do tipo and ie_situacao = 'A'
begin
	execute immediate 'begin open :cursor_w for ''' || replace(ds_sql_clob_w, '''', '''''') || ''' ' || ds_using_w || '; end; ' using in out cursor_w;
	-- limpeza de memória
	tb_bind_w.delete;
	bind_sql_valor_p.delete;
	dbms_session.free_unused_user_memory;
exception
when others then
	-- Se deu erro no comando, exibe o erro desta forma:
	-- #@SQLERRM#@:
	--#@COMANDO#@.
	wheb_mensagem_pck.exibir_mensagem_abort(290584,	'SQLERRM=' || sqlerrm(sqlcode) || ';' ||
							'COMANDO=' || substr(ds_sql_p, 1, 4000) || ';');
end;

return cursor_w;

end executa_sql_big_cursor;

procedure executa_sql(	ds_sql_p		in varchar2,
			bind_sql_valor_p	in out sql_pck.t_dado_bind,
			ie_auto_commit_p	in varchar2 default 'S') is
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Finalidade:	Recebe um comando sql juntamente com seus binds e o executa
-------------------------------------------------------------------------------------------------------------------
Locais de chamada direta:
[X]  Objetos do dicionário [ ] Tasy (Delphi/Java) [  ] Portal [  ]  Relatórios [ ] Outros:
-------------------------------------------------------------------------------------------------------------------
Pontos de atenção:

Alterações:
 ------------------------------------------------------------------------------------------------------------------
 usuario OS XXXXXX 01/01/2000 - 	
 Alteração:	Descrição da alteração.
Motivo:	Descrição do motivo.
 ------------------------------------------------------------------------------------------------------------------
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
tb_bind_w		sql_pck.t_varchar2_table_bind;
ds_using_w		varchar2(25000);

begin
-- retorna todas as binds do comando sql e armazena nesta table
tb_bind_w := obter_bind_sql(ds_sql_p);
-- passa de parâmetro as binds identificadas no comando SQL e o valor das mesmas
ds_using_w := obter_using(tb_bind_w, bind_sql_valor_p);

-- executa o comando SQL e retorna um cursor
-- o replace no ds_sql_p em relação as aspas é para tratar as situações do comando SQL do tipo and ie_situacao = 'A'
begin
	execute immediate 'begin execute immediate ''' || replace(ds_sql_p, '''', '''''') || ''' ' || ds_using_w || '; end; ';
	-- se for para comitar automaticamente, comita
	if	(ie_auto_commit_p = 'S') then
		commit;
	end if;
	-- limpeza de memória
	tb_bind_w.delete;
	bind_sql_valor_p.delete;
	dbms_session.free_unused_user_memory;
	-- limpa o contexto
	dbms_session.clear_all_context('bind_var_sql_pck');
exception
when others then
	-- Se deu erro no comando, exibe o erro desta forma:
	
	-- #@SQLERRM#@:
	--#@COMANDO#@.
	wheb_mensagem_pck.exibir_mensagem_abort(290584,	'SQLERRM=' || sqlerrm(sqlcode) || ';' ||
							'COMANDO=' || substr(ds_sql_p, 1, 4000) || ';');
end;

end executa_sql;

end sql_pck;
/