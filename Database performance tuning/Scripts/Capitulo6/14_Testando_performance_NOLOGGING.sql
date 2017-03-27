create table hr.emp_origem as select * from hr.employees where 1=0;
create table hr.emp_destino as select * from hr.employees where 1=0;
/

INSERT INTO HR.emp_origem
SELECT * FROM HR.EMPLOYEES E CONNECT BY level <= 3;
/

-- executar este script no minimo 3 vezes
SET SERVEROUTPUT ON
DECLARE 
  	L_START         NUMBER;    
BEGIN 
  EXECUTE IMMEDIATE 'ALTER TABLE HR.emp_destino LOGGING';

  L_START := DBMS_UTILITY.GET_TIME;
  -- executa insert convencional
  INSERT INTO HR.emp_destino
  SELECT * FROM HR.emp_origem;
  -- Tempo de um insert convencional 
  DBMS_OUTPUT.PUT_LINE('INSERT convencional: ' || round((DBMS_UTILITY.GET_TIME - L_START)/100,2) || 's');  
  -- desfaz insercao dos dados
  ROLLBACK;
 
  L_START := DBMS_UTILITY.GET_TIME;  
  -- executa insert direct path
  INSERT  /*+ APPEND */ INTO HR.emp_destino
  SELECT * FROM HR.emp_origem;
  DBMS_OUTPUT.PUT_LINE('INSERT c/ direct path: ' || round((DBMS_UTILITY.GET_TIME - L_START)/100,2) || 's');
  ROLLBACK;
  
  EXECUTE IMMEDIATE 'ALTER TABLE HR.emp_destino NOLOGGING';
  
  L_START := DBMS_UTILITY.GET_TIME;  
  -- executa insert direct path c/ minimal logging
  INSERT  /*+ APPEND */ INTO HR.emp_destino
  SELECT * FROM HR.emp_origem;
  DBMS_OUTPUT.PUT_LINE('INSERT c/ direct path e minimal logging (NOLOGGING): ' || round((DBMS_UTILITY.GET_TIME - L_START)/100,2) || 's');
  ROLLBACK;
END;