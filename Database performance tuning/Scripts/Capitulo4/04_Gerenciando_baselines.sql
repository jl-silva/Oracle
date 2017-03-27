-- criando baseline fixo a partir de snapshots existentes
BEGIN
	dbms_workload_repository.create_baseline(
		start_snap_id => &start_snap_id,
		end_snap_id => &end_snap_id,
		baseline_name=>'&baseline_name',
		expiration=>30);  -- tempo de expiracao em dias (NULL nao expira)
END;
		
-- criando baseline fixo a partir de um periodo 
BEGIN
	dbms_workload_repository.create_baseline( 
			start_time=>to_date('11/02/17 14:00:11','dd/mm/yy:hh24:mi:ss'),
			end_time=>to_date('11/02/17 15:00:14','dd/mm/yy:hh24:mi:ss'),
			baseline_name=>'&baseline_name',
			expiration=>30);
END;

-- NO 11G foi criado o conceito de baseline de janela flutuante que eh usado para calcular metricas adaptaveis. O tamanho default dessa janela eh igual ao periodo de retencao do AWR

-- consultar baselines criados (fixo e flutuante)
SELECT    baseline_name, start_snap_id start_id,
          TO_CHAR(start_snap_time, 'yyyy-mm-dd:hh24:mi') start_time,
          end_snap_id end_id,
          TO_CHAR(end_snap_time, 'yyyy-mm-dd:hh24:mi') end_time,
          expiration
FROM      DBA_HIST_BASELINE
ORDER BY  baseline_id;

-- RENOMEAR BASELINE
exec dbms_workload_repository.rename_baseline('&nome_anterior','&nome_novo');

--APAGAR BASELINE
exec dbms_workload_repository.drop_baseline('&nome_baseline');



-- alterando baseline flutuante (metricas acumuladas dos snapshots no periodo configurado)
exec dbms_workload_repository.modify_baseline_window_size(30); -- valor em dias, recomendacao eh deixar igual ao periodo de retencao de snapshots do AWR

-- verificar as metricas do baseline flutuante
SELECT 		metric_name, average, maximum 
FROM		(	SELECT * 
				FROM TABLE(DBMS_WORKLOAD_REPOSITORY.select_baseline_metric('SYSTEM_MOVING_WINDOW')))
WHERE 		LOWER(METRIC_NAME) LIKE '%read%'
order by 	metric_name;

