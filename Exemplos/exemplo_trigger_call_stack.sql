create or replace trigger jls_t1
before insert or update on pls_pag_item_trib
for each row

declare

vl_imposto_w	pls_pag_prest_venc_trib.vl_imposto%type;

begin

if 	(:new.vl_evento > :new.vl_evento_origem) then

	select 	sum(vl_imposto)
	into	vl_imposto_w
	from	pls_pag_prest_venc_trib
	where	nr_sequencia = :new.nr_seq_venc_trib

	if	(vl_imposto_w < :new.vl_evento) then
	
		raise_application_error(-20011, dbms_utility.format_call_stack);
	end if;
end if;

end jls_t1;
/