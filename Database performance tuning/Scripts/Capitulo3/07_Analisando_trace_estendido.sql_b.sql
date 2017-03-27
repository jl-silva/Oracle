-- EXECUTE BLOCO 1 E VERIFIQUE O TEMPO DE EXECUCAO

-- ******** INICIO BLOCO 1 ***********
  alter session set db_file_multiblock_read_count = 8;
  
-- configure um identificador para o arquivo trace que sera gerado
	alter session set tracefile_identifier='block8';
	
-- inicie a geracao do trace.
	alter session set events '10046 trace name context forever, level 12';
	
-- execute uma instrucao SQL
	select sum(salary) from hr.employees;

-- desligue o trace
	alter session set events '10046 trace name context off';
-- ******** FIM BLOCO 1 ***********

-- DESCONECTE A SESSAO, CONECTE DE NOVO, EXECUTE O BLOCO 2 E VERIFIQUE O TEMPO DE EXECUCAO    

-- ******** INICIO BLOCO 2 ***********
  alter session set db_file_multiblock_read_count = 128;
  
-- configure um identificador para o arquivo trace que sera gerado
	alter session set tracefile_identifier='block128';
	
-- inicie a geração do trace.
	alter session set events '10046 trace name context forever, level 12';
	
-- execute uma instrução SQL
	select sum(salary) from hr.employees;

-- desligue o trace
	alter session set events '10046 trace name context off';
-- ******** FIM BLOCO 2 ***********    


-- COMPARE O TEMPO DE EXECUCAO COM O BLOCO 1 E RESPONDA AS QUESTOES ABAIXO:
1- QUAL TEMPO DE EXECUCAO FOI MELHOR?
2- QUAL VALOR DE db_file_multiblock_read_count VC CONFIGURARIA PARA UM BD OLTP?
