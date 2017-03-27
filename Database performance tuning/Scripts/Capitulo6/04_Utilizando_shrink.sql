-- Habilitando ROW MOVEMENT
ALTER TABLE SOE.PRODUCT_INFORMATION ENABLE ROW MOVEMENT;

-- Executando SHRINK sem ajustar a marca dagua
ALTER TABLE SOE.PRODUCT_INFORMATION SHRINK SPACE COMPACT;

-- Executando SHRINK ajustando a marca dagua
ALTER TABLE SOE.PRODUCT_INFORMATION SHRINK SPACE;

-- Executando SHRINK tambem nos objetos dependentes  
ALTER TABLE SOE.PRODUCT_INFORMATION SHRINK SPACE CASCADE;

-- avaliar objetos que contem blocos vazios (candidatos para o shrink)
    -- a) analise o objeto 
        ANALYZE TABLE &schema.&tabela COMPUTE STATISTICS;
        
    -- b) verifique qtde blocos vazios
    select  blocks "Blocos Usados", empty_blocks "Blocos vazios", num_rows "Total de Linhas" 
    from    dba_tables 
    where   OWNER = '&schema'
    AND     table_name='&tabela';

    -- c) Executar DBMS_STATS apos ANALYZE TABLE


-- script para efetuar SHRINK em todas as tabelas e objetos dependentes de um determinado SCHEMA
SET SERVEROUTPUT ON
DECLARE
	v_schema VARCHAR2(30) := '&schema_name';
BEGIN
    DBMS_OUTPUT.ENABLE(NULL);
	-- habilita ROW MOVEMENT EM OBJETOS QUE AINDA NAO possuem este recursos habilitado
    FOR CUR_TAB IN (    SELECT  'ALTER TABLE ' || OWNER || '.' || TABLE_NAME || ' ENABLE ROW MOVEMENT' AS CMD,
                        OWNER, TABLE_NAME
                        FROM    ALL_TABLES
                        WHERE   OWNER = UPPER('&&SCHEMA_NAME')
                        AND     IOT_NAME IS NULL
                        AND     IOT_TYPE IS NULL
                        AND     STATUS = 'VALID'
                        AND     TABLE_NAME NOT LIKE 'DR$%'
                        AND     ROW_MOVEMENT = 'DISABLED'
						AND		OWNER = v_schema)
    LOOP
        BEGIN
            EXECUTE IMMEDIATE cur_tab.CMD;
            dbms_output.put_line(cur_tab.OWNER || '.' || cur_tab.TABLE_NAME || ' ENABLE ROW MOVEMENT OK!');
        EXCEPTION
            WHEN OTHERS THEN
                dbms_output.put_line(SQLERRM);
        END;
    END LOOP;
    
	-- efetua SHRINK CASCADE nos objetos
    FOR CUR_TAB2 IN (   SELECT  'ALTER TABLE ' || OWNER || '.' || TABLE_NAME || ' SHRINK SPACE CASCADE' AS CMD,
                                OWNER, TABLE_NAME
                        FROM    ALL_TABLES
                        WHERE   OWNER = UPPER('&SCHEMA_NAME')
                        AND     IOT_NAME IS NULL
                        AND     IOT_TYPE IS NULL
                        AND     STATUS = 'VALID'
                        AND     TABLE_NAME NOT LIKE 'DR$%'
						AND		OWNER = v_schema)
    LOOP
        BEGIN
            EXECUTE IMMEDIATE cur_tab2.CMD;
            dbms_output.put_line(cur_tab2.OWNER || '.' || cur_tab2.TABLE_NAME || ' SHRINK SPACE CASCADE OK!');
        EXCEPTION
            WHEN OTHERS THEN
                dbms_output.put_line(cur_tab2.OWNER || '.' || cur_tab2.TABLE_NAME || ' - ' || SQLERRM);
        END;
    END LOOP;
END;


