-- habilitar ASSM qdo houver muitos "buffer busy waits" e ocorrer contencao no gerenciamento de free list em segmentos:
select * from v$waitstat where class='segment header';


-- EXEMPLO DE CRIACAO DE tablespace gerenciado localmente com ASSM
create tablespace teste datafile '/tmp/teste.dbf' size 100M
    AUTOEXTEND ON NEXT 1G  MAXSIZE UNLIMITED     
    extent management local -- Locally managed    
    segment space management auto -- ASSM
    ; 
