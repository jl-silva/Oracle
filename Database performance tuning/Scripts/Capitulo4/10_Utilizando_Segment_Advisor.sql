-- utilizando o Segment Advisor para analisar TODOS os problemas mais recentes (inclui recomendacoes repetidas)
select      'Task Name : ' || f.task_name || chr(10) ||
            'Start Run Time : ' || TO_CHAR(execution_start, 'dd-mon-yy hh24:mi') || chr (10) ||
            'Segment Name : ' || o.attr2 || chr(10) ||
            'Segment Type : ' || o.type || chr(10) ||
            'Partition Name : ' || o.attr3 || chr(10) ||
            'Message : ' || f.message || chr(10) ||
            'More Info : ' || f.more_info || chr(10) ||
            '------------------------------------------------------' Advice
FROM        dba_advisor_findings f
INNER JOIN  dba_advisor_objects o
    ON      o.task_id = f.task_id
    AND     o.object_id = f.object_id
INNER JOIN  dba_advisor_executions e
    ON      f.task_id = e.task_id
WHERE       e. execution_start > sysdate - 1
AND         e.advisor_name = 'Segment Advisor'
ORDER BY    f.task_name;


-- ver somente as recomendacoes distintas 
SELECT          'Segment Advice --------------------------'|| chr(10) ||
                'TABLESPACE_NAME : ' || tablespace_name || chr(10) ||
                'SEGMENT_OWNER : ' || segment_owner || chr(10) ||
                'SEGMENT_NAME : ' || segment_name || chr(10) ||
                'ALLOCATED_SPACE : ' || allocated_space || chr(10) ||
                'RECLAIMABLE_SPACE: ' || reclaimable_space || chr(10) ||
                'RECOMMENDATIONS : ' || recommendations || chr(10) ||
                'SOLUTION 1 : ' || c1 || chr(10) ||
                'SOLUTION 2 : ' || c2 || chr(10) ||
                'SOLUTION 3 : ' || c3 Advice
FROM            TABLE(dbms_space.asa_recommendations(all_runs=>'TRUE', show_manual=>'TRUE', show_findings=>'FALSE'));



-- SEGMENT ADVISOR faz as seguintes verificacoes
--  - Segmentos que sao bons candidatos a operacoes de shrink
--  - Segmentos que tem significante encadeamento de linhas
--  - Segmentos que devem se beneficar de compressao (OLTP)