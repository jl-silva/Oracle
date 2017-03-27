select	z.nr_sequencia, z.cd_prestador, b.nr_titulo titulo
from	pls_pagamento_prestador		a,
	pls_pag_prest_vencimento	b,
	pls_pag_prest_venc_trib		c,
	tributo				d,
	pls_lote_pagamento		e,
	pls_prestador			z
where	c.nr_seq_vencimento		= b.nr_sequencia
and	b.nr_seq_pag_prestador		= a.nr_sequencia
and	c.cd_tributo			= d.cd_tributo
and	e.nr_sequencia			= a.nr_seq_lote
and	z.nr_sequencia			= a.nr_seq_prestador
and	b.nr_titulo is not null
--and	cd_prestador = código_prestador
/*and	('A' = :tipo_pessoa 
or	('F' = :tipo_pessoa and z.cd_pessoa_fisica is not null and z.cd_cgc is null)
or	('J' = :tipo_pessoa and z.cd_pessoa_fisica is null and z.cd_cgc is not null))*/
order by
	z.nr_sequencia,
	b.nr_titulo