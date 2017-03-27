-- criando tabela cliente com coluna basic lob em tablespace separado (otimiza FTS em consultas que nao envolvem a coluna LOB)
CREATE TABLE HR.CLIENTE_B_BC
      ( id    NUMBER,
        nome  VARCHAR2(50),
        foto  BLOB
      )
            LOB (FOTO) STORE AS BASICFILE lb_foto_b_bc (TABLESPACE users
                                         INDEX ix_foto_b_bc (TABLESPACE users))
      TABLESPACE example;
ALTER TABLE HR.CLIENTE_B_BC MODIFY LOB (FOTO) (CACHE);      

-- executar script p/ limpar tabelas
truncate table hr.cliente_b;
truncate table hr.cliente_b_bc;
    
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
  FOR I IN 1..1000
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
  DBMS_OUTPUT.PUT_LINE('INSERT em blob sem cache: ' || ROUND((DBMS_UTILITY.GET_TIME - L_START)/100,2) || 's');

  L_START := DBMS_UTILITY.GET_TIME;  
  FOR I IN 1..1000
  LOOP
      INSERT  INTO HR.CLIENTE_B_BC (id, nome, foto)
      VALUES    (i, 'nome ' || to_char(i) , EMPTY_BLOB())
      RETURN foto INTO v_blob;
      
      v_bfile := BFILENAME(v_dir, v_file);
      DBMS_LOB.fileopen(v_bfile, DBMS_LOB.file_readonly);
      DBMS_LOB.loadfromfile(v_blob, v_bfile, DBMS_LOB.getlength(v_bfile));
      DBMS_LOB.fileclose(v_bfile);  
  end loop;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('INSERT em blob cache: ' || ROUND((DBMS_UTILITY.GET_TIME - L_START)/100,2) || 's');
END;


-- limpar buffer cache
ALTER SYSTEM FLUSH BUFFER_CACHE;

-- ver tamanho da buffer cache
select             name,
                   mb as mb_total,
                   nvl(inuse,0) as mb_used,
                   round(100 - ((nvl(inuse,0) / mb) * 100),2) "perc_mb_free"                    
from  (
                  select   name, 
                          round(sum(mb),2) mb, 
                          round(sum(inuse),2) inuse        
                  from (
                          select case when name = 'buffer_cache' then 'buffer cache'
                                       when name = 'log_buffer'   then 'log buffer'
                                      else pool                     
                                  end name,                      
                                  bytes/1024/1024 mb,
                                  case when name = 'buffer_cache'
                                        then (bytes - (select count(*) 
                                                       from v$bh where status='free') *
                                                      (select value 
                                                      from v$parameter 
                                                      where name = 'db_block_size')
                                              )/1024/1024
                                      when name <> 'free memory'
                                            then bytes/1024/1024
                                  end inuse
                          from    v$sgastat
                        )
                WHERE     NAME is not null
                group by  name
            )
UNION ALL    
select      'SGA',
            round(sum(bytes)/1024/1024,2),
            (round(sum(bytes)/1024/1024,2)) - round(sum(decode(name,'free memory',bytes,0))/1024/1024,2),
            round((sum(decode(name,'free memory',bytes,0))/sum(bytes))*100,2)                        
from        v$sgastat;

-- lendo blob sem cache
SET SERVEROUTPUT ON
DECLARE 
  L_START  NUMBER;  
  v_blob   BLOB;
  v_size   NUMBER;
   Buffer            RAW(32767);
    Amount            BINARY_INTEGER := 32767;
    Position          INTEGER := 1000;
    Chunksize         INTEGER;
BEGIN      
  L_START := DBMS_UTILITY.GET_TIME;  
  FOR I IN 1..1000
  LOOP
      SELECT FOTO INTO v_blob FROM HR.CLIENTE_B WHERE id = I;
      v_size := DBMS_LOB.GETLENGTH(v_blob);  
   /* Find out the chunksize for this LOB column: */
   Chunksize := DBMS_LOB.GETCHUNKSIZE(v_blob);
   IF (Chunksize < 32767) THEN
      Amount := (32767 / Chunksize) * Chunksize;
   END IF;
   /* Opening the LOB is optional: */
   DBMS_LOB.OPEN (v_blob, DBMS_LOB.LOB_READONLY);
   /* Read data from the LOB: */
   DBMS_LOB.READ (v_blob, Amount, Position, Buffer);
   /* Closing the LOB is mandatory if you have opened it: */
   DBMS_LOB.CLOSE (v_blob);      
      
  end loop;  
  DBMS_OUTPUT.PUT_LINE('Tempo total LOB sem cache: ' || ROUND((DBMS_UTILITY.GET_TIME - L_START)/100,2) || 's');  
END;


-- limpar buffer cache E ver de novo tamanho dela

-- lendo blob COM cache
SET SERVEROUTPUT ON
DECLARE 
  L_START  NUMBER;  
  v_blob   BLOB;
  v_size   NUMBER;
   Buffer            RAW(32767);
    Amount            BINARY_INTEGER := 32767;
    Position          INTEGER := 1000;
    Chunksize         INTEGER;
BEGIN      
  L_START := DBMS_UTILITY.GET_TIME;  
  FOR I IN 1..1000
  LOOP
      SELECT FOTO INTO v_blob FROM HR.CLIENTE_B_BC WHERE id = I;
      v_size := DBMS_LOB.GETLENGTH(v_blob);  
   /* Find out the chunksize for this LOB column: */
   Chunksize := DBMS_LOB.GETCHUNKSIZE(v_blob);
   IF (Chunksize < 32767) THEN
      Amount := (32767 / Chunksize) * Chunksize;
   END IF;
   /* Opening the LOB is optional: */
   DBMS_LOB.OPEN (v_blob, DBMS_LOB.LOB_READONLY);
   /* Read data from the LOB: */
   DBMS_LOB.READ (v_blob, Amount, Position, Buffer);
   /* Closing the LOB is mandatory if you have opened it: */
   DBMS_LOB.CLOSE (v_blob);      
      
  end loop;  
  DBMS_OUTPUT.PUT_LINE('Tempo total LOB com cache: ' || ROUND((DBMS_UTILITY.GET_TIME - L_START)/100,2) || 's');  
END;

-- ver tamanho da buffer cache
