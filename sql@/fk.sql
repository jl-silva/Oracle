select	NM_TABELA,
	NM_INTEGRIDADE_REFERENCIAL,
	NM_TABELA_REFERENCIA
from	integridade_referencial
where	upper(nm_integridade_referencial) = upper('&fk')
/
