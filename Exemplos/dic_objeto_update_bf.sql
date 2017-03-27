CREATE OR REPLACE TRIGGER dic_objeto_update_bf
before update on dic_objeto 
for each row
declare
ds_user_w varchar2(100);

begin
select max(USERNAME)
into ds_user_w
from v$session
where  audsid = (select userenv('sessionid') from dual);

if (ds_user_w = 'TASY') then
 if (:new.nm_usuario = 'jlsilva') and
  (:new.nr_sequencia  = 471826) then
  
  --raise_application_error(-20011,'oi');
  :new.ds_texto := 'Cancelar e desvincular títulos lote';
 end if;

end if;

end;
/