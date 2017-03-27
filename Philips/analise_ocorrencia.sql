select	a.nr_seq_ocorrencia,
	sum(pls_util_pck.obter_somente_numero(a.ds_tempo_execucao)) tempo_total_segundos,
 (sum(pls_util_pck.obter_somente_numero(a.ds_tempo_execucao)) * 100) / (select sum(pls_util_pck.obter_somente_numero(a.ds_tempo_execucao))
                                                                        from	pls_oc_cta_log_ocor a
                                                                        where	a.dt_atualizacao between &dt_inicio and &dt_fim) peso_em_relacao_total
from	pls_oc_cta_log_ocor a
where	a.dt_atualizacao between &dt_inicio and &dt_fim
group by a.nr_seq_ocorrencia
order by peso_em_relacao_total desc