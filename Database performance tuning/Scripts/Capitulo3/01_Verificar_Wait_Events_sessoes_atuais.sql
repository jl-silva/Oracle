-- ANTES DE EXECUTAR ESTE SCRIPT, INICIE UM TESTE DE STRESS COM O SWINGBENCH POR 30 MIN, 10 USUARIOS

-- ver WE das sessoes atuais (conectadas)
SELECT      SID, EVENT, SECONDS_IN_WAIT
FROM        V$SESSION_WAIT
ORDER BY    SECONDS_IN_WAIT DESC;


-- V$SESSION_WAIT: Fornece informacoes sobre o atual ou ultimo evento de espera de cada sessao aberta no BD.