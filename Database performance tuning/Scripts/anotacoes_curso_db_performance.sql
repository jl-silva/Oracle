- TDE Criptografia a nível de tabela ou tablespace;
- Pool de conexão para aplicações Web;
- Checklist, pode ser montado uma série de scripts para ajudar a identificar;
- Swingbench, simula uma aplicação com número de usuário e fazendo alguma alteração de tempos em tempos;
- VM usuario oracle senha oracle
- iostat precisa de instalação no linux e precisa tbm em algumas versões de permissão para execução;
- echo $ORACLE_HOME
- Zabbix para monitorar arquivos de txt, por exemplo o alertlog, na busca de erros;
- Procurar no site do fabio prado referente a monitoramento do banco, possui scripts para auxiliar nesta tarefa
- Mandar e-mail pro Fabio pedindo os scripts do statspack, também pedir sql que mostra o SQL em execução e com o valores das variáveis bind
- log switches (derived), quantidade de arquivo de redo, quanto menor mais seguro porém menos performático
- keeppool
- STO/OOS != de zero significa que está dando muito snapshot too old, e precisa ser verificado
- Memory Resize significa que o oracle está tirando memoria de uma operação para outra, nem sempre significa problema, só quando acontece constantemente ou muitas vezes em um curto periodo
- packs and options proucurar no google pra saber das features, o preço oracle price list;
- edb360 ferramenta free para gerar relatórios sobre o banco de dados, como um AWR
- select * from table(dbms_xplan.display_cursor('ID_DO_SQL')); pegar o explain real do sql, que foi executado
- keeppool, parte da buffer e sempre deixa o objeto ou sql em cache



dúvida no caso de objeto procedure, funcition ou package ele atualiza ao recompilar?