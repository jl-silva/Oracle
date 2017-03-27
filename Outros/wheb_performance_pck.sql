create or replace 
package wheb_performance_pck authid CURRENT_USER as

procedure	gera_plano_execucao;
function	obter_plano_execucao return varchar2;

end wheb_performance_pck;
/

create or replace 
package body wheb_performance_pck as

qt_blocos_logico_w 	number(10);
qt_chamada_recursiva_w	number(10);
qt_leitura_fisica_w	number(10);

procedure gera_plano_execucao as

qt_valor_w		number(10);
ds_indicador_w		varchar2(50);

cursor C01 is
	select 	sum(b.value),
		'consistent gets' 
	from 	v$statname a, 
		v$mystat b 
	where 	a.statistic#=b.statistic# 
	and	a.name in ('db block gets','consistent gets')
	union
	select 	b.value,
		a.name
	from 	v$statname a, 
		v$mystat b 
	where 	a.statistic#=b.statistic# 
	and	a.name in ('recursive calls','physical reads');
begin

open C01;
loop
fetch C01 into	
	qt_valor_w,
	ds_indicador_w;
exit when C01%notfound;

	if	(ds_indicador_w = 'consistent gets') then

		qt_blocos_logico_w := qt_valor_w;

	elsif	(ds_indicador_w = 'recursive calls') then

		qt_chamada_recursiva_w := qt_valor_w;

	elsif	(ds_indicador_w = 'physical reads') then

		qt_leitura_fisica_w := qt_valor_w;
	end if;

end loop;
close C01;
end;

function obter_plano_execucao return varchar2 as

qt_blocos_logico_inicio_w 	number(10);
qt_chamada_recursiva_inicio_w	number(10);
qt_leitura_fisica_inicio_w	number(10);
ds_retorno_w			varchar2(2000);

begin

qt_blocos_logico_inicio_w 	:= qt_blocos_logico_w;
qt_chamada_recursiva_inicio_w	:= qt_chamada_recursiva_w;
qt_leitura_fisica_inicio_w	:= qt_leitura_fisica_w;

gera_plano_execucao;
ds_retorno_w := 'BL='|| (qt_blocos_logico_w - qt_blocos_logico_inicio_w) ||';'||
		'BF='|| (qt_leitura_fisica_w - qt_leitura_fisica_inicio_w) ||';'||
		'CR='|| (qt_chamada_recursiva_w - qt_chamada_recursiva_inicio_w);

return ds_retorno_w;

end;
end wheb_performance_pck;
/