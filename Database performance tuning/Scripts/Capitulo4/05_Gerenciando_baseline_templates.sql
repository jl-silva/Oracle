-- ver templates existentes:
SELECT  template_name, baseline_name_prefix prefix,
        to_char(start_time,'mm/dd/yy:hh24') start_time,
        to_char(end_time,'mm/dd/yy:hh24') end_time,
        substr(day_of_week,1,3) day, hour_in_day hr, duration dur, expiration exp,
        to_char(last_generated,'mm/dd/yy:hh24') last
FROM    dba_hist_baseline_template;

-- criando um baseline template (baseia-se em periodos futuros) com baselines renovaveis.
-- Neste caso, o baseline sera toda quarta das 8h as 17h e tera expiracao apos 365 dias
-- Informar periodo (data inicio e fim) de criacao do baseline
 begin
	DBMS_WORKLOAD_REPOSITORY.create_baseline_template(
				day_of_week => 'WEDNESDAY', -- dia da semana em q o baseline ira se repetir (ex.: ALL, MONDAY - SYNDAY)
				hour_in_day => 8, -- hora do dia em q o baseline ira iniciar 
				duration => 9, -- duracao em horas do baseline
				start_time =>  to_date('&data_inicio','dd/mm/yyyy hh24:mi:ss'), -- hora inicio de criacao do baseline ou momento em que ele sera ativado
				end_time =>  to_date('&data_fim','dd/mm/yyyy hh24:mi:ss'), -- hora fim de criacao do baseline ou momento em que ele sera desativado
				baseline_name_prefix => 'Baseline_Teste_', -- nome do SUFIXO do baseline (nome eh composto de sufixo + data)
				template_name => 'Template_Teste', -- nome do template
				expiration => 365); -- expiracao em dias (null nao expira) do baseline
end;

-- ver baselines existentes
SELECT * FROM DBA_HIST_BASELINE;

-- ver informacoes do baseline (informando baseline id)
SELECT * FROM TABLE(dbms_workload_repository.select_baseline_details(1));

-- ver metricas de um baseline (informando baseline name)
SELECT * FROM TABLE(dbms_workload_repository.select_baseline_metric('&baseline_name'));
				
-- apagar baseline template (cascade=false nao apaga snapshots relacionados aos baselines gerados)
BEGIN
    DBMS_WORKLOAD_REPOSITORY.DROP_BASELINE (baseline_name => '&baseline_template', cascade => FALSE); 
END;
				
	
