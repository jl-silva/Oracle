(select a.nr_seq_conta
from   tasy.sip_nv_dados a
where  a.nr_seq_lote_sip = 33
and    exists (select    1
               from      tasy.sip_nv_regra_vinc_it b
               where     b.nr_seq_sip_nv_dados = a.nr_sequencia
               and       b.nr_seq_item_assist = 75)
minus
select a.nr_seq_conta
from   tasy.sip_nv_dados a
where  a.nr_seq_lote_sip = 33
and    exists (select    1
               from      tasy.sip_nv_regra_vinc_it b
               where     b.nr_seq_sip_nv_dados = a.nr_sequencia
               and       b.nr_seq_item_assist in (76, 77))
)
intersect
select a.nr_seq_conta
from   tasy.sip_nv_dados a
where  a.nr_seq_lote_sip = 33
and    exists (select    1
               from      tasy.sip_nv_regra_vinc_it b
               where     b.nr_seq_sip_nv_dados = a.nr_sequencia
               and       b.nr_seq_item_assist = 108)