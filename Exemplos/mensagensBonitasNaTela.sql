-- Funciona no sql*plus, teria que testar no PL\SQL Developer e no SQLDeveloper por que tem cliente que usa.

set serveroutput on;

exec dbms_output.put_line('Mensagem bem bonita');

begin
declare
qt_registro_w 		pls_integer;

cursor c01 is
	select	nr_sequencia
	from	pls_conta;

begin
	
	qt_registro_w := 0;
	for r_c01_w in c01 loop
		dbms_output.put_line('Conta ' || r_c01_w.nr_sequencia || ' posição ' || qt_registro_w);
		qt_registro_w := qt_registro_w + 1;
		
		if	(qt_registro_w = 1450) then
			dbms_output.put_line('Saiu fora');
			if	(c01%isopen) then
				dbms_output.put_line('Cursor ainda aberto');
			end if;
			exit;
		end if;
	end loop;
	
	if	(c01%isopen) then
		dbms_output.put_line('Cursor ainda aberto, ERROOOOOOO!!!!!');
	end if;
	
exception
when others then
	null;
end;
commit;
end;
/