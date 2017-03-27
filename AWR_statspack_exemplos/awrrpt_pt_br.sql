Introdução
AWR periodicamente reúne e armazena a atividade do sistema e dados de carga de trabalho que é então analisado pelo ADDM. Cada camada do Oracle é equipada com instrumentação que reúne informações sobre a carga de trabalho que será então usado para tomar decisões de auto-gestão. AWR é o local onde esses dados são armazenados. AWR examina periodicamente o desempenho do sistema (por padrão a cada 60 minutos) e armazena as informações encontradas (por padrão, até 7 dias). AWR é executado por padrão e Oracle afirma que ele não adiciona um nível visível de sobrecarga. Um novo processo de servidor de plano de fundo (MMON) leva instantâneos das estatísticas de banco de dados na memória (bem como STATSPACK) e armazena essas informações no repositório. O MMON também fornece à Oracle um recurso de alerta iniciado pelo servidor, que notifica os administradores de banco de dados de possíveis problemas (fora do espaço, alcance máximo alcançado, limiares de desempenho, etc.). As informações são armazenadas no tablespace SYSAUX. Esta informação é a base para todas as decisões de auto-gestão.

Para acessar o Repositório de carga de trabalho automático através do Oracle Enterprise Manager Database Control:
Na página Administração , selecione o link Repositório de carga de trabalho em Carga de trabalho . Na página Repositório de carga automática de trabalho , você pode gerenciar snapshots ou modificar as configurações AWR.
O Para gerenciar instantâneos, clique no link ao lado de Snapshots ou Conjuntos de instantâneos preservados . Nas páginas Snapshots ou Snapshots preservados , você pode:
+ Exibir informações sobre instantâneos ou conjuntos de instantâneos preservados (linhas de base).
+ Execute uma variedade de tarefas através do menu de ações pull-down, incluindo a criação de instantâneos adicionais, conjuntos de instantâneos preservados de um intervalo existente de instantâneos ou uma tarefa do ADDM para executar a análise em um intervalo de instantâneos ou um conjunto de instantâneos preservados.
O Para modificar as configurações AWR, clique no botão Editar . Na página Editar definições , pode definir o período de Retenção de Instantâneo e o intervalo de Recolha de Instantâneo .


Seções mais informativas do relatório
Acho que as seções a seguir são mais úteis:
- Resumo
- Top 5 eventos cronometrados
- Top SQL (por tempo decorrido, por recebe, às vezes por lê)

Ao visualizar o relatório AWR, verifique sempre o relatório ADDM correspondente para obter recomendações accionáveis. O ADDM é um mecanismo de autodiagnóstico projetado a partir da experiência dos melhores especialistas em sintonia da Oracle. Analisa os dados AWR automaticamente após um instantâneo AWR. Faz recomendações de desempenho específicas.


Tanto a freqüência de snapshot como o tempo de retenção podem ser modificados pelo usuário. Para ver as configurações atuais, você pode usar:
Selecione snap_interval, retenção de dba_hist_wr_control;

SNAP_INTERVAL RETENÇÃO
------------------- -------------------
+00000 01: 00: 00.0 +00007 00: 00: 00.0

ou
Selecione dbms_stats.get_stats_history_availability from dual;
Selecione dbms_stats.get_stats_history_retention from dual;

Este SQL mostra que os snapshots são tomados a cada hora e as coleções são mantidas por 7 dias

Se você quiser estender esse período de retenção você pode executar:
Execute dbms_workload_repository.modify_snapshot_settings (
Intervalo => 60, - Em Minutos. Valor atual retido se NULL.
Retenção = & gt; 43200); - Em Minutos (= 30 Dias). Valor atual retido se NULL

Neste exemplo, o período de retenção é especificado como 30 dias (43200 min) eo intervalo entre cada instantâneo é de 60 min.


Diferenças entre AWR e relatório STATSPACK
1) Statspack snapshot purgas devem ser agendadas manualmente. Quando o tablespace Statspack fica sem espaço, Statspack encerra trabalho. AWR snapshots são purgados automaticamente pelo MMON todas as noites. MMON, por padrão, tenta manter uma semana de AWR snapshots disponíveis. Se o AWR detectar que o tablespace SYSAUX corre o risco de ficar sem espaço, ele liberará espaço no SYSAUX ao excluir automaticamente o conjunto mais antigo de instantâneos. Se isso ocorrer, o AWR iniciará um alerta gerado pelo servidor para notificar os administradores da condição de erro fora do espaço.

2) O repositório AWR contém todas as estatísticas disponíveis no STATSPACK, bem como algumas estatísticas adicionais que não são.

3) STATSPACK não armazena as estatísticas de histórico de sessão ativa (ASH) que estão disponíveis na AWR dba_hist_active_sess_history exibição.

4) O STATSPACK não armazena histórico para novas estatísticas de métricas introduzidas no Oracle. As principais visualizações AWR são: dba_hist_sysmetric_history e dba_hist_sysmetric_summary .

5) O AWR também contém visualizações como dba_hist_service_stat , dba_hist_service_wait_class e dba_hist_service_name , que armazenam o histórico de estatísticas cumulativas de desempenho rastreadas para serviços específicos.

6) A versão mais recente do STATSPACK incluída no Oracle contém um conjunto de tabelas específicas, que acompanham o histórico de estatísticas que refletem o desempenho do recurso Oracle Streams. Essas tabelas são estatísticas $ streams_capture, stats $ streams_apply_sum, stats $ buffered_subscribers, stats $ rule_set, stats $ propagation_sender, stats $ propagation_receiver e stats $ buffered_queues. O AWR não contém as tabelas específicas que refletem a atividade do Oracle Streams; Portanto, se um DBA depende muito do recurso Oracle Streams, seria útil monitorar seu desempenho usando o utilitário STATSPACK.

7) Os snapshots do Statspack devem ser executados por um programador externo (dbms_jobs, CRON, etc.). AWR snapshots são agendadas a cada 60 minutos por padrão.

8) ADDM captura uma profundidade muito maior e amplitude de estatísticas do que Statspack faz. Durante o processamento do instantâneo, o MMON transfere uma versão em memória das estatísticas para as tabelas de estatísticas permanentes.




Relatórios do repositório de carga de trabalho
A Oracle fornece dois scripts principais para produzir relatórios de repositório de carga de trabalho. Eles são semelhantes em formato para os statspack relatórios e dar a opção de HTML ou texto simples formatos. Os dois relatórios fornecem a mesma saída, mas o awrrpti.sql permite selecionar uma única instância. Os relatórios podem ser gerados da seguinte forma:
@ $ ORACLE_HOME / rdbms / admin / awrrpt.sql
@ $ ORACLE_HOME / rdbms / admin / awrrpti.sql

Existem outros scripts também, aqui está a lista completa:

NOME DO RELATÓRIO 	Script SQL
Relatório de repositório de carga de trabalho automático 	Awrrpt.sql
Relatório Automático do Monitor de Diagnósticos de Banco de Dados 	Addmrpt.sql
Relatório ASH 	Ashrpt.sql
Relatório de Períodos Diferenciais AWR 	Awrddrpt.sql
Relatório AWR Single Statement SQL 	Awrsqrpt.sql
Relatório Global AWR 	Awrgrpt.sql
AWR Global Diff Report 	Awrgdrpt.sql


Os scripts solicitam que você insira o formato de relatório (html ou texto), o ID de instantâneo de início, o ID de snapshot final eo nome do arquivo do relatório. Este script parece Statspack; Ele mostra todos os snapshots AWR disponíveis e solicita dois específicos como limites de intervalo.



Instantâneos AWR e linhas de base
Você pode criar um instantâneo manualmente usando:
EXEC dbms_workload_repository.create_snapshot;

Você pode ver quais snapshots estão atualmente no AWR usando a visualização DBA_HIST_SNAPSHOT como visto neste exemplo:

SELECT snap_id, to_char (begin_interval_time, 'dd / MON / yy hh24: mi') Begin_Interval,
To_char ( end_interval_time , 'dd / MON / yy hh24: mi') End _Interval
FROM dba_hist_snapshot
ORDEM POR 1;

SNAP_ID BEGIN_INTERVAL END_INTERVAL
---------- ---------------
954 30 / NOV / 05 03:01 30 / NOV / 05 04:00
955 30 / NOV / 05 04:00 30 / NOV / 05 05:00
956 30 / NOV / 05 05:00 30 / NOV / 05 06:00
957 30 / NOV / 05 06:00 30 / NOV / 05 07:00
958 30 / NOV / 05 07:00 30 / NOV / 05 08:00
959 30 / NOV / 05 08:00 30 / NOV / 05 09:00

A cada snapshot é atribuído um ID de instantâneo exclusivo que é refletido na coluna SNAP_ID. A coluna END_INTERVAL_TIME exibe a hora em que o instantâneo real foi tirado.

Às vezes, você pode querer soltar snapshots manualmente. O procedimento dbms_workload_repository.drop_snapshot_range pode ser usado para remover um intervalo de instantâneos da AWR. Esse procedimento leva dois parâmetros, low_snap_id e high_snap_id, como mostrado neste exemplo:

EXEC dbms_workload_repository.drop_snapshot_range (low_snap_id => 1107, high_snap_id => 1108);

As seguintes visualizações do repositório de carga de trabalho estão disponíveis:
* V $ ACTIVE_SESSION_HISTORY - Exibe o histórico de sessão ativo (ASH) amostrado a cada segundo.
* V $ METRIC - Exibe informações métricas.
* V $ METRICNAME - Exibe as métricas associadas a cada grupo de métricas.
* V $ METRIC_HISTORY - Exibe métricas históricas.
* V $ METRICGROUP - Exibe todos os grupos de métricas.
* DBA_HIST_ACTIVE_SESS_HISTORY - Exibe o conteúdo do histórico do histórico da sessão ativa.
* DBA_HIST_BASELINE - Exibe informações de linha de base.
* DBA_HIST_DATABASE_INSTANCE - Exibe informações sobre o ambiente do banco de dados.
* DBA_HIST_SNAPSHOT - Exibe informações de instantâneo.
* DBA_HIST_SQL_PLAN - Exibe planos de execução SQL.
* DBA_HIST_WR_CONTROL - Exibe as configurações AWR.

Finalmente, você pode usar a seguinte consulta para identificar os ocupantes do SYSAUX Tablespace

Select substr (nome do ocupante, 1,40), space_usage_kbytes
De v $ sysaux_occupants;


Instantâneos automatizados da AWR

O Oracle usa um job agendado, GATHER_STATS_JOB, para coletar estatísticas AWR. Esse trabalho é criado e ativado automaticamente quando você cria um novo banco de dados Oracle. Para ver este trabalho, use a visualização DBA_SCHEDULER_JOBS como mostrado neste exemplo:

SELECT a.job_name, a.enabled, c.window_name, c.schedule_name, c.start_date, c.repeat_interval
FROM dba_scheduler_jobs a, dba_scheduler_wingroup_members b, dba_scheduler_windows c
WHERE job_name = 'GATHER_STATS_JOB'
E a.schedule_name = b.window_group_name
E b.window_name = c.window_name;

Você pode desativar esse trabalho usando o procedimento dbms_scheduler.disable, como mostrado neste exemplo:
Exec dbms_scheduler.disable ('GATHER_STATS_JOB');

E você pode habilitar o trabalho usando o procedimento dbms_scheduler.enable, como visto neste exemplo:
Exec dbms_scheduler.enable ('GATHER_STATS_JOB');

Linhas de base AWR
Geralmente é uma boa idéia criar uma linha de base no AWR. Uma linha de base é definida como um intervalo de instantâneos que podem ser usados ​​para comparar com outros pares de instantâneos. O servidor de banco de dados Oracle isentará os snapshots atribuídos a uma linha de base específica da rotina de purga automática. Assim, o objetivo principal de uma linha de base é preservar as estatísticas de tempo de execução típicas no repositório AWR, permitindo que você execute os instantâneos AWR nos snapshots de linha de base preservados a qualquer momento e compare-os aos instantâneos recentes contidos no AWR. Isso permite comparar o desempenho atual (e a configuração) com o desempenho de linha de base estabelecido, o que pode ajudar a determinar os problemas de desempenho do banco de dados.

Criando linhas de base
Você pode usar o procedimento create_baseline contido no pacote dbms_workload_repository armazenado PL / SQL para criar uma linha de base como visto neste exemplo:
EXEC dbms_workload_repository.create_baseline (start_snap_id => 1109, end_snap_id => 1111, baseline_name => 'EOM Baseline');

As linhas de base podem ser vistas usando a exibição DBA_HIST_BASELINE como visto no exemplo a seguir:
SELECT baseline_id, baseline_name, start_snap_id, end_snap_id
FROM dba_hist_baseline;

BASELINE_ID BASELINE_NAME START_SNAP_ID END_SNAP_ID
-----------------------------------------------------------------
1 EOM Baseline 1109 1111

Nesse caso, a coluna BASELINE_ID identifica cada linha de base individual que foi definida. O nome atribuído à linha de base é listado, assim como as IDs de instantâneo inicial e final.

Remoção de linhas de base
O par de instantâneos associados a uma linha de base são mantidos até que a linha de base seja explicitamente excluída. Você pode remover uma linha de base usando o procedimento dbms_workload_repository.drop_baseline, como visto neste exemplo, que descarta o "EOM Baseline" que acabamos de criar.
EXEC dbms_workload_repository.drop_baseline (baseline_name => 'EOM Base', Cascade => FALSE);

Observe que o parâmetro cascata fará com que todos os snapshots associados sejam removidos se estiver definido como TRUE; Caso contrário, os snapshots serão limpos automaticamente pelos processos automatizados AWR.




Resumo rápido das seções AWR
Esta seção contém orientações detalhadas para avaliar cada seção de um relatório AWR.
Seção Resumo do Relatório:
Isso fornece um resumo geral da instância durante o período do instantâneo e contém informações sumárias agregadas importantes.
- Cache Sizes : Isso mostra o tamanho de cada região SGA depois que a AMM as alterou. Essas informações podem ser comparadas aos parâmetros originais do init.ora no final do relatório AWR.
- Carregar perfil:   Esta seção mostra taxas importantes expressas em unidades por segundo e transações por segundo.
- Porcentagens de Eficiência de Instância:   Com uma meta de 100%, estas são razões de alto nível para a atividade no SGA.
- Estatísticas Partilhadas da Piscina:   Este é um bom resumo das alterações ao pool compartilhado durante o período do instantâneo.
- Top 5 eventos cronometrados:   Esta é a seção mais importante no relatório AWR. Ele mostra os principais eventos de espera e pode mostrar rapidamente o gargalo geral do banco de dados.

Seção de Estatísticas de Eventos de Espera
Esta seção mostra um detalhamento dos principais eventos de espera no banco de dados, incluindo eventos de espera de banco de dados de primeiro plano e de fundo, bem como estatísticas de modelo de tempo, sistema operacional, serviço e classes de espera.
-   Estatísticas do Modelo de Tempo:   As estatísticas de modo de tempo relatam como o tempo de processamento do banco de dados é gasto. Esta seção contém informações detalhadas de tempo sobre componentes específicos que participam no processamento do banco de dados.
- Classe de espera:  
- Eventos de espera:   Esta seção de relatório AWR fornece informações de eventos de espera mais detalhadas para processos de usuário em primeiro plano que incluem os 5 primeiros eventos de espera e muitos outros eventos de espera ocorridos durante o intervalo de instantâneo.
- Eventos de espera de plano de fundo:   Esta seção é relevante para os eventos de espera do processo em segundo plano.
-   Estatísticas do sistema operacional:   O estresse no servidor Oracle é importante, e esta seção mostra os principais recursos externos, incluindo E / S, CPU, memória e uso da rede.
- Estatísticas de Serviço:   A seção de estatísticas de serviço fornece informações sobre como determinados serviços configurados no banco de dados estão operando.
- Estatísticas da Classe Wait Wait:  

Seção de Estatísticas do SQL
Esta seção exibe o SQL superior, ordenado por métricas de execução SQL importantes.
-   SQL requisitado pelo tempo decorrido:   Inclui instruções SQL que levaram tempo de execução significativo durante o processamento.
-   SQL ordenado por tempo de CPU:   Inclui instruções SQL que consumiram um significativo tempo de CPU durante o seu processamento.
-   SQL encomendado por Gets:   Esses SQLs realizaram um grande número de leituras lógicas ao recuperar dados.
-   SQL ordenado por lê:   Esses SQLs realizaram um grande número de leituras de disco físico ao recuperar dados.
-   SQL encomendado por execuções:  
-   SQL requisitado por Parse chamadas:   Esses SQLs tiveram um grande número de operações de reparação.
-   SQL requisitado pela memória compartilhável:   Inclui cursores de instruções SQL que consumiram uma grande quantidade de memória de pool compartilhada SGA.
-   SQL ordenado por Contagem de versão:   Esses SQLs têm um grande número de versões no pool compartilhado por algum motivo.
-   Lista completa de texto SQL:  

Estatísticas de Atividade de Instância
Esta seção contém informações estatísticas descrevendo como o banco de dados operado durante o período de instantâneo.
-   Estatísticas de Atividade de Instância - Valores Absolutos:   Esta seção contém estatísticas que possuem valores absolutos não derivados de snapshots de fim e início.
-   Instance Activity Stats - Atividade de Tópicos:   Esta seção de relatório relata uma estatística de atividade de troca de logs.

Seção de Estatísticas de I / O
Esta seção mostra toda a atividade de E / S importante para a instância e mostra a atividade de E / S por tablespace, arquivo de dados e inclui estatísticas de conjunto de buffer.
- Tablespace IO Estatísticas  
- Arquivo IO Stats  

Seção de estatísticas de pool de buffer

Seção de Estatísticas
Esta seção mostra detalhes dos avisos para o buffer, pool compartilhado, PGA e Java pool.
-   Estatísticas de recuperação de instância:  
-   Recomendação de pool de buffer:  
-   PGA Aggr Resumo:   PGA Aggr Target Stats; PGA Aggr Target Histogram; E PGA Memory Advisory.  
-   Aviso de pool compartilhado:  
-   SGA Target Advisory
-   Stream Spool Advisory
-   Java Pool Advisory  

Seção de estatísticas de espera
- Estatísticas de espera de buffer:   Esta seção importante mostra buffer cache espera estatísticas.
- Enqueue Atividade:   Esta seção importante mostra como enqueue opera no banco de dados. Enqueues são estruturas internas especiais que fornecem acesso simultâneo a vários recursos de banco de dados.

Desfazer Seção de estatísticas
- Desfazer Resumo do segmento:   Esta seção fornece um resumo sobre como os segmentos de desfazer são usados ​​pelo banco de dados.
- Undo Segment Stats:   Esta seção mostra informações detalhadas do histórico sobre a atividade do segmento de desfazer.

Latch Statistics Seção:
Esta seção mostra detalhes sobre as estatísticas de trava. As travas são um mecanismo de serialização leve que é usado para o acesso single-thread às estruturas internas do Oracle.
- Atividade de Trava
- Quebra de sono de travamento
- Latch Miss Fontes
- Parent Latch Statistics
- Child Latch Statistics

Secção de Estatísticas de Segmentos:
Esta seção de relatório fornece detalhes sobre segmentos quentes usando os seguintes critérios:
-   Segmentos por lições lógicas:   Inclui os segmentos superiores que experimentaram o número elevado de leituras lógicas.
-   Segmentos por Leituras Físicas : Inclui segmentos superiores que tiveram um número elevado de leituras físicas de disco.
-   Segmentos por Row Lock Waits:   Inclui segmentos que tiveram um grande número de bloqueios de linha em seus dados.
-   Segmentos por ITL Waits : Inclui segmentos que tiveram uma grande disputa para Lista de Transações Interessadas (ITL). A contenção para ITL pode ser reduzida aumentando o parâmetro de armazenamento INITRANS da tabela.
-   Segmentos por Buffer Busy Waits : Estes segmentos têm o maior número de espera de buffer causado por seus blocos de dados.

Dicionário Cache Estatísticas Seção
Esta seção expõe detalhes sobre como o cache do dicionário de dados está operando.

Seção de cache da biblioteca
Inclui estatísticas de cache de biblioteca descrevendo como objetos de biblioteca compartilhada são gerenciados pelo Oracle.

