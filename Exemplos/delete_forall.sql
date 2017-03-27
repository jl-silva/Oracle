declare

t_sequ      pkg_util.tb_number;

cursor c_01 is
   SELECT alun_codi
     FROM aluno
    WHERE alun_codi BETWEEN 1000000 AND 1026193;

begin
for r_c01 in c_01 loop
    begin
        DELETE
          FROM aluno
         WHERE alun_codi = r_c01.alun_codi;
    exception
        when others then
        null;
    end;
end loop;
COMMIT;
end;
/