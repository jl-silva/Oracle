-- *** NAO ACONSELHO DESABILITAR O JOB DE COLETA AUTOMATICA. Mude-o p/ coletar no MINIMO as ESTATISTICAS DE OBJETOS DO DD:
EXEC DBMS_STATS.GET_GLOBAL_PREFS('AUTOSTATS_TARGET', 'ORACLE');
-- Se vc ja tem um job para efetuar coleta manual de estatisticas, acrescente nele o comando abaixo:
EXEC DBMS_STATS.GATHER_DICTIONARY_STATS();



-- coleta de estatisticas de padrao (baseada em amostragem)
BEGIN
  DBMS_STATS.GATHER_SCHEMA_STATS (
    ownname          => UPPER('&SCHEMA_NAME'),    
    cascade          => TRUE,
    options          => 'GATHER AUTO'); -- o oracle implicitamente determina quais objetos precisam de coleta de estatitiscas e como fazer essa coleta    
END;

-- coleta de estatisticas completa (demora em media 3 a 4 vezes mais que a anterior , mas as estatisticas sao PRECISAS)
BEGIN
  DBMS_STATS.GATHER_SCHEMA_STATS (
    OWNNAME             => UPPER('&SCHEMA_NAME'),
    ESTIMATE_PERCENT   => 100 , -- a opcao default DBMS_STATS.AUTO_SAMPLE_SIZE pode melhor tempo de coleta e produz resultado satisfatorio no 11G 
    CASCADE          => TRUE,
    options          => 'GATHER'); -- coleta estatisticas de todos os objetos
END;

-- coleta de estatisticas completa utilizando paralelismo
BEGIN
  DBMS_STATS.GATHER_SCHEMA_STATS (
    OWNNAME             => UPPER('&SCHEMA_NAME'),
    ESTIMATE_PERCENT    => 100, -- a opcao default DBMS_STATS.AUTO_SAMPLE_SIZE pode melhor tempo de coleta e produz resultado satisfatorio no 11G 
    DEGREE              => 2, -- este parametro permite utilizar paralelismo
    CASCADE             => TRUE,
    options             => 'GATHER'); -- coleta estatisticas de todos os objetos
END;

-- Coletando estatisticas de uma tabela:
EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>'ECOMMERCE', TABNAME=>'PEDIDO');  

-- Coletando estatisticas estimadas (20%) de um schema:
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('ECOMMERCE', estimate_percent=> 20);

-- Coletando estatisticas de todo o banco de dados: 
EXEC DBMS_STATS.GATHER_DATABASE_STATS;
  
-- Coletando estatisticas do dicionario de dados: 
EXEC DBMS_STATS.GATHER_DICTIONARY_STATS;
