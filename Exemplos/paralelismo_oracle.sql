	Bom dia,

	Criar um parâmetro na OPS - Gestão de Operadoras > Parâmetros OPS > Informações ANS > ANS > "Habilitar geração de arquivos em paralelo" (padrão 'N').
	Este parâmetro deve ser documentado no shift+f8 para que apenas seja habilitado caso o cliente possua versão do Oracle 11g ou superior, seja Enterprise e a Package DBMS_PARALLEL_EXECUTE esteja liberada para uso pelo usuário Tasy. Caso contrário não será possível utilizar o parâmetro.
	Na rotina pls_gerar_arq_monit_ans_utf, quando não for passado nenhum valor no parâmetro nr_seq_arquivo_p e o parâmetro criado estiver como 'S' ao invés de abrir o cursor e processar a rotina, iremos utilizar os comandos abaixo para startar várias execuções em paralelo da rotina.

	-- Primeiro passo criar uma Task
	DBMS_PARALLEL_EXECUTE.create_task (task_name => passar um nome para a task);

	-- segundo passo alimentar os parâmetros das tasks
	DBMS_PARALLEL_EXECUTE.create_chunks_by_sql(task_name => passar o nome da task criada acima,
	sql_stmt  => 'select nr_seq_lote_monitor lote_p, ' || nm_usuario_p || ' usuario_p, nr_sequencia arquivo_p from pls_monitor_tiss_arquivo where nr_seq_lote_monitor = ' || passar o parâmetro da sequencia do lote (nr_seq_lote_p),
	by_rowid  => FALSE);
	
	-- terceiro ao fim da execução a task precisa ser dropada
	exec DBMS_PARALLEL_EXECUTE.drop_task(passar o nome da task);
	
	Desenvolver conforme documentado acima e realizar testes na base de desenvolvimento da Rio Preto.


DECLARE
  l_sql_stmt 		VARCHAR2(32767);
  nr_seq_lote_p		pls_monitor_tiss_arquivo.nr_seq_lote_monitor%type;
BEGIN
-- alimentar com o número do lote
nr_seq_lote_p := 164;

l_sql_stmt :=q'[begin pls_gerar_arq_monit_ans_utf(:start_id,:end_id);end;]';

DBMS_PARALLEL_EXECUTE.create_task (task_name => 'test_task');

DBMS_PARALLEL_EXECUTE.create_chunks_by_sql(	task_name => 'test_task',
						sql_stmt  => 'select nr_seq_lote_monitor start_id, nr_sequencia end_id from pls_monitor_tiss_arquivo where nr_seq_lote_monitor = ' || nr_seq_lote_p,
						by_rowid  => FALSE);

DBMS_PARALLEL_EXECUTE.run_task(	task_name      => 'test_task',
				sql_stmt       => l_sql_stmt,
				language_flag  => DBMS_SQL.NATIVE,
				parallel_level => 43);

commit;
END;
/

exec DBMS_PARALLEL_EXECUTE.create_task (task_name => 'test_task');

exec DBMS_PARALLEL_EXECUTE.drop_task('test_task');

exec DBMS_PARALLEL_EXECUTE.create_chunks_by_sql(task_name => 'test_task',
						sql_stmt  => 'select nr_seq_lote_monitor start_id, nr_sequencia end_id from pls_monitor_tiss_arquivo where nr_seq_lote_monitor = 164',
						by_rowid  => FALSE);

exec DBMS_PARALLEL_EXECUTE.create_chunks_by_sql(task_name => 'test_task',
						sql_stmt  => 'select  nr_seq_lote_monitor start_id, nr_sequencia end_id from  pls_monitor_tiss_arquivo where  nr_seq_lote_monitor = 164 and nr_sequencia = 2131',
						by_rowid  => FALSE);

/

DECLARE
  l_sql_stmt VARCHAR2(32767);
BEGIN
  l_sql_stmt :=q'[begin process_test_tab(:end_id,:start_id);end;]';

  DBMS_PARALLEL_EXECUTE.run_task(task_name      => 'analise',
                                 sql_stmt       => l_sql_stmt,
                                 language_flag  => DBMS_SQL.NATIVE,
                                 parallel_level => 5);
				 
 commit;
END;
/

exec DBMS_PARALLEL_EXECUTE.create_task (task_name => 'analise');

exec DBMS_PARALLEL_EXECUTE.drop_task('analise');

exec DBMS_PARALLEL_EXECUTE.create_chunks_by_sql(task_name => 'analise',sql_stmt  => 'SELECT nr_seq_analise start_id, nr_sequencia end_id FROM pls_cta_analise_cons ',by_rowid  => FALSE);

create table test_tab (num_col number(10), session_id number(10),session_id2 number(10), dt_reg date);


create or replace
procedure process_test_tab (start_id number, end_id number) is 

begin

insert into test_tab (num_col,session_id,dt_reg,session_id2) values (start_id,end_id,sysdate,SYS_CONTEXT('USERENV','SESSIONID'));

commit;

end process_test_tab;
/

