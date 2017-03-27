create or replace PACKAGE BODY  PKG_ESTATISTICAS AS
        
    FUNCTION FC_RETORNA_METRICAS_PRINCIPAIS return TABLE_METRIC_TYPE PIPELINED        
    IS      
      VAR_LINHA ROW_METRIC_TYPE;
    begin
        FOR CUR_ROW IN (  
                      SELECT  metric_name,
                              value,
                              metric_unit
                      FROM    (        SELECT     metric_name, 
                                                  value,
                                                  metric_unit                                                  
                                        from      v$sysmetric
                                        where     metric_name IN ('Buffer Cache Hit Ratio','Host CPU Utilization (%)', 'Network Traffic Volume Per Sec', 'Logical Reads Per Sec',
                                                                            'SQL Service Response Time','PGA Cache Hit %','Current OS Load','Average Active Sessions', 'Shared Pool Free %')
                                        and       group_id = 2                                       
                              )
                    )
        LOOP            
            VAR_LINHA.METRICA := CUR_ROW.metric_name;
            VAR_LINHA.VALOR := (CASE CUR_ROW.metric_name 
                                          WHEN 'Network Traffic Volume Per Sec' THEN round(CUR_ROW.value / 1024 /1024,2) 
                                          WHEN 'Logical Reads Per Sec' THEN ROUND((CUR_ROW.value / 131072) * 1024,2)
                                          ELSE round(CUR_ROW.value,2) END);
            VAR_LINHA.valor_referencia := 
                                CASE   CUR_ROW.metric_name
                                                                when 'Buffer Cache Hit Ratio' then '>= ' || lpad(to_char(v_bc_ratio),8)
                                                                when 'Host CPU Utilization (%)' then '< ' || lpad(to_char(v_cpu_utilization),8)
                                                                when 'Network Traffic Volume Per Sec' then '< ' || lpad(to_char(v_network_traffic),8)
                                                                when 'SQL Service Response Time' then '< ' || lpad(to_char(v_sql_response),8)
                                                                when 'PGA Cache Hit %' then '>= ' || lpad(to_char(v_pga_ratio),8)
                                                                when 'Current OS Load' then '<= ' || lpad(to_char(v_os_load),8)
                                                                when 'Average Active Sessions' then '<= ' || lpad(to_char(v_active_sessions),8)
                                                                when 'Shared Pool Free %' then '>= ' || lpad(to_char(v_sp_free),8)
                                                                when 'Logical Reads Per Sec' then '<= ' || lpad(to_char(v_lio),8)
                                                                else null
                                END;              
            VAR_LINHA.UNIDADE_METRICA := (CASE CUR_ROW.metric_name 
                                              WHEN 'Logical Reads Per Sec' THEN 'MBytes Per Second'
                                              WHEN 'Network Traffic Volume Per Sec' THEN 'MBytes Per Second' ELSE CUR_ROW.metric_unit END);
            VAR_LINHA.STATUS := (CASE  CUR_ROW.metric_name
                                                      when 'Buffer Cache Hit Ratio' then (CASE when CUR_ROW.value >= v_bc_ratio then 'BOM' else '** RUIM **' end)
                                                      when 'Host CPU Utilization (%)' then (CASE when CUR_ROW.value < v_cpu_utilization then 'BOM' else '** RUIM **' end)
                                                      when 'Network Traffic Volume Per Sec' then (CASE WHEN (CUR_ROW.value / 1024 /1024) < v_network_traffic then 'BOM' else '** RUIM **' end)
                                                      when 'SQL Service Response Time' then (CASE WHEN CUR_ROW.value < v_sql_response then 'BOM' else '** RUIM **' end)
                                                      when 'PGA Cache Hit %' then (CASE WHEN CUR_ROW.value >= v_pga_ratio then 'BOM' else '** RUIM **' end)
                                                      when 'Current OS Load' then (CASE WHEN CUR_ROW.value <= v_os_load then 'BOM' else '** RUIM **' end)
                                                      when 'Average Active Sessions' then (CASE WHEN CUR_ROW.value <= v_active_sessions then 'BOM' else '** RUIM **' end)
                                                      when 'Shared Pool Free %' then (CASE WHEN CUR_ROW.value >= v_sp_free then 'BOM' else '** RUIM **' end)                                                      
                                                      when 'Logical Reads Per Sec' then (CASE WHEN ((CUR_ROW.value / 131072) * 1024) <= v_lio then 'BOM' else '** RUIM **' end)
                                                      else null
                                  END);
            
            PIPE ROW(VAR_LINHA);  
        END LOOP;
        RETURN;
    END FC_RETORNA_METRICAS_PRINCIPAIS;
        
    FUNCTION FC_RETORNA_TOP_SQL return TABLE_SQL_TYPE PIPELINED 
     IS
        VAR_LINHA ROW_SQL_TYPE;        
    BEGIN
        FOR CUR_ROW IN (
                          SELECT  *
                          FROM    (SELECT           /*+ ALL_ROWS */                                                    
                                                    a.sid,                    
                                                    a.username,
                                                    (b.elapsed_time/(1000000)) / b.executions as avg_elapsed_time_sec,
                                                    substr(b.sql_text,1,4000) sql_text
                                    FROM            V$SESSION A
                                    inner join      v$sql b
                                        on          a.sql_address = b.address
                                    WHERE           A.USERNAME IS NOT NULL
                                    AND             A.STATUS = 'ACTIVE'
                                    AND             b.elapsed_time > 0
                                    AND             b.executions > 0)
                          WHERE     avg_elapsed_time_sec >= v_sql_response                          
                        )
        LOOP            
            VAR_LINHA.SID := CUR_ROW.SID;
            VAR_LINHA.username := CUR_ROW.USERNAME;
            VAR_LINHA.avg_elapsed_time_sec := CUR_ROW.avg_elapsed_time_sec;
            VAR_LINHA.sql_text := CUR_ROW.sql_text;            
            PIPE ROW(VAR_LINHA);
        END LOOP;
    
    END FC_RETORNA_TOP_SQL;
    
     --BLOCO DE INICIALIZACAO
    BEGIN      
      SELECT  a.instance_name INTO v_nome_bd
      from    v$instance a;
END PKG_ESTATISTICAS;
/

create public synonym PKG_ESTATISTICAS FOR PKG_ESTATISTICAS;
