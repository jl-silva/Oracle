CREATE TABLE philipDelling (phill varchar2(4000))

INSERT INTO philipDelling (phill)
VALUES(ds_sql_final_w)

SELECT * FROM philipDelling

DELETE philipDelling COMMIT

DROP TABLE philipDelling

ALTER TABLE tabela modify (campo VARCHAR2(1) null);
