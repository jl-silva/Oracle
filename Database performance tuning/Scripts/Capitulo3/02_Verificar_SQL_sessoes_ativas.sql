-- ver SQL de sessoes ativas
SELECT      S.USERNAME,
            S.SID,
            T.SQL_TEXT
FROM        V$SESSION S
INNER JOIN  V$SQLTEXT T
    ON      S.SQL_HASH_VALUE = T.HASH_VALUE
WHERE       S.SID in (select sid from v$session where username is not null and status='ACTIVE')
ORDER BY    T.PIECE;


-- V$SESSION: Fornece informacoes de sessao de todas as sessoes atuais do BD.