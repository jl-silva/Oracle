-- 1: coletando estatisticas de sistema sem carga de trabalho 
	execute dbms_stats.gather_system_stats()

-- 2: coletando estatisticas de sistema com carga de trabalho (metodo recomendado)
  execute dbms_stats.gather_system_stats('start')
  EFETUAR CARGA (executar por exemplo SwingBench)
  execute dbms_stats.gather_system_stats('stop')
        
-- 3: especifique intervalo de tempo (em segundos) para coletar estatisticas de carga
    execute dbms_stats.gather_system_stats('interval',30);
	
-- 4: ver estatisticas de sistema:
	select pname, pval1 from sys.aux_stats$ where sname = 'SYSSTATS_MAIN';
	
/* VISAO aux_stats$
-----------------------------------------------
cpuspeed: 		Velocidade da CPU com carga de trabalho, baseando-se em uma colecao de estatisticas
cpuspeedNW: 	Velocidade da CPU sem carga de trabalho (media de ciclos de CPU por segundo)
ioseektim: 		Soma do tempo de pesquisa, latencia e sobrecarga do SO relativos a I/O
iotfrspeed: 	Velocidade padrao de I/O (quao rapido o BD pode ler dados em 1 unico request)
maxthr: 		Taxa de transferencia maxima de I/O
slavethr: 		Media de transferencia de dados em I/O por processo escravo paralelo
sreadtim: 		Tempo medio em segundos para ler um unico bloco randomicamente
mreadtim: 		Tempo medio em segundos para ler multiplos blocos sequenciais randomicamente
mbrc: 			Media de contador de blocos por leitura em multiplos blocos

Obs. 1: Oracle usa o valor de mbrc e mreadtim para estimar o custo de um FTS. Na ausencia destes valores, o BD usa o valor do parametro db_file_multiblock_read_count.
Obs. 2: Quando estatisticas de sistema sao coletadas sem carga de trabalho, o BD captura valores somente para as colunas: cpuspeedNW, ioseektim e iotfrspeed.
*/


-- Para coletar estatisticas de objetos fixos (tabelas x$ e seus indices) do DD (acessiveis atraves de VPD), execute o script abaixo preferencialmente com carga de trabalho:
EXEC DBMS_STATS.GATHER_FIXED_OBJECTS_STATS();
-- Mais info: https://blogs.oracle.com/optimizer/entry/fixed_objects_statistics_and_why
