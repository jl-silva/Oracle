-- LIMPE a tabela dos registros de auditoria p/ facilitar os testes
TRUNCATE TABLE AUD$;

-- entre com o usuario HR, execute o bloco 1 e veja o tempo de execucao SEM AUDITORIA

-- entre com o usuario SYS e habilite auditoria de INSERT na tabela HR.EMP
audit INSERT on hr.emp;

-- execute novamente o bloco 1, veja o tempo de execucao COM AUDITORIA e compare-o com o tempo SEM AUDITORIA

-- *** BLOCO 1 ***
SET SERVEROUTPUT ON
declare
  v_count NUMber;
  V_START NUMBER;
begin
  V_START := DBMS_UTILITY.GET_TIME;
  for linha in (SELECT   FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER,
            HIRE_DATE, JOB_ID, SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID
    FROM    HR.EMPLOYEES)
  loop
      FOR I IN 1..100
      LOOP
        INSERT  INTO HR.EMP
        values (HR.EMPLOYEES_SEQ.NEXTVAL, linha.FIRST_NAME, linha.LAST_NAME, linha.EMAIL, 
                linha.PHONE_NUMBER, linha.HIRE_DATE, linha.JOB_ID, linha.SALARY, 
                linha.COMMISSION_PCT, linha.MANAGER_ID, linha.DEPARTMENT_ID);  
      END LOOP;
  end loop;
  
  DBMS_OUTPUT.PUT_LINE('Tempo de execucao: ' || (DBMS_UTILITY.GET_TIME - V_START) || 'cs');
end;
-- FIM BLOCO 1

-- instrucao SQL para validar se a tabela foi auditada
SELECT * FROM DBA_AUDIT_TRAIL;