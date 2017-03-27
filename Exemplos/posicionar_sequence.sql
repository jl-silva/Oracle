declare

l_maxi_sequ     pls_integer;
l_sequ_atua     pls_integer;
l_sql           varchar2(255);

begin

SELECT MAX(pess_codi)
  INTO l_maxi_sequ
  FROM pessoa;
         
SELECT sequ_pessoa.nextval
  INTO l_sequ_atua
  FROM dual;

WHILE l_sequ_atua < l_maxi_sequ LOOP

    SELECT sequ_pessoa.nextval
      INTO l_sequ_atua
      FROM dual;
END LOOP;
end;
/
