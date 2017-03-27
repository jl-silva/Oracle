Sincronizar base
exec tasy_sincronizar_base;

Consistir base
exec tasy_consistir_base;

View para ver as inconsistencias
select * from consiste_base_v order by nm_tabela;

Em caso de dúvida olhar nos cursores da tasy_consistir_base;

Como resolver inconsistencias:

1 - verificar no banco do cliente o campo
2 - verificar em nossa base
3 - verificar no dic objetos
4 - deletar, alterar ou criar conforme necessidade

ALGUNS COMANDOS UTEIS
--Modificar o tipo de um campo
ALTER TABLE PLS_CONTA_EXCLUSAO modify ( NR_PROTOCOLO_PRESTADOR VARCHAR2(20));
--Criar indice
CREATE INDEX PTUNOSE_I3 ON PTU_NOTA_SERVICO( NR_SEQ_PACOTE);
--Dropar indice
DROP INDEX PTUNOSE_PLSPACO_FK_I ON PTU_NOTA_SERVICO;
--Verificar indices de uma tabela
SELECT index_name, index_type FROM USER_INDEXES WHERE TABLE_NAME = NOMETABELA
-- Campos de indices da base

Insert no dicionario de objeto do cliente
selecionar o campo que quer criar ex. tabela Indice seleciona um indice
ctrl + shift + alt + click no canto superior esquerdo do dbp
irá gerar na pasta padrão o insert do registro