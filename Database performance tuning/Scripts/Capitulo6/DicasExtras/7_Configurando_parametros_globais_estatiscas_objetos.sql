-- GLOBAL: 		PARA TODOS OBJETOS QUE NAO TEM VALORES PREDEFINIDOS
-- DATABASE: 	PARA TODOS OBJETOS QUE POSSUEM VALORES PREDEFINIDOS (ESPECIFICADOS PREVIAMENTE NO NIVEL DO OBJETO)
    

-- configurando percentual de linhas a serem analisadas para a coleta de estatisticas
BEGIN
    DBMS_STATS.SET_GLOBAL_PREFS('ESTIMATE_PERCENT','80'); -- valor permitido entre 1 e 100 + constante DBMS_STATS.AUTO_SAMPLE_SIZE (default)
END;

-- configurando paralelismo
BEGIN
    DBMS_STATS.SET_GLOBAL_PREFS('DEGREE','4');  -- ver CPU_COUNT
END;

-- configurando percentual de linhas que foram alteradas (linhas desatualizadas) para permitir atualizacao
BEGIN
    DBMS_STATS.SET_GLOBAL_PREFS('STALE_PERCENT','20'); 
END;

-- coletar estatisticas de objetos dependentes (indices)
BEGIN
	DBMS_STATS.SET_GLOBAL_PREFS('CASCADE', 'true');
END;


-- coletar estatisticas de tabelas particionadas em modo incremental, ou seja, somente particoes que tiveram alteracoes (ver ganho de tempo em http://structureddata.org/2008/07/16/oracle-11g-incremental-global-statistics-on-partitioned-tables/)
BEGIN
	DBMS_STATS.SET_GLOBAL_PREFS('INCREMENTAL', 'true');
END;

-- para reduzir o tempo de tabelas particionadas, habilte coleta de estatisticas concorrentes (cria multiplos scheduler jobs para fazer a coleta em cada particao concorrentemente ) 
begin
	dbms_stats.set_global_prefs('CONCURRENT','TRUE');  -- util para table
end;
    
-- configurando somente coleta de objetos do DD
BEGIN
	DBMS_STATS.SET_GLOBAL_PREFS('AUTOSTATS_TARGET','ORACLE');
END;