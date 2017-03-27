@domtab :nome tabela  = Busca todos dominios na tabela informada
 
@dom :numero do dominio = Busca os valores do dominio informado

@desc tabela = lista campos da tabela em ordem alfabetica
/*set linesize 400;
set pagesize 300;
set verify off;
select	substr(upper(column_name),1,200) Campo,
	decode(nullable,'Y','','NOT NULL') "Nulo?",
	(substr(data_type,1,30) ||
	 to_char(decode(data_precision,null,
			decode(data_type,'DATE','','LONG','','(' || data_length || ')'),
			'(' || data_precision ||
			decode(data_scale,0,'',',' || data_scale) || ')')))  "TIPO/TAMANHO"
from	user_tab_columns
where	upper(table_name) = upper('&1')
order by
	column_name;
set pagesize 10;
set linesize 100;*/

@integridade tabela = lista as relações da tabela
/*
select	substr(a.nm_tabela,1,25) tabela,
	substr(a.nm_tabela_referencia,1,25) tabela_referencia,
	substr(b.nm_atributo,1,25) atributo
from	integridade_referencial a,
	integridade_atributo b
where	a.nm_tabela = b.nm_tabela
and	a.nm_integridade_referencial = b.nm_integridade_referencial
and	lower(a.nm_tabela) = lower('&1')
order by	a.nm_tabela_referencia;
-- Script By Luiz FM
*/

@format para formatar a ultima busca
/*
set pages 2000
set lines 800
*/

@obj function/procedure = verifica o sql
/*select text from user_source
where name = upper('&nm_objeto')
/*/

Enviar um exec colocar = exec nome_function('parametro1','parametroN');

consulta de FK = select * from user_constraints where constraint_name like 'PLSAFLO%';

http://blog.gaudencio.net.br/2012/11/oracle-comandos-basicos-sqlplus.html