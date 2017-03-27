-- *** No 11G ou superior configure batch commit para otimizar muitas transacoes curtas:
alter session set COMMIT_WAIT = wait;
ALTER session SET COMMIT_LOGGING = BATCH;