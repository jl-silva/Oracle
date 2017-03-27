declare

cursor c_01 is
       SELECT 'ALTER TRIGGER '|| TRIGGER_NAME || ' DISABLE ' texto
         FROM all_triggers 
        WHERE table_name = 'PESSOA';

begin 

for r_c_01 in c_01 loop
  
    EXECUTE IMMEDIATE r_c_01.texto;
end loop;

end;
/