-- ver parametro db_securefile, valores possiveis: always, force , permitted (11G), never , ignore, preferred (12c)
show parameter db_securefile

-- criando objeto DIRECTORY que contem imagem que iremos gravar nas colunas BLOB (basic e secure)
CREATE DIRECTORY IMG AS '/usr/share/backgrounds/images';
-- concedendo privs p/ usuario HR ler e escrever no DIRECTORY
GRANT READ, WRITE ON DIRECTORY IMG TO HR;

 -- criando tabela cliente com coluna basic lob em tablespace separado (otimiza FTS em consultas que nao envolvem a coluna LOB)
 CREATE TABLE HR.CLIENTE_B
      ( id    NUMBER,
        nome  VARCHAR2(50),
        foto  BLOB
      )
            LOB (FOTO) STORE AS BASICFILE lb_foto_b (TABLESPACE users
                                         INDEX ix_foto_b (TABLESPACE users))
      TABLESPACE example;

-- criando tabela cliente com coluna secure lob em tablespace separado (otimiza FTS em consultas que nao envolvem a coluna LOB)
CREATE TABLE HR.CLIENTE_S
      ( id    NUMBER,
        nome  VARCHAR2(50),        
        foto  BLOB
      )
            LOB (FOTO) STORE AS SECUREFILE lb_foto_s (DEDUPLICATE LOB TABLESPACE users
                                         INDEX ix_foto_s (TABLESPACE users))                                         
      TABLESPACE example;

-- executar script p/ limpar tabelas
truncate table hr.cliente_b;
truncate table hr.cliente_s;
    

-- inserindo dados nas 2 tabelas
SET SERVEROUTPUT ON
DECLARE 
  L_START  NUMBER;
  v_bfile  BFILE;
  v_blob   BLOB;
  v_dir    VARCHAR2(3) := 'IMG';
  v_file   VARCHAR2(30) := 'flowers_and_leaves.jpg';
BEGIN    
  L_START := DBMS_UTILITY.GET_TIME;  
  FOR I IN 1..200
  LOOP
      INSERT  INTO HR.CLIENTE_B (id, nome, foto)
      VALUES    (i, 'nome ' || to_char(i) , EMPTY_BLOB())
      RETURN foto INTO v_blob;
      
      v_bfile := BFILENAME(v_dir, v_file);
      DBMS_LOB.fileopen(v_bfile, DBMS_LOB.file_readonly);
      DBMS_LOB.loadfromfile(v_blob, v_bfile, DBMS_LOB.getlength(v_bfile));
      DBMS_LOB.fileclose(v_bfile);  
  end loop;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('INSERT em basic lob: ' || ROUND((DBMS_UTILITY.GET_TIME - L_START)/100,2) || 's');
  
  L_START := DBMS_UTILITY.GET_TIME;  
  FOR I IN 1..200
  LOOP
      INSERT  INTO HR.CLIENTE_S (id, nome, foto)
      VALUES    (i, 'nome ' || to_char(i) , EMPTY_BLOB())
      RETURN foto INTO v_blob;
      
      v_bfile := BFILENAME(v_dir, v_file);
      DBMS_LOB.fileopen(v_bfile, DBMS_LOB.file_readonly);
      DBMS_LOB.loadfromfile(v_blob, v_bfile, DBMS_LOB.getlength(v_bfile));
      DBMS_LOB.fileclose(v_bfile);  
  end loop;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('INSERT em securefile lob: ' || ROUND((DBMS_UTILITY.GET_TIME - L_START)/100,2) || 's');
END;

-- ver tamanho dos segmentos das tabelas e dos lobs:
SELECT  segment_name, SUM(bytes)/1024/1024 size_mb
FROM    dba_segments
WHERE   (owner = 'HR' and
        segment_name IN ('CLIENTE_B','CLIENTE_S')) 
OR      (owner, segment_name) IN (
                        SELECT  owner, segment_name
                        FROM    dba_lobs
                        WHERE   owner = 'HR' 
                        AND     table_name IN ('CLIENTE_B','CLIENTE_S'))
GROUP BY segment_name;