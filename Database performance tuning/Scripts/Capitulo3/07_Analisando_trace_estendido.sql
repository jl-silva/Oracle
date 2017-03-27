-- *** IMPORTANTE:
--       Cursores abertos n�o s�o inclusos no trace
--       instrucoes como: set role, grant, alter user etc s�o truncadas com at� 25 caracteres 


-- *********	Generating an Event 10046 Trace for a Session   
-- desbloqueie o usuario HR, desconecte-se do BD e conecte-se com o usuario HR (senha hr)
alter user hr identified by hr account unlock;

-- execute a instrucao SQL abaixo para fazer I/O e carregar os dados na buffer cache (esse passo eh executado somente p/ permitir melhor comparacao entre as execucoes posteriores)
	select sum(salary) from hr.employees;

-- configure um identificador para o arquivo trace que sera gerado
	alter session set tracefile_identifier='10046';
	
-- inicie a geracao do trace de SQL
	alter session set events '10046 trace name context forever, level 12';
	
-- execute uma instrucao SQL
	select sum(salary) from hr.employees;

-- desabilite o trace de SQL
	alter session set events '10046 trace name context off';


-- DETALHES SOBRE O COMANDO alter session set events '10046 trace name context forever, level 12'
-- 		set events: Configura um evento Oracle especifico
-- 		10046: 		Especifica o evento de quando uma acao sera tomada
-- 		trace: 		O BD deve registrar a acao previamente configurada quando ela ocorrer
-- 		name: 		Indica o tipo de trace
-- 		context: 	Especifica que devera gerar um trace de contexto de uma instrucao SQL
-- 		forever: 	Ira sempre executar o trace para o evento especificado ate que o trace seja desabilitado. Sem forever, o trace eh executado apenas uma vez
--		level 12: 	Especifica o nivel do trace igual a 12, ou seja, deve capturar informacoes de bind e wait events


-- Para habilitar trace 10046 em outra sessao de usuario, execute:
    execute dbms_monitor.session_trace_enable(session_id=>&sid,serial_num=>&serial,waits=>true,binds=>true);
	
-- Observacao: antes de ler o arquivo trace, formate-o usando o TKPROF (sys=no filtra sql recursivo no DD):
	tkprof trace_file result_file.txt sys=no
  -- tkprof orcl_ora_3838_10046.trc result_file.txt sys=no
  -- sys = no não mostra os selects recursivos (executados pelo oracle)
    
-- ver se existem sess�es com trace habilitado
SELECT * FROM DBA_ENABLED_TRACES;

-- para localizar facilmente a pasta onde o arquivo de trace foi gerado execute o comando abaixo:
show parameter user_dump_dest
