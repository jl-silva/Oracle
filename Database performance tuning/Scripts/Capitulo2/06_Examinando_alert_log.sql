-- localizando o arquivo trace (a partir do 11G):
SELECT * FROM V$DIAG_INFO where name IN ('Diag Alert','Diag Trace');
   
-- localizando o arquivo trace (todas as versoes):
show parameter background_dump_dest