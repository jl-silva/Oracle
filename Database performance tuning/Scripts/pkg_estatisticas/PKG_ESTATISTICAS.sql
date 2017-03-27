create or replace PACKAGE  PKG_ESTATISTICAS AS 
    v_nome_bd V$INSTANCE.instance_name%type;
    
    -- preencher valores abaixo conforme medias do BD que vc administra ou valores desejados que vc deseja alcancar
    v_bc_ratio NUMBER:= 90;             -- buffer cache hit ratio desejado
    v_cpu_utilization NUMBER := 30;     -- uso maximo de cpu desejado
    v_network_traffic NUMBER := 50;     -- maximo de trafego de rede desejado
    v_sql_response NUMBER := 2;         -- tempo maximo de resposta de um SQL desejado
    v_pga_ratio number := 90;           -- pga hit ratio desejado
    v_os_load NUMBER := 4;              -- carga de sistema operacional maxima desejada
    v_active_sessions NUMBER := 8;      -- media de sessoes ativas
    v_sp_free NUMBER := 10;             -- % da shared pool livre desejado
    v_lio NUMBER := 1000;               -- maximo de I/O logico desejado
    
    -- declaracao de row types p/ uso em PTF
    TYPE ROW_METRIC_TYPE IS RECORD (
                                  BD                v$instance.instance_name%type,
                                  METRICA           v$sysmetric.metric_name%type,
                                  VALOR             number(10,2),
                                  VALOR_REFERENCIA  VARCHAR2(15),
                                  UNIDADE_METRICA   v$sysmetric.metric_unit%type,
                                  STATUS            varchar2(11)
                                  );

    TYPE ROW_SQL_TYPE IS RECORD ( BD                    v$instance.instance_name%type,
                                  SID                   V$SESSION.SID%type,
                                  username              V$SESSION.username%type,
                                  avg_elapsed_time_sec  NUMBER(10),
                                  sql_text              VARCHAR2(4000)
                                  );                                  
    
    -- declaracao de table types p/ uso em PTF
    TYPE TABLE_METRIC_TYPE IS TABLE OF ROW_METRIC_TYPE;
    
    TYPE TABLE_SQL_TYPE IS TABLE OF ROW_SQL_TYPE;
    
    -- declaracao das funcoes PTF
    FUNCTION FC_RETORNA_METRICAS_PRINCIPAIS return TABLE_METRIC_TYPE PIPELINED;
    
    FUNCTION FC_RETORNA_TOP_SQL return TABLE_SQL_TYPE PIPELINED;
    
END PKG_ESTATISTICAS;
/