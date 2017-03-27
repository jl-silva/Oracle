1- Crie uma tabela clone da tabela SOE.ORDERS (se já não existir a ORDERS2) e crie um índice btree em qualquer coluna dessa tabela.

2- Analise o índice e veja o tamanho dele:
    ALTER INDEX SOE.&INDEX_NAME SHRINK SPACE;
    
    SELECT      i.owner,
                i.index_name AS "Index Name", 
                nvl(i.num_rows,0) AS "Rows",           
                ROUND((nvl(i.leaf_blocks,0) * p.value)/1024/1024,2) AS "Size MB", 
                i.last_analyzed AS "Last Analyzed"
    FROM        dba_indexes i,
                v$parameter p
    WHERE       i.owner = 'SOE'
    AND         INDEX_NAME = '&index_name'
    AND         p.name = 'db_block_size'
    ORDER by    4 desc;

3- Delete 1 milhão de linhas na tabela criada no passo 1
    DELETE FROM SOE.&table_name WHERE ROWNUM < 100000;
    COMMIT;

4- Execute o SHRINK na tabela criada (ver comando abaixo), analise o indice novamente e veja de novo o tamanho dele. 
    alter table soe.orders2 shrink space;
    select * from dba_indexes where owner = 'SOE';
    
5- Agora responda a questão: o índice permaneceu com o mesmo tamanho, aumentou ou diminuiu? Porque?