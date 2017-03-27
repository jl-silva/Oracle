-- vendo o uso do AWR 
SELECT  name,
        detected_usages,
        currently_used,
        TO_CHAR(last_sample_date,'DD-MON-YYYY:HH24:MI') last_sample
FROM    dba_feature_usage_statistics
WHERE   name = 'AWR Report' ;


-- executar no sqlplus os scripts abaixo, fornecendo os valores de entrada solicitados

-- AWR Report
	SQL > @?/rdbms/admin/awrrpt.sql

-- AWR Compare Report (compara somente periodos iguais):
	SQL > @?/rdbms/admin/awrddrpt.sql
    
    
-- Dica: para efetuar comparacao com um baseline, recupere os snapshots IDs dele.    
	
