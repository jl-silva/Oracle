CREATE TABLE REPOSITORY_METADATA
  (
    TX_OBJECT_DDL CLOB,
    NM_SCHEMA VARCHAR2(30 BYTE) NOT NULL ENABLE,
    NM_OBJECT VARCHAR2(30 BYTE) NOT NULL ENABLE,
    DT_LAST_UPDATE DATE NOT NULL ENABLE,
    DS_OBJECT_TYPE VARCHAR2(19 BYTE) NOT NULL ENABLE,
    DT_INSERT_REG DATE NOT NULL ENABLE,
    CONSTRAINT PK_REPOSITORYMETADATA PRIMARY KEY (NM_SCHEMA, NM_OBJECT, DS_OBJECT_TYPE, DT_LAST_UPDATE) 
  );
/

create or replace PROCEDURE      SP_UPDATE_REPOSITORY
-- 19/05/2012 - www.fabioprado.net SP_UPDATE_METADATA_TABLE: Manter um histórico dos metadados dos objetos, atualizado diariamente a partir de quaisquer alterações.
-- se quiser incluir mais tipos de objetos no repositório, analise a instrução SELECT  a seguir e descomente as linhas que julgar necessário para incluir os respectivos objetos em seu repositório
AUTHID CURRENT_USER AS
    S_DDL CLOB;
    EXISTE INTEGER;
BEGIN
  FOR I IN (SELECT DISTINCT
               U.USERNAME SCHEMA,
               O.NAME NAME,
               DECODE (O.TYPE#,
              --0, 'NEXT_OBJECT',
                1, 'INDEX',
                2, 'TABLE',
              --3, 'CLUSTER',
                4, 'VIEW',
              --5, 'SYNONYM',
              --6, 'SEQUENCE',
                7, 'PROCEDURE',
                8, 'FUNCTION',
                9, 'PACKAGE',
                11, 'PACKAGE_BODY',
                12, 'TRIGGER',
              --13, 'TYPE',
              --14, 'TYPE_BODY',
              --19, 'TABLE_PARTITION',
              --20, 'INDEX_PARTITION',
              --21, 'LOB',
              --22, 'LIBRARY',
              --23, 'DIRECTORY',
              --24, 'QUEUE',
              --28, 'JAVA_SOURCE',
              --29, 'JAVA_CLASS',
              --30, 'JAVA_RESOURCE',
              --32, 'INDEXTYPE',
              --33, 'OPERATOR',
              --34, 'TABLE_SUBPARTITION',
              --35, 'INDEX_SUBPARTITION',
              --40, 'LOB_PARTITION',
              --41, 'LOB_SUBPARTITION',
                42, 'MATERIALIZED_VIEW',
              --43, 'DIMENSION',
              --44, 'CONTEXT',
              --46, 'RULE_SET',
              --47, 'RESOURCE_PLAN',
              --48, 'CONSUMER_GROUP',
              --51, 'SUBSCRIPTION',
              --52, 'LOCATION',
              --55, 'XMLSCHEMA',
              --56, 'JAVA_DATA',
              --57, 'SECURITY_PROFILE',
              --59, 'RULE',
              --62, 'EVALUATION_CONTEXT',
                66, 'PROCOBJ',
                'UNDEFINED') TYPE,
                O.MTIME L_DATE
            FROM            SYS.OBJ$ O 
            INNER JOIN      SYS.DBA_USERS U 
                    ON      (O.OWNER# = U.USER_ID)
            INNER JOIN      SYS.DBA_OBJECTS DO 
                    ON      (O.NAME = DO.OBJECT_NAME AND U.USERNAME = DO.OWNER)
            WHERE           O.TYPE# IN (1,2,4,7,8,9,11,12,42,66)
            AND             U.USERNAME NOT IN ('RMAN','ORACLE','ROOT','MGMT_VIEW','SYSMAN','OPS$ORACLE','APEX_PUBLIC_USER','ORACLE_OCM',
                                       'TSMSYS','DBSNMP','CTXSYS','ANONYMOUS','DMSYS','WKSYS','WK_TEST,WKPROXY','OLAPSYS',
                                       'FLOWS_FILES','APEX_030200','MDSYS','WMSYS','SI_INFORMTN_SCHEMA','ORDSYS, EXFSYS','XDB',
                                       'ORDPLUGINS','OUTLN','SYS','SYSTEM','APPQOSSYS','EXFSYS','ORDDATA','ORDSYS','D4OSYS','APEX_040100')
            AND             DO.GENERATED = 'N'
            MINUS
            SELECT
                MO.NM_SCHEMA SCHEMA,
                MO.NM_OBJECT NAME,
                MO.DS_OBJECT_TYPE,
                MAX(MO.DT_LAST_UPDATE) L_DATE
            FROM
                REPOSITORY_METADATA MO
            GROUP BY
                MO.NM_SCHEMA, MO.NM_OBJECT, MO.DS_OBJECT_TYPE)
  LOOP     
      EXISTE := 0;
      
      IF I.TYPE = 'PROCOBJ' THEN
         SELECT COUNT(*) INTO EXISTE 
         FROM   REPOSITORY_METADATA WHERE NM_OBJECT = I.NAME AND NM_SCHEMA = I.SCHEMA;
      END IF;
      
      IF EXISTE = 0 THEN     
             SELECT DBMS_METADATA.GET_DDL(I.TYPE, I.NAME, I.SCHEMA)
                    INTO S_DDL FROM DUAL;
      
             INSERT INTO REPOSITORY_METADATA (TX_OBJECT_DDL, NM_SCHEMA, NM_OBJECT, DT_LAST_UPDATE, DS_OBJECT_TYPE, DT_INSERT_REG)
                                        VALUES (S_DDL, I.SCHEMA, I.NAME, I.L_DATE, I.TYPE, SYSDATE);
      END IF;
      
  END LOOP;

  COMMIT;
  
END;
/

BEGIN      
      DBMS_SCHEDULER.CREATE_JOB(
        job_name=>'JOB_UPDATE_REPOSITORY ',
        JOB_TYPE => 'PLSQL_BLOCK',
        JOB_ACTION =>'BEGIN SP_UPDATE_REPOSITORY END;',
        START_DATE => systimestamp,
        repeat_interval => 'FREQ=DAILY;BYHOUR=22;BYMINUTE=0;BYSECOND=0',
        ENABLED => TRUE,
        COMMENTS => 'Job para atualizar diariamente o repositório de metadados');
END;
/

