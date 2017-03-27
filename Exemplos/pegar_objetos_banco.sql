declare

t_tipo      pkg_util.tb_varchar2_150;
t_objt      pkg_util.tb_clob;
l_cont      simple_integer := 1;

cursor c01 is
    SELECT upper(object_name) nome
         , upper(object_type) tipo
      FROM all_objects
     WHERE owner = 'DBAASS'
       AND object_type IN (
                        'FUNCTION', 'INDEX', 'MATERIALIZED VIEW'
                      , 'LOB', 'JOB', 'PACKAGE', 'PROCEDURE'
                      , 'TABLE', 'TRIGGER', 'TYPE', 'VIEW');

procedure insere(   t_tipo      in out nocopy pkg_util.tb_varchar2_150
                  , t_objt      in out nocopy pkg_util.tb_clob
                  , l_cont      in out nocopy simple_integer) is

begin

if  (t_tipo.count > 0) then

    forall i in t_tipo.first..t_tipo.last
        INSERT INTO jls (ds, ds_clob) VALUES (t_tipo(i), t_objt(i));
    COMMIT;
end if;

t_tipo.delete;
t_objt.delete;
l_cont := 1;

end insere;

begin

insere(t_tipo, t_objt, l_cont);

for r_c01 in c01 loop

    begin
        t_tipo(l_cont) := r_c01.nome;
        t_objt(l_cont) := DBMS_METADATA.GET_DDL(r_c01.tipo, r_c01.nome);

        if  (l_cont >= 500) then

            insere(t_tipo, t_objt, l_cont);
        else
            l_cont := l_cont + 1;
        end if;
    exception
    when others then 
        null;
    end;
end loop;

insere(t_tipo, t_objt, l_cont);

end;
/