Seção de Estatísticas de Memória
- Resumo da Memória do Processo
- Resumo da memória SGA : Esta seção fornece informações resumidas sobre várias regiões SGA.
- SGA Diferença de avanço:  

Seção de Estatísticas de Fluxos
- Streams CPU / IO Usage
- Captura de Streams
- Fluxos Aplicar
- Filas Buffered
Inscritos na lista Buffered
- Conjunto de Regras

-- inicio
As principais seções em um relatório AWR incluem:

AWR Cabeçalho do relatório:
Esta seção mostra informações básicas sobre o relatório, como quando o instantâneo foi tirado, por quanto tempo, Cache Sizes no início e no final do Snapshot, etc.

WORKLOAD REPOSITORY report for

DB Name         DB Id    Instance     Inst Num Startup Time    Release     RAC
------------ ----------- ------------ -------- --------------- ----------- ---
ORCL          1344731332 orcl                1 12-Feb-17 08:19 11.2.0.1.0  NO

Host Name        Platform                         CPUs Cores Sockets Memory(GB)
---------------- -------------------------------- ---- ----- ------- ----------
fabioprado.net   Linux x86 64-bit                    2     2       1       1.96

              Snap Id      Snap Time      Sessions Curs/Sess
            --------- ------------------- -------- ---------
Begin Snap:        37 12-Feb-17 12:16:04        25       1.6
  End Snap:        38 12-Feb-17 12:22:06        27       2.1
   Elapsed:                6.03 (mins)
   DB Time:              141.41 (mins)

Cache Sizes                       Begin        End
~~~~~~~~~~~                  ---------- ----------
               Buffer Cache:       424M       424M  Std Block Size:         8K
           Shared Pool Size:       212M       212M      Log Buffer:     5,424K

Elasped Time: Representa a janela do instantâneo ou o tempo entre os dois instantâneos.
DB TIME: Representa a atividade no banco de dados.

Se DB TIME for maior do que o tempo decorrido, significa que o banco de dados tem carga de trabalho alta.
           
Load Profile              Per Second    Per Transaction   Per Exec   Per Call
~~~~~~~~~~~~         ---------------    --------------- ---------- ----------
      DB Time(s):               23.5                0.9       0.09       0.68
       DB CPU(s):                0.1                0.0       0.00       0.00
       Redo size:           56,890.1            2,287.8
   Logical reads:            2,021.9               81.3
   Block changes:              405.1               16.3
  Physical reads:              130.9                5.3
 Physical writes:               40.7                1.6
      User calls:               34.7                1.4
          Parses:               49.3                2.0
     Hard parses:                0.9                0.0
W/A MB processed:                0.2                0.0
          Logons:                0.3                0.0
        Executes:              256.5               10.3
       Rollbacks:                0.0                0.0
    Transactions:               24.9

Instance Efficiency Percentages (Target 100%)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            Buffer Nowait %:   99.99       Redo NoWait %:  100.00
            Buffer  Hit   %:   93.53    In-memory Sort %:  100.00
            Library Hit   %:   99.25        Soft Parse %:   98.16
         Execute to Parse %:   80.77         Latch Hit %:   99.96
Parse CPU to Parse Elapsd %:    2.06     % Non-Parse CPU:   98.37

 Shared Pool Statistics        Begin    End
                              ------  ------
             Memory Usage %:   84.48   87.07
    % SQL with executions>1:   84.70   80.36
  % Memory for SQL w/exec>1:   85.53   74.24

Top 5 Timed Foreground Events
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                                           Avg
                                                          wait   % DB
Event                                 Waits     Time(s)   (ms)   time Wait Class
------------------------------ ------------ ----------- ------ ------ ----------
db file sequential read              35,732       6,575    184   77.5 User I/O
log file sync                         3,825       1,495    391   17.6 Commit
db file parallel read                   545         166    304    2.0 User I/O
db file scattered read                  470          92    196    1.1 User I/O
resmgr:cpu quantum                      155          60    385     .7 Scheduler
Host CPU (CPUs:    2 Cores:    2 Sockets:    1)
~~~~~~~~         Load Average
               Begin       End     %User   %System      %WIO     %Idle
           --------- --------- --------- --------- --------- ---------
                7.15     17.70       9.4       4.6      80.5      84.7

Instance CPU
~~~~~~~~~~~~
              % of total CPU for Instance:       7.3
              % of busy  CPU for Instance:      47.5
  %DB time waiting for CPU - Resource Mgr:       0.7

Memory Statistics
~~~~~~~~~~~~~~~~~                       Begin          End
                  Host Mem (MB):      2,002.5      2,002.5
                   SGA use (MB):        756.0        756.0
                   PGA use (MB):         60.6        105.0
    % Host Mem used for SGA+PGA:        40.78        43.00

Time Model Statistics                        DB/Inst: ORCL/orcl  Snaps: 37-38
-> Total time in database user-calls (DB Time): 8484.3s
-> Statistics including the word "background" measure background process
   time, and so do not contribute to the DB time statistic
-> Ordered by % or DB time desc, Statistic name

Statistic Name                                       Time (s) % of DB Time
------------------------------------------ ------------------ ------------
sql execute elapsed time                              6,967.9         82.1 @jls
DB CPU                                                   50.2           .6
PL/SQL execution elapsed time                            48.7           .6
parse time elapsed                                       41.1           .5
hard parse elapsed time                                  40.2           .5
connection management call elapsed time                   5.7           .1
PL/SQL compilation elapsed time                           3.3           .0
repeated bind elapsed time                                0.1           .0
hard parse (sharing criteria) elapsed time                0.0           .0
sequence load elapsed time                                0.0           .0
hard parse (bind mismatch) elapsed time                   0.0           .0
DB time                                               8,484.3
background elapsed time                                 424.3
background cpu time                                       3.1
          -------------------------------------------------------------

Operating System Statistics                   DB/Inst: ORCL/orcl  Snaps: 37-38
-> *TIME statistic values are diffed.
   All others display actual values.  End Value is displayed if different
-> ordered by statistic type (CPU Use, Virtual Memory, Hardware Config), Name

Statistic                                  Value        End Value
------------------------- ---------------------- ----------------
BUSY_TIME                                 11,245
IDLE_TIME                                 62,275
IOWAIT_TIME                               59,179
NICE_TIME                                     41
SYS_TIME                                   3,362
USER_TIME                                  6,894
LOAD                                           7               18
RSRC_MGR_CPU_WAIT_TIME                     5,819
PHYSICAL_MEMORY_BYTES              2,099,740,672
NUM_CPUS                                       2
NUM_CPU_CORES                                  2
NUM_CPU_SOCKETS                                1
GLOBAL_RECEIVE_SIZE_MAX                  131,071
GLOBAL_SEND_SIZE_MAX                     131,071
TCP_RECEIVE_SIZE_DEFAULT                  87,380
TCP_RECEIVE_SIZE_MAX                   4,194,304
TCP_RECEIVE_SIZE_MIN                       4,096
TCP_SEND_SIZE_DEFAULT                     16,384
TCP_SEND_SIZE_MAX                      4,194,304
TCP_SEND_SIZE_MIN                          4,096
          -------------------------------------------------------------

Operating System Statistics - Detail          DB/Inst: ORCL/orcl  Snaps: 37-38

Snap Time           Load    %busy    %user     %sys    %idle  %iowait
--------------- -------- -------- -------- -------- -------- --------
12-Feb 12:16:04      7.1      N/A      N/A      N/A      N/A      N/A
12-Feb 12:22:06     17.7     15.3      9.4      4.6     84.7     80.5
          -------------------------------------------------------------

Foreground Wait Class                         DB/Inst: ORCL/orcl  Snaps: 37-38
-> s  - second, ms - millisecond -    1000th of a second
-> ordered by wait time desc, waits desc
-> %Timeouts: value of 0 indicates value was < .5%.  Value of null is truly 0
-> Captured Time accounts for         99.6%  of Total DB time       8,484.33 (s)
-> Total FG Wait Time:             8,402.19 (s)  DB CPU time:          50.24 (s)

                                                                  Avg
                                      %Time       Total Wait     wait
Wait Class                      Waits -outs         Time (s)     (ms)  %DB time
-------------------- ---------------- ----- ---------------- -------- ---------
User I/O                       37,056     0            6,840      185      80.6 @jls
Commit                          3,825     0            1,495      391      17.6
Scheduler                         155     0               60      385       0.7
DB CPU                                                    50                0.6
Other                             159    83                3       20       0.0
Concurrency                       128     0                3       25       0.0
System I/O                         97     0                0        2       0.0
Network                         6,298     0                0        0       0.0
          -------------------------------------------------------------

Foreground Wait Events                       DB/Inst: ORCL/orcl  Snaps: 37-38
-> s  - second, ms - millisecond -    1000th of a second
-> Only events with Total Wait Time (s) >= .001 are shown
-> ordered by wait time desc, waits desc (idle events last)
-> %Timeouts: value of 0 indicates value was < .5%.  Value of null is truly 0

                                                             Avg
                                        %Time Total Wait    wait    Waits   % DB
Event                             Waits -outs   Time (s)    (ms)     /txn   time
-------------------------- ------------ ----- ---------- ------- -------- ------
db file sequential read          35,732     0      6,575     184      4.0   77.5 @jls
log file sync                     3,825     0      1,495     391      0.4   17.6
db file parallel read               545     0        166     304      0.1    2.0
db file scattered read              470     0         92     196      0.1    1.1
resmgr:cpu quantum                  155     0         60     385      0.0     .7
read by other session                64     0          8     122      0.0     .1
latch: enqueue hash chains           18     0          3     175      0.0     .0
latch: shared pool                    8     0          2     253      0.0     .0
latch: row cache objects              5     0          0      95      0.0     .0
library cache: mutex X              100     0          0       4      0.0     .0
control file sequential re           97     0          0       2      0.0     .0
enq: TX - index contention            2     0          0      78      0.0     .0
row cache lock                        1     0          0     155      0.0     .0
latch free                            7     0          0      12      0.0     .0
SQL*Net message to client         6,298     0          0       0      0.7     .0
buffer busy waits                    10     0          0       3      0.0     .0
Disk file operations I/O            240     0          0       0      0.0     .0
asynch descriptor resize            132   100          0       0      0.0     .0
direct path sync                      1     0          0       1      0.0     .0
PL/SQL lock timer                40,655   100      6,140     151      4.5
SQL*Net message from clien        6,298     0      1,766     280      0.7
jobq slave wait                     181    99         90     500      0.0
          -------------------------------------------------------------

Background Wait Events                       DB/Inst: ORCL/orcl  Snaps: 37-38
-> ordered by wait time desc, waits desc (idle events last)
-> Only events with Total Wait Time (s) >= .001 are shown
-> %Timeouts: value of 0 indicates value was < .5%.  Value of null is truly 0

                                                             Avg
                                        %Time Total Wait    wait    Waits   % bg
Event                             Waits -outs   Time (s)    (ms)     /txn   time
-------------------------- ------------ ----- ---------- ------- -------- ------
log file parallel write           6,962     0        258      37      0.8   60.8
db file async I/O submit          1,773     0         49      28      0.2   11.6
os thread startup                     9     0         26    2865      0.0    6.1
db file sequential read              51     0         20     396      0.0    4.8
control file parallel writ          170     0         12      70      0.0    2.8
ADR block file read                  12     0          3     253      0.0     .7
control file sequential re          420     0          1       2      0.0     .2
ADR block file write                  5     0          0      60      0.0     .1
LGWR wait for redo copy              24     0          0       9      0.0     .1
db file scattered read                1     0          0      18      0.0     .0
reliable message                     74     0          0       0      0.0     .0
log file sync                         1     0          0      10      0.0     .0
latch free                            4     0          0       3      0.0     .0
rdbms ipc reply                      74     0          0       0      0.0     .0
SQL*Net message to client           240     0          0       0      0.0     .0
latch: shared pool                    1     0          0       2      0.0     .0
asynch descriptor resize             91   100          0       0      0.0     .0
enq: JS - queue lock                  1     0          0       1      0.0     .0
rdbms ipc message                 4,392    32      5,463    1244      0.5
DIAG idle wait                      729   100        730    1001      0.1
Space Manager: slave idle            73   100        365    5001      0.0
pmon timer                          138    88        364    2640      0.0
Streams AQ: qmn coordinato           26    50        364   14003      0.0
Streams AQ: qmn slave idle           14     0        363   25934      0.0
shared server idle wait              12   100        360   30011      0.0
dispatcher timer                      6   100        360   60012      0.0
smon timer                           11     0        211   19145      0.0
SQL*Net message from clien          320     0          2       7      0.0
class slave wait                      4     0          0       9      0.0
          -------------------------------------------------------------

Wait Event Histogram                         DB/Inst: ORCL/orcl  Snaps: 37-38
-> Units for Total Waits column: K is 1000, M is 1000000, G is 1000000000
-> % of Waits: value of .0 indicates value was <.05%; value of null is truly 0
-> % of Waits: column heading of <=1s is truly <1024ms, >1s is truly >=1024ms
-> Ordered by Event (idle events last)

                                                    % of Waits
                                 -----------------------------------------------
                           Total
Event                      Waits  <1ms  <2ms  <4ms  <8ms <16ms <32ms  <=1s   >1s
-------------------------- ----- ----- ----- ----- ----- ----- ----- ----- -----
ADR block file read           12                     8.3   8.3   8.3  75.0
ADR block file write           5  60.0                                40.0
ADR file lock                  6 100.0
Disk file operations I/O     252  99.2    .4          .4
LGWR wait for redo copy       24  83.3                     4.2        12.5
SQL*Net message to client   6538 100.0                      .0
asynch descriptor resize     225 100.0
buffer busy waits             11  63.6         9.1   9.1  18.2
control file parallel writ   175  64.6   9.1   1.1   1.1   2.3   1.1  19.4   1.1
control file sequential re   524  98.3                            .6   1.1
db file async I/O submit    1936  88.0   2.7    .9    .4   1.0   1.3   4.9    .8
db file parallel read        545   1.7                     1.5   5.0  89.4   2.6
db file scattered read       471   5.9    .6    .6    .2    .6   8.1  83.2    .6
db file sequential read    35.9K   7.0    .0    .0    .3   2.9  12.2  75.9   1.6
direct path sync               2  50.0  50.0
direct path write              4 100.0
direct path write temp         1 100.0
enq: JS - queue lock           1       100.0
enq: TX - index contention     2              50.0                    50.0
latch free                    11  45.5         9.1        18.2  27.3
latch: In memory undo latc     2 100.0
latch: cache buffers chain     1 100.0
latch: cache buffers lru c     1 100.0
latch: call allocation         1 100.0
latch: enqueue hash chains    18                          11.1        88.9
latch: object queue header     1 100.0
latch: redo allocation         1 100.0
latch: row cache objects       5                                     100.0
latch: shared pool             9  22.2  11.1  33.3  11.1              22.2
library cache: mutex X       100  82.0   6.0   5.0   3.0         1.0   3.0
log file parallel write     6966  70.3   1.2    .4   1.6   4.6   9.5  11.8    .6
log file sync               3825   5.1    .9    .4   1.6   3.6   7.9  70.4  10.2
os thread startup              9                                33.3  44.4  22.2
rdbms ipc reply               75  98.7   1.3
read by other session         64   1.6   3.1   4.7   1.6   9.4  26.6  53.1
reliable message              74  97.3   2.7
resmgr:cpu quantum           155          .6    .6   3.2   4.5   9.7  70.3  11.0
row cache lock                 1                                     100.0
DIAG idle wait               740                                     100.0
PL/SQL lock timer          40.6K    .0                               100.0
SQL*Net message from clien  6616   5.0   1.0    .9    .8    .8    .3  90.8    .3
Space Manager: slave idle     74                                           100.0
Streams AQ: qmn coordinato    28  50.0                                      50.0
Streams AQ: qmn slave idle    15   6.7                                      93.3
class slave wait               4  75.0                                25.0
dispatcher timer               6                                           100.0
jobq slave wait              181                                     100.0
pmon timer                   140  11.4                                  .7  87.9
rdbms ipc message           4410  22.0   1.7   3.7   5.4   9.0  10.6  23.8  23.9
shared server idle wait       12                                           100.0
smon timer                    11                                       9.1  90.9
          -------------------------------------------------------------

Wait Event Histogram Detail (64 msec to 2 sec)DB/Inst: ORCL/orcl  Snaps: 37-3
-> Units for Total Waits column: K is 1000, M is 1000000, G is 1000000000
-> Units for % of Total Waits:
   ms is milliseconds
   s is 1024 milliseconds (approximately 1 second)
-> % of Total Waits: total waits for all wait classes, including Idle
-> % of Total Waits: value of .0 indicates value was <.05%;
   value of null is truly 0
-> Ordered by Event (only non-idle events are displayed)

                                                 % of Total Waits
                                 -----------------------------------------------
                           Waits
                           64ms
Event                      to 2s <32ms <64ms <1/8s <1/4s <1/2s   <1s   <2s  >=2s
-------------------------- ----- ----- ----- ----- ----- ----- ----- ----- -----
ADR block file read            9  25.0  33.3         8.3   8.3  25.0
ADR block file write           2  60.0        20.0  20.0
LGWR wait for redo copy        3  87.5   4.2   8.3
control file parallel writ    36  79.4   3.4   3.4   5.7   2.9   4.0   1.1
control file sequential re     6  98.9          .4    .4    .4
db file async I/O submit     109  94.3   1.0    .7   1.1   1.2    .9    .8    .1
db file parallel read        501   8.1  10.3  15.2  19.1  31.9  12.8   2.6
db file scattered read       395  16.1  13.4  22.3  21.2  19.3   7.0    .6
db file sequential read    27.9K  22.5  15.1  18.9  21.8  14.5   5.7   1.6
enq: TX - index contention     1  50.0              50.0
latch: enqueue hash chains    16  11.1   5.6  16.7  44.4  22.2
latch: row cache objects       5             100.0
latch: shared pool             2  77.8                          22.2
library cache: mutex X         3  97.0   2.0         1.0
log file parallel write      864  87.6   3.0   2.3   2.4   3.1   1.1    .6
log file sync               3073  19.5   5.7   8.9  17.1  22.4  16.3  10.0    .2
os thread startup              4  33.3  22.2        11.1        11.1        22.2
read by other session         34  46.9  10.9  14.1  14.1   9.4   4.7
resmgr:cpu quantum           119  18.7  14.8  19.4  11.6  14.2  10.3   6.5   4.5
row cache lock                 1                   100.0
          -------------------------------------------------------------

Wait Event Histogram Detail (4 sec to 2 min) DB/Inst: ORCL/orcl  Snaps: 37-38
-> Units for Total Waits column: K is 1000, M is 1000000, G is 1000000000
-> Units for % of Total Waits:
   s is 1024 milliseconds (approximately 1 second)
   m is 64*1024 milliseconds (approximately 67 seconds or 1.1 minutes)
-> % of Total Waits: total waits for all wait classes, including Idle
-> % of Total Waits: value of .0 indicates value was <.05%;
   value of null is truly 0
-> Ordered by Event (only non-idle events are displayed)

                                                 % of Total Waits
                                 -----------------------------------------------
                           Waits
                            4s
Event                      to 2m   <2s   <4s   <8s  <16s  <32s  < 1m  < 2m  >=2m
-------------------------- ----- ----- ----- ----- ----- ----- ----- ----- -----
db file async I/O submit       1  99.9    .1
log file sync                  8  99.8    .2
os thread startup              2  77.8              22.2
resmgr:cpu quantum             7  95.5   4.5
          -------------------------------------------------------------

Wait Event Histogram Detail (4 min to 1 hr)  DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Service Statistics                           DB/Inst: ORCL/orcl  Snaps: 37-38
-> ordered by DB Time

                                                           Physical      Logical
Service Name                  DB Time (s)   DB CPU (s)    Reads (K)    Reads (K)
---------------------------- ------------ ------------ ------------ ------------
orcl                                8,337           38           45          573
SYS$USERS                             137           13            2          150
SYS$BACKGROUND                          0            0            0            6
orclXDB                                 0            0            0            0
          -------------------------------------------------------------

Service Wait Class Stats                      DB/Inst: ORCL/orcl  Snaps: 37-38
-> Wait Class info for services in the Service Statistics section.
-> Total Waits and Time Waited displayed for the following wait
   classes:  User I/O, Concurrency, Administrative, Network
-> Time Waited (Wt Time) in seconds

