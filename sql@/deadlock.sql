select s1.username || '@' || s1.machine
|| ' ( SID=' || s1.sid || ' )  ----> está bloqueando a sessão ----> '
|| s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS BloqueadorXBloqueado
from v$lock l1, v$session s1, v$lock l2, v$session s2
where s1.sid=l1.sid and s2.sid=l2.sid
and l1.BLOCK=1 and l2.request > 0
and l1.id1 = l2.id1
and l2.id2 = l2.id2 
/

-- select * from v$lock where sid = &SID and block <> 0;
select * from v$lock where sid = &SID and TYPE = 'TM';

select object_name from all_objects where object_id = &Object_ID1_Acima;

-- select row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row# from v$session --where sid=&SID;

select do.object_name,
dbms_rowid.rowid_create ( 1, ROW_WAIT_OBJ#, ROW_WAIT_FILE#, ROW_WAIT_BLOCK#, ROW_WAIT_ROW# )
from v$session s, all_objects do
where sid=&SID_TM_ACIMA
and s.ROW_WAIT_OBJ# = do.OBJECT_ID;

select * from &Objeto_Identificado_acima where rowid='&ROWID_Identificado_acima';