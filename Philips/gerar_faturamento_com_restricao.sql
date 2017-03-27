declare
nr_seq_lote_w	pls_lote_faturamento.nr_sequencia%type;

Cursor C01 is
	select	c.nr_seq_conta
	from	pls_fatura_conta c,
		pls_fatura_evento b,
		pls_fatura a
	where	a.nr_sequencia	= b.nr_seq_fatura
	and	b.nr_sequencia	= c.nr_seq_fatura_evento
	and	a.nr_sequencia	= 264666;

begin
nr_seq_lote_w := 2351;
for r_C01_w in C01 loop
	insert into pls_lote_fat_adic
		(nr_sequencia,
		dt_atualizacao,
		nm_usuario,
		dt_atualizacao_nrec,
		nm_usuario_nrec,
		nr_seq_lote,
		nr_contrato,
		nr_seq_contrato,
		nr_seq_cooperativa,
		nr_seq_conta,
		nr_seq_intercambio,
		nr_seq_protocolo)
	values	(pls_lote_fat_adic_seq.nextval,
		sysdate,
		'Tasy',
		sysdate,
		'Tasy',
		nr_seq_lote_w,
		null,
		null,
		null,
		r_C01_w.nr_seq_conta,
		null,
		null);
	commit;
end loop;


end;
/