Service Name
----------------------------------------------------------------
 User I/O  User I/O  Concurcy  Concurcy     Admin     Admin   Network   Network
Total Wts   Wt Time Total Wts   Wt Time Total Wts   Wt Time Total Wts   Wt Time
--------- --------- --------- --------- --------- --------- --------- ---------
orcl
    36048      6766       123         2         0         0      6296         0
SYS$USERS
     1002        74         5         1         0         0         2         0
SYS$BACKGROUND
       69        20        11        26         0         0         0         0
          -------------------------------------------------------------

SQL ordered by Elapsed Time                  DB/Inst: ORCL/orcl  Snaps: 37-38
-> Resources reported for PL/SQL code includes the resources used by all SQL
   statements called by the code.
-> % Total DB Time is the Elapsed Time of the SQL statement divided
   into the Total Database Time multiplied by 100
-> %Total - Elapsed Time  as a percentage of Total DB time
-> %CPU   - CPU Time      as a percentage of Elapsed Time
-> %IO    - User I/O Time as a percentage of Elapsed Time
-> Captured SQL account for   81.4% of Total DB Time (s):           8,484
-> Captured PL/SQL account for   82.2% of Total DB Time (s):           8,484

        Elapsed                  Elapsed Time
        Time (s)    Executions  per Exec (s)  %Total   %CPU    %IO    SQL Id
---------------- -------------- ------------- ------ ------ ------ -------------
         4,733.3          2,047          2.31   55.8     .4   99.1 0w2qpuc6u2zsp
Module: Swingbench User Thread
BEGIN :1 := orderentry.neworder(:2 ,:3 ,:4 ); END;

         1,821.3          5,771          0.32   21.5     .1   99.7 8dq0v1mjngj7t
Module: New Order
SELECT CUSTOMER_ID, CUST_FIRST_NAME, CUST_LAST_NAME, NLS_LANGUAGE, NLS_TERRITORY
, CREDIT_LIMIT, CUST_EMAIL, ACCOUNT_MGR_ID FROM CUSTOMERS WHERE CUSTOMER_ID = :B
2 AND ROWNUM < :B1

         1,650.4          5,480          0.30   19.5     .2   99.6 0yas01u2p9ch4
Module: New Order
INSERT INTO ORDER_ITEMS(ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY
) VALUES (:B4 , :B3 , :B2 , :B1 , 1)

         1,112.4          2,503          0.44   13.1     .7   98.6 147a57cxq3w5y
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseproducts(:2 ,:3 ,:4 ); END;

           931.8          6,117          0.15   11.0     .3   99.7 c13sma6rkr27c
Module: New Order
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.CATEGORY_
ID = :B3 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND INVENTORIES.WAREHO

           839.0          2,047          0.41    9.9     .2   99.4 bymb3ujkr3ubk
Module: New Order
INSERT INTO ORDERS(ORDER_ID, ORDER_DATE, CUSTOMER_ID, WAREHOUSE_ID) VALUES (ORDE
RS_SEQ.NEXTVAL + :B3 , SYSTIMESTAMP , :B2 , :B1 ) RETURNING ORDER_ID INTO :O0

           411.1            405          1.02    4.8     .3   99.5 apgb2g9q2zjh1
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseandupdateorders(:2 ,:3 ,:4 ); END;

           356.4          2,047          0.17    4.2     .2   99.6 5mddt5kt45rg3
Module: New Order
UPDATE ORDERS SET ORDER_MODE = 'online', ORDER_STATUS = FLOOR(DBMS_RANDOM.VALUE(
0, :B3 )), ORDER_TOTAL = :B2 WHERE ORDER_ID = :B1

           353.3            816          0.43    4.2     .5   98.7 dcq9a12vtcnuw
Module: Swingbench User Thread
BEGIN :1 := orderentry.newcustomer(:2 ,:3 ,:4 ,:5 ,:6 ,:7 ); END;

           345.8            816          0.42    4.1     .2   99.3 0bzhqhhj9mpaa
