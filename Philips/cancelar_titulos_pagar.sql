declare

cursor c01(	nr_seq_lote_p	pls_lote_pagamento.nr_sequencia%type) is
	select	distinct x.nr_titulo_pagar, x.nr_seq_baixa
	from 	(
		select	c.nr_titulo nr_titulo_pagar,
			(select max(e.nr_sequencia) from titulo_pagar_baixa e where e.nr_titulo = c.nr_titulo) nr_seq_baixa
		from	titulo_pagar		c,
			pls_pagamento_prestador	b,
			pls_lote_pagamento	a
		where	a.nr_sequencia	= b.nr_seq_lote
		and	b.nr_sequencia	= c.nr_seq_pls_pag_prest
		and	a.nr_sequencia 	= nr_seq_lote_p
		and	c.vl_saldo_titulo = 0
		union all
		select	d.nr_titulo nr_titulo_pagar,
			(select max(e.nr_sequencia) from titulo_pagar_baixa e where e.nr_titulo = d.nr_titulo) nr_seq_baixa
		from	titulo_pagar			d,
			pls_pag_prest_venc_trib		c,
			pls_pag_prest_vencimento 	b,
			pls_pagamento_prestador 	a,
			titulo_pagar_baixa		e
		where	d.nr_seq_pls_venc_trib 	= c.nr_sequencia
		and	b.nr_sequencia		= c.nr_seq_vencimento
		and	a.nr_sequencia		= b.nr_seq_pag_prestador
		and	a.nr_seq_lote 		= nr_seq_lote_p
		and	d.VL_SALDO_TITULO 	= 0) x
	where 	x.nr_seq_baixa is not null;

begin

for r_c01_w in c01(4097) loop
	
	if	(r_c01_w.nr_seq_baixa is not null) then
		begin
		estornar_tit_pagar_baixa(	r_c01_w.nr_titulo_pagar,
						r_c01_w.nr_seq_baixa,
						sysdate,
						'TasyBaca',
						'N');
		exception
		when others then
			null;
		end;
	end if;
end loop;

commit;

end;
/
