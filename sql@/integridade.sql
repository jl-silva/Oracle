select	substr(a.nm_tabela,1,25) tabela,
	substr(a.nm_tabela_referencia,1,25) tabela_referencia,
	substr(b.nm_atributo,1,25) atributo
from	integridade_referencial a,
	integridade_atributo b
where	a.nm_tabela = b.nm_tabela
and	a.nm_integridade_referencial = b.nm_integridade_referencial
and	lower(a.nm_tabela) = lower('&1')
order by	a.nm_tabela_referencia;
-- Script By Luiz FM
/
