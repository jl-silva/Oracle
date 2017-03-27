-- Executar show parameter ou SELECT * FROM V$PARAMETER e verificar valores de parametros da instancia
SHOW PARAMETER

/*
-- verificar principais parametros que influnciam na performance do BD

	- db_block_size 
		Ver tamanho de blocos de dados. Para leitura bloco maior eh melhor. Para gravacao bloco menor eh melhor, pois evita-se hot blocks ou contencao de dados.
		Tamanho default: 8kb

	- fast_start_mttr_target
		Determina valor em segundos de MTTR (mean time to recover). Deve ser configurado se for desejado minimizar riscos de perdas de dados no caso de um crash do BD.
		Sua configuracao inadequada (valor muito baixo) pode gerar muito logfiles com pouco conteudo e degradar performance do BD.
		Se for configurado, ressete log_checkpoint_interval (default 0), log_checkpoint_timeout (default 1800) e fast_start_io_target.
			
	- db_file_multiblock_read_count
		Ver qtde em kb de dados que podem ser lido a cada requisicao de acesso aos dados. Valor menor favore IS. Valor maior favorece FTS.
		A partir do 10G este parece Eh auto-tunado, mas o auto-tuning nao Eh muito bom para OLTP (fica em torno de 128 e por isso favorece FTS).
	
	- memory_max_target, memory_target
		Sao utilizados quando configura-se AMM (Automatic Memory Management), onde tamanho de memoria da SGA e PGA sao gerenciadas atravEhs de um soh parametro. 
		Eh bom para ambientes mistos, porEhm nao funciona com HUGE Pages (so unix, linux)		
	
	- sga_max_size, sga_target
		Sao utilizados quando configura-se ASMM (Automatic Shared Memory Management), onde tamanho das subdivisoes de memoria da SGA sao gerenciadas atraves de um soh parametro.
		Permite isolar gerenciamento da SGA e PGA e permite configurar Huge Pages
		Sao ignorados se AMM esta configurado.
		
	- pga_aggregate_target
		Configura tamanho maximo da PGA.
		Eh ignorado se AMM esta configurado.
		
	- db_cache_size
		Permite configurar tamanho da buffer cache (para o tamanho de bloco padrao, configurado em db_block_size) com gerenciamento manual de memoria ou tamanho minimo dela se estiver usando AMM ou ASMM.
		
	-  db_2k_cache_size, db_4k_cache_size, db_8k_cache_size, db_16k_cache_size, db_32k_cache_size
		Permitem configurar memoria para blocos diferentes do padrao (ver db_block_size) para o BD.
		Eles nao sao autogerenciaveis, portanto, se forem configurados devem ser muito bem dimensionados.
	
	- buffer_pool_keep
		Dentro da buffer cache, configura area para manter dados em memoria que nao sao gerenciados pelo algoritmo LRU.
		Nao Eh autogerenciavel, portanto, se for configurado devem ser muito bem dimensionado.

	- buffer_pool_recycle
		Dentro da buffer cache, configura area para NaO manter dados em memoria.
		Nao Eh autogerenciavel, portanto, se for configurado devem ser muito bem dimensionado.
		
	- shared_pool_size
		Permite configurar tamanho da shared pool com gerenciamento manual de memoria ou tamanho minimo dela se estiver usando AMM ou ASMM.

	- shared_pool_reserved_size
		 Deve ser configurado para armazenar dados de grandes requisicoes de armazenamento na shared pool. Usa-lo reduz fragmentacao na Shared Pool.
		 Valor default Eh de 5% da shared pool.
	
	- large_pool_size
		Permite configurar tamanho da large pool com gerenciamento manual de memoria ou tamanho minimo dela se estiver usando AMM ou ASMM.
	
	- result_cache_max_result, result_cache_max_size, result_cache_mode
		Permite configurar cache de resultados para otimizar leituras. Dados ficam em uma area dentro da shared pool, ao invEhs de ficarem na buffer cache.
		Se configurados, devem ser muito bem gerenciados.
		Valores possiveis para result_cache_mode: force e manual (padrao)		
		
	- log_buffer
		Parametro que possui algoritmo interno para determinar tamanho do buffer de log. Se tamanho default for pequeno Eh possivel aumenta-lo.	
        
	- optimizer_mode
		Modo em que o otimizador trabalha para recuperar linhas. Valor ALL_ROWS favore FTS. Valor FIRST_ROWS favorece IS.
		
	- CURSOR_SHARING
		Permite determinar se BD usara ou nao cursores compartilhados. Valores possiveis: FORCE e EXACT (padrao).
		
	- OPTIMIZER_INDEX_CACHING
		Indica percentual de indices em cache. Valores mais altos favorecem operacoes IS, nested loop joins e interacoes em operadores IN. Valores mais baixos favorecem operacoes de FTS, hash joins ou sort merge joins. 
		
	- OPTIMIZER_INDEX_COST_ADJ
		Indica o custo de usar indices. Valores baixos favorecem IS. Valores altos favorecem FTS. 
		Valores permitidos: entre 0 e 10000 (default - 100)