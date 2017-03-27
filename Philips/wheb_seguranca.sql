create or replace package wheb_seguranca as

  function encrypt (texto_p  in  varchar2,ds_chave_p  in  varchar2) return raw;
  function decrypt (texto_cript_p  in  raw,ds_chave_p  in  varchar2) return varchar2;
  
  function encrypt (texto_p  in  varchar2) return raw;
  function decrypt (texto_cript_p  in  raw) return varchar2;
  
  function gerar_chave return raw;

end wheb_seguranca;
/
create or replace
package body wheb_seguranca as
	
g_pad_chr varchar2(1) := '~';

procedure padstring(p_text  in out  varchar2);

function encrypt(	texto_p  	in  varchar2,
			ds_chave_p  	in  varchar2)  return raw is

l_text_w       varchar2(32767) := texto_p;
l_encrypted_w  raw(32767);
g_key_w        raw(32767) := utl_raw.cast_to_raw(ds_chave_p);

begin
	padstring(l_text_w);

	dbms_obfuscation_toolkit.desencrypt(	input => utl_raw.cast_to_raw(l_text_w),
						key => g_key_w,
						encrypted_data => l_encrypted_w);

	return l_encrypted_w;
end;

function encrypt (texto_p	in  varchar2) return raw is

l_text_w       varchar2(32767) := texto_p;
l_encrypted_w  raw(32767);
ds_chave_w     raw(32767);
g_key_w        raw(32767);

begin

if	(texto_p is not null) then

	ds_chave_w := gerar_chave;
	g_key_w := utl_raw.cast_to_raw(ds_chave_w);
	padstring(l_text_w);

	dbms_obfuscation_toolkit.desencrypt(	input => utl_raw.cast_to_raw(l_text_w),
						key => g_key_w,
						encrypted_data => l_encrypted_w);
	
	l_encrypted_w	:= substr(ds_chave_w,1,14) || l_encrypted_w || substr(ds_chave_w,15,14);

	return l_encrypted_w;
else
	return null;
end if;

end;


function decrypt(	texto_cript_p	in raw,
			ds_chave_p	in varchar2)  return varchar2 is

l_decrypted_w  	varchar2(32767);
g_key_w        	raw(32767)  := utl_raw.cast_to_raw(ds_chave_p);

begin

dbms_obfuscation_toolkit.desdecrypt(	input => texto_cript_p,
					key => g_key_w,
					decrypted_data => l_decrypted_w);

return rtrim(utl_raw.cast_to_varchar2(l_decrypted_w), g_pad_chr);

end;

function decrypt (texto_cript_p  in raw) return varchar2 is

l_decrypted_w  	varchar2(32767);
g_key_w        	raw(32767);
ds_chave_w	raw(32767);
texto_cript_w	raw(32767);

begin

if	(texto_cript_p is not null) then

	ds_chave_w := substr(texto_cript_p,1,14) || substr(texto_cript_p,length(texto_cript_p)-13,14);
	texto_cript_w := substr(texto_cript_p,15,length(texto_cript_p)-28);
	g_key_w	:= utl_raw.cast_to_raw(ds_chave_w);

	dbms_obfuscation_toolkit.desdecrypt(	input => texto_cript_w,
						key => g_key_w,
						decrypted_data => l_decrypted_w);

	return rtrim(utl_raw.cast_to_varchar2(l_decrypted_w), g_pad_chr);
else
	return null;
end if;

end;

procedure padstring(p_text  in out  varchar2) is 

l_units  number;

begin

if length(p_text) mod 8 > 0 then

	l_units := trunc(length(p_text)/8) + 1;
	p_text  := rpad(p_text, l_units * 8, g_pad_chr);
end if;

end;

function gerar_chave return raw is

numero_w 	number;
ds_semente_w 	varchar2(16);

begin

select to_number(to_char(sysdate,'HH24')) + to_number(to_char(sysdate,'MI'))
into numero_w
from dual;

dbms_random.initialize (numero_w);

select  substr(to_char(sum(b.value)) || to_char(sysdate,'SSSSS'),1,16)
into	ds_semente_w
from  	v$statname a,
	V$SESSTAT b
where  	a.statistic# = b.statistic#
and 	a.name in ('db block gets','consistent gets');

while (length(ds_semente_w) < 16) loop

	ds_semente_w := ds_semente_w || '1';
end loop;

return utl_raw.cast_to_raw(ds_semente_w);

end;
end wheb_seguranca;
/