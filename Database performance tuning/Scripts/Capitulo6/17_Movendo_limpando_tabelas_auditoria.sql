
-- CRIANDO tablespace AUDSYS 
create tablespace AUDSYS datafile '/tmp/audsys.dbf' size 100M
    AUTOEXTEND ON NEXT 1G  MAXSIZE UNLIMITED     
    extent management local -- Locally managed    
    segment space management auto -- ASSM
    ;
    
-- movendo AUD$ para tablespace AUSYS   
BEGIN
  DBMS_AUDIT_MGMT.set_audit_trail_location(
    audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
    audit_trail_location_value => 'AUDSYS');
END;
/

-- movendo FGA_LOG$ para tablespace AUSYS
BEGIN
  DBMS_AUDIT_MGMT.set_audit_trail_location(
    audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,
    audit_trail_location_value => 'AUDSYS');
END;
/

-- limpando registros de auditoria obsoletos iniciais(maximo de 41,6 dias = 999 horas)
BEGIN
  DBMS_AUDIT_MGMT.init_cleanup(
    audit_trail_type         => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
    default_cleanup_interval => 999 /* 0-999 horas */);
END;
/

-- Ler mais informações para limpar registros de auditoria no link abaixo:
--		http://jmoracle.com/DBMSAuditMgmt/index.html.