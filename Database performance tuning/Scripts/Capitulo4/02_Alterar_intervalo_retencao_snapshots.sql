-- MODIFICAR RETENCAO E INTERVALO (PARAMETROS EM MINUTOS) P/ 30 DIAS E 30 MINUTOS
exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(retention=>43200, interval=>60);

-- alterar PARA RETENCAO ILIMITADA:     
exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(retention=>0);
     
-- RETENCAO RECOMENDADA: 30 OU 45 DIAS

-- ver espaco utilizado pelo AWR no tablespace SYSAUX (para decidir melhor qual a retencao apropriada):
select      OCCUPANT_NAME , OCCUPANT_DESC, SCHEMA_NAME, 
            MOVE_PROCEDURE, MOVE_PROCEDURE_DESC, 
            space_usage_kbytes / 1024 as space_usage_mb 
from        V$SYSAUX_OCCUPANTS 
order by    space_usage_mb desc;