begin
declare
qt_fluxo_grupo_w		pls_integer;
qt_fluxo_nao_finalizar_w	pls_integer;

cursor c01(	qt_registro_pc	pls_integer) is
	select	nr_seq_conta,
		nr_seq_conta_proc
	from	pls_ocorrencia_benef
	where 	rownum <= qt_registro_pc;
begin

for r_c01_w in c01(50000) loop

	select 	count(1)
	into	qt_fluxo_grupo_w
	from	pls_ocorrencia_benef	a,
		pls_ocorrencia		b
	where	a.nr_seq_ocorrencia	= b.nr_sequencia
	and	a.nr_seq_conta_proc 	= r_c01_w.nr_seq_conta_proc
	and	a.nr_seq_conta		= r_c01_w.nr_seq_conta
	and	a.ie_situacao	 	= 'A'
	and	b.ie_glosar_pagamento	= 'S'
	and	rownum  = 1
	and	not exists (	select	1
				from	tiss_motivo_glosa y,
					pls_conta_glosa x
				where	x.nr_seq_motivo_glosa 	= y.nr_sequencia
				and	x.nr_sequencia 		= a.nr_seq_glosa
				and	y.cd_motivo_tiss 	in ('1705','1706')
				union all
				select	1
				from	tiss_motivo_glosa y,
					pls_conta_glosa x
				where	x.nr_seq_motivo_glosa 	= y.nr_sequencia
				and	x.nr_seq_ocorrencia_benef	= a.nr_sequencia
				and	y.cd_motivo_tiss 	in ('1705','1706'));
end loop;
exception
when others then
	null;
end;
commit;
end;
/
