select	sum(vl_item)
from	(select	sum(vl_proc) vl_item
	from	procedimento
	where	....
	union all
	select	sum(vl_mat) vl_item
	from	material
	where	....)