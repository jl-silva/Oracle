create or replace 
procedure p_teste_jls is

t_jls_sequ      pkg_util.tb_number;
t_jls_desc      pkg_util.tb_varchar2_255;

cursor c01 is
    select mpes_nome || mpes_pcpf
      from mgr_pessoa
     where mpes_atua = 'S';

begin

open c01;
loop
    fetch c01 bulk collect into t_jls_desc
    limit pkg_util.c_limit_trans;
    exit when t_jls_desc.count = 0;

    for i in t_jls_desc.first..t_jls_desc.last loop

        t_jls_sequ(i) := fget_sequ('SEQU_JLS', 'NUM', 'JLS');
    end loop;

    forall i in t_jls_desc.first..t_jls_desc.last
        INSERT INTO JLS(
            NUM, DS
        ) VALUES (
            t_jls_sequ(i), t_jls_desc(i)
        );
    COMMIT;
end loop;
close c01;

end p_teste_jls;
/
BEGIN
  /* Start profiling.
     Write raw profiler output to file test.trc in a directory
     that is mapped to directory object DUMP_DBASS
     (see note following example). */

  DBMS_HPROF.START_PROFILING('DUMP_DBASS', 'teste_hprofile.trc');
END;
/
-- Execute procedure to be profiled
BEGIN
  p_teste_jls;
END;
/
BEGIN
  -- Stop profiling
  DBMS_HPROF.STOP_PROFILING;
END;
/