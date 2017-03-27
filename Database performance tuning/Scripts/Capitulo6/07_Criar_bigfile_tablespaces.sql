-- EXEMPLO DE CRIACAO DE BIGFILE tablespace 
create bigfile tablespace teste2 datafile '/tmp/teste2.dbf' size 100M
    AUTOEXTEND ON NEXT 1G  MAXSIZE UNLIMITED     
    extent management local -- Locally managed    
    segment space management auto -- ASSM
    ; 
