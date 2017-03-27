/*
Tabelas clusterizadas compartilham colunas e armazenam dados relacionados nos mesmos blocos;

Crie tabelas clusterizadas para otimizar consultas em tabelas que são frequentemente pesquisadas juntas;

O cluster apresenta os seguintes benefícios:
Reduz I/O;
Requer menos armazenamento;

Pode não ser apropriado nas seguintes situações:
Tabelas que são frequentemente atualizadas;
Tabelas que frequentemente requerem FTS;
Tabelas que requerem TRUNCATE TABLE.
*/


-- criando indice na FK da tabela SCOTT.EMP p/ ficar + parecida com o cluster que criaremos depois
CREATE INDEX SCOTT.IX_EMP_DEPTNO ON SCOTT.EMP(DEPTNO);

-- inserindo mais dados na tabela EMP
BEGIN
  FOR I IN 100..50000 
  LOOP
    FOR J IN 1..3
    LOOP
      BEGIN
          INSERT INTO SCOTT.EMP VALUES (I, 'TESTE ' || I, 'ANALYST', NULL, SYSDATE, 1000, 10, (CASE J WHEN 1 THEN 10 WHEN 2 THEN 20 ELSE 30 END) );
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
  END LOOP;
  COMMIT;
END;

-- coletar estatisticas da tabela EMP
ANALYZE TABLE SCOTT.EMP COMPUTE STATISTICS;

-- verificar plano de execucao da query em tabelas HEAP
EXPLAIN PLAN FOR
  SELECT      A.EMPNO, A.ENAME, B.DNAME              
  FROM        SCOTT.EMP A
  INNER JOIN  SCOTT.DEPT B 
      ON      A.DEPTNO=B.DEPTNO
  WHERE       B.DEPTNO=10;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- criando o cluster
CREATE CLUSTER SCOTT.DEPT_EMP (DEPTNO NUMBER);  
CREATE INDEX SCOTT.IX_DEPT_EMP_01 ON CLUSTER SCOTT.DEPT_EMP;  

-- criando tabelas clusterizadas
CREATE TABLE SCOTT.DEPT_CL (DEPTNO NUMBER, DNAME VARCHAR2(14), LOC VARCHAR2(13)) CLUSTER SCOTT.DEPT_EMP (DEPTNO);  
ALTER TABLE SCOTT.DEPT_CL ADD CONSTRAINT PK_DEPT_CL PRIMARY KEY (DEPTNO);  
CREATE TABLE SCOTT.EMP_CL ( EMPNO NUMBER(4), ENAME VARCHAR2(10), JOB VARCHAR2(9), MGR NUMBER(4), HIREDATE DATE, SAL NUMBER(7,2), COMM NUMBER(7,2), 
        DEPTNO NUMBER) CLUSTER SCOTT.DEPT_EMP (DEPTNO) ;
ALTER TABLE SCOTT.EMP_CL ADD CONSTRAINT PK_EMP_CL PRIMARY KEY (EMPNO);  

-- carregando dados nas tabelas clusterizadas
INSERT INTO SCOTT.DEPT_CL SELECT * FROM SCOTT.DEPT;
INSERT INTO SCOTT.EMP_CL SELECT * FROM SCOTT.EMP;
COMMIT;

-- coletar estatisticas das tabelas clusterizadas
ANALYZE TABLE SCOTT.EMP_CL COMPUTE STATISTICS;
ANALYZE TABLE SCOTT.DEPT_CL COMPUTE STATISTICS;

-- verificar plano de execucao da query em tabelas clusterizadas e comparar com o anterior
EXPLAIN PLAN FOR
  SELECT      A.EMPNO, A.ENAME, B.DNAME              
  FROM        SCOTT.EMP_CL A
  INNER JOIN  SCOTT.DEPT_CL B 
      ON      A.DEPTNO=B.DEPTNO
  WHERE       B.DEPTNO=10;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);