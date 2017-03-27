select	nm_objeto
from	objeto_sistema
where	lower(nm_objeto) like '%&descricao%'
and	ie_tipo_objeto = 'Function'
ORDER BY 1
/
