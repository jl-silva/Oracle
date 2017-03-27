/*
Se houver memória limitada para a SGA, utilize Database Smart Flash Cache (FLASH CACHE) (novo no 11GR2);

Flash Cache permite usar SSD para armazenar dados da buffer cache e gerar menos I/O quando SGA não tem tamanho suficiente para comportar dados com mais eficiência (menos I/O);

SSD é menos eficiente que memória RAM, mas é mais barata. SSD tem I/O mais eficiente que discos rígidos, mas é mais cara;

Utilize DRAM SSD e não Flash SSD;

É bom para ambientes OLTP e ambientes com RAC e está disponível somente para EL ou Solaris e Database Enterprise Edition;

No 12c, é possível utilizar múltiplos dispositivos SSD mais facilmente;

Cuidado! Apesar de gerar menos I/O, irá aumentar o uso de CPU;
*/


-- habilitando flash_cache
    -- a) habilitar caminho (raw device, um arquivo ou disk group ASM) para gerar flash_cache
    alter system set db_flash_cache_file = '/tmp/teste.fc' scope=spfile;
    -- b) configurar tamanho 
    alter system set db_flash_cache_size = 100M scope=spfile;
    
    
-- altere um objeto para usar flash cache
alter table schema.table storage (flash_cache keep);