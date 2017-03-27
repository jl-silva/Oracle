select *
from 	v$lock
where	id1 = (
	select	object_id
	from	user_objects
	where	object_name = 'PLS_CP_CTA_SELECAO');

select *
from   v$session
where  sid = 1538