Module: New Customer
INSERT INTO CUSTOMERS(CUSTOMER_ID ,CUST_FIRST_NAME ,CUST_LAST_NAME ,NLS_LANGUAGE
 ,NLS_TERRITORY ,CREDIT_LIMIT ,CUST_EMAIL ,ACCOUNT_MGR_ID ) VALUES (:B9 , :B4 ,
:B3 , :B8 , :B7 , FLOOR(DBMS_RANDOM.VALUE(:B6 , :B5 )), :B4 ||'.'||:B3 ||'@'||'o
racle.com', FLOOR(DBMS_RANDOM.VALUE(:B2 , :B1 )))

           218.5            205          1.07    2.6     .2   99.7 a9gvfh5hx9u98
Module: Swingbench User Thread
BEGIN :1 := orderentry.processorders(:2 ,:3 ,:4 ); END;

           180.5            205          0.88    2.1     .1   99.8 7hk2m2702ua0g
Module: Process Orders
WITH NEED_TO_PROCESS AS (SELECT ORDER_ID, CUSTOMER_ID FROM ORDERS WHERE ORDER_ST
ATUS <= 4 AND WAREHOUSE_ID = :B1 AND ROWNUM < 10 ) SELECT O.ORDER_ID, OI.LINE_IT
EM_ID, OI.PRODUCT_ID, OI.UNIT_PRICE, OI.QUANTITY, O.ORDER_MODE, O.ORDER_STATUS,
SQL ordered by Elapsed Time                  DB/Inst: ORCL/orcl  Snaps: 37-38
-> Resources reported for PL/SQL code includes the resources used by all SQL
   statements called by the code.
-> % Total DB Time is the Elapsed Time of the SQL statement divided
   into the Total Database Time multiplied by 100
-> %Total - Elapsed Time  as a percentage of Total DB time
-> %CPU   - CPU Time      as a percentage of Elapsed Time
-> %IO    - User I/O Time as a percentage of Elapsed Time
-> Captured SQL account for   81.4% of Total DB Time (s):           8,484
-> Captured PL/SQL account for   82.2% of Total DB Time (s):           8,484

        Elapsed                  Elapsed Time
        Time (s)    Executions  per Exec (s)  %Total   %CPU    %IO    SQL Id
---------------- -------------- ------------- ------ ------ ------ -------------
O.ORDER_TOTAL, O.SALES_REP_ID, O.PROMOTION_ID, C.CUSTOMER_ID, C.CUST_FIRST_NAME,

           177.3          6,018          0.03    2.1     .3   99.7 8z3542ffmp562
Module: New Order
SELECT QUANTITY_ON_HAND FROM PRODUCT_INFORMATION P, INVENTORIES I WHERE I.PRODUC
T_ID = :B2 AND I.PRODUCT_ID = P.PRODUCT_ID AND I.WAREHOUSE_ID = :B1

           172.0            405          0.42    2.0     .1   99.4 0ruh367af7gbw
Module: Browse and Update Orders
SELECT ORDER_ID, ORDER_MODE, CUSTOMER_ID, ORDER_STATUS, ORDER_TOTAL, SALES_REP_I
D, PROMOTION_ID FROM ORDERS WHERE CUSTOMER_ID = :B2 AND ROWNUM < :B1

           144.4          7,471          0.02    1.7     .7   98.9 0y1prvxqc2ra9
Module: Browse Products
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.PRODUCT_I
D = :B2 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND ROWNUM < :B1

          -------------------------------------------------------------

SQL ordered by CPU Time                      DB/Inst: ORCL/orcl  Snaps: 37-38
-> Resources reported for PL/SQL code includes the resources used by all SQL
   statements called by the code.
-> %Total - CPU Time      as a percentage of Total DB CPU
-> %CPU   - CPU Time      as a percentage of Elapsed Time
-> %IO    - User I/O Time as a percentage of Elapsed Time
-> Captured SQL account for   53.3% of Total CPU Time (s):              50
-> Captured PL/SQL account for   88.1% of Total CPU Time (s):              50

    CPU                   CPU per           Elapsed
  Time (s)  Executions    Exec (s) %Total   Time (s)   %CPU    %IO    SQL Id
---------- ------------ ---------- ------ ---------- ------ ------ -------------
      19.8        2,047       0.01   39.4    4,733.3     .4   99.1 0w2qpuc6u2zsp
Module: Swingbench User Thread
BEGIN :1 := orderentry.neworder(:2 ,:3 ,:4 ); END;

       9.9            0        N/A   19.7       68.1   14.5   55.5 b6usrg82hwsa3
Module: DBMS_SCHEDULER
call dbms_stats.gather_database_stats_job_proc ( )

       9.2            1       9.20   18.3       14.1   65.1   26.7 2tr12b1b8uj71
Module: DBMS_SCHEDULER
MERGE /*+ dynamic_sampling(ST 4) dynamic_sampling_est_cdn(ST) */ INTO STATS_TARG
ET$ ST USING (SELECT STALENESS, OSIZE, OBJ#, TYPE#, CASE WHEN STALENESS > LOG(0.
01, NVL(LOC_STALE_PCT, :B1 )/100) THEN 128 ELSE 0 END + AFLAGS AFLAGS, STATUS, S
ID, SERIAL#, PART#, BO# FROM ( SELECT /*+ no_expand dynamic_sampling(4) dynamic_

       8.2        2,503       0.00   16.4    1,112.4     .7   98.6 147a57cxq3w5y
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseproducts(:2 ,:3 ,:4 ); END;

       3.3        5,480       0.00    6.5    1,650.4     .2   99.6 0yas01u2p9ch4
Module: New Order
INSERT INTO ORDER_ITEMS(ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY
) VALUES (:B4 , :B3 , :B2 , :B1 , 1)

       2.6        6,117       0.00    5.2      931.8     .3   99.7 c13sma6rkr27c
Module: New Order
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.CATEGORY_
ID = :B3 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND INVENTORIES.WAREHO

       2.5        5,771       0.00    4.9    1,821.3     .1   99.7 8dq0v1mjngj7t
Module: New Order
SELECT CUSTOMER_ID, CUST_FIRST_NAME, CUST_LAST_NAME, NLS_LANGUAGE, NLS_TERRITORY
, CREDIT_LIMIT, CUST_EMAIL, ACCOUNT_MGR_ID FROM CUSTOMERS WHERE CUSTOMER_ID = :B
2 AND ROWNUM < :B1

       1.7          816       0.00    3.4      353.3     .5   98.7 dcq9a12vtcnuw
Module: Swingbench User Thread
BEGIN :1 := orderentry.newcustomer(:2 ,:3 ,:4 ,:5 ,:6 ,:7 ); END;

       1.7        2,047       0.00    3.3      839.0     .2   99.4 bymb3ujkr3ubk
Module: New Order
INSERT INTO ORDERS(ORDER_ID, ORDER_DATE, CUSTOMER_ID, WAREHOUSE_ID) VALUES (ORDE
RS_SEQ.NEXTVAL + :B3 , SYSTIMESTAMP , :B2 , :B1 ) RETURNING ORDER_ID INTO :O0

       1.5            1       1.51    3.0       14.5   10.4   35.8 1uk5m5qbzj1vt
Module: sqlplus@fabioprado.net (TNS V1-V3)
BEGIN dbms_workload_repository.create_snapshot; END;

       1.3            0        N/A    2.6       62.8    2.1   68.0 6mcpb06rctk0x
Module: DBMS_SCHEDULER
call dbms_space.auto_space_advisor_job_proc ( )

       1.1          405       0.00    2.3      411.1     .3   99.5 apgb2g9q2zjh1
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseandupdateorders(:2 ,:3 ,:4 ); END;

       1.0        7,471       0.00    2.1      144.4     .7   98.9 0y1prvxqc2ra9
Module: Browse Products
SQL ordered by CPU Time                      DB/Inst: ORCL/orcl  Snaps: 37-38
-> Resources reported for PL/SQL code includes the resources used by all SQL
   statements called by the code.
-> %Total - CPU Time      as a percentage of Total DB CPU
-> %CPU   - CPU Time      as a percentage of Elapsed Time
-> %IO    - User I/O Time as a percentage of Elapsed Time
-> Captured SQL account for   53.3% of Total CPU Time (s):              50
-> Captured PL/SQL account for   88.1% of Total CPU Time (s):              50

    CPU                   CPU per           Elapsed
  Time (s)  Executions    Exec (s) %Total   Time (s)   %CPU    %IO    SQL Id
---------- ------------ ---------- ------ ---------- ------ ------ -------------
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.PRODUCT_I
D = :B2 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND ROWNUM < :B1

       0.8        2,047       0.00    1.6      356.4     .2   99.6 5mddt5kt45rg3
Module: New Order
UPDATE ORDERS SET ORDER_MODE = 'online', ORDER_STATUS = FLOOR(DBMS_RANDOM.VALUE(
0, :B3 )), ORDER_TOTAL = :B2 WHERE ORDER_ID = :B1

       0.7          816       0.00    1.4      345.8     .2   99.3 0bzhqhhj9mpaa
Module: New Customer
INSERT INTO CUSTOMERS(CUSTOMER_ID ,CUST_FIRST_NAME ,CUST_LAST_NAME ,NLS_LANGUAGE
 ,NLS_TERRITORY ,CREDIT_LIMIT ,CUST_EMAIL ,ACCOUNT_MGR_ID ) VALUES (:B9 , :B4 ,
:B3 , :B8 , :B7 , FLOOR(DBMS_RANDOM.VALUE(:B6 , :B5 )), :B4 ||'.'||:B3 ||'@'||'o
racle.com', FLOOR(DBMS_RANDOM.VALUE(:B2 , :B1 )))

       0.6        6,018       0.00    1.1      177.3     .3   99.7 8z3542ffmp562
Module: New Order
SELECT QUANTITY_ON_HAND FROM PRODUCT_INFORMATION P, INVENTORIES I WHERE I.PRODUC
T_ID = :B2 AND I.PRODUCT_ID = P.PRODUCT_ID AND I.WAREHOUSE_ID = :B1

       0.5       14,233       0.00    1.0        0.6   86.2     .0 7sx5p1ug5ag12
Module: DBMS_SCHEDULER
SELECT SPARE4 FROM SYS.OPTSTAT_HIST_CONTROL$ WHERE SNAME = :B1

       0.5          205       0.00    1.0      218.5     .2   99.7 a9gvfh5hx9u98
Module: Swingbench User Thread
BEGIN :1 := orderentry.processorders(:2 ,:3 ,:4 ); END;

          -------------------------------------------------------------

SQL ordered by User I/O Wait Time            DB/Inst: ORCL/orcl  Snaps: 37-38
-> Resources reported for PL/SQL code includes the resources used by all SQL
   statements called by the code.
-> %Total - User I/O Time as a percentage of Total User I/O Wait time
-> %CPU   - CPU Time      as a percentage of Elapsed Time
-> %IO    - User I/O Time as a percentage of Elapsed Time
-> Captured SQL account for   99.8% of Total User I/O Wait Time (s):           6
-> Captured PL/SQL account for   99.9% of Total User I/O Wait Time (s):

  User I/O                UIO per           Elapsed
  Time (s)  Executions    Exec (s) %Total   Time (s)   %CPU    %IO    SQL Id
---------- ------------ ---------- ------ ---------- ------ ------ -------------
   4,692.9        2,047       2.29   68.4    4,733.3     .4   99.1 0w2qpuc6u2zsp
Module: Swingbench User Thread
BEGIN :1 := orderentry.neworder(:2 ,:3 ,:4 ); END;

   1,816.0        5,771       0.31   26.5    1,821.3     .1   99.7 8dq0v1mjngj7t
Module: New Order
SELECT CUSTOMER_ID, CUST_FIRST_NAME, CUST_LAST_NAME, NLS_LANGUAGE, NLS_TERRITORY
, CREDIT_LIMIT, CUST_EMAIL, ACCOUNT_MGR_ID FROM CUSTOMERS WHERE CUSTOMER_ID = :B
2 AND ROWNUM < :B1

   1,643.7        5,480       0.30   24.0    1,650.4     .2   99.6 0yas01u2p9ch4
Module: New Order
INSERT INTO ORDER_ITEMS(ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY
) VALUES (:B4 , :B3 , :B2 , :B1 , 1)

   1,096.4        2,503       0.44   16.0    1,112.4     .7   98.6 147a57cxq3w5y
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseproducts(:2 ,:3 ,:4 ); END;

     929.4        6,117       0.15   13.5      931.8     .3   99.7 c13sma6rkr27c
Module: New Order
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.CATEGORY_
ID = :B3 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND INVENTORIES.WAREHO

     834.0        2,047       0.41   12.2      839.0     .2   99.4 bymb3ujkr3ubk
Module: New Order
INSERT INTO ORDERS(ORDER_ID, ORDER_DATE, CUSTOMER_ID, WAREHOUSE_ID) VALUES (ORDE
RS_SEQ.NEXTVAL + :B3 , SYSTIMESTAMP , :B2 , :B1 ) RETURNING ORDER_ID INTO :O0

     409.1          405       1.01    6.0      411.1     .3   99.5 apgb2g9q2zjh1
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseandupdateorders(:2 ,:3 ,:4 ); END;

     355.0        2,047       0.17    5.2      356.4     .2   99.6 5mddt5kt45rg3
Module: New Order
UPDATE ORDERS SET ORDER_MODE = 'online', ORDER_STATUS = FLOOR(DBMS_RANDOM.VALUE(
0, :B3 )), ORDER_TOTAL = :B2 WHERE ORDER_ID = :B1

     348.7          816       0.43    5.1      353.3     .5   98.7 dcq9a12vtcnuw
Module: Swingbench User Thread
BEGIN :1 := orderentry.newcustomer(:2 ,:3 ,:4 ,:5 ,:6 ,:7 ); END;

     343.2          816       0.42    5.0      345.8     .2   99.3 0bzhqhhj9mpaa
Module: New Customer
INSERT INTO CUSTOMERS(CUSTOMER_ID ,CUST_FIRST_NAME ,CUST_LAST_NAME ,NLS_LANGUAGE
 ,NLS_TERRITORY ,CREDIT_LIMIT ,CUST_EMAIL ,ACCOUNT_MGR_ID ) VALUES (:B9 , :B4 ,
:B3 , :B8 , :B7 , FLOOR(DBMS_RANDOM.VALUE(:B6 , :B5 )), :B4 ||'.'||:B3 ||'@'||'o
racle.com', FLOOR(DBMS_RANDOM.VALUE(:B2 , :B1 )))

     217.8          205       1.06    3.2      218.5     .2   99.7 a9gvfh5hx9u98
Module: Swingbench User Thread
BEGIN :1 := orderentry.processorders(:2 ,:3 ,:4 ); END;

     180.1          205       0.88    2.6      180.5     .1   99.8 7hk2m2702ua0g
Module: Process Orders
WITH NEED_TO_PROCESS AS (SELECT ORDER_ID, CUSTOMER_ID FROM ORDERS WHERE ORDER_ST
ATUS <= 4 AND WAREHOUSE_ID = :B1 AND ROWNUM < 10 ) SELECT O.ORDER_ID, OI.LINE_IT
EM_ID, OI.PRODUCT_ID, OI.UNIT_PRICE, OI.QUANTITY, O.ORDER_MODE, O.ORDER_STATUS,
SQL ordered by User I/O Wait Time            DB/Inst: ORCL/orcl  Snaps: 37-38
-> Resources reported for PL/SQL code includes the resources used by all SQL
   statements called by the code.
-> %Total - User I/O Time as a percentage of Total User I/O Wait time
-> %CPU   - CPU Time      as a percentage of Elapsed Time
-> %IO    - User I/O Time as a percentage of Elapsed Time
-> Captured SQL account for   99.8% of Total User I/O Wait Time (s):           6
-> Captured PL/SQL account for   99.9% of Total User I/O Wait Time (s):

  User I/O                UIO per           Elapsed
  Time (s)  Executions    Exec (s) %Total   Time (s)   %CPU    %IO    SQL Id
---------- ------------ ---------- ------ ---------- ------ ------ -------------
O.ORDER_TOTAL, O.SALES_REP_ID, O.PROMOTION_ID, C.CUSTOMER_ID, C.CUST_FIRST_NAME,

     176.8        6,018       0.03    2.6      177.3     .3   99.7 8z3542ffmp562
Module: New Order
SELECT QUANTITY_ON_HAND FROM PRODUCT_INFORMATION P, INVENTORIES I WHERE I.PRODUC
T_ID = :B2 AND I.PRODUCT_ID = P.PRODUCT_ID AND I.WAREHOUSE_ID = :B1

     171.0          405       0.42    2.5      172.0     .1   99.4 0ruh367af7gbw
Module: Browse and Update Orders
SELECT ORDER_ID, ORDER_MODE, CUSTOMER_ID, ORDER_STATUS, ORDER_TOTAL, SALES_REP_I
D, PROMOTION_ID FROM ORDERS WHERE CUSTOMER_ID = :B2 AND ROWNUM < :B1

     142.9        7,471       0.02    2.1      144.4     .7   98.9 0y1prvxqc2ra9
Module: Browse Products
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.PRODUCT_I
D = :B2 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND ROWNUM < :B1

          -------------------------------------------------------------

SQL ordered by Gets                          DB/Inst: ORCL/orcl  Snaps: 37-38
-> Resources reported for PL/SQL code includes the resources used by all SQL
   statements called by the code.
-> %Total - Buffer Gets   as a percentage of Total Buffer Gets
-> %CPU   - CPU Time      as a percentage of Elapsed Time
-> %IO    - User I/O Time as a percentage of Elapsed Time
-> Total Buffer Gets:         731,220
-> Captured SQL account for  101.1% of Total

     Buffer                 Gets              Elapsed
      Gets   Executions   per Exec   %Total   Time (s)   %CPU    %IO    SQL Id
----------- ----------- ------------ ------ ---------- ------ ------ -----------
    433,407       2,047        211.7   59.3    4,733.3     .4   99.1 0w2qpuc6u2z
Module: Swingbench User Thread
BEGIN :1 := orderentry.neworder(:2 ,:3 ,:4 ); END;

    182,986       6,117         29.9   25.0      931.8     .3   99.7 c13sma6rkr2
Module: New Order
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.CATEGORY_
ID = :B3 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND INVENTORIES.WAREHO

    100,729       5,480         18.4   13.8    1,650.4     .2   99.6 0yas01u2p9c
Module: New Order
INSERT INTO ORDER_ITEMS(ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY
) VALUES (:B4 , :B3 , :B2 , :B1 , 1)

     98,828           0          N/A   13.5       68.1   14.5   55.5 b6usrg82hws
Module: DBMS_SCHEDULER
call dbms_stats.gather_database_stats_job_proc ( )

     95,493       2,503         38.2   13.1    1,112.4     .7   98.6 147a57cxq3w
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseproducts(:2 ,:3 ,:4 ); END;

     81,977           1     81,977.0   11.2       14.1   65.1   26.7 2tr12b1b8uj
Module: DBMS_SCHEDULER
MERGE /*+ dynamic_sampling(ST 4) dynamic_sampling_est_cdn(ST) */ INTO STATS_TARG
ET$ ST USING (SELECT STALENESS, OSIZE, OBJ#, TYPE#, CASE WHEN STALENESS > LOG(0.
01, NVL(LOC_STALE_PCT, :B1 )/100) THEN 128 ELSE 0 END + AFLAGS AFLAGS, STATUS, S
ID, SERIAL#, PART#, BO# FROM ( SELECT /*+ no_expand dynamic_sampling(4) dynamic_

     67,944       7,471          9.1    9.3      144.4     .7   98.9 0y1prvxqc2r
Module: Browse Products
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.PRODUCT_I
D = :B2 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND ROWNUM < :B1

     45,960       2,047         22.5    6.3      839.0     .2   99.4 bymb3ujkr3u
Module: New Order
INSERT INTO ORDERS(ORDER_ID, ORDER_DATE, CUSTOMER_ID, WAREHOUSE_ID) VALUES (ORDE
RS_SEQ.NEXTVAL + :B3 , SYSTIMESTAMP , :B2 , :B1 ) RETURNING ORDER_ID INTO :O0

     42,719      14,233          3.0    5.8        0.6   86.2     .0 7sx5p1ug5ag
Module: DBMS_SCHEDULER
SELECT SPARE4 FROM SYS.OPTSTAT_HIST_CONTROL$ WHERE SNAME = :B1

     41,074           0          N/A    5.6       62.8    2.1   68.0 6mcpb06rctk
Module: DBMS_SCHEDULER
call dbms_space.auto_space_advisor_job_proc ( )

     34,567       5,771          6.0    4.7       38.0    1.3   91.7 5raw2bzx227
Module: New Order
INSERT INTO LOGON VALUES (:B2 , :B1 )

     34,500       6,018          5.7    4.7      177.3     .3   99.7 8z3542ffmp5
Module: New Order
SELECT QUANTITY_ON_HAND FROM PRODUCT_INFORMATION P, INVENTORIES I WHERE I.PRODUC
T_ID = :B2 AND I.PRODUCT_ID = P.PRODUCT_ID AND I.WAREHOUSE_ID = :B1

SQL ordered by Gets                          DB/Inst: ORCL/orcl  Snaps: 37-38
-> Resources reported for PL/SQL code includes the resources used by all SQL
   statements called by the code.
-> %Total - Buffer Gets   as a percentage of Total Buffer Gets
-> %CPU   - CPU Time      as a percentage of Elapsed Time
-> %IO    - User I/O Time as a percentage of Elapsed Time
-> Total Buffer Gets:         731,220
-> Captured SQL account for  101.1% of Total

     Buffer                 Gets              Elapsed
      Gets   Executions   per Exec   %Total   Time (s)   %CPU    %IO    SQL Id
----------- ----------- ------------ ------ ---------- ------ ------ -----------
     28,352         816         34.7    3.9      353.3     .5   98.7 dcq9a12vtcn
Module: Swingbench User Thread
BEGIN :1 := orderentry.newcustomer(:2 ,:3 ,:4 ,:5 ,:6 ,:7 ); END;

     23,086       5,771          4.0    3.2    1,821.3     .1   99.7 8dq0v1mjngj
Module: New Order
SELECT CUSTOMER_ID, CUST_FIRST_NAME, CUST_LAST_NAME, NLS_LANGUAGE, NLS_TERRITORY
, CREDIT_LIMIT, CUST_EMAIL, ACCOUNT_MGR_ID FROM CUSTOMERS WHERE CUSTOMER_ID = :B
2 AND ROWNUM < :B1

     22,731       2,047         11.1    3.1      356.4     .2   99.6 5mddt5kt45r
Module: New Order
UPDATE ORDERS SET ORDER_MODE = 'online', ORDER_STATUS = FLOOR(DBMS_RANDOM.VALUE(
0, :B3 )), ORDER_TOTAL = :B2 WHERE ORDER_ID = :B1

     22,139       1,964         11.3    3.0        1.2   15.1   28.4 7r7636982at
Module: New Order
UPDATE INVENTORIES SET QUANTITY_ON_HAND = QUANTITY_ON_HAND - :B1 WHERE PRODUCT_I
D = :B3 AND WAREHOUSE_ID = :B2

     18,531         816         22.7    2.5      345.8     .2   99.3 0bzhqhhj9mp
Module: New Customer
INSERT INTO CUSTOMERS(CUSTOMER_ID ,CUST_FIRST_NAME ,CUST_LAST_NAME ,NLS_LANGUAGE
 ,NLS_TERRITORY ,CREDIT_LIMIT ,CUST_EMAIL ,ACCOUNT_MGR_ID ) VALUES (:B9 , :B4 ,
:B3 , :B8 , :B7 , FLOOR(DBMS_RANDOM.VALUE(:B6 , :B5 )), :B4 ||'.'||:B3 ||'@'||'o
racle.com', FLOOR(DBMS_RANDOM.VALUE(:B2 , :B1 )))

     14,220      14,220          1.0    1.9        0.4  100.3     .0 cn39cg7kr98
Module: DBMS_SCHEDULER
SELECT P.VALCHAR FROM SYS.OPTSTAT_USER_PREFS$ P WHERE P.OBJ#=:B2 AND P.PNAME=:B1


     10,820           1     10,820.0    1.5        5.2    2.8   96.4 01xv155rhts
Module: DBMS_SCHEDULER
SELECT COUNT(*) FROM SYS_UNCOMPRESSED_SEGS WHERE TOTAL_INDEXES >= 3 AND SEGSIZE
> 10485760

     10,114           1     10,114.0    1.4       14.5   10.4   35.8 1uk5m5qbzj1
Module: sqlplus@fabioprado.net (TNS V1-V3)
BEGIN dbms_workload_repository.create_snapshot; END;

      7,837          38        206.2    1.1       10.1    1.3   68.4 8bmx9xzmx4u
Module: DBMS_SCHEDULER
SELECT OWNER, SEGMENT_NAME, PARTITION_NAME, SEGMENT_TYPE, TABLESPACE_NAME, TABLE
SPACE_ID FROM SYS_DBA_SEGS WHERE SEGMENT_OBJD = :B1 AND SEGMENT_TYPE <> 'ROLLBAC
K' AND SEGMENT_TYPE <> 'TYPE2 UNDO' AND SEGMENT_TYPE <> 'DEFERRED ROLLBACK' AND
SEGMENT_TYPE <> 'TEMPORARY' AND SEGMENT_TYPE <> 'CACHE' AND SEGMENT_TYPE <> 'SPA

      7,797         405         19.3    1.1      411.1     .3   99.5 apgb2g9q2zj
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseandupdateorders(:2 ,:3 ,:4 ); END;

          -------------------------------------------------------------

SQL ordered by Reads                         DB/Inst: ORCL/orcl  Snaps: 37-38
-> %Total - Physical Reads as a percentage of Total Disk Reads
-> %CPU   - CPU Time      as a percentage of Elapsed Time
-> %IO    - User I/O Time as a percentage of Elapsed Time
-> Total Disk Reads:          47,336
-> Captured SQL account for   97.4% of Total

   Physical              Reads              Elapsed
      Reads  Executions per Exec   %Total   Time (s)   %CPU    %IO    SQL Id
----------- ----------- ---------- ------ ---------- ------ ------ -------------
     30,833       2,047       15.1   65.1    4,733.3     .4   99.1 0w2qpuc6u2zsp
Module: Swingbench User Thread
BEGIN :1 := orderentry.neworder(:2 ,:3 ,:4 ); END;

      9,192       5,480        1.7   19.4    1,650.4     .2   99.6 0yas01u2p9ch4
Module: New Order
INSERT INTO ORDER_ITEMS(ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY
) VALUES (:B4 , :B3 , :B2 , :B1 , 1)

      8,268       2,047        4.0   17.5      839.0     .2   99.4 bymb3ujkr3ubk
Module: New Order
INSERT INTO ORDERS(ORDER_ID, ORDER_DATE, CUSTOMER_ID, WAREHOUSE_ID) VALUES (ORDE
RS_SEQ.NEXTVAL + :B3 , SYSTIMESTAMP , :B2 , :B1 ) RETURNING ORDER_ID INTO :O0

      7,810       5,771        1.4   16.5    1,821.3     .1   99.7 8dq0v1mjngj7t
Module: New Order
SELECT CUSTOMER_ID, CUST_FIRST_NAME, CUST_LAST_NAME, NLS_LANGUAGE, NLS_TERRITORY
, CREDIT_LIMIT, CUST_EMAIL, ACCOUNT_MGR_ID FROM CUSTOMERS WHERE CUSTOMER_ID = :B
2 AND ROWNUM < :B1

      7,536       6,117        1.2   15.9      931.8     .3   99.7 c13sma6rkr27c
Module: New Order
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.CATEGORY_
ID = :B3 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND INVENTORIES.WAREHO

      6,081         405       15.0   12.8      411.1     .3   99.5 apgb2g9q2zjh1
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseandupdateorders(:2 ,:3 ,:4 ); END;

      4,986         405       12.3   10.5      172.0     .1   99.4 0ruh367af7gbw
Module: Browse and Update Orders
SELECT ORDER_ID, ORDER_MODE, CUSTOMER_ID, ORDER_STATUS, ORDER_TOTAL, SALES_REP_I
D, PROMOTION_ID FROM ORDERS WHERE CUSTOMER_ID = :B2 AND ROWNUM < :B1

      4,977       2,503        2.0   10.5    1,112.4     .7   98.6 147a57cxq3w5y
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseproducts(:2 ,:3 ,:4 ); END;

      1,532           0        N/A    3.2       68.1   14.5   55.5 b6usrg82hwsa3
Module: DBMS_SCHEDULER
call dbms_stats.gather_database_stats_job_proc ( )

      1,495         205        7.3    3.2      218.5     .2   99.7 a9gvfh5hx9u98
Module: Swingbench User Thread
BEGIN :1 := orderentry.processorders(:2 ,:3 ,:4 ); END;

      1,454         816        1.8    3.1      353.3     .5   98.7 dcq9a12vtcnuw
Module: Swingbench User Thread
BEGIN :1 := orderentry.newcustomer(:2 ,:3 ,:4 ,:5 ,:6 ,:7 ); END;

      1,427         816        1.7    3.0      345.8     .2   99.3 0bzhqhhj9mpaa
Module: New Customer
INSERT INTO CUSTOMERS(CUSTOMER_ID ,CUST_FIRST_NAME ,CUST_LAST_NAME ,NLS_LANGUAGE
 ,NLS_TERRITORY ,CREDIT_LIMIT ,CUST_EMAIL ,ACCOUNT_MGR_ID ) VALUES (:B9 , :B4 ,
:B3 , :B8 , :B7 , FLOOR(DBMS_RANDOM.VALUE(:B6 , :B5 )), :B4 ||'.'||:B3 ||'@'||'o
racle.com', FLOOR(DBMS_RANDOM.VALUE(:B2 , :B1 )))

      1,403       2,047        0.7    3.0      356.4     .2   99.6 5mddt5kt45rg3
SQL ordered by Reads                         DB/Inst: ORCL/orcl  Snaps: 37-38
-> %Total - Physical Reads as a percentage of Total Disk Reads
-> %CPU   - CPU Time      as a percentage of Elapsed Time
-> %IO    - User I/O Time as a percentage of Elapsed Time
-> Total Disk Reads:          47,336
-> Captured SQL account for   97.4% of Total

   Physical              Reads              Elapsed
      Reads  Executions per Exec   %Total   Time (s)   %CPU    %IO    SQL Id
----------- ----------- ---------- ------ ---------- ------ ------ -------------
Module: New Order
UPDATE ORDERS SET ORDER_MODE = 'online', ORDER_STATUS = FLOOR(DBMS_RANDOM.VALUE(
0, :B3 )), ORDER_TOTAL = :B2 WHERE ORDER_ID = :B1

      1,297         205        6.3    2.7      180.5     .1   99.8 7hk2m2702ua0g
Module: Process Orders
WITH NEED_TO_PROCESS AS (SELECT ORDER_ID, CUSTOMER_ID FROM ORDERS WHERE ORDER_ST
ATUS <= 4 AND WAREHOUSE_ID = :B1 AND ROWNUM < 10 ) SELECT O.ORDER_ID, OI.LINE_IT
EM_ID, OI.PRODUCT_ID, OI.UNIT_PRICE, OI.QUANTITY, O.ORDER_MODE, O.ORDER_STATUS,
O.ORDER_TOTAL, O.SALES_REP_ID, O.PROMOTION_ID, C.CUSTOMER_ID, C.CUST_FIRST_NAME,

      1,137       6,018        0.2    2.4      177.3     .3   99.7 8z3542ffmp562
Module: New Order
SELECT QUANTITY_ON_HAND FROM PRODUCT_INFORMATION P, INVENTORIES I WHERE I.PRODUC
T_ID = :B2 AND I.PRODUCT_ID = P.PRODUCT_ID AND I.WAREHOUSE_ID = :B1

        959       7,471        0.1    2.0      144.4     .7   98.9 0y1prvxqc2ra9
Module: Browse Products
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.PRODUCT_I
D = :B2 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND ROWNUM < :B1

        870           0        N/A    1.8       62.8    2.1   68.0 6mcpb06rctk0x
Module: DBMS_SCHEDULER
call dbms_space.auto_space_advisor_job_proc ( )

          -------------------------------------------------------------

SQL ordered by Physical Reads (UnOptimized)  DB/Inst: ORCL/orcl  Snaps: 37-38
-> UnOptimized Read Reqs = Physical Read Reqts - Optimized Read Reqs
-> %Opt   - Optimized Reads as percentage of SQL Read Requests
-> %Total - UnOptimized Read Reqs as a percentage of Total UnOptimized Read Reqs
-> Total Physical Read Requests:          38,018
-> Captured SQL account for   99.4% of Total
-> Total UnOptimized Read Requests:          38,018
-> Captured SQL account for   99.4% of Total
-> Total Optimized Read Requests:               1
-> Captured SQL account for    0.0% of Total

UnOptimized   Physical              UnOptimized
  Read Reqs   Read Reqs Executions Reqs per Exe   %Opt %Total    SQL Id
----------- ----------- ---------- ------------ ------ ------ -------------
     27,573      27,573      2,047         13.5    0.0   72.5 0w2qpuc6u2zsp
Module: Swingbench User Thread
BEGIN :1 := orderentry.neworder(:2 ,:3 ,:4 ); END;

      9,192       9,192      5,480          1.7    0.0   24.2 0yas01u2p9ch4
Module: New Order
INSERT INTO ORDER_ITEMS(ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY
) VALUES (:B4 , :B3 , :B2 , :B1 , 1)

      7,810       7,810      5,771          1.4    0.0   20.5 8dq0v1mjngj7t
Module: New Order
SELECT CUSTOMER_ID, CUST_FIRST_NAME, CUST_LAST_NAME, NLS_LANGUAGE, NLS_TERRITORY
, CREDIT_LIMIT, CUST_EMAIL, ACCOUNT_MGR_ID FROM CUSTOMERS WHERE CUSTOMER_ID = :B
2 AND ROWNUM < :B1

      7,536       7,536      6,117          1.2    0.0   19.8 c13sma6rkr27c
Module: New Order
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.CATEGORY_
ID = :B3 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND INVENTORIES.WAREHO

      5,007       5,007      2,047          2.4    0.0   13.2 bymb3ujkr3ubk
Module: New Order
INSERT INTO ORDERS(ORDER_ID, ORDER_DATE, CUSTOMER_ID, WAREHOUSE_ID) VALUES (ORDE
RS_SEQ.NEXTVAL + :B3 , SYSTIMESTAMP , :B2 , :B1 ) RETURNING ORDER_ID INTO :O0

      4,977       4,977      2,503          2.0    0.0   13.1 147a57cxq3w5y
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseproducts(:2 ,:3 ,:4 ); END;

      1,839       1,839        405          4.5    0.0    4.8 apgb2g9q2zjh1
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseandupdateorders(:2 ,:3 ,:4 ); END;

      1,454       1,454        816          1.8    0.0    3.8 dcq9a12vtcnuw
Module: Swingbench User Thread
BEGIN :1 := orderentry.newcustomer(:2 ,:3 ,:4 ,:5 ,:6 ,:7 ); END;

      1,427       1,427        816          1.7    0.0    3.8 0bzhqhhj9mpaa
Module: New Customer
INSERT INTO CUSTOMERS(CUSTOMER_ID ,CUST_FIRST_NAME ,CUST_LAST_NAME ,NLS_LANGUAGE
 ,NLS_TERRITORY ,CREDIT_LIMIT ,CUST_EMAIL ,ACCOUNT_MGR_ID ) VALUES (:B9 , :B4 ,
:B3 , :B8 , :B7 , FLOOR(DBMS_RANDOM.VALUE(:B6 , :B5 )), :B4 ||'.'||:B3 ||'@'||'o
racle.com', FLOOR(DBMS_RANDOM.VALUE(:B2 , :B1 )))

      1,403       1,403      2,047          0.7    0.0    3.7 5mddt5kt45rg3
Module: New Order
UPDATE ORDERS SET ORDER_MODE = 'online', ORDER_STATUS = FLOOR(DBMS_RANDOM.VALUE(
0, :B3 )), ORDER_TOTAL = :B2 WHERE ORDER_ID = :B1

      1,137       1,137      6,018          0.2    0.0    3.0 8z3542ffmp562
Module: New Order
SELECT QUANTITY_ON_HAND FROM PRODUCT_INFORMATION P, INVENTORIES I WHERE I.PRODUC
T_ID = :B2 AND I.PRODUCT_ID = P.PRODUCT_ID AND I.WAREHOUSE_ID = :B1

      1,054       1,054        205          5.1    0.0    2.8 a9gvfh5hx9u98
Module: Swingbench User Thread
BEGIN :1 := orderentry.processorders(:2 ,:3 ,:4 ); END;

SQL ordered by Physical Reads (UnOptimized)  DB/Inst: ORCL/orcl  Snaps: 37-38
-> UnOptimized Read Reqs = Physical Read Reqts - Optimized Read Reqs
-> %Opt   - Optimized Reads as percentage of SQL Read Requests
-> %Total - UnOptimized Read Reqs as a percentage of Total UnOptimized Read Reqs
-> Total Physical Read Requests:          38,018
-> Captured SQL account for   99.4% of Total
-> Total UnOptimized Read Requests:          38,018
-> Captured SQL account for   99.4% of Total
-> Total Optimized Read Requests:               1
-> Captured SQL account for    0.0% of Total

UnOptimized   Physical              UnOptimized
  Read Reqs   Read Reqs Executions Reqs per Exe   %Opt %Total    SQL Id
----------- ----------- ---------- ------------ ------ ------ -------------
        959         959      7,471          0.1    0.0    2.5 0y1prvxqc2ra9
Module: Browse Products
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.PRODUCT_I
D = :B2 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND ROWNUM < :B1

        856         856        205          4.2    0.0    2.3 7hk2m2702ua0g
Module: Process Orders
WITH NEED_TO_PROCESS AS (SELECT ORDER_ID, CUSTOMER_ID FROM ORDERS WHERE ORDER_ST
ATUS <= 4 AND WAREHOUSE_ID = :B1 AND ROWNUM < 10 ) SELECT O.ORDER_ID, OI.LINE_IT
EM_ID, OI.PRODUCT_ID, OI.UNIT_PRICE, OI.QUANTITY, O.ORDER_MODE, O.ORDER_STATUS,
O.ORDER_TOTAL, O.SALES_REP_ID, O.PROMOTION_ID, C.CUSTOMER_ID, C.CUST_FIRST_NAME,

        744         744        405          1.8    0.0    2.0 0ruh367af7gbw
Module: Browse and Update Orders
SELECT ORDER_ID, ORDER_MODE, CUSTOMER_ID, ORDER_STATUS, ORDER_TOTAL, SALES_REP_I
D, PROMOTION_ID FROM ORDERS WHERE CUSTOMER_ID = :B2 AND ROWNUM < :B1

        527         527          0          N/A    0.0    1.4 6mcpb06rctk0x
Module: DBMS_SCHEDULER
call dbms_space.auto_space_advisor_job_proc ( )

        505         505          0          N/A    0.0    1.3 b6usrg82hwsa3
Module: DBMS_SCHEDULER
call dbms_stats.gather_database_stats_job_proc ( )

          -------------------------------------------------------------

SQL ordered by Executions                    DB/Inst: ORCL/orcl  Snaps: 37-38
-> %CPU   - CPU Time      as a percentage of Elapsed Time
-> %IO    - User I/O Time as a percentage of Elapsed Time
-> Total Executions:          92,773
-> Captured SQL account for   88.6% of Total

                                              Elapsed
 Executions   Rows Processed  Rows per Exec   Time (s)   %CPU    %IO    SQL Id
------------ --------------- -------------- ---------- ------ ------ -----------
      14,233          14,233            1.0        0.6   86.2     .0 7sx5p1ug5ag
Module: DBMS_SCHEDULER
SELECT SPARE4 FROM SYS.OPTSTAT_HIST_CONTROL$ WHERE SNAME = :B1

      14,220               0            0.0        0.4  100.3     .0 cn39cg7kr98
Module: DBMS_SCHEDULER
SELECT P.VALCHAR FROM SYS.OPTSTAT_USER_PREFS$ P WHERE P.OBJ#=:B2 AND P.PNAME=:B1


       7,471         104,608           14.0      144.4     .7   98.9 0y1prvxqc2r
Module: Browse Products
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.PRODUCT_I
D = :B2 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND ROWNUM < :B1

       6,117          27,422            4.5      931.8     .3   99.7 c13sma6rkr2
Module: New Order
SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG
HT_CLASS, WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE, MIN_PRICE, C
ATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS, INVENTORIES WHERE PRODUCTS.CATEGORY_
ID = :B3 AND INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND INVENTORIES.WAREHO

       6,018           5,480            0.9      177.3     .3   99.7 8z3542ffmp5
Module: New Order
SELECT QUANTITY_ON_HAND FROM PRODUCT_INFORMATION P, INVENTORIES I WHERE I.PRODUC
T_ID = :B2 AND I.PRODUCT_ID = P.PRODUCT_ID AND I.WAREHOUSE_ID = :B1

       5,771           5,771            1.0       38.0    1.3   91.7 5raw2bzx227
Module: New Order
INSERT INTO LOGON VALUES (:B2 , :B1 )

       5,771           5,771            1.0    1,821.3     .1   99.7 8dq0v1mjngj
Module: New Order
SELECT CUSTOMER_ID, CUST_FIRST_NAME, CUST_LAST_NAME, NLS_LANGUAGE, NLS_TERRITORY
, CREDIT_LIMIT, CUST_EMAIL, ACCOUNT_MGR_ID FROM CUSTOMERS WHERE CUSTOMER_ID = :B
2 AND ROWNUM < :B1

       5,768           5,771            1.0        0.3   52.6     .0 c749bc43qqf
Module: New Order
SELECT SYSDATE FROM DUAL

       5,480           5,480            1.0    1,650.4     .2   99.6 0yas01u2p9c
Module: New Order
INSERT INTO ORDER_ITEMS(ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY
) VALUES (:B4 , :B3 , :B2 , :B1 , 1)

       2,503           2,503            1.0    1,112.4     .7   98.6 147a57cxq3w
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseproducts(:2 ,:3 ,:4 ); END;

       2,047           2,047            1.0    4,733.3     .4   99.1 0w2qpuc6u2z
Module: Swingbench User Thread
BEGIN :1 := orderentry.neworder(:2 ,:3 ,:4 ); END;

       2,047           2,047            1.0      356.4     .2   99.6 5mddt5kt45r
Module: New Order
UPDATE ORDERS SET ORDER_MODE = 'online', ORDER_STATUS = FLOOR(DBMS_RANDOM.VALUE(
0, :B3 )), ORDER_TOTAL = :B2 WHERE ORDER_ID = :B1

SQL ordered by Executions                    DB/Inst: ORCL/orcl  Snaps: 37-38
-> %CPU   - CPU Time      as a percentage of Elapsed Time
-> %IO    - User I/O Time as a percentage of Elapsed Time
-> Total Executions:          92,773
-> Captured SQL account for   88.6% of Total

                                              Elapsed
 Executions   Rows Processed  Rows per Exec   Time (s)   %CPU    %IO    SQL Id
------------ --------------- -------------- ---------- ------ ------ -----------
       2,047           2,047            1.0      839.0     .2   99.4 bymb3ujkr3u
Module: New Order
INSERT INTO ORDERS(ORDER_ID, ORDER_DATE, CUSTOMER_ID, WAREHOUSE_ID) VALUES (ORDE
RS_SEQ.NEXTVAL + :B3 , SYSTIMESTAMP , :B2 , :B1 ) RETURNING ORDER_ID INTO :O0

       1,964           5,480            2.8        1.2   15.1   28.4 7r7636982at
Module: New Order
UPDATE INVENTORIES SET QUANTITY_ON_HAND = QUANTITY_ON_HAND - :B1 WHERE PRODUCT_I
D = :B3 AND WAREHOUSE_ID = :B2

          -------------------------------------------------------------

SQL ordered by Parse Calls                   DB/Inst: ORCL/orcl  Snaps: 37-38
-> Total Parse Calls:          17,837
-> Captured SQL account for   22.5% of Total

                            % Total
 Parse Calls  Executions     Parses    SQL Id
------------ ------------ --------- -------------
       2,503        2,503     14.03 147a57cxq3w5y
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseproducts(:2 ,:3 ,:4 ); END;

       2,047        2,047     11.48 0w2qpuc6u2zsp
Module: Swingbench User Thread
BEGIN :1 := orderentry.neworder(:2 ,:3 ,:4 ); END;

         816          816      4.57 dcq9a12vtcnuw
Module: Swingbench User Thread
BEGIN :1 := orderentry.newcustomer(:2 ,:3 ,:4 ,:5 ,:6 ,:7 ); END;

         405          405      2.27 apgb2g9q2zjh1
Module: Swingbench User Thread
BEGIN :1 := orderentry.browseandupdateorders(:2 ,:3 ,:4 ); END;

         386          386      2.16 350f5yrnnmshs
lock table sys.mon_mods$ in exclusive mode nowait

         386          386      2.16 g00cj285jmgsw
update sys.mon_mods$ set inserts = inserts + :ins, updates = updates + :upd, del
etes = deletes + :del, flags = (decode(bitand(flags, :flag), :flag, flags, flags
 + :flag)), drop_segments = drop_segments + :dropseg, timestamp = :time where ob
j# = :objn

         209          209      1.17 cm5vu20fhtnq1
select /*+ connect_by_filtering */ privilege#,level from sysauth$ connect by gra
ntee#=prior privilege# and privilege#>0 start with grantee#=:1 and privilege#>0

         205          205      1.15 a9gvfh5hx9u98
Module: Swingbench User Thread
BEGIN :1 := orderentry.processorders(:2 ,:3 ,:4 ); END;

         173            6      0.97 0v3dvmc22qnam
insert into sys.col_usage$ (obj#, intcol#, equality_preds, equijoin_preds, noneq
uijoin_preds, range_preds, like_preds, null_preds, timestamp) values ( :objn,
:coln, decode(bitand(:flag,1),0,0,1), decode(bitand(:flag,2),0,0,1), decod
e(bitand(:flag,4),0,0,1), decode(bitand(:flag,8),0,0,1), decode(bitand(:flag

         173          442      0.97 3c1kubcdjnppq
update sys.col_usage$ set equality_preds = equality_preds + decode(bitan
d(:flag,1),0,0,1), equijoin_preds = equijoin_preds + decode(bitand(:flag
,2),0,0,1), nonequijoin_preds = nonequijoin_preds + decode(bitand(:flag,4),0,0
,1), range_preds = range_preds + decode(bitand(:flag,8),0,0,1),

          -------------------------------------------------------------

SQL ordered by Sharable Memory               DB/Inst: ORCL/orcl  Snaps: 37-38
-> Only Statements with Sharable Memory greater than 1048576 are displayed

Sharable Mem (b)  Executions   % Total    SQL Id
---------------- ------------ -------- -------------
       2,106,812            1     0.95 2tr12b1b8uj71
Module: DBMS_SCHEDULER
MERGE /*+ dynamic_sampling(ST 4) dynamic_sampling_est_cdn(ST) */ INTO STATS_TARG
ET$ ST USING (SELECT STALENESS, OSIZE, OBJ#, TYPE#, CASE WHEN STALENESS > LOG(0.
01, NVL(LOC_STALE_PCT, :B1 )/100) THEN 128 ELSE 0 END + AFLAGS AFLAGS, STATUS, S
ID, SERIAL#, PART#, BO# FROM ( SELECT /*+ no_expand dynamic_sampling(4) dynamic_

          -------------------------------------------------------------

SQL ordered by Version Count                 DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Instance Activity Stats                      DB/Inst: ORCL/orcl  Snaps: 37-38
-> Ordered by statistic name

Statistic                                     Total     per Second     per Trans
-------------------------------- ------------------ -------------- -------------
Batched IO (bound) vector count                   0            0.0           0.0
Batched IO (full) vector count                  208            0.6           0.0
Batched IO block miss count                   2,027            5.6           0.2
Batched IO buffer defrag count                  103            0.3           0.0
Batched IO double miss count                    916            2.5           0.1
Batched IO same unit count                        0            0.0           0.0
Batched IO single block count                   576            1.6           0.1
Batched IO vector block count                 1,659            4.6           0.2
Batched IO vector read count                    548            1.5           0.1
Block Cleanout Optim referenced               1,335            3.7           0.2
CCursor + sql area evicted                       17            0.1           0.0
CPU used by this session                      4,767           13.2           0.5
CPU used when call started                    3,613           10.0           0.4
CR blocks created                                48            0.1           0.0
Cached Commit SCN referenced                      0            0.0           0.0
Commit SCN cached                               148            0.4           0.0
DB time                                   1,454,326        4,021.4         161.7
DBWR checkpoint buffers written               3,176            8.8           0.4
DBWR checkpoints                                  0            0.0           0.0
DBWR transaction table writes                    28            0.1           0.0
DBWR undo block writes                          607            1.7           0.1
HSC Heap Segment Block Changes               24,764           68.5           2.8
Heap Segment Array Inserts                       79            0.2           0.0
Heap Segment Array Updates                       20            0.1           0.0
IMU CR rollbacks                                 21            0.1           0.0
IMU Flushes                                     582            1.6           0.1
IMU Redo allocation size                  3,215,316        8,890.8         357.5
IMU commits                                   6,834           18.9           0.8
IMU contention                                  448            1.2           0.1
IMU ktichg flush                                  3            0.0           0.0
IMU pool not allocated                        1,591            4.4           0.2
IMU undo allocation size                 19,704,704       54,486.0       2,191.1
IMU- failed to get a private str              1,591            4.4           0.2
LOB table id lookup cache misses                  0            0.0           0.0
Number of read IOs issued                         0            0.0           0.0
RowCR - row contention                            7            0.0           0.0
RowCR attempts                                2,846            7.9           0.3
RowCR hits                                    2,837            7.8           0.3
SMON posted for undo segment shr                 11            0.0           0.0
SQL*Net roundtrips to/from clien              6,298           17.4           0.7
TBS Extension: bytes extended                     0            0.0           0.0
TBS Extension: files extended                     0            0.0           0.0
TBS Extension: tasks created                      0            0.0           0.0
TBS Extension: tasks executed                     0            0.0           0.0
active txn count during cleanout                269            0.7           0.0
application wait time                             0            0.0           0.0
background checkpoints completed                  0            0.0           0.0
background checkpoints started                    0            0.0           0.0
background timeouts                           1,506            4.2           0.2
branch node splits                                1            0.0           0.0
buffer is not pinned count                  287,547          795.1          32.0
buffer is pinned count                      291,344          805.6          32.4
bytes received via SQL*Net from           1,278,058        3,534.0         142.1
bytes sent via SQL*Net to client            664,996        1,838.8          74.0
calls to get snapshot scn: kcmgs             91,677          253.5          10.2
calls to kcmgas                              10,858           30.0           1.2
calls to kcmgcs                              46,250          127.9           5.1
cell physical IO interconnect by        545,082,880    1,507,223.6      60,611.9
change write time                               116            0.3           0.0
cleanout - number of ktugct call              3,428            9.5           0.4
Instance Activity Stats                      DB/Inst: ORCL/orcl  Snaps: 37-38
-> Ordered by statistic name

Statistic                                     Total     per Second     per Trans
-------------------------------- ------------------ -------------- -------------
cleanouts and rollbacks - consis                 21            0.1           0.0
cleanouts only - consistent read                277            0.8           0.0
cluster key scan block gets                  18,417           50.9           2.1
cluster key scans                            16,666           46.1           1.9
commit batch/immediate performed                  6            0.0           0.0
commit batch/immediate requested                  6            0.0           0.0
commit cleanout failures: block                   6            0.0           0.0
commit cleanout failures: buffer                  5            0.0           0.0
commit cleanout failures: callba                  8            0.0           0.0
commit cleanout failures: cannot                126            0.4           0.0
commit cleanouts                             42,332          117.1           4.7
commit cleanouts successfully co             42,187          116.7           4.7
commit immediate performed                        6            0.0           0.0
commit immediate requested                        6            0.0           0.0
commit txn count during cleanout              3,963           11.0           0.4
concurrency wait time                         2,897            8.0           0.3
consistent changes                              255            0.7           0.0
consistent gets                             505,451        1,397.6          56.2
consistent gets - examination               301,067          832.5          33.5
consistent gets direct                            0            0.0           0.0
consistent gets from cache                  505,451        1,397.6          56.2
consistent gets from cache (fast            192,185          531.4          21.4
cursor authentications                          137            0.4           0.0
data blocks consistent reads - u                 56            0.2           0.0
db block changes                            146,506          405.1          16.3
db block gets                               225,769          624.3          25.1
db block gets direct                             38            0.1           0.0
db block gets from cache                    225,731          624.2          25.1
db block gets from cache (fastpa             76,841          212.5           8.5
deferred (CURRENT) block cleanou             17,990           49.7           2.0
dirty buffers inspected                       8,006           22.1           0.9
enqueue conversions                             311            0.9           0.0
enqueue releases                             44,413          122.8           4.9
enqueue requests                             44,424          122.8           4.9
enqueue timeouts                                  1            0.0           0.0
enqueue waits                                     3            0.0           0.0
execute count                                92,773          256.5          10.3
file io service time                            623            1.7           0.1
file io wait time                     6,744,677,484   18,649,892.0     749,991.9
free buffer inspected                        43,511          120.3           4.8
free buffer requested                        49,975          138.2           5.6
heap block compress                              25            0.1           0.0
hot buffers moved to head of LRU             20,716           57.3           2.3
immediate (CR) block cleanout ap                298            0.8           0.0
immediate (CURRENT) block cleano              2,318            6.4           0.3
index crx upgrade (positioned)                    0            0.0           0.0
index fast full scans (full)                      9            0.0           0.0
index fetch by key                          142,477          394.0          15.8
index scans kdiixs1                          24,421           67.5           2.7
leaf node 90-10 splits                           16            0.0           0.0
leaf node splits                                 85            0.2           0.0
lob reads                                        11            0.0           0.0
lob writes                                      114            0.3           0.0
lob writes unaligned                            114            0.3           0.0
logons cumulative                                90            0.3           0.0
max cf enq hold time                          1,890            5.2           0.2
messages received                             5,474           15.1           0.6
messages sent                                 5,474           15.1           0.6
min active SCN optimization appl              8,397           23.2           0.9
no work - consistent read gets              154,262          426.6          17.2
Instance Activity Stats                      DB/Inst: ORCL/orcl  Snaps: 37-38
-> Ordered by statistic name

Statistic                                     Total     per Second     per Trans
-------------------------------- ------------------ -------------- -------------
non-idle wait count                          75,058          207.5           8.4
non-idle wait time                          878,269        2,428.5          97.7
opened cursors cumulative                   100,941          279.1          11.2
parse count (describe)                            7            0.0           0.0
parse count (failures)                            5            0.0           0.0
parse count (hard)                              328            0.9           0.0
parse count (total)                          17,837           49.3           2.0
parse time cpu                                   82            0.2           0.0
parse time elapsed                            3,980           11.0           0.4
physical read IO requests                    38,018          105.1           4.2
physical read bytes                     387,776,512    1,072,251.4      43,119.8
physical read total IO requests              38,552          106.6           4.3
physical read total bytes               396,509,184    1,096,398.4      44,090.9
physical read total multi block                 285            0.8           0.0
physical reads                               47,336          130.9           5.3
physical reads cache                         47,336          130.9           5.3
physical reads cache prefetch                10,425           28.8           1.2
physical reads direct                             0            0.0           0.0
physical reads direct (lob)                       0            0.0           0.0
physical reads prefetch warmup                7,944           22.0           0.9
physical write IO requests                    9,495           26.3           1.1
physical write bytes                    120,586,240      333,436.3      13,408.9
physical write total IO requests             13,380           37.0           1.5
physical write total bytes              148,573,696      410,825.2      16,521.0
physical write total multi block                 69            0.2           0.0
physical writes                              14,720           40.7           1.6
physical writes direct                           38            0.1           0.0
physical writes direct (lob)                      0            0.0           0.0
physical writes direct temporary                  1            0.0           0.0
physical writes from cache                   14,682           40.6           1.6
physical writes non checkpoint               14,356           39.7           1.6
pinned buffers inspected                          2            0.0           0.0
pinned cursors current                            4            0.0           0.0
prefetch warmup blocks aged out               4,354           12.0           0.5
prefetched blocks aged out befor                167            0.5           0.0
process last non-idle time                   13,843           38.3           1.5
recursive calls                             179,879          497.4          20.0
recursive cpu usage                           1,854            5.1           0.2
redo blocks checksummed by FG (e             18,841           52.1           2.1
redo blocks written                          43,463          120.2           4.8
redo entries                                 39,393          108.9           4.4
redo ordering marks                             457            1.3           0.1
redo size                                20,574,124       56,890.1       2,287.8
redo size for direct writes                     208            0.6           0.0
redo subscn max counts                        2,054            5.7           0.2
redo synch time                             151,352          418.5          16.8
redo synch writes                             6,139           17.0           0.7
redo wastage                                933,440        2,581.1         103.8
redo write time                              25,792           71.3           2.9
redo writes                                   3,483            9.6           0.4
rollback changes - undo records                  11            0.0           0.0
rollbacks only - consistent read                 13            0.0           0.0
rows fetched via callback                    48,234          133.4           5.4
scheduler wait time                           5,964           16.5           0.7
session connect time                              0            0.0           0.0
session cursor cache hits                    97,379          269.3          10.8
session logical reads                       731,220        2,021.9          81.3
shared hash latch upgrades - no              23,596           65.3           2.6
sorts (memory)                                1,491            4.1           0.2
sorts (rows)                                 24,199           66.9           2.7
Instance Activity Stats                      DB/Inst: ORCL/orcl  Snaps: 37-38
-> Ordered by statistic name

Statistic                                     Total     per Second     per Trans
-------------------------------- ------------------ -------------- -------------
sql area evicted                                143            0.4           0.0
sql area purged                                   8            0.0           0.0
summed dirty queue length                    24,427           67.5           2.7
switch current to new buffer                     61            0.2           0.0
table fetch by rowid                        202,035          558.7          22.5
table fetch continued row                       206            0.6           0.0
table scan blocks gotten                     47,299          130.8           5.3
table scan rows gotten                    1,355,176        3,747.2         150.7
table scans (long tables)                         0            0.0           0.0
table scans (short tables)                   15,062           41.7           1.7
temp space allocated (bytes)              5,242,880       14,497.2         583.0
total cf enq hold time                        3,890           10.8           0.4
total number of cf enq holders                   14            0.0           0.0
total number of times SMON poste                 11            0.0           0.0
transaction rollbacks                             6            0.0           0.0
undo change vector size                   6,909,880       19,106.7         768.4
user I/O wait time                          687,066        1,899.8          76.4
user calls                                   12,544           34.7           1.4
user commits                                  8,993           24.9           1.0
workarea executions - optimal                   668            1.9           0.1
write clones created in foregrou                 17            0.1           0.0
          -------------------------------------------------------------

Instance Activity Stats - Absolute Values    DB/Inst: ORCL/orcl  Snaps: 37-38
-> Statistics with absolute values (should not be diffed)

Statistic                            Begin Value       End Value
-------------------------------- --------------- ---------------
session pga memory max               248,230,328     308,024,768
session cursor cache count                 4,536           7,127
session uga memory               1.975906811E+11 2.018948513E+11
opened cursors current                        39              58
logons current                                25              27
session uga memory max               371,408,336     625,059,064
session pga memory                   151,482,136     193,123,104
          -------------------------------------------------------------

Instance Activity Stats - Thread Activity     DB/Inst: ORCL/orcl  Snaps: 37-38
-> Statistics identified by '(derived)' come from sources other than SYSSTAT

Statistic                                     Total  per Hour
-------------------------------- ------------------ ---------
log switches (derived)                            0       .00
          -------------------------------------------------------------

IOStat by Function summary                    DB/Inst: ORCL/orcl  Snaps: 37-38
-> 'Data' columns suffixed with M,G,T,P are in multiples of 1024
    other columns suffixed with K,M,G,T,P are in multiples of 1000
-> ordered by (Data Read + Write) desc

                Reads:   Reqs   Data    Writes:  Reqs   Data    Waits:    Avg
Function Name   Data    per sec per sec Data    per sec per sec Count    Tm(ms)
--------------- ------- ------- ------- ------- ------- ------- ------- -------
Buffer Cache Re    370M   105.3 1.02309      0M     0.0      0M   37.5K   187.4
DBWR                 0M     0.0      0M    118M    27.0 .326285    2004    25.2
LGWR                 0M     0.0      0M     21M     9.8 .058067    3482    73.6
Others               8M     1.5 .022121      5M     1.0 .013825     880    29.0
Direct Writes        0M     0.0      0M      0M     0.0      0M       5     0.0
TOTAL:             378M   106.7 1.04521    144M    37.7 .398178   43.9K   167.8
          -------------------------------------------------------------

IOStat by Filetype summary                    DB/Inst: ORCL/orcl  Snaps: 37-38
-> 'Data' columns suffixed with M,G,T,P are in multiples of 1024
    other columns suffixed with K,M,G,T,P are in multiples of 1000
-> Small Read and Large Read are average service times, in milliseconds
-> Ordered by (Data Read + Write) desc

                Reads:   Reqs   Data    Writes:  Reqs   Data      Small   Large
Filetype Name   Data    per sec per sec Data    per sec per sec    Read    Read
--------------- ------- ------- ------- ------- ------- ------- ------- -------
Data File          369M   105.3 1.02033    119M    27.0 .329050   184.5   202.9
Log File             0M     0.0      0M     21M     9.8 .058067     N/A     N/A
Control File         8M     1.4 .022121      6M     1.0 .016590     2.3     N/A
Temp File            0M     0.0      0M      0M     0.0      0M    33.0     N/A
TOTAL:             377M   106.7 1.04245    146M    37.7 .403708   182.0   202.9
          -------------------------------------------------------------

IOStat by Function/Filetype summary           DB/Inst: ORCL/orcl  Snaps: 37-38
-> 'Data' columns suffixed with M,G,T,P are in multiples of 1024
    other columns suffixed with K,M,G,T,P are in multiples of 1000
-> Ordered by (Data Read + Write) desc for each function

 Reads:   Reqs   Data    Writes:  Reqs   Data    Waits:    Avg
 Data    per sec per sec Data    per sec per sec Count    Tm(ms)
 ------- ------- ------- ------- ------- ------- ------- -------
Buffer Cache Reads
    370M   105.3 1.02309      0M     0.0      0M   36.4K   183.9
 Buffer Cache Reads (Data File)
    370M   105.3 1.02309      0M     0.0      0M   36.4K   183.9
DBWR
      0M     0.0      0M    118M    27.0 .326285       0     N/A
 DBWR (Data File)
      0M     0.0      0M    118M    27.0 .326285       0     N/A
LGWR
      0M     0.0      0M     21M     9.8 .058067       0     N/A
 LGWR (Log File)
      0M     0.0      0M     21M     9.8 .058067       0     N/A
Others
      8M     1.5 .022121      5M     1.0 .013825     530     3.7
 Others (Control File)
      8M     1.4 .022121      5M     1.0 .013825     524     2.3
 Others (Data File)
      0M     0.0      0M      0M     0.0      0M       6   131.3
Direct Writes
      0M     0.0      0M      0M     0.0      0M       0     N/A
 Direct Writes (Data File)
      0M     0.0      0M      0M     0.0      0M       0     N/A
TOTAL:
    378M   106.7 1.04521    144M    37.7 .398178     37K   181.3
          -------------------------------------------------------------

Tablespace IO Stats                          DB/Inst: ORCL/orcl  Snaps: 37-38
-> ordered by IOs (Reads + Writes) desc

Tablespace
------------------------------
                 Av       Av     Av                       Av     Buffer  Av Buf
         Reads Reads/s  Rd(ms) Blks/Rd       Writes Writes/s      Waits  Wt(ms)
-------------- ------- ------- ------- ------------ -------- ---------- -------
SOE
        37,134     103   177.6     1.2        9,009       25         34   203.2 @jls
SYSTEM
           694       2   115.7     3.0           16        0         67    14.0
SYSAUX
            50       0   103.4     1.1          218        1          0     0.0
UNDOTBS1
             8       0   320.0     1.0           80        0          1     0.0
TEMP
             1       0    40.0     1.0            3        0          0     0.0
          -------------------------------------------------------------

File IO Stats                                DB/Inst: ORCL/orcl  Snaps: 37-38
-> ordered by Tablespace, File

Tablespace               Filename
------------------------ ----------------------------------------------------
                 Av       Av     Av                       Av     Buffer  Av Buf
         Reads Reads/s  Rd(ms) Blks/Rd       Writes Writes/s      Waits  Wt(ms)
-------------- ------- ------- ------- ------------ -------- ---------- -------
SOE                      /home/oracle/app/oracle/product/11.2.0/dbs/soe.dbf
        37,134     103   177.6     1.2        9,009       25         34   203.2
SYSAUX                   /home/oracle/app/oracle/oradata/orcl/sysaux01.dbf
            50       0   103.4     1.1          218        1          0     0.0
SYSTEM                   /home/oracle/app/oracle/oradata/orcl/system01.dbf
           694       2   115.7     3.0           16        0         67    14.0
TEMP                     /home/oracle/app/oracle/oradata/orcl/temp01.dbf
             1       0    40.0     1.0            3        0          0     N/A
UNDOTBS1                 /home/oracle/app/oracle/oradata/orcl/undotbs01.dbf
             8       0   320.0     1.0           80        0          1     0.0
          -------------------------------------------------------------

Buffer Pool Statistics                       DB/Inst: ORCL/orcl  Snaps: 37-38
-> Standard block size Pools  D: default,  K: keep,  R: recycle
-> Default Pools for other block sizes: 2k, 4k, 8k, 16k, 32k

                                                            Free   Writ   Buffer
     Number of Pool       Buffer     Physical    Physical   Buff   Comp     Busy
P      Buffers Hit%         Gets        Reads      Writes   Wait   Wait    Waits
--- ---------- ---- ------------ ------------ ----------- ------ ------ --------
D       52,046   95      714,328       38,622      14,220      0      0      101
K       12,275   42       14,873        8,694         462      0      0        1
          -------------------------------------------------------------

Checkpoint Activity                           DB/Inst: ORCL/orcl  Snaps: 37-38
-> Total Physical Writes:                       14,720

                                          Other    Autotune      Thread
       MTTR    Log Size    Log Ckpt    Settings        Ckpt        Ckpt
     Writes      Writes      Writes      Writes      Writes      Writes
----------- ----------- ----------- ----------- ----------- -----------
          0           0           0           0       3,176           0
          -------------------------------------------------------------

Instance Recovery Stats                       DB/Inst: ORCL/orcl  Snaps: 37-38
-> B: Begin Snapshot,  E: End Snapshot

                                                                            Estd
  Targt  Estd                                     Log Ckpt Log Ckpt    Opt   RAC
  MTTR   MTTR Recovery  Actual   Target   Log Sz   Timeout Interval    Log Avail
   (s)    (s) Estd IOs RedoBlks RedoBlks RedoBlks RedoBlks RedoBlks  Sz(M)  Time
- ----- ----- -------- -------- -------- -------- -------- -------- ------ -----
B     0    33     1667     2577    12920   165888    12920      N/A    N/A   N/A
E     0   140    14030    38327    56359   165888    56359      N/A    N/A   N/A
          -------------------------------------------------------------

MTTR Advisory                                     DB/Inst: ORCL/orcl  Snap: 38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Buffer Pool Advisory                              DB/Inst: ORCL/orcl  Snap: 38
-> Only rows with estimated physical reads >0 are displayed
-> ordered by Block Size, Buffers For Estimate

                                    Est
                                   Phys      Estimated                  Est
    Size for   Size      Buffers   Read     Phys Reads     Est Phys %DBtime
P    Est (M) Factor  (thousands) Factor    (thousands)    Read Time for Rds
--- -------- ------ ------------ ------ -------------- ------------ -------
D         40     .1            5    2.1            205            1 2.0E+04
D         80     .2           10    1.6            158            1 1.5E+04
D        120     .3           15    1.4            134            1 1.2E+04
D        160     .4           20    1.2            123            1 1.1E+04
D        200     .5           25    1.2            117            1 1.0E+04
D        240     .6           29    1.1            112            1  9508.0
D        280     .7           34    1.1            108            1  9051.0
D        320     .8           39    1.1            105            1  8775.0
D        360     .8           44    1.0            103            1  8517.0
D        400     .9           49    1.0             99            1  8056.0
D        424    1.0           52    1.0             98            1  8000.0	@jls não compensa aumentar o tamanho pois o ganho será pouco, de 98 para 96 mesmo se dobrar o tamanho de 424 para 800
D        440    1.0           54    1.0             98            1  7973.0
D        480    1.1           59    1.0             98            1  7930.0
D        520    1.2           64    1.0             98            1  7892.0
D        560    1.3           69    1.0             97            1  7870.0
D        600    1.4           74    1.0             96            1  7744.0
D        640    1.5           79    1.0             96            1  7744.0
D        680    1.6           83    1.0             96            1  7744.0
D        720    1.7           88    1.0             96            1  7744.0
D        760    1.8           93    1.0             96            1  7744.0
D        800    1.9           98    1.0             96            1  7744.0
K          8     .1            1    1.1             14            1   562.0
K         16     .2            2    1.0             13            1   260.0
K         24     .2            3    1.0             12            1   236.0
K         32     .3            4    1.0             12            1   236.0
K         40     .4            5    1.0             12            1   236.0
K         48     .5            6    1.0             12            1   236.0
K         56     .6            7    1.0             12            1   236.0
K         64     .6            8    1.0             12            1   236.0
K         72     .7            9    1.0             12            1   236.0
K         80     .8           10    1.0             12            1   236.0
K         88     .9           11    1.0             12            1   236.0
K         96    1.0           12    1.0             12            1   236.0
K        100    1.0           12    1.0             12            1   236.0
K        104    1.0           13    1.0             12            1   236.0
K        112    1.1           14    1.0             12            1   236.0
K        120    1.2           15    1.0             12            1   236.0
K        128    1.3           16    1.0             12            1   236.0
K        136    1.4           17    1.0             12            1   236.0
K        144    1.4           18    1.0             12            1   236.0
K        152    1.5           19    1.0             12            1   236.0
K        160    1.6           20    1.0             12            1   236.0
          -------------------------------------------------------------

PGA Aggr Summary                             DB/Inst: ORCL/orcl  Snaps: 37-38
-> PGA cache hit % - percentage of W/A (WorkArea) data processed only in-memory

PGA Cache Hit %   W/A MB Processed  Extra W/A MB Read/Written
--------------- ------------------ --------------------------
          100.0                 86                          0
          -------------------------------------------------------------

PGA Aggr Target Stats                         DB/Inst: ORCL/orcl  Snaps: 37-38
-> B: Begin Snap   E: End Snap (rows dentified with B or E contain data
   which is absolute i.e. not diffed over the interval)
-> Auto PGA Target - actual workarea memory target
-> W/A PGA Used    - amount of memory used for all Workareas (manual + auto)
-> %PGA W/A Mem    - percentage of PGA memory allocated to workareas
-> %Auto W/A Mem   - percentage of workarea memory controlled by Auto Mem Mgmt
-> %Man W/A Mem    - percentage of workarea memory under manual control

                                                %PGA  %Auto   %Man
    PGA Aggr   Auto PGA   PGA Mem    W/A PGA     W/A    W/A    W/A Global Mem
   Target(M)  Target(M)  Alloc(M)    Used(M)     Mem    Mem    Mem   Bound(K)
- ---------- ---------- ---------- ---------- ------ ------ ------ ----------
B        256        206       60.6        0.0     .0     .0     .0     54,886
E        256        200      105.0        0.0     .0     .0     .0     54,886
          -------------------------------------------------------------

PGA Aggr Target Histogram                     DB/Inst: ORCL/orcl  Snaps: 37-38
-> Optimal Executions are purely in-memory operations

  Low     High
Optimal Optimal    Total Execs  Optimal Execs 1-Pass Execs M-Pass Execs
------- ------- -------------- -------------- ------------ ------------
     2K      4K            579            579            0            0
    64K    128K              4              4            0            0
   128K    256K              1              1            0            0
   256K    512K              4              4            0            0
   512K   1024K             68             68            0            0
     1M      2M             14             14            0            0
     2M      4M              2              2            0            0
     4M      8M              2              2            0            0
          -------------------------------------------------------------

PGA Memory Advisory                               DB/Inst: ORCL/orcl  Snap: 38
-> When using Auto Memory Mgmt, minimally choose a pga_aggregate_target value
   where Estd PGA Overalloc Count is 0

                                       Estd Extra    Estd P Estd PGA
PGA Target    Size           W/A MB   W/A MB Read/    Cache Overallo    Estd
  Est (MB)   Factr        Processed Written to Disk   Hit %    Count    Time
---------- ------- ---------------- ---------------- ------ -------- -------
        34     0.1            999.6             61.9   94.0       16 1.3E+07
        67     0.3            999.6             21.8   98.0        7 1.3E+07
       134     0.5            999.6              3.3  100.0        3 1.2E+07
       201     0.8            999.6              0.0  100.0        0 1.2E+07  @jls
       268     1.0            999.6              0.0  100.0        0 1.2E+07
       322     1.2            999.6              0.0  100.0        0 1.2E+07
       375     1.4            999.6              0.0  100.0        0 1.2E+07
       429     1.6            999.6              0.0  100.0        0 1.2E+07
       482     1.8            999.6              0.0  100.0        0 1.2E+07
       536     2.0            999.6              0.0  100.0        0 1.2E+07
       804     3.0            999.6              0.0  100.0        0 1.2E+07
     1,072     4.0            999.6              0.0  100.0        0 1.2E+07
     1,608     6.0            999.6              0.0  100.0        0 1.2E+07
     2,144     8.0            999.6              0.0  100.0        0 1.2E+07
          -------------------------------------------------------------

Shared Pool Advisory                             DB/Inst: ORCL/orcl  Snap: 38
-> SP: Shared Pool     Est LC: Estimated Library Cache   Factr: Factor
-> Note there is often a 1:Many correlation between a single logical object
   in the Library Cache, and the physical number of memory objects associated
   with it.  Therefore comparing the number of Lib Cache objects (e.g. in
   v$librarycache), with the number of Lib Cache Memory Objects is invalid.

                                       Est LC Est LC  Est LC Est LC
  Shared    SP   Est LC                  Time   Time    Load   Load       Est LC
    Pool  Size     Size       Est LC    Saved  Saved    Time   Time      Mem Obj
 Size(M) Factr      (M)      Mem Obj      (s)  Factr     (s)  Factr     Hits (K)
-------- ----- -------- ------------ -------- ------ ------- ------ ------------
     164    .8       11          787    8,398    1.0     535    1.1           63
     188    .9       35        2,062    8,414    1.0     519    1.0          141
     212   1.0       59        2,710    8,438    1.0     495    1.0          142
     236   1.1       83        3,493    8,446    1.0     487    1.0          143
     260   1.2      107        4,521    8,450    1.0     483    1.0          143
     284   1.3      131        5,633    8,454    1.0     479    1.0          143
     308   1.5      152        6,665    8,455    1.0     478    1.0          143
     332   1.6      162        7,133    8,455    1.0     478    1.0          144
     356   1.7      162        7,133    8,455    1.0     478    1.0          144
     380   1.8      162        7,133    8,455    1.0     478    1.0          144
     404   1.9      162        7,133    8,455    1.0     478    1.0          144
     428   2.0      162        7,133    8,455    1.0     478    1.0          144
          -------------------------------------------------------------

SGA Target Advisory                               DB/Inst: ORCL/orcl  Snap: 38

SGA Target   SGA Size       Est DB     Est Physical
  Size (M)     Factor     Time (s)            Reads
---------- ---------- ------------ ----------------
       378        0.5       17,280          151,748
       567        0.8       11,821          103,228
       756        1.0       11,069           96,538
       945        1.3       10,930           95,727 @jls
     1,134        1.5       10,924           95,727
     1,323        1.8       10,924           95,727
     1,512        2.0       10,823           98,882
          -------------------------------------------------------------

Streams Pool Advisory                             DB/Inst: ORCL/orcl  Snap: 38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Java Pool Advisory                                DB/Inst: ORCL/orcl  Snap: 38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Buffer Wait Statistics                        DB/Inst: ORCL/orcl  Snaps: 37-38
-> ordered by wait time desc, waits desc

Class                    Waits Total Wait Time (s)  Avg Time (ms)
------------------ ----------- ------------------- --------------
data block                  98                   7             75
1st level bmb                2                   0            205
2nd level bmb                1                   0            100
undo header                  1                   0              0
          -------------------------------------------------------------

Enqueue Activity                             DB/Inst: ORCL/orcl  Snaps: 37-38
-> only enqueues with waits are shown
-> Enqueue stats gathered prior to 10g should not be compared with 10g data
-> ordered by Wait Time desc, Waits desc

Enqueue Type (Request Reason)
------------------------------------------------------------------------------
    Requests    Succ Gets Failed Gets       Waits  Wt Time (s) Av Wt Time(ms)
------------ ------------ ----------- ----------- ------------ --------------
TX-Transaction (index contention)
          21           21           0           2            1         275.00
JS-Job Scheduler (queue lock)
       1,311        1,311           0           1            0            .00
          -------------------------------------------------------------

Undo Segment Summary                         DB/Inst: ORCL/orcl  Snaps: 37-38
-> Min/Max TR (mins) - Min and Max Tuned Retention (minutes)
-> STO - Snapshot Too Old count,  OOS - Out of Space count
-> Undo segment block stats:
-> uS - unexpired Stolen,   uR - unexpired Released,   uU - unexpired reUsed
-> eS - expired   Stolen,   eR - expired   Released,   eU - expired   reUsed

Undo   Num Undo       Number of  Max Qry   Max Tx Min/Max   STO/     uS/uR/uU/
 TS# Blocks (K)    Transactions  Len (s) Concurcy TR (mins) OOS      eS/eR/eU
---- ---------- --------------- -------- -------- --------- ----- --------------
   2         .7           7,671      920       33 29.4/29.4 0/0   0/0/0/0/0/0
          -------------------------------------------------------------

Undo Segment Stats                            DB/Inst: ORCL/orcl  Snaps: 37-38
-> Most recent 35 Undostat rows, ordered by Time desc

                Num Undo    Number of Max Qry  Max Tx Tun Ret STO/    uS/uR/uU/
End Time          Blocks Transactions Len (s)   Concy  (mins) OOS     eS/eR/eU
------------ ----------- ------------ ------- ------- ------- ----- ------------
12-Feb 12:19         733        7,671     920      33      29 0/0   0/0/0/0/0/0
          -------------------------------------------------------------

Latch Activity                               DB/Inst: ORCL/orcl  Snaps: 37-38
-> "Get Requests", "Pct Get Miss" and "Avg Slps/Miss" are statistics for
   willing-to-wait latch get requests
-> "NoWait Requests", "Pct NoWait Miss" are for no-wait latch get requests
-> "Pct Misses" for both should be very close to 0.0

                                           Pct    Avg   Wait                 Pct
                                    Get    Get   Slps   Time       NoWait NoWait
Latch Name                     Requests   Miss  /Miss    (s)     Requests   Miss
------------------------ -------------- ------ ------ ------ ------------ ------
AQ deq hash table latch               1    0.0             0            0    N/A
ASM db client latch                 388    0.0             0            0    N/A
ASM map operation hash t              1    0.0             0            0    N/A
ASM network state latch               6    0.0             0            0    N/A
AWR Alerted Metric Eleme          2,726    0.0             0            0    N/A
Change Notification Hash            117    0.0             0            0    N/A
Consistent RBA                    3,481    0.0             0            0    N/A
DML lock allocation              59,925    0.0    0.0      0            0    N/A
Event Group Locks                    90    0.0             0            0    N/A
FOB s.o list latch                  496    1.4    0.1      0            0    N/A
File State Object Pool P              1    0.0             0            0    N/A
IPC stats buffer allocat              1    0.0             0            0    N/A
In memory undo latch             61,921    0.0    1.0      0        9,081    0.0
JS Sh mem access                      3   33.3    1.0      0            0    N/A
JS broadcast autostart l              1    0.0             0            0    N/A
JS mem alloc latch                    4    0.0             0            0    N/A
JS queue access latch                 5    0.0             0            0    N/A
JS queue state obj latch          2,622    0.0             0            0    N/A
JS slv state obj latch              326    0.6    0.0      0            0    N/A
KFC FX Hash Latch                     1    0.0             0            0    N/A
KFC Hash Latch                        1    0.0             0            0    N/A
KFCL LE Freelist                      1    0.0             0            0    N/A
KGNFS-NFS:SHM structure               1    0.0             0            0    N/A
KGNFS-NFS:SVR LIST                    1    0.0             0            0    N/A
KJC message pool free li              1    0.0             0            0    N/A
KJCT flow control latch               1    0.0             0            0    N/A
KMG MMAN ready and start            122    0.0             0            0    N/A
KTF sga latch                         2    0.0             0          120    0.0
Locator state objects po              1    0.0             0            0    N/A
Lsod array latch                      1    0.0             0            0    N/A
MQL Tracking Latch                    0    N/A             0            9    0.0
Memory Management Latch               1    0.0             0          122    0.0
Memory Queue                          1    0.0             0            0    N/A
Memory Queue Message Sub              1    0.0             0            0    N/A
Memory Queue Message Sub              1    0.0             0            0    N/A
Memory Queue Message Sub              1    0.0             0            0    N/A
Memory Queue Message Sub              1    0.0             0            0    N/A
Memory Queue Subscriber               1    0.0             0            0    N/A
MinActiveScn Latch                    2    0.0             0            0    N/A
Mutex                                 1    0.0             0            0    N/A
Mutex Stats                           1    0.0             0            0    N/A
OS process                          484    0.0             0            0    N/A
OS process allocation               334    0.9    0.0      0            0    N/A
OS process: request allo            176    1.1    0.0      0            0    N/A
PL/SQL warning settings           6,155    0.2    0.0      0            0    N/A
PX hash array latch                   1    0.0             0            0    N/A
QMT                                   1    0.0             0            0    N/A
Real-time plan statistic             74    0.0             0            0    N/A
SGA IO buffer pool latch            254    0.0             0          254    0.0
SGA blob parent                       1    0.0             0            0    N/A
SGA bucket locks                      1    0.0             0            0    N/A
SGA heap locks                        1    0.0             0            0    N/A
SGA pool locks                        1    0.0             0            0    N/A
SQL memory manager latch             13    0.0             0          118    0.0
SQL memory manager worka          8,670    0.0             0            0    N/A
Shared B-Tree                        14    0.0             0            0    N/A
Streams Generic                       1    0.0             0            0    N/A
Testing                               1    0.0             0            0    N/A
Token Manager                         1    0.0             0            0    N/A
WCR: sync                             1    0.0             0            0    N/A
Latch Activity                               DB/Inst: ORCL/orcl  Snaps: 37-38
-> "Get Requests", "Pct Get Miss" and "Avg Slps/Miss" are statistics for
   willing-to-wait latch get requests
-> "NoWait Requests", "Pct NoWait Miss" are for no-wait latch get requests
-> "Pct Misses" for both should be very close to 0.0

                                           Pct    Avg   Wait                 Pct
                                    Get    Get   Slps   Time       NoWait NoWait
Latch Name                     Requests   Miss  /Miss    (s)     Requests   Miss
------------------------ -------------- ------ ------ ------ ------------ ------
Write State Object Pool               1    0.0             0            0    N/A
X$KSFQP                               1    0.0             0            0    N/A
XDB NFS Security Latch                1    0.0             0            0    N/A
XDB unused session pool               1    0.0             0            0    N/A
XDB used session pool                 1    0.0             0            0    N/A
active checkpoint queue           1,895    0.0             0            0    N/A
active service list               1,252    0.3    0.5      0          728    0.0
begin backup scn array                4    0.0             0            0    N/A
buffer pool                           1    0.0             0            0    N/A
business card                         1    0.0             0            0    N/A
cache buffer handles              2,433    0.0             0            0    N/A
cache buffers chains          1,745,217    0.0    0.0      0       75,183    0.0
cache buffers lru chain          18,402    0.0    0.2      0       78,619    0.1
cache table scan latch              106    0.0             0          106    0.0
call allocation                   1,047    0.4    0.3      0            0    N/A
cas latch                             1    0.0             0            0    N/A
change notification clie              1    0.0             0            0    N/A
channel handle pool latc            181    0.0             0            0    N/A
channel operations paren          2,971    0.0    0.0      0            0    N/A
checkpoint queue latch           42,131    0.0             0       24,358    0.0
client/application info         250,902    0.1    0.0      0            0    N/A
compile environment latc             90    0.0             0            0    N/A
corrupted undo seg latch             46    0.0             0            0    N/A
cp cmon/server latch                  1    0.0             0            0    N/A
cp pool latch                         1    0.0             0            0    N/A
cp server hash latch                  1    0.0             0            0    N/A
cp sga latch                          6    0.0             0            0    N/A
cvmap freelist lock                   1    0.0             0            0    N/A
database property servic              8    0.0             0            0    N/A
deferred cleanup latch                6    0.0             0            0    N/A
dml lock allocation                  10    0.0             0            0    N/A
done queue latch                      1    0.0             0            0    N/A
dummy allocation                    179    0.0             0            0    N/A
enqueue hash chains              89,226    0.1    0.2      3            0    N/A
enqueues                          8,892    0.0    0.0      0            0    N/A
fifth spare latch                     1    0.0             0            0    N/A
file cache latch                    150    0.0             0            0    N/A
flashback copy                        1    0.0             0            0    N/A
gc element                            1    0.0             0            0    N/A
gcs commit scn state                  1    0.0             0            0    N/A
gcs partitioned table ha              1    0.0             0            0    N/A
gcs pcm hashed value buc              1    0.0             0            0    N/A
gcs resource freelist                 1    0.0             0            0    N/A
gcs resource hash                     1    0.0             0            0    N/A
gcs resource scan list                1    0.0             0            0    N/A
gcs shadows freelist                  1    0.0             0            0    N/A
ges domain table                      1    0.0             0            0    N/A
ges enqueue table freeli              1    0.0             0            0    N/A
ges group table                       1    0.0             0            0    N/A
ges process hash list                 1    0.0             0            0    N/A
ges process parent latch              1    0.0             0            0    N/A
ges resource hash list                1    0.0             0            0    N/A
ges resource scan list                1    0.0             0            0    N/A
ges resource table freel              1    0.0             0            0    N/A
ges value block free lis              1    0.0             0            0    N/A
global KZLD latch for me             80    0.0             0            0    N/A
global tx hash mapping                1    0.0             0            0    N/A
granule operation                     1    0.0             0            0    N/A
hash table column usage             359    0.0             0      247,004    0.0
hash table modification              56    0.0             0            0    N/A
Latch Activity                               DB/Inst: ORCL/orcl  Snaps: 37-38
-> "Get Requests", "Pct Get Miss" and "Avg Slps/Miss" are statistics for
   willing-to-wait latch get requests
-> "NoWait Requests", "Pct NoWait Miss" are for no-wait latch get requests
-> "Pct Misses" for both should be very close to 0.0

                                           Pct    Avg   Wait                 Pct
                                    Get    Get   Slps   Time       NoWait NoWait
Latch Name                     Requests   Miss  /Miss    (s)     Requests   Miss
------------------------ -------------- ------ ------ ------ ------------ ------
heartbeat check                       1    0.0             0            0    N/A
internal temp table obje              9    0.0             0            0    N/A
intra txn parallel recov              1    0.0             0            0    N/A
io pool granule metadata              1    0.0             0            0    N/A
job workq parent latch                4    0.0             0            3   33.3
job_queue_processes free              8    0.0             0            0    N/A
job_queue_processes para             78    0.0             0            0    N/A
k2q lock allocation                   1    0.0             0            0    N/A
kdlx hb parent latch                  1    0.0             0            0    N/A
kgb parent                            1    0.0             0            0    N/A
kks stats                           729    0.0             0            0    N/A
kokc descriptor allocati             13    0.0             0            0    N/A
ksfv messages                         1    0.0             0            0    N/A
kss move lock                         9    0.0             0            0    N/A
ksuosstats global area               28    0.0             0            0    N/A
ksv allocation latch                 22    0.0             0            0    N/A
ksv class latch                      17    0.0             0            0    N/A
ksv msg queue latch                   1    0.0             0            0    N/A
ksz_so allocation latch             176    0.6    0.0      0            0    N/A
ktm global data                      24    0.0             0            0    N/A
kwqbsn:qsga                          13    0.0             0            0    N/A
lgwr LWN SCN                      3,511    0.0             0            0    N/A
list of block allocation            262    0.0             0            0    N/A
loader state object free              4    0.0             0            0    N/A
lob segment dispenser la              1    0.0             0            0    N/A
lob segment hash table l              1    0.0             0            0    N/A
lob segment query latch               1    0.0             0            0    N/A
lock DBA buffer during m              1    0.0             0            0    N/A
logical standby cache                 1    0.0             0            0    N/A
logminer context allocat              1    0.0             0            0    N/A
logminer work area                    1    0.0             0            0    N/A
longop free list parent               1    0.0             0            0    N/A
mapped buffers lru chain              1    0.0             0            0    N/A
message pool operations             235    0.0             0            0    N/A
messages                         17,721    0.0    0.0      0            0    N/A
mostly latch-free SCN             3,512    0.0             0            0    N/A
msg queue latch                       1    0.0             0            0    N/A
multiblock read objects           2,138    0.0             0            0    N/A
name-service namespace b              1    0.0             0            0    N/A
ncodef allocation latch               6    0.0             0            0    N/A
object queue header heap          7,727    0.0             0          121    0.0
object queue header oper        138,877    0.0    0.1      0            0    N/A
object stats modificatio            551    0.0             0            0    N/A
parallel query alloc buf             45    0.0             0            0    N/A
parallel query stats                  1    0.0             0            0    N/A
parameter list                      761    0.0             0            0    N/A
parameter table manageme            178    0.0             0            0    N/A
peshm                                 1    0.0             0            0    N/A
pesom_free_list                       1    0.0             0            0    N/A
pesom_hash_node                       1    0.0             0            0    N/A
post/wait queue                  16,102    0.1    0.0      0       16,901    0.1
process allocation                  185    1.6    0.3      0           88    1.1
process group creation              176    2.8    0.0      0            0    N/A
process queue                         1    0.0             0            0    N/A
process queue reference               1    0.0             0            0    N/A
qmn task queue latch                 56    0.0             0            0    N/A
query server freelists                1    0.0             0            0    N/A
queued dump request                   1    0.0             0            0    N/A
queuing load statistics               1    0.0             0            0    N/A
recovery domain hash lis              1    0.0             0            0    N/A
Latch Activity                               DB/Inst: ORCL/orcl  Snaps: 37-38
-> "Get Requests", "Pct Get Miss" and "Avg Slps/Miss" are statistics for
   willing-to-wait latch get requests
-> "NoWait Requests", "Pct NoWait Miss" are for no-wait latch get requests
-> "Pct Misses" for both should be very close to 0.0

                                           Pct    Avg   Wait                 Pct
                                    Get    Get   Slps   Time       NoWait NoWait
Latch Name                     Requests   Miss  /Miss    (s)     Requests   Miss
------------------------ -------------- ------ ------ ------ ------------ ------
redo allocation                  25,541    0.1    0.1      0       39,323    0.1
redo copy                             1    0.0             0       39,346    0.3
redo writing                     12,652    0.0             0            0    N/A
resmgr group change latc         75,546    0.0    0.0      0            0    N/A
resmgr:active threads               342    0.0             0           60    0.0
resmgr:actses change gro            261    0.0             0            0    N/A
resmgr:actses change sta             88    0.0             0            0    N/A
resmgr:free threads list            184    0.5    0.0      0            0    N/A
resmgr:plan CPU method                1    0.0             0            0    N/A
resmgr:resource group CP              1    0.0             0            0    N/A
resmgr:schema config                 76    0.0             0            6    0.0
resmgr:session queuing                1    0.0             0            0    N/A
rm cas latch                          1    0.0             0            0    N/A
row cache objects               326,108    0.0    0.1      0          386    0.0
second spare latch                    1    0.0             0            0    N/A
sequence cache                    9,219    0.0             0            0    N/A
session allocation               27,806    0.0    0.0      0        9,271    0.1
session idle bit                 34,266    0.1    0.0      0            0    N/A
session queue latch                   1    0.0             0            0    N/A
session state list latch            510    0.4    0.0      0            0    N/A
session switching                   442    0.2    0.0      0            0    N/A
session timer                       138    0.0             0            0    N/A
shared pool                      49,560    0.2    0.1      2            0    N/A
shared pool sim alloc                12    0.0             0            0    N/A
shared pool simulator             2,437    0.0             0            0    N/A
sim partition latch                   1    0.0             0            0    N/A
simulator hash latch             59,731    0.0             0            0    N/A
simulator lru latch               1,459    0.0             0       54,264    0.0
sort extent pool                     46    0.0             0            0    N/A
space background task la            268    0.0             0          244    0.0
state object free list                2    0.0             0            0    N/A
statistics aggregation              560    0.0             0            0    N/A
tablespace key chain                  1    0.0             0            0    N/A
temp lob duration state               3    0.0             0            0    N/A
temporary table state ob              3    0.0             0            0    N/A
test excl. parent l0                  1    0.0             0            0    N/A
test excl. parent2 l0                 1    0.0             0            0    N/A
third spare latch                     1    0.0             0            0    N/A
threshold alerts latch               19    0.0             0            0    N/A
trace latch                          24    0.0             0            0    N/A
transaction allocation              411    0.0             0            0    N/A
undo global data                 50,436    0.0    0.0      0            0    N/A
virtual circuit buffers               1    0.0             0            0    N/A
virtual circuit holder                1    0.0             0            0    N/A
virtual circuit queues                1    0.0             0            0    N/A
          -------------------------------------------------------------

Latch Sleep Breakdown                        DB/Inst: ORCL/orcl  Snaps: 37-38
-> ordered by misses desc

                                       Get                                 Spin
Latch Name                        Requests       Misses      Sleeps        Gets
-------------------------- --------------- ------------ ----------- -----------
client/application info            250,902          325           6         319
cache buffers chains             1,745,217          320           1         319
shared pool                         49,560          105          11          96
enqueue hash chains                 89,226          104          18          86
row cache objects                  326,108           86           5          81
object queue header operat         138,877           16           1          15
redo allocation                     25,541           15           1          14
FOB s.o list latch                     496            7           1           6
cache buffers lru chain             18,402            6           1           5
active service list                  1,252            4           2           2
call allocation                      1,047            4           1           3
process allocation                     185            3           1           2
In memory undo latch                61,921            2           2           0
JS Sh mem access                         3            1           1           0
          -------------------------------------------------------------

Latch Miss Sources                           DB/Inst: ORCL/orcl  Snaps: 37-38
-> only latches with sleeps are shown
-> ordered by name, sleeps desc

                                                     NoWait              Waiter
Latch Name               Where                       Misses     Sleeps   Sleeps
------------------------ -------------------------- ------- ---------- --------
FOB s.o list latch       ksfd_allfob                      0          1        1
In memory undo latch     ktiFlush: child                  0          1        1
In memory undo latch     ktichg: child                    0          1        0
JS Sh mem access         jsksGetShMemLatch                0          1        1
active service list      kswslogon: session logout        0          3        3
cache buffers chains     kcbget: pin buffer               0          5        1
cache buffers chains     kcbgcur_2                        0          1        0
cache buffers chains     kcbget: exchange                 0          1        2
cache buffers chains     kcbgtcr: fast path               0          1        1
cache buffers chains     kcbgtcr: fast path (cr pin       0          1        0
cache buffers chains     kcbzib: exchange rls             0          1        3
cache buffers lru chain  kcbzgws                          0          1        0
call allocation          ksuxds                           0          1        1
client/application info  ksuinfos_act                     0          8        8
client/application info  ksuinfos_modact                  0          5        2
client/application info  kskirefrattrmap                  0          1        4
enqueue hash chains      ksqgtl3                          0         10       14
enqueue hash chains      ksqrcl                           0          8        4
object queue header oper kcbo_switch_cq                   0          1        0
process allocation       ksucrp:1                         0          1        0
redo allocation          kcrfw_redo_gen: redo alloc       0          1        0
row cache objects        kqreqd: reget                    0          5        0
shared pool              kghalo                           0          8        6
shared pool              kghupr1                          0          2        2
shared pool              kghfre                           0          1        1
          -------------------------------------------------------------

Mutex Sleep Summary                           DB/Inst: ORCL/orcl  Snaps: 37-38
-> ordered by number of sleeps desc

                                                                         Wait
Mutex Type            Location                               Sleeps    Time (ms)
--------------------- -------------------------------- ------------ ------------
Library Cache         kglpnal1  90                               46           -0
Library Cache         kglpndl1  95                               29           -1
Library Cache         kglhdgn2 106                                9           -1
Library Cache         kglIsOwnerVersionable 121                   3            0
Library Cache         kglget2   2                                 3         -172
Library Cache         kgllkdl1  85                                3            4
Library Cache         kglobpn1  71                                3            0
Library Cache         kglhdgn1  62                                2           -4
Library Cache         kglpin1   4                                 2           -8
          -------------------------------------------------------------

Parent Latch Statistics                      DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Child Latch Statistics                        DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Segments by Logical Reads                    DB/Inst: ORCL/orcl  Snaps: 37-38
-> Total Logical Reads:         731,220
-> Captured Segments account for   82.0% of Total

           Tablespace                      Subobject  Obj.       Logical
Owner         Name    Object Name            Name     Type         Reads  %Total
---------- ---------- -------------------- ---------- ----- ------------ -------
SOE        SOE        INVENTORY_PK                    INDEX      107,440   14.69
SOE        SOE        PRD_DESC_PK                     INDEX       57,200    7.82
SOE        SOE        INVENTORIES                     TABLE       48,512    6.63
SYS        SYSTEM     OPTSTAT_HIST_CONTROL            TABLE       42,736    5.84
SOE        SOE        PRODUCT_INFORMATION_            INDEX       36,800    5.03
          -------------------------------------------------------------

Segments by Physical Reads                    DB/Inst: ORCL/orcl  Snaps: 37-38
-> Total Physical Reads:          47,336
-> Captured Segments account for   70.1% of Total

           Tablespace                      Subobject  Obj.      Physical
Owner         Name    Object Name            Name     Type         Reads  %Total
---------- ---------- -------------------- ---------- ----- ------------ -------
SOE        SOE        INVENTORIES                     TABLE        8,199   17.32
SOE        SOE        ITEM_PRODUCT_IX                 INDEX        5,024   10.61
SOE        SOE        CUSTOMERS_PK                    INDEX        3,928    8.30
SOE        SOE        ORD_WAREHOUSE_IX                INDEX        2,283    4.82
SOE        SOE        ITEM_ORDER_IX                   INDEX        2,228    4.71
          -------------------------------------------------------------

Segments by Physical Read Requests            DB/Inst: ORCL/orcl  Snaps: 37-38
-> Total Physical Read Requests:          38,018
-> Captured Segments account for   83.8% of Total

           Tablespace                      Subobject  Obj.     Phys Read
Owner         Name    Object Name            Name     Type      Requests  %Total
---------- ---------- -------------------- ---------- ----- ------------ -------
SOE        SOE        INVENTORIES                     TABLE        8,199   21.57
SOE        SOE        ITEM_PRODUCT_IX                 INDEX        5,024   13.21
SOE        SOE        CUSTOMERS_PK                    INDEX        3,928   10.33
SOE        SOE        ORD_WAREHOUSE_IX                INDEX        2,283    6.01
SOE        SOE        ITEM_ORDER_IX                   INDEX        2,228    5.86
          -------------------------------------------------------------

Segments by UnOptimized Reads                 DB/Inst: ORCL/orcl  Snaps: 37-38
-> Total UnOptimized Read Requests:          38,018
-> Captured Segments account for   83.8% of Total

           Tablespace                      Subobject  Obj.   UnOptimized
Owner         Name    Object Name            Name     Type         Reads  %Total
---------- ---------- -------------------- ---------- ----- ------------ -------
SOE        SOE        INVENTORIES                     TABLE        8,199   21.57
SOE        SOE        ITEM_PRODUCT_IX                 INDEX        5,024   13.21
SOE        SOE        CUSTOMERS_PK                    INDEX        3,928   10.33
SOE        SOE        ORD_WAREHOUSE_IX                INDEX        2,283    6.01
SOE        SOE        ITEM_ORDER_IX                   INDEX        2,228    5.86
          -------------------------------------------------------------

Segments by Optimized Reads                   DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Segments by Direct Physical Reads             DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Segments by Physical Writes                   DB/Inst: ORCL/orcl  Snaps: 37-38
-> Total Physical Writes:          14,720
-> Captured Segments account for   82.0% of Total

           Tablespace                      Subobject  Obj.      Physical
Owner         Name    Object Name            Name     Type        Writes  %Total
---------- ---------- -------------------- ---------- ----- ------------ -------
SOE        SOE        ITEM_PRODUCT_IX                 INDEX        3,015   20.48
SOE        SOE        ORD_WAREHOUSE_IX                INDEX        1,363    9.26
SOE        SOE        ORDER_PK                        INDEX        1,339    9.10
** UNAVAIL ** UNAVAIL ** UNAVAILABLE **    AILABLE ** UNDEF        1,162    7.89
SOE        SOE        INVENTORIES                     TABLE        1,157    7.86
          -------------------------------------------------------------

Segments by Physical Write Requests           DB/Inst: ORCL/orcl  Snaps: 37-38
-> Total Physical Write Requestss:           9,495
-> Captured Segments account for   86.7% of Total

           Tablespace                      Subobject  Obj.    Phys Write
Owner         Name    Object Name            Name     Type      Requests  %Total
---------- ---------- -------------------- ---------- ----- ------------ -------
SOE        SOE        ITEM_PRODUCT_IX                 INDEX        2,441   25.71
SOE        SOE        ITEM_ORDER_IX                   INDEX        1,141   12.02
SOE        SOE        ORDER_ITEMS_PK                  INDEX        1,133   11.93
SOE        SOE        ORD_WAREHOUSE_IX                INDEX          986   10.38
** UNAVAIL ** UNAVAIL ** UNAVAILABLE **    AILABLE ** UNDEF          975   10.27
          -------------------------------------------------------------

Segments by Direct Physical Writes            DB/Inst: ORCL/orcl  Snaps: 37-38
-> Total Direct Physical Writes:              38
-> Captured Segments account for   97.4% of Total

           Tablespace                      Subobject  Obj.        Direct
Owner         Name    Object Name            Name     Type        Writes  %Total
---------- ---------- -------------------- ---------- ----- ------------ -------
SYS        SYSAUX     WRH$_ACTIVE_SESSION_ 4731332_34 TABLE           37   97.37
          -------------------------------------------------------------

Segments by Table Scans                       DB/Inst: ORCL/orcl  Snaps: 37-38
-> Total Table Scans:               9
-> Captured Segments account for   44.4% of Total

           Tablespace                      Subobject  Obj.         Table
Owner         Name    Object Name            Name     Type         Scans  %Total
---------- ---------- -------------------- ---------- ----- ------------ -------
SYS        SYSTEM     I_OBJ2                          INDEX            3   33.33
SYS        SYSAUX     WRH$_SEG_STAT_PK     4731332_34 INDEX            1   11.11
          -------------------------------------------------------------

Segments by DB Blocks Changes                 DB/Inst: ORCL/orcl  Snaps: 37-38
-> % of Capture shows % of DB Block Changes for each top segment compared
-> with total DB Block Changes for all segments captured by the Snapshot

           Tablespace                      Subobject  Obj.      DB Block    % of
Owner         Name    Object Name            Name     Type       Changes Capture
---------- ---------- -------------------- ---------- ----- ------------ -------
SOE        SOE        ORD_WAREHOUSE_IX                INDEX        4,848   25.40
SOE        SOE        INVENTORIES                     TABLE        2,832   14.84
SOE        SOE        ITEM_ORDER_IX                   INDEX        2,544   13.33
SOE        SOE        ITEM_PRODUCT_IX                 INDEX        2,416   12.66
SOE        SOE        ORDER_ITEMS_PK                  INDEX        1,984   10.39
          -------------------------------------------------------------

Segments by Row Lock Waits                   DB/Inst: ORCL/orcl  Snaps: 37-38
-> % of Capture shows % of row lock waits for each top segment compared
-> with total row lock waits for all segments captured by the Snapshot

                                                                     Row
           Tablespace                      Subobject  Obj.          Lock    % of
Owner         Name    Object Name            Name     Type         Waits Capture
---------- ---------- -------------------- ---------- ----- ------------ -------
SOE        SOE        CUST_ACCOUNT_MANAGER            INDEX           13   61.90
SOE        SOE        ORD_ORDER_DATE_IX               INDEX            8   38.10
          -------------------------------------------------------------

Segments by ITL Waits                         DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Segments by Buffer Busy Waits                 DB/Inst: ORCL/orcl  Snaps: 37-38
-> % of Capture shows % of Buffer Busy Waits for each top segment compared
-> with total Buffer Busy Waits for all segments captured by the Snapshot

                                                                  Buffer
           Tablespace                      Subobject  Obj.          Busy    % of
Owner         Name    Object Name            Name     Type         Waits Capture
---------- ---------- -------------------- ---------- ----- ------------ -------
SYS        SYSTEM     AUD$                            TABLE           10  100.00
          -------------------------------------------------------------

Dictionary Cache Stats                       DB/Inst: ORCL/orcl  Snaps: 37-38
-> "Pct Misses"  should be very low (< 2% in most cases)
-> "Final Usage" is the number of cache entries being used

                                   Get    Pct    Scan   Pct      Mod      Final
Cache                         Requests   Miss    Reqs  Miss     Reqs      Usage
------------------------- ------------ ------ ------- ----- -------- ----------
dc_awr_control                      11    0.0       0   N/A        2          1
dc_global_oids                      61    9.8       0   N/A        0         40
dc_histogram_data                5,195    3.5       0   N/A        0      1,481
dc_histogram_defs                6,648    6.2       0   N/A        7      3,397
dc_object_grants                    34   11.8       0   N/A        0         17
dc_objects                       7,387    2.6       0   N/A       17      1,027
dc_profiles                         83    0.0       0   N/A        0          1
dc_rollback_segments               639    0.3       0   N/A       24         34
dc_segments                      1,108    7.2       0   N/A       18        558
dc_sequences                        12   16.7       0   N/A       12          5
dc_tablespaces                  44,263    0.0       0   N/A        0          8
dc_users                        46,513    0.0       0   N/A        0        122
global database name               325    0.0       0   N/A        0          1
outstanding_alerts                   5    0.0       0   N/A        0          5
sch_lj_objs                          8   25.0       0   N/A        0          2
sch_lj_oids                          4   50.0       0   N/A        0          4
          -------------------------------------------------------------

Library Cache Activity                        DB/Inst: ORCL/orcl  Snaps: 37-38
-> "Pct Misses"  should be very low

                         Get    Pct            Pin    Pct             Invali-
Namespace           Requests   Miss       Requests   Miss    Reloads  dations
--------------- ------------ ------ -------------- ------ ---------- --------
BODY                     542    1.8         33,250    0.0          1        0
CLUSTER                  256    0.4             76    1.3          0        0
DBLINK                   161    0.0              0    N/A          0        0
EDITION                   87    0.0            168    0.0          0        0
INDEX                     43    7.0             44    9.1          0        0
OBJECT ID                  3  100.0              0    N/A          0        0
SCHEMA                   437    1.1              0    N/A          0        0
SQL AREA               3,489   28.9        101,974    0.8        120        8
TABLE/PROCEDURE        4,040    3.4         39,880    1.1        258        0
TRIGGER                   10   50.0             10   50.0          0        0
          -------------------------------------------------------------

Memory Dynamic Components                    DB/Inst: ORCL/orcl  Snaps: 37-38
-> Min/Max sizes since instance startup
-> Oper Types/Modes: INItializing,GROw,SHRink,STAtic/IMMediate,DEFerred
-> ordered by Component

                 Begin Snap     Current         Min         Max   Oper Last Op
Component         Size (Mb)   Size (Mb)   Size (Mb)   Size (Mb)  Count Typ/Mod
--------------- ----------- ----------- ----------- ----------- ------ -------
ASM Buffer Cach         .00         .00         .00         .00      0 STA/
DEFAULT 16K buf         .00         .00         .00         .00      0 STA/
DEFAULT 2K buff         .00         .00         .00         .00      0 STA/
DEFAULT 32K buf         .00         .00         .00         .00      0 STA/
DEFAULT 4K buff         .00         .00         .00         .00      0 STA/
DEFAULT 8K buff         .00         .00         .00         .00      0 STA/
DEFAULT buffer       424.00      424.00      424.00      460.00      0 SHR/DEF
KEEP buffer cac      100.00      100.00      100.00      100.00      0 INI/
PGA Target           268.00      268.00      268.00      268.00      0 STA/
RECYCLE buffer          .00         .00         .00         .00      0 STA/
SGA Target           756.00      756.00      756.00      756.00      0 STA/
Shared IO Pool          .00         .00         .00         .00      0 STA/
java pool              4.00        4.00        4.00        4.00      0 STA/
large pool             4.00        4.00        4.00        4.00      0 STA/
shared pool          212.00      212.00      176.00      212.00      0 GRO/DEF
streams pool            .00         .00         .00         .00      0 STA/
          -------------------------------------------------------------

Memory Resize Operations Summary              DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Memory Resize Ops                             DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Process Memory Summary                       DB/Inst: ORCL/orcl  Snaps: 37-38
-> B: Begin Snap   E: End Snap
-> All rows below contain absolute values (i.e. not diffed over the interval)
-> Max Alloc is Maximum PGA Allocation size at snapshot time
-> Hist Max Alloc is the Historical Max Allocation for still-connected processes
-> ordered by Begin/End snapshot, Alloc (MB) desc

                                                            Hist
                                    Avg  Std Dev     Max     Max
               Alloc      Used    Alloc    Alloc   Alloc   Alloc    Num    Num
  Category      (MB)      (MB)     (MB)     (MB)    (MB)    (MB)   Proc  Alloc
- -------- --------- --------- -------- -------- ------- ------- ------ ------
B Other         46.4       N/A      1.7      2.3      11      11     27     27
  Freeable      12.6        .0      1.6      1.5       5     N/A      8      8
  SQL            1.0        .8       .1       .2       1      21     13      9
  PL/SQL          .6        .5       .0       .1       0       0     25     25
E Other         83.0       N/A      2.9      6.4      34      34     29     29
  Freeable      18.1        .0      1.8      2.3       7     N/A     10     10
  PL/SQL         2.7       2.6       .1       .3       1       1     27     27
  SQL            1.3       1.0       .1       .2       1      21     15     11
          -------------------------------------------------------------

SGA Memory Summary                            DB/Inst: ORCL/orcl  Snaps: 37-38

                                                      End Size (Bytes)
SGA regions                     Begin Size (Bytes)      (if different)
------------------------------ ------------------- -------------------
Database Buffers                       549,453,824
Fixed Size                               2,220,200
Redo Buffers                             5,554,176
Variable Size                          511,709,016
                               -------------------
sum                                  1,068,937,216
          -------------------------------------------------------------

SGA breakdown difference                      DB/Inst: ORCL/orcl  Snaps: 37-38
-> ordered by Pool, Name
-> N/A value for Begin MB or End MB indicates the size of that Pool/Name was
   insignificant, or zero in that snapshot

Pool   Name                                 Begin MB         End MB  % Diff
------ ------------------------------ -------------- -------------- -------
java   free memory                               4.0            4.0    0.00
large  PX msg pool                               3.7            3.7    0.00
large  free memory                                .3             .3    0.00
shared ASH buffers                               4.0            4.0    0.00
shared CCUR                                      8.7            9.0    3.71
shared FileOpenBlock                             3.8            3.8    0.00
shared KCB Table Scan Buffer                     3.8            3.8    0.00
shared KGLH0                                     3.3            3.9   17.30
shared KGLHD                                     3.4            4.1   19.28
shared KGLS                                      4.8            6.7   39.12
shared KGLSG                                     5.0            5.0    0.00
shared KSFD SGA I/O b                            3.8            3.8    0.00
shared PCUR                                      5.0            5.6   12.90
shared PLDIA                                     N/A            2.1     N/A
shared PLMCD                                     4.8            6.7   39.15
shared SQLA                                     52.3           50.1   -4.30
shared db_block_hash_buckets                     5.6            5.6    0.00
shared dbktb: trace buffer                       2.3            2.3    0.00
shared dbwriter coalesce buffer                  3.8            3.8    0.00
shared event statistics per sess                 3.0            3.0    0.00
shared free memory                              32.9           27.4  -16.69
shared kglsim hash table bkts                    4.0            4.0    0.00
shared ksunfy : SSO free list                    2.8            2.8    0.00
shared obj stats allocation chun                 2.5            2.5    0.00
shared private strands                           3.5            3.5    0.00
shared row cache                                 7.2            7.2    0.00
shared write state object                        2.8            2.8    0.00
       buffer_cache                            524.0          524.0    0.00
       fixed_sga                                 2.1            2.1    0.00
       log_buffer                                5.3            5.3    0.00
          -------------------------------------------------------------

Streams CPU/IO Usage                         DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Streams Capture                               DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Streams Capture Rate                          DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Streams Apply                                 DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Streams Apply Rate                            DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Buffered Queues                               DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Buffered Queue Subscribers                    DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Rule Set                                      DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Persistent Queues                             DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Persistent Queues Rate                        DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Persistent Queue Subscribers                  DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Resource Limit Stats                             DB/Inst: ORCL/orcl  Snap: 38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Shared Servers Activity                       DB/Inst: ORCL/orcl  Snaps: 37-38
-> Values represent averages for all samples

   Avg Total   Avg Active    Avg Total   Avg Active    Avg Total   Avg Active
 Connections  Connections Shared Srvrs Shared Srvrs  Dispatchers  Dispatchers
------------ ------------ ------------ ------------ ------------ ------------
           0            0            1            0            1            0
          -------------------------------------------------------------

Shared Servers Rates                          DB/Inst: ORCL/orcl  Snaps: 37-38

  Common     Disp                        Common       Disp     Server
   Queue    Queue   Server    Server      Queue      Queue      Total     Server
 Per Sec  Per Sec Msgs/Sec    KB/Sec      Total      Total       Msgs  Total(KB)
-------- -------- -------- --------- ---------- ---------- ---------- ----------
       0        0        0       0.0          0          0          0          0
          -------------------------------------------------------------

Shared Servers Utilization                    DB/Inst: ORCL/orcl  Snaps: 37-38
-> Statistics are combined for all servers
-> Incoming and Outgoing Net % are included in %Busy

  Total Server                    Incoming  Outgoing
      Time (s)    %Busy    %Idle     Net %     Net %
-------------- -------- -------- --------- ---------
           372      0.0    100.0       0.0       0.0
          -------------------------------------------------------------

Shared Servers Common Queue                   DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

Shared Servers Dispatchers                    DB/Inst: ORCL/orcl  Snaps: 37-38
-> Ordered by %Busy, descending
-> Total Queued, Total Queue Wait and Avg Queue Wait are for dispatcher queue
-> Name suffixes:
     "(N)" - dispatcher started between begin and end snapshots
     "(R)" - dispatcher re-started between begin and end snapshots

              Avg Total Disp                        Total Total Queue  Avg Queue
Name        Conns   Time (s)    %Busy    %Idle     Queued    Wait (s)  Wait (ms)
------- --------- ---------- -------- -------- ---------- ----------- ----------
D000          0.0        372      0.0    100.0          0           0
          -------------------------------------------------------------

init.ora Parameters                          DB/Inst: ORCL/orcl  Snaps: 37-38
-> if IP/Public/Source at End snap is different a '*' is displayed

                                                                End value
Parameter Name                Begin value                       (if different)
----------------------------- --------------------------------- --------------
audit_file_dest               /home/oracle/app/oracle/admin/orc
audit_trail                   DB
compatible                    11.2.0.0.0
control_files                 /home/oracle/app/oracle/oradata/o
db_block_size                 8192
db_domain
db_keep_cache_size            104857600
db_name                       orcl
diagnostic_dest               /home/oracle/app/oracle
dispatchers                   (PROTOCOL=TCP) (SERVICE=orclXDB)
memory_max_target             1585446912
memory_target                 1073741824
open_cursors                  300
pga_aggregate_target          268435456
processes                     150
remote_login_passwordfile     EXCLUSIVE
sga_max_size                  1073741824
sga_target                    792723456
undo_tablespace               UNDOTBS1
          -------------------------------------------------------------

Dynamic Remastering Stats                     DB/Inst: ORCL/orcl  Snaps: 37-38

                  No data exists for this section of the report.
          -------------------------------------------------------------

End of Report

