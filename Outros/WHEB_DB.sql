create or replace 
PACKAGE WHEB_DB AS

	CURSOR C_INDICES(nm_tabela_p VARCHAR2, ie_tipo_p VARCHAR2 DEFAULT NULL) RETURN INDICE%rowtype;
	CURSOR C_INDICE_ATRIBUTOS(nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2) RETURN INDICE_ATRIBUTO%rowtype;
	CURSOR C_INTEGRIDADES_REFERENCIAIS(nm_tabela_p VARCHAR2, nm_tabela_p_REFERENCIA VARCHAR2 DEFAULT NULL) RETURN INTEGRIDADE_REFERENCIAL%rowtype;
	CURSOR C_INTEGRIDADE_ATRIBUTOS(nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN INTEGRIDADE_ATRIBUTO%rowtype;

  FUNCTION DO_COUNT_DUPLICATES           (table_name_p VARCHAR2, constraint_name_p VARCHAR2) RETURN NUMBER;
  PROCEDURE DO_DROP_CONSTRAINT            (table_name_p VARCHAR2, constraint_name_p VARCHAR2);
  PROCEDURE DO_DROP_CONSTRAINT            (integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype);
  PROCEDURE DO_DROP_INCORRECT_INDEX       (indice_p INDICE%rowtype);
  PROCEDURE DO_DROP_INDEX                 (table_name_p VARCHAR2, index_name_p VARCHAR2);
  PROCEDURE DO_DROP_INDEX                 (indice_p INDICE%rowtype);
  PROCEDURE DO_DROP_INDEX_OF_CONSTRAINT   (table_name_p VARCHAR2, index_name_p VARCHAR2);
  PROCEDURE DO_DROP_PK_REFERENCES         (primary_key_name_p VARCHAR2);
  PROCEDURE DO_MODIFY_CONSTRAINT_INDEX    (nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2, nm_indice_p VARCHAR2);
  PROCEDURE DO_RECREATE_CONSTRAINT        (nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2);
  PROCEDURE DO_RECREATE_CONSTRAINT        (integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype);
  PROCEDURE DO_RECREATE_INDEX             (nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2);
  PROCEDURE DO_RECREATE_INDEX             (indice_p INDICE%rowtype);

   FUNCTION EXISTS_INDEX                  (indice_p INDICE%rowtype) RETURN BOOLEAN;
   FUNCTION EXISTS_INDEX                  (table_name_p VARCHAR2, index_name_p VARCHAR2) RETURN BOOLEAN;
   FUNCTION EXISTS_CONSTRAINT             (integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN BOOLEAN;
   FUNCTION EXISTS_CONSTRAINT             (table_name_p VARCHAR2, constraint_name_p VARCHAR2) RETURN BOOLEAN;

   FUNCTION GET_DB_USER_INDEX             (table_name_p VARCHAR2, index_name_p VARCHAR2) RETURN USER_INDEXES%rowtype;
   FUNCTION GET_DB_USER_CONSTRAINT        (table_name_p VARCHAR2, constraint_name_p VARCHAR2) RETURN USER_CONSTRAINTS%rowtype;
   FUNCTION GET_INDICE                    (nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2) RETURN INDICE%rowtype;
   FUNCTION GET_INDICE_ATRIBUTO           (nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2, nr_sequencia_p NUMBER) RETURN INDICE_ATRIBUTO%rowtype;
   FUNCTION GET_INTEGRIDADE_REFERENCIAL   (nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN INTEGRIDADE_REFERENCIAL%rowtype;
   FUNCTION GET_INTEGRIDADE_ATRIBUTO      (nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2, nm_atributo_p VARCHAR2) RETURN INTEGRIDADE_ATRIBUTO%rowtype;
   FUNCTION GET_SCHEMA                    (schema_p VARCHAR2) RETURN VARCHAR2;

   FUNCTION GETCOMMA_FIELDS_INDICE        (indice_p INDICE%rowtype) RETURN VARCHAR2;
   FUNCTION GETCOMMA_FIELDS_INTEGRIDADE   (integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2;
   FUNCTION GETCOMMA_FIELDS_REFERENCIADOS (integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2;
   FUNCTION GETCOMMA_INDICE_ATRIBUTOS     (return_field_name_p VARCHAR2, indice_p INDICE%rowtype) RETURN VARCHAR2;
   FUNCTION GETCOMMA_INDICE_ATRIBUTOS     (return_field_name_p VARCHAR2, nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2) RETURN VARCHAR2;
   FUNCTION GETCOMMA_INTEGRIDADE_ATRIBUTOS(return_field_name_p VARCHAR2, integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2;
   FUNCTION GETCOMMA_INTEGRIDADE_ATRIBUTOS(return_field_name_p VARCHAR2, nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN VARCHAR2;
   FUNCTION GETCOMMA_TABLE_COLUMNS        (nm_tabela_p VARCHAR2, alias_p VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

   FUNCTION GETSQL_CREATE_CONSTRAINT      (nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN VARCHAR2;
   FUNCTION GETSQL_CREATE_CONSTRAINT      (integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2;
   FUNCTION GETSQL_DROP_CONSTRAINT        (nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN VARCHAR2;
   FUNCTION GETSQL_DROP_CONSTRAINT        (integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2;
   FUNCTION GETSQL_ENABLE_CONSTRAINT      (nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN VARCHAR2;
   FUNCTION GETSQL_ENABLE_CONSTRAINT      (integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2;
   FUNCTION GETSQL_DISABLE_CONSTRAINT     (nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN VARCHAR2;
   FUNCTION GETSQL_DISABLE_CONSTRAINT     (integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2;

   FUNCTION HAS_DUPLICATES                (indice_p INDICE%rowtype) RETURN BOOLEAN;
   FUNCTION HAS_DUPLICATES                (integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN BOOLEAN;

   FUNCTION IS_INDEX_OF_CONSTRAINT        (nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2) RETURN BOOLEAN;
   FUNCTION IS_PHILIPS_FIELD              (nm_tabela_p VARCHAR2, nm_atributo_p VARCHAR2) RETURN BOOLEAN;
   FUNCTION IS_PHILIPS_INDEX              (nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2) RETURN BOOLEAN;
   FUNCTION IS_PHILIPS_CONSTRAINT         (nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN BOOLEAN;
   FUNCTION IS_PHILIPS_OBJECT             (ie_tipo_objeto_p VARCHAR2, nm_objeto_p VARCHAR2) RETURN BOOLEAN;
   FUNCTION IS_PHILIPS_TABLE              (nm_tabela_p VARCHAR2) RETURN BOOLEAN;
   FUNCTION IS_PRIMARY_KEY                (indice_p INDICE%rowtype) RETURN BOOLEAN;
   FUNCTION IS_PRIMARY_KEY                (integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN BOOLEAN;
   FUNCTION IS_UNIQUE_KEY                 (indice_p INDICE%rowtype) RETURN BOOLEAN;
   FUNCTION IS_UNIQUE_KEY                 (integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN BOOLEAN;
   FUNCTION IS_ROWTYPE_VALID              (indice_p INDICE%rowtype) RETURN BOOLEAN;
   FUNCTION IS_ROWTYPE_VALID              (indice_atributo_p INDICE_ATRIBUTO%rowtype) RETURN BOOLEAN;
   FUNCTION IS_ROWTYPE_VALID              (integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN BOOLEAN;
   FUNCTION IS_ROWTYPE_VALID              (integridade_atributo_p INTEGRIDADE_ATRIBUTO%rowtype) RETURN BOOLEAN;

   PROCEDURE ENABLE_DB_CHANGES;
   PROCEDURE DISABLE_DB_CHANGES;

   FUNCTION GETCOMMA_TEXT(sql_p VARCHAR2, separator_p VARCHAR2 DEFAULT ', ', prefix_p VARCHAR2 DEFAULT NULL, sufix_p VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION GETSQL_IN    (item1_p VARCHAR2 DEFAULT NULL, item2_p VARCHAR2 DEFAULT NULL, item3_p VARCHAR2 DEFAULT NULL,
                          item4_p VARCHAR2 DEFAULT NULL, item5_p VARCHAR2 DEFAULT NULL, item6_p VARCHAR2 DEFAULT NULL,
                          item7_p VARCHAR2 DEFAULT NULL, item8_p VARCHAR2 DEFAULT NULL, item9_p VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION QUOTED_STR   (str_p VARCHAR2) RETURN VARCHAR2;

END WHEB_DB;
/

create or replace PACKAGE BODY WHEB_DB AS

  CanChangeDatabase BOOLEAN := TRUE;

  -- C_INDICES
  CURSOR C_INDICES(nm_tabela_p VARCHAR2, ie_tipo_p VARCHAR2 DEFAULT NULL) RETURN INDICE%rowtype IS
    SELECT *
      FROM INDICE
     WHERE NM_TABELA = nm_tabela_p
       AND (   ie_tipo_p IS NULL
            OR ie_tipo_p = IE_TIPO);

  -- C_INDICE_ATRIBUTOS
  CURSOR C_INDICE_ATRIBUTOS(nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2) RETURN INDICE_ATRIBUTO%rowtype IS
      SELECT *
        FROM INDICE_ATRIBUTO
       WHERE NM_TABELA = nm_tabela_p
         AND NM_INDICE = nm_indice_p
    ORDER BY NR_SEQUENCIA;

  -- C_INTEGRIDADES_REFERENCIAIS
  CURSOR C_INTEGRIDADES_REFERENCIAIS(nm_tabela_p VARCHAR2, nm_tabela_p_REFERENCIA VARCHAR2 DEFAULT NULL) RETURN INTEGRIDADE_REFERENCIAL%rowtype IS
    SELECT *
      FROM INTEGRIDADE_REFERENCIAL
     WHERE NM_TABELA = nm_tabela_p
       AND (   nm_tabela_p_REFERENCIA IS NULL
            OR nm_tabela_p_REFERENCIA = NM_TABELA_REFERENCIA);

  -- C_INTEGRIDADE_ATRIBUTOS
  CURSOR C_INTEGRIDADE_ATRIBUTOS(nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN INTEGRIDADE_ATRIBUTO%rowtype IS
      SELECT *
        FROM INTEGRIDADE_ATRIBUTO
       WHERE NM_TABELA                  = nm_tabela_p
         AND NM_INTEGRIDADE_REFERENCIAL = nm_integridade_referencial_p
    ORDER BY IE_SEQUENCIA_CRIACAO;

  FUNCTION DO_COUNT_DUPLICATES(table_name_p VARCHAR2, constraint_name_p VARCHAR2) RETURN NUMBER AS
    count_w                NUMBER;
    group_by_w             VARCHAR2(250);
    indice_atributo_w      INDICE_ATRIBUTO%rowtype;
    integridade_atributo_w INTEGRIDADE_ATRIBUTO%rowtype;
  BEGIN
    group_by_w := NULL;
    BEGIN
      OPEN WHEB_DB.C_INTEGRIDADE_ATRIBUTOS(table_name_p, constraint_name_p);
      LOOP
        FETCH WHEB_DB.C_INTEGRIDADE_ATRIBUTOS INTO integridade_atributo_w;
        EXIT WHEN WHEB_DB.C_INTEGRIDADE_ATRIBUTOS%NOTFOUND;

        IF integridade_atributo_w.NM_ATRIBUTO IS NOT NULL THEN
          IF group_by_w IS NOT NULL THEN
            group_by_w := group_by_w || ', ';
          END IF;

          group_by_w := group_by_w || integridade_atributo_w.NM_ATRIBUTO;
        END IF;
      END LOOP;

      CLOSE WHEB_DB.C_INTEGRIDADE_ATRIBUTOS;
    EXCEPTION
      WHEN OTHERS THEN
        CLOSE WHEB_DB.C_INTEGRIDADE_ATRIBUTOS;
        WHEB_MENSAGEM_PCK.EXIBIR_MENSAGEM_ABORT(sqlerrm(sqlcode));
    END;

    IF group_by_w IS NULL THEN
      BEGIN
        OPEN WHEB_DB.C_INDICE_ATRIBUTOS(table_name_p, constraint_name_p);
        LOOP
          FETCH WHEB_DB.C_INDICE_ATRIBUTOS INTO indice_atributo_w;
          EXIT WHEN WHEB_DB.C_INDICE_ATRIBUTOS%NOTFOUND;

          IF indice_atributo_w.NM_ATRIBUTO IS NOT NULL THEN
            IF group_by_w IS NOT NULL THEN
              group_by_w := group_by_w || ', ';
            END IF;

            group_by_w := group_by_w || indice_atributo_w.NM_ATRIBUTO;
          END IF;
        END LOOP;

        CLOSE WHEB_DB.C_INDICE_ATRIBUTOS;
      EXCEPTION
        WHEN OTHERS THEN
          CLOSE WHEB_DB.C_INDICE_ATRIBUTOS;
          WHEB_MENSAGEM_PCK.EXIBIR_MENSAGEM_ABORT(sqlerrm(sqlcode));
      END;
    END IF;

    IF group_by_w IS NULL THEN
      RETURN -1;
    END IF;

    EXECUTE IMMEDIATE 'SELECT SUM(X.NRECS)' ||
                      ' FROM ( SELECT COUNT(1) NRECS' ||
                               ' FROM ' || UPPER(TRIM(table_name_p)) ||
                           ' GROUP BY ' || group_by_w ||
                             ' HAVING COUNT(1) > 1 ) X '
                 INTO count_w;

    RETURN count_w;
  END;

  PROCEDURE DO_DROP_CONSTRAINT(table_name_p VARCHAR2, constraint_name_p VARCHAR2) AS
    sql_w VARCHAR2(255);
  BEGIN
    IF NOT EXISTS_CONSTRAINT(table_name_p, constraint_name_p) THEN
      RETURN;
    END IF;

    sql_w := 'ALTER TABLE ' || UPPER(table_name_p) ||
        ' DROP CONSTRAINT ' || UPPER(constraint_name_p);

    WHEB_INCONSISTENCIA_LOG.LOG_COMMAND(sql_w || ';');

    IF CanChangeDatabase THEN
      EXECUTE IMMEDIATE sql_w;
    END IF;
  END;

  PROCEDURE DO_DROP_CONSTRAINT(integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) AS
  BEGIN
    IF IS_ROWTYPE_VALID(integridade_referencial_p) THEN
      DO_DROP_CONSTRAINT(integridade_referencial_p.NM_TABELA, integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL);
    END IF;
  END;

  PROCEDURE DO_DROP_INCORRECT_INDEX(indice_p INDICE%rowtype) AS
  BEGIN
    FOR REC IN (SELECT TABLE_NAME,
                       INDEX_NAME
                  FROM USER_INDEXES UI
                 WHERE UI.TABLE_NAME = UPPER(indice_p.NM_TABELA)
                   AND UI.INDEX_NAME <> UPPER(indice_p.NM_INDICE)
                   AND (    NOT EXISTS (SELECT 1
                                          FROM INDICE
                                         WHERE NM_TABELA = UI.TABLE_NAME
                                           AND NM_INDICE = UI.INDEX_NAME)
                         OR (     EXISTS (SELECT 1 FROM INDICE
                                                  WHERE NM_TABELA = UI.TABLE_NAME
                                                    AND NM_INDICE = UI.INDEX_NAME
                                                    AND IE_TIPO <> 'IF')
                              AND (SELECT COUNT(1)
                                     FROM USER_IND_COLUMNS UIC
                               INNER JOIN INDICE_ATRIBUTO  IA
                                       ON IA.NM_TABELA = UIC.TABLE_NAME AND IA.NM_INDICE = UIC.INDEX_NAME AND IA.NR_SEQUENCIA = UIC.COLUMN_POSITION AND IA.NM_ATRIBUTO = UIC.COLUMN_NAME
                                    WHERE UI.TABLE_NAME = UIC.TABLE_NAME
                                      AND UI.INDEX_NAME = UIC.INDEX_NAME) <> (SELECT COUNT(1)
                                                                                FROM INDICE_ATRIBUTO IA
                                                                               WHERE IA.NM_TABELA = UI.TABLE_NAME
                                                                                 AND IA.NM_INDICE = UI.INDEX_NAME))))
    LOOP
      IF IS_INDEX_OF_CONSTRAINT(REC.TABLE_NAME, REC.INDEX_NAME) THEN
        DO_DROP_INDEX_OF_CONSTRAINT(REC.TABLE_NAME, REC.INDEX_NAME);
      ELSE
        DO_DROP_INDEX(REC.TABLE_NAME, REC.INDEX_NAME);
      END IF;
    END LOOP;
  END;

  PROCEDURE DO_DROP_INDEX(table_name_p VARCHAR2, index_name_p VARCHAR2) AS
    sql_w VARCHAR2(255);
  BEGIN
    IF NOT EXISTS_INDEX(table_name_p, index_name_p) THEN
      RETURN;
    END IF;

    sql_w := 'DROP INDEX ' || UPPER(index_name_p);

    WHEB_INCONSISTENCIA_LOG.LOG_COMMAND(sql_w || ';');

    IF CanChangeDatabase THEN
      EXECUTE IMMEDIATE sql_w;
    END IF;
  END;

  PROCEDURE DO_DROP_INDEX(indice_p INDICE%rowtype) AS
  BEGIN
    IF IS_ROWTYPE_VALID(indice_p) THEN
      DO_DROP_INDEX(indice_p.NM_TABELA, indice_p.NM_INDICE);
    END IF;
  END;

  PROCEDURE DO_DROP_INDEX_OF_CONSTRAINT(table_name_p VARCHAR2, index_name_p VARCHAR2) AS
  BEGIN
    FOR REC IN (SELECT TABLE_NAME,
                       CONSTRAINT_NAME,
                       INDEX_NAME
                  FROM USER_CONSTRAINTS
                 WHERE TABLE_NAME = table_name_p
                   AND INDEX_NAME = index_name_p)
    LOOP
      DO_DROP_CONSTRAINT(REC.TABLE_NAME, REC.CONSTRAINT_NAME);
      DO_DROP_INDEX(REC.TABLE_NAME, REC.INDEX_NAME);
    END LOOP;
  END;

  PROCEDURE DO_DROP_PK_REFERENCES(primary_key_name_p VARCHAR2) AS
  BEGIN
    FOR REC IN (SELECT TABLE_NAME,
                       CONSTRAINT_NAME
                  FROM USER_CONSTRAINTS
                 WHERE CONSTRAINT_TYPE   = 'R'
                   AND R_CONSTRAINT_NAME = primary_key_name_p)
    LOOP
      DO_DROP_CONSTRAINT(REC.TABLE_NAME, REC.CONSTRAINT_NAME);
    END LOOP;
  END;

  PROCEDURE DO_MODIFY_CONSTRAINT_INDEX(nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2, nm_indice_p VARCHAR2) AS
    sql_w VARCHAR2(255);
  BEGIN
    IF NOT EXISTS_CONSTRAINT(nm_tabela_p, nm_integridade_referencial_p) AND EXISTS_INDEX(nm_tabela_p, nm_indice_p) THEN
      RETURN;
    END IF;

    sql_w := 'ALTER TABLE ' || UPPER(nm_tabela_p) ||
      ' MODIFY CONSTRAINT ' || UPPER(nm_integridade_referencial_p) ||
            ' USING INDEX ' || UPPER(nm_indice_p);

    WHEB_INCONSISTENCIA_LOG.LOG_COMMAND(sql_w || ';');

    IF CanChangeDatabase THEN
      EXECUTE IMMEDIATE sql_w;
    END IF;
  END;

  PROCEDURE DO_RECREATE_CONSTRAINT(nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) IS
  BEGIN
    IF nm_tabela_p IS NULL OR nm_integridade_referencial_p IS NULL THEN
      RETURN;
    END IF;

    DO_DROP_CONSTRAINT(nm_tabela_p, nm_integridade_referencial_p);

    WHEB_INCONSISTENCIA_LOG.LOG_COMMAND('EXECUTE TASY_CRIAR_INTEGRIDADE(''' || nm_tabela_p || ''', ''' || nm_integridade_referencial_p || ''', ''N'');');

    IF CanChangeDatabase THEN
      TASY_CRIAR_INTEGRIDADE(nm_tabela_p, nm_integridade_referencial_p, 'N');
    END IF;
  END;

  PROCEDURE DO_RECREATE_CONSTRAINT(integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) IS
  BEGIN
    IF IS_ROWTYPE_VALID(integridade_referencial_p) THEN
      DO_RECREATE_CONSTRAINT(integridade_referencial_p.NM_TABELA, integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL);
    END IF;
  END;

  PROCEDURE DO_RECREATE_INDEX(nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2) IS
  BEGIN
    IF nm_tabela_p IS NULL OR nm_indice_p IS NULL THEN
      RETURN;
    END IF;

    IF IS_INDEX_OF_CONSTRAINT(nm_tabela_p, nm_indice_p) THEN
      DO_DROP_CONSTRAINT(nm_tabela_p, nm_indice_p);
    ELSE
      DO_DROP_INDEX(nm_tabela_p, nm_indice_p);
    END IF;

    WHEB_INCONSISTENCIA_LOG.LOG_COMMAND('EXECUTE TASY_CRIAR_INDICE(''' || nm_tabela_p || ''', ''' || nm_indice_p || ''', 0, ''N'');');

    IF CanChangeDatabase THEN
      TASY_CRIAR_INDICE(nm_tabela_p, nm_indice_p, 0, 'N');
    END IF;
  END;

  PROCEDURE DO_RECREATE_INDEX(indice_p INDICE%rowtype) IS
  BEGIN
    IF IS_ROWTYPE_VALID(indice_p) THEN
      DO_RECREATE_INDEX(indice_p.NM_TABELA, indice_p.NM_INDICE);
    END IF;
  END;

  FUNCTION EXISTS_INDEX(table_name_p VARCHAR2, index_name_p VARCHAR2) RETURN BOOLEAN AS
    count_w NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO count_w
      FROM USER_INDEXES
     WHERE TABLE_NAME = UPPER(table_name_p)
       AND INDEX_NAME = UPPER(index_name_p);

    RETURN count_w > 0;
  END;

  FUNCTION EXISTS_INDEX(indice_p INDICE%rowtype) RETURN BOOLEAN AS
  BEGIN
    RETURN EXISTS_INDEX(indice_p.NM_TABELA, indice_p.NM_INDICE);
  END;

  FUNCTION EXISTS_CONSTRAINT(table_name_p VARCHAR2, constraint_name_p VARCHAR2) RETURN BOOLEAN AS
    count_w NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO count_w
      FROM USER_CONSTRAINTS
     WHERE TABLE_NAME      = UPPER(table_name_p)
       AND CONSTRAINT_NAME = UPPER(constraint_name_p);

    RETURN count_w > 0;
  END;

  FUNCTION EXISTS_CONSTRAINT(integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN BOOLEAN AS
  BEGIN
    RETURN EXISTS_CONSTRAINT(integridade_referencial_p.NM_TABELA, integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL);
  END;

  FUNCTION GET_DB_USER_INDEX(table_name_p VARCHAR2, index_name_p VARCHAR2) RETURN USER_INDEXES%rowtype AS
    user_index_w USER_INDEXES%rowtype;
  BEGIN
    BEGIN
      SELECT *
        INTO user_index_w
        FROM USER_INDEXES
       WHERE TABLE_NAME = table_name_p
         AND INDEX_NAME = index_name_p;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        user_index_w := NULL;
    END;

    RETURN user_index_w;
  END;

  FUNCTION GET_DB_USER_CONSTRAINT(table_name_p VARCHAR2, constraint_name_p VARCHAR2) RETURN USER_CONSTRAINTS%rowtype AS
    user_constraint_w USER_CONSTRAINTS%rowtype;
  BEGIN
    BEGIN
      SELECT *
        INTO user_constraint_w
        FROM USER_CONSTRAINTS
       WHERE TABLE_NAME      = table_name_p
         AND CONSTRAINT_NAME = constraint_name_p;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        user_constraint_w := NULL;
    END;

    RETURN user_constraint_w;
  END;

  FUNCTION GET_INDICE(nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2) RETURN INDICE%rowtype AS
    indice_w INDICE%rowtype;
  BEGIN
    BEGIN
      SELECT *
        INTO indice_w
        FROM INDICE
       WHERE NM_TABELA = nm_tabela_p
         AND NM_INDICE = nm_indice_p;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        indice_w := NULL;
    END;

    RETURN indice_w;
  END;

  FUNCTION GET_INDICE_ATRIBUTO(nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2, nr_sequencia_p NUMBER) RETURN INDICE_ATRIBUTO%rowtype AS
    indice_atributo_w INDICE_ATRIBUTO%rowtype;
  BEGIN
    BEGIN
      SELECT *
        INTO indice_atributo_w
        FROM INDICE_ATRIBUTO
       WHERE NM_TABELA    = nm_tabela_p
         AND NM_INDICE    = nm_indice_p
         AND NR_SEQUENCIA = nr_sequencia_p;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        indice_atributo_w := NULL;
    END;

    RETURN indice_atributo_w;
  END;

  FUNCTION GET_INTEGRIDADE_REFERENCIAL(nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN INTEGRIDADE_REFERENCIAL%rowtype AS
    integridade_referencial_w INTEGRIDADE_REFERENCIAL%rowtype;
  BEGIN
    BEGIN
      SELECT *
        INTO integridade_referencial_w
        FROM INTEGRIDADE_REFERENCIAL
       WHERE NM_TABELA                  = nm_tabela_p
         AND NM_INTEGRIDADE_REFERENCIAL = nm_integridade_referencial_p;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        integridade_referencial_w := NULL;
    END;

    RETURN integridade_referencial_w;
  END;

  FUNCTION GET_INTEGRIDADE_ATRIBUTO(nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2, nm_atributo_p VARCHAR2) RETURN INTEGRIDADE_ATRIBUTO%rowtype AS
    integridade_atributo_w INTEGRIDADE_ATRIBUTO%rowtype;
  BEGIN
    BEGIN
        SELECT *
          INTO integridade_atributo_w
          FROM INTEGRIDADE_ATRIBUTO
         WHERE NM_TABELA                  = nm_tabela_p
           AND NM_INTEGRIDADE_REFERENCIAL = nm_integridade_referencial_p
           AND NM_ATRIBUTO                = nm_atributo_p
      ORDER BY IE_SEQUENCIA_CRIACAO;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        integridade_atributo_w := NULL;
    END;

    RETURN integridade_atributo_w;
  END;

  FUNCTION GET_SCHEMA(schema_p VARCHAR2) RETURN VARCHAR2 AS
    schema_w VARCHAR2(255);
  BEGIN
    IF schema_p IS NULL THEN
      RETURN NULL;
    END IF;

    schema_w := schema_p;
    WHILE INSTR(schema_w, '..') > 0
    LOOP
      schema_w := REPLACE(schema_p, '..', '.');
    END LOOP;

    IF SUBSTR(schema_w, LENGTH(schema_w), 1) <> '.' THEN
      schema_w := schema_w || '.';
    END IF;

    RETURN schema_w;
  END;

  FUNCTION GETCOMMA_FIELDS_INDICE(indice_p INDICE%rowtype) RETURN VARCHAR2 AS
  BEGIN
    RETURN GETCOMMA_INDICE_ATRIBUTOS('NM_ATRIBUTO', indice_p);
  END;

  FUNCTION GETCOMMA_FIELDS_INTEGRIDADE(integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2 AS
  BEGIN
    RETURN GETCOMMA_INTEGRIDADE_ATRIBUTOS('NM_ATRIBUTO', integridade_referencial_p);
  END;

  FUNCTION GETCOMMA_FIELDS_REFERENCIADOS(integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2 AS
    field_w                VARCHAR(30);
    fields_retorno_w       VARCHAR(1000);
    indice_w               INDICE%rowtype;
    indice_atributo_w      INDICE_ATRIBUTO%rowtype;
    integridade_atributo_w INTEGRIDADE_ATRIBUTO%rowtype;
  BEGIN
    fields_retorno_w := NULL;
    BEGIN
      OPEN C_INTEGRIDADE_ATRIBUTOS(integridade_referencial_p.NM_TABELA, integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL);
      LOOP
        FETCH C_INTEGRIDADE_ATRIBUTOS INTO integridade_atributo_w;
        EXIT WHEN C_INTEGRIDADE_ATRIBUTOS%NOTFOUND;

        IF integridade_atributo_w.NM_ATRIBUTO_REF IS NULL THEN
          BEGIN
            OPEN C_INDICES(integridade_referencial_p.NM_TABELA_REFERENCIA, 'PK');
            FETCH C_INDICES INTO indice_w;

            indice_atributo_w := GET_INDICE_ATRIBUTO(indice_w.NM_TABELA, indice_w.NM_INDICE, integridade_atributo_w.IE_SEQUENCIA_CRIACAO);

            field_w := indice_atributo_w.NM_ATRIBUTO;

            CLOSE WHEB_DB.C_INDICES;
          EXCEPTION
            WHEN OTHERS THEN
              CLOSE WHEB_DB.C_INDICES;
              WHEB_MENSAGEM_PCK.EXIBIR_MENSAGEM_ABORT(sqlerrm(sqlcode));
          END;
        ELSE
          field_w := integridade_atributo_w.NM_ATRIBUTO_REF;
        END IF;

        IF fields_retorno_w IS NOT NULL THEN
          fields_retorno_w := fields_retorno_w || ', ';
        END IF;

        fields_retorno_w := fields_retorno_w || field_w;
      END LOOP;

      CLOSE C_INTEGRIDADE_ATRIBUTOS;
    EXCEPTION
      WHEN OTHERS THEN
        CLOSE C_INTEGRIDADE_ATRIBUTOS;
        WHEB_MENSAGEM_PCK.EXIBIR_MENSAGEM_ABORT(sqlerrm(sqlcode));
    END;
    RETURN fields_retorno_w;
  END;

  FUNCTION GETCOMMA_INDICE_ATRIBUTOS(return_field_name_p VARCHAR2, indice_p INDICE%rowtype) RETURN VARCHAR2 AS
  BEGIN
    RETURN GETCOMMA_INDICE_ATRIBUTOS(return_field_name_p, indice_p.NM_TABELA, indice_p.NM_INDICE);
  END;

  FUNCTION GETCOMMA_INDICE_ATRIBUTOS(return_field_name_p VARCHAR2, nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    RETURN GETCOMMA_TEXT('   SELECT ' || return_field_name_p ||
                         '     FROM INDICE_ATRIBUTO ' ||
                         '    WHERE NM_TABELA = UPPER(''' || nm_tabela_p || ''')' ||
                         '      AND NM_INDICE = UPPER(''' || nm_indice_p || ''')' ||
                         ' ORDER BY NR_SEQUENCIA');
  END;

  FUNCTION GETCOMMA_INTEGRIDADE_ATRIBUTOS(return_field_name_p VARCHAR2, integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2 AS
  BEGIN
    RETURN GETCOMMA_INTEGRIDADE_ATRIBUTOS(return_field_name_p, integridade_referencial_p.NM_TABELA, integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL);
  END;

  FUNCTION GETCOMMA_INTEGRIDADE_ATRIBUTOS(return_field_name_p VARCHAR2, nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    RETURN GETCOMMA_TEXT('   SELECT ' || return_field_name_p ||
                         '     FROM INTEGRIDADE_ATRIBUTO ' ||
                         '    WHERE NM_TABELA                  = UPPER(''' || nm_tabela_p || ''')' ||
                         '      AND NM_INTEGRIDADE_REFERENCIAL = UPPER(''' || nm_integridade_referencial_p || ''')' ||
                         ' ORDER BY IE_SEQUENCIA_CRIACAO');
  END;

  FUNCTION GETCOMMA_TABLE_COLUMNS(nm_tabela_p VARCHAR2, alias_p VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 AS
    alias_w VARCHAR2(31);
  BEGIN
    alias_w := alias_p;
    IF alias_w IS NOT NULL THEN
      alias_w := alias_w || '.';
    END IF;

    RETURN GETCOMMA_TEXT('   SELECT COLUMN_NAME ' ||
                         '     FROM USER_TAB_COLUMNS ' ||
                         '    WHERE TABLE_NAME = UPPER(''' || UPPER(nm_tabela_p) || ''') ' ||
                         ' ORDER BY COLUMN_NAME', ', ', alias_w);
  END;

  FUNCTION GETSQL_CREATE_CONSTRAINT(nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    RETURN GETSQL_CREATE_CONSTRAINT(GET_INTEGRIDADE_REFERENCIAL(nm_tabela_p, nm_integridade_referencial_p));
  END;

  FUNCTION GETSQL_CREATE_CONSTRAINT(integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2 AS
    sql_w        VARCHAR(1000);
    fields_w     VARCHAR(255);
    fields_ref_w VARCHAR(255);
    indice_w     INDICE%rowtype;
  BEGIN
    IF NOT IS_ROWTYPE_VALID(integridade_referencial_p) THEN
      RETURN NULL;
    END IF;

    fields_w     := GETCOMMA_INTEGRIDADE_ATRIBUTOS('NM_ATRIBUTO',     integridade_referencial_p.NM_TABELA, integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL);
    fields_ref_w := GETCOMMA_INTEGRIDADE_ATRIBUTOS('NM_ATRIBUTO_REF', integridade_referencial_p.NM_TABELA, integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL);

    IF fields_ref_w IS NULL THEN
      BEGIN
        OPEN C_INDICES(integridade_referencial_p.NM_TABELA_REFERENCIA, 'PK');
        FETCH C_INDICES INTO indice_w;

        fields_ref_w := WHEB_DB.GETCOMMA_INDICE_ATRIBUTOS('NM_ATRIBUTO', indice_w.NM_TABELA, indice_w.NM_INDICE);

        CLOSE C_INDICES;
      EXCEPTION
        WHEN OTHERS THEN
          CLOSE C_INDICES;
          WHEB_MENSAGEM_PCK.EXIBIR_MENSAGEM_ABORT(sqlerrm(sqlcode));
      END;
    END IF;

    sql_w := 'ALTER TABLE ' || integridade_referencial_p.NM_TABELA ||
                 ' ADD CONSTRAINT ' || integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL ||
                     ' FOREIGN KEY (' || fields_w || ')' ||
                     ' REFERENCES ' || integridade_referencial_p.NM_TABELA_REFERENCIA || ' (' || fields_ref_w || ')';

    IF UPPER(integridade_referencial_p.IE_REGRA_DELECAO) = 'CASCADE' THEN
      sql_w := sql_w || ' ON DELETE CASCADE';
    END IF;

    IF UPPER(WHEB_USUARIO_PCK.GET_NM_USUARIO) = 'NOVALIDATE' THEN
      sql_w := sql_w || ' NOVALIDATE';
    END IF;

    RETURN sql_w;
  END;

  FUNCTION GETSQL_DROP_CONSTRAINT(nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    IF nm_tabela_p IS NULL OR nm_integridade_referencial_p IS NULL THEN
      RETURN NULL;
    END IF;

    RETURN 'ALTER TABLE ' || nm_tabela_p || ' DROP CONSTRAINT ' || nm_integridade_referencial_p;
  END;

  FUNCTION GETSQL_DROP_CONSTRAINT(integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2 AS
  BEGIN
    RETURN GETSQL_DROP_CONSTRAINT(integridade_referencial_p.NM_TABELA, integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL);
  END;

  FUNCTION GETSQL_ENABLE_CONSTRAINT (nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    IF nm_tabela_p IS NULL OR nm_integridade_referencial_p IS NULL THEN
      RETURN NULL;
    END IF;

    RETURN 'ALTER TABLE ' || nm_tabela_p || ' ENABLE CONSTRAINT ' || nm_integridade_referencial_p;
  END;

  FUNCTION GETSQL_ENABLE_CONSTRAINT(integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2 AS
  BEGIN
    RETURN GETSQL_ENABLE_CONSTRAINT(integridade_referencial_p.NM_TABELA, integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL);
  END;

  FUNCTION GETSQL_DISABLE_CONSTRAINT(nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    IF nm_tabela_p IS NULL OR nm_integridade_referencial_p IS NULL THEN
      RETURN NULL;
    END IF;

    RETURN 'ALTER TABLE ' || nm_tabela_p || ' DISABLE CONSTRAINT ' || nm_integridade_referencial_p;
  END;

  FUNCTION GETSQL_DISABLE_CONSTRAINT(integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN VARCHAR2 AS
  BEGIN
    RETURN GETSQL_DISABLE_CONSTRAINT(integridade_referencial_p.NM_TABELA, integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL);
  END;

  FUNCTION HAS_DUPLICATES(indice_p INDICE%rowtype) RETURN BOOLEAN IS
  BEGIN
    IF IS_PRIMARY_KEY(indice_p) OR IS_UNIQUE_KEY(indice_p) THEN
      RETURN DO_COUNT_DUPLICATES(indice_p.NM_TABELA, indice_p.NM_INDICE) > 0;
    END IF;
    RETURN FALSE;
  END;

  FUNCTION HAS_DUPLICATES(integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN BOOLEAN IS
  BEGIN
    IF IS_PRIMARY_KEY(integridade_referencial_p) OR IS_UNIQUE_KEY(integridade_referencial_p) THEN
      RETURN DO_COUNT_DUPLICATES(integridade_referencial_p.NM_TABELA, integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL) > 0;
    END IF;
    RETURN FALSE;
  END;

  FUNCTION IS_INDEX_OF_CONSTRAINT(nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2) RETURN BOOLEAN AS
    count_w NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO count_w
      FROM USER_CONSTRAINTS
     WHERE TABLE_NAME = UPPER(nm_tabela_p)
       AND INDEX_NAME = UPPER(nm_indice_p);

    RETURN count_w > 0;
  END;

  FUNCTION IS_PHILIPS_FIELD(nm_tabela_p VARCHAR2, nm_atributo_p VARCHAR2) RETURN BOOLEAN AS
    count_w NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO count_w
      FROM TABELA_ATRIBUTO
     WHERE NM_TABELA   = UPPER(nm_tabela_p)
       AND NM_ATRIBUTO = UPPER(nm_atributo_p);

    RETURN count_w > 0;
  END;

  FUNCTION IS_PHILIPS_INDEX(nm_tabela_p VARCHAR2, nm_indice_p VARCHAR2) RETURN BOOLEAN AS
    count_w NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO count_w
      FROM INDICE
     WHERE NM_TABELA = UPPER(nm_tabela_p)
       AND NM_INDICE = UPPER(nm_indice_p);

    RETURN count_w > 0;
  END;

  FUNCTION IS_PHILIPS_CONSTRAINT(nm_tabela_p VARCHAR2, nm_integridade_referencial_p VARCHAR2) RETURN BOOLEAN AS
    count_w NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO count_w
      FROM INTEGRIDADE_REFERENCIAL
     WHERE NM_TABELA                  = UPPER(nm_tabela_p)
       AND NM_INTEGRIDADE_REFERENCIAL = UPPER(nm_integridade_referencial_p);

    RETURN count_w > 0;
  END;

  FUNCTION IS_PHILIPS_OBJECT(ie_tipo_objeto_p VARCHAR2, nm_objeto_p VARCHAR2) RETURN BOOLEAN AS
    count_w NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO count_w
      FROM OBJETO_SISTEMA
     WHERE NM_OBJETO      = UPPER(nm_objeto_p)
       AND IE_TIPO_OBJETO = UPPER(ie_tipo_objeto_p);

    RETURN count_w > 0;
  END;

  FUNCTION IS_PHILIPS_TABLE(nm_tabela_p VARCHAR2) RETURN BOOLEAN AS
    count_w NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO count_w
      FROM TABELA_SISTEMA
     WHERE NM_TABELA = UPPER(nm_tabela_p);

    RETURN count_w > 0;
  END;

  FUNCTION IS_PRIMARY_KEY(indice_p INDICE%rowtype) RETURN BOOLEAN IS
  BEGIN
    RETURN IS_ROWTYPE_VALID(indice_p) AND indice_p.IE_TIPO = 'PK';
  END;

  FUNCTION IS_PRIMARY_KEY(integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN BOOLEAN IS
    indice_w INDICE%rowtype;
  BEGIN
    indice_w := GET_INDICE(integridade_referencial_p.NM_TABELA, integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL);
    RETURN IS_PRIMARY_KEY(indice_w);
  END;

  FUNCTION IS_UNIQUE_KEY(indice_p INDICE%rowtype) RETURN BOOLEAN IS
  BEGIN
    RETURN IS_ROWTYPE_VALID(indice_p) AND indice_p.IE_TIPO = 'UK';
  END;

  FUNCTION IS_UNIQUE_KEY(integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN BOOLEAN IS
    indice_w INDICE%rowtype;
  BEGIN
    indice_w := GET_INDICE(integridade_referencial_p.NM_TABELA, integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL);
    RETURN IS_UNIQUE_KEY(indice_w);
  END;

  FUNCTION IS_ROWTYPE_VALID(indice_p INDICE%rowtype) RETURN BOOLEAN AS
  BEGIN
    RETURN indice_p.NM_TABELA IS NOT NULL
       AND indice_p.NM_INDICE IS NOT NULL;
  END;

  FUNCTION IS_ROWTYPE_VALID(indice_atributo_p INDICE_ATRIBUTO%rowtype) RETURN BOOLEAN AS
  BEGIN
    RETURN indice_atributo_p.NM_TABELA IS NOT NULL
       AND indice_atributo_p.NM_INDICE IS NOT NULL
       AND indice_atributo_p.NR_SEQUENCIA IS NOT NULL;
  END;

  FUNCTION IS_ROWTYPE_VALID(integridade_referencial_p INTEGRIDADE_REFERENCIAL%rowtype) RETURN BOOLEAN AS
  BEGIN
    RETURN integridade_referencial_p.NM_TABELA IS NOT NULL
       AND integridade_referencial_p.NM_INTEGRIDADE_REFERENCIAL IS NOT NULL;
  END;

  FUNCTION IS_ROWTYPE_VALID(integridade_atributo_p INTEGRIDADE_ATRIBUTO%rowtype) RETURN BOOLEAN AS
  BEGIN
    RETURN integridade_atributo_p.NM_TABELA IS NOT NULL
       AND integridade_atributo_p.NM_INTEGRIDADE_REFERENCIAL IS NOT NULL
       AND integridade_atributo_p.NM_ATRIBUTO IS NOT NULL;
  END;

  PROCEDURE ENABLE_DB_CHANGES AS
  BEGIN
    CanChangeDatabase := TRUE;
  END;

  PROCEDURE DISABLE_DB_CHANGES AS
  BEGIN
    CanChangeDatabase := FALSE;
  END;

  FUNCTION GETCOMMA_TEXT(sql_p VARCHAR2, separator_p VARCHAR2 DEFAULT ', ', prefix_p VARCHAR2 DEFAULT NULL, sufix_p VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 AS
    comma_text_w VARCHAR2(32000);
    column_w     VARCHAR2(4000);
    cursor_w     INTEGER;
    ignore_w     INTEGER;
  BEGIN
    comma_text_w := NULL;
    BEGIN
      cursor_w := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(cursor_w, sql_p, DBMS_SQL.Native);
      DBMS_SQL.DEFINE_COLUMN(cursor_w, 1, column_w, 4000);
      ignore_w := DBMS_SQL.EXECUTE(cursor_w);

      LOOP
        IF DBMS_SQL.FETCH_ROWS(cursor_w) > 0 THEN
          DBMS_SQL.COLUMN_VALUE(cursor_w, 1, column_w);

          IF column_w IS NOT NULL THEN

            IF comma_text_w IS NOT NULL THEN
              comma_text_w := comma_text_w || separator_p;
            END IF;

            comma_text_w := comma_text_w || prefix_p || column_w || sufix_p;
          END IF;
        ELSE
          EXIT;
        END IF;
      END LOOP;

      DBMS_SQL.CLOSE_CURSOR(cursor_w);
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_SQL.CLOSE_CURSOR(cursor_w);
        WHEB_MENSAGEM_PCK.EXIBIR_MENSAGEM_ABORT(sqlerrm(sqlcode));
    END;

    RETURN comma_text_w;
  END;

  FUNCTION GETSQL_IN(item1_p VARCHAR2 DEFAULT NULL, item2_p VARCHAR2 DEFAULT NULL, item3_p VARCHAR2 DEFAULT NULL,
                     item4_p VARCHAR2 DEFAULT NULL, item5_p VARCHAR2 DEFAULT NULL, item6_p VARCHAR2 DEFAULT NULL,
                     item7_p VARCHAR2 DEFAULT NULL, item8_p VARCHAR2 DEFAULT NULL, item9_p VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 AS
    sql_in_w VARCHAR2(2000);

    PROCEDURE ADD_IN_ITEM(item_p VARCHAR2) AS
    BEGIN
      IF item_p IS NULL THEN
        RETURN;
      END IF;

      IF sql_in_w IS NOT NULL THEN
        sql_in_w := sql_in_w || ', ';
      END IF;
      sql_in_w := sql_in_w || QUOTED_STR(item_p);
    END;

  BEGIN
    sql_in_w := NULL;

    ADD_IN_ITEM(item1_p);
    ADD_IN_ITEM(item2_p);
    ADD_IN_ITEM(item3_p);
    ADD_IN_ITEM(item4_p);
    ADD_IN_ITEM(item5_p);
    ADD_IN_ITEM(item6_p);
    ADD_IN_ITEM(item7_p);
    ADD_IN_ITEM(item8_p);
    ADD_IN_ITEM(item9_p);

    RETURN sql_in_w;
  END;

  FUNCTION QUOTED_STR(str_p VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    RETURN CHR(39) || str_p || CHR(39);
  END;

END WHEB_DB;
/