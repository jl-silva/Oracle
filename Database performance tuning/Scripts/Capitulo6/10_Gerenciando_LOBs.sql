 -- criando tabela cliente com coluna lob em tablespace separado (otimiza FTS em consultas que nao envolvem a coluna LOB)
 CREATE TABLE HR.CLIENTE (  id    NUMBER,
                             nome  VARCHAR2(50),
                             foto  BLOB)
            LOB (FOTO) STORE AS lb_foto (TABLESPACE users
                                         INDEX ix_foto (TABLESPACE users))
      TABLESPACE example;
      
-- SHRINK na coluna LOB em tabelas que sofrem muitas delecoes
ALTER TABLE HR.CLIENTE MODIFY LOB (FOTO) (SHRINK SPACE);

-- Se coluna eh constantemente acessada e ha espaco disponivel na BC, configure-a p/ permitir armazenamento na buffer cache
ALTER TABLE HR.CLIENTE MODIFY LOB (FOTO) (CACHE);