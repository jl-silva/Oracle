create or replace package wheb_sms authid CURRENT_USER as
  
  /*Inicio Métodos gerais -
Se for necess rio verificar status do SMS utilizar no campo DS_REMETENTE_P o valor sequence WHEB_SMS_SEQ, este valor dever  ser utilizado para consultar o status do SMS
*/
procedure enviar_sms(DS_REMETENTE_p in varchar2,DS_DESTINATARIO_p in varchar2,DS_MENSAGEM_p in varchar2,NM_USUARIO_P in varchar2,ID_SMS_P out number);
procedure grava_retorno_sms(nr_celular_p in varchar2, ds_resposta_p in varchar2,	dt_resposta_p in varchar2);
procedure verifica_resposta_sms(NM_USUARIO_p IN VARCHAR2, ID_SMS_P in number default null);
function get_creditos(NM_USUARIO_P in varchar2) return number;
/*DS_REMETENTE -> Identificador utilizado no envio do SMS / DT_ENVIO - Data que foi realizado o envio do SMS*/
function obter_status_sms(ID_SMS_P in number,DT_ENVIO_P in VARCHAR2,NM_USUARIO_P in varchar2) return varchar2;
function obter_ds_status_sms(CD_STATUS_P in varchar2,NM_USUARIO_P in varchar2) return varchar2;
/*Fim Métodos gerais*/

end wheb_sms;
/
create or replace package body wheb_sms as
  TYPE t_list_of_xml IS TABLE OF VARCHAR2 (32767);
  
	/*Variaveis Globais*/
	cd_empresa_w 			number(10);
	nm_usuario_sms_w 		varchar2(255);
	ds_senha_usuario_sms_w	varchar2(255);
	nm_usuario_proxy_w		varchar2(255);
	ds_senha_proxy_w		varchar2(255);
	ip_servidor_proxy_w		varchar2(255);

	/* Rotinas utilizadas para integração com WhebServidorSMS */
	function	OBTER_RETORNO(ds_xml_p varchar2) return LT_RETORNO is
		retorno_w LT_RETORNO;
		xml_w     xmltype;
	begin
		xml_w := SYS.XMLTYPE.CREATEXML(ds_xml_p);

		xml_w.toObject(retorno_w);

		return retorno_w;
	end;

	function	OBTER_LISTA_MSGS_RETORNO_SMS(ds_xml_p varchar2) return lt_mensagens_sms is
		retorno_w lt_mensagens_sms;
		xml_w     xmltype;
	begin
		xml_w := SYS.XMLTYPE.CREATEXML(ds_xml_p);

		xml_w.toObject(retorno_w);

		return retorno_w;
	end;

	function	obter_retorno_operacao_sms(nm_usuario_p in varchar2, 
		parametros_sms_p lt_parametros_sms) return t_list_of_xml
	as
		tipo_w				constant pls_integer := dbms_crypto.encrypt_aes128 + dbms_crypto.chain_ecb + dbms_crypto.pad_pkcs5;
		chave_w				constant raw(16)     := '193915579efa5663c0a4da213a219b5f';
		req_w				sys.utl_http.req;
		res_w				sys.utl_http.resp;
		xml_string_w			varchar2(2000);
		encrypted_xml_w			raw(2000);
		url_w				varchar2(100);
		ip_w				varchar2(255);
		xml_w				xmltype;
		linha_w				varchar2(32767);
		buffer_criptografado_w		raw(32767);
		buffer_descriptografado_w	raw(32767);  
		lista_w				t_list_of_xml; 
	begin
		lista_w := t_list_of_xml();

		ip_w            := obter_valor_param_usuario(9041,5,nvl(wheb_usuario_pck.get_cd_perfil,0),nm_usuario_p, nvl(wheb_usuario_pck.get_cd_estabelecimento,1));
		url_w           := ip_w || '/WhebServidorSMS/ServerSMSServlet';
    
		xml_w           := sys.xmltype.createxml(parametros_sms_p);
		xml_string_w    := xml_w.getstringval();
		encrypted_xml_w := sys.dbms_crypto.encrypt(utl_raw.cast_to_raw(xml_string_w), tipo_w, chave_w);
    
		req_w           := sys.utl_http.begin_request(url => url_w, method => 'POST');
		sys.utl_http.set_header(r => req_w, name => 'Content-Type', value => 'text/plain;charset=UTF-8');
		sys.utl_http.set_header(r => req_w, name => 'Content-Length', value => length(encrypted_xml_w));
		sys.utl_http.write_text(r => req_w, data => encrypted_xml_w);

    		begin		
			res_w := sys.utl_http.get_response(req_w);
			loop
				--Lê uma linha da resposta (é um arquivo XML por linha)
				--a resposta é um hexadecimal em forma de texto (content-type: text/plain;charset=UTF-8)
				sys.utl_http.read_line(res_w, linha_w); 
        
				--retira fim de linha e espaços em branco (tem que ser um hexadecimal válido)
				linha_w := replace(replace(replace(linha_w, chr(13), ''), chr(10), ''), ' ', '');
        
				buffer_criptografado_w := cast(linha_w as raw); --ex: varchar2 'FFFF para raw 'FFFF'
        
				if (sys.utl_raw.length(buffer_criptografado_w) > 0) then          
					buffer_descriptografado_w := sys.dbms_crypto.decrypt(buffer_criptografado_w, tipo_w, chave_w);
          
					--cada item é um XML completo
					lista_w.extend;
					lista_w(lista_w.last) := sys.utl_raw.cast_to_varchar2(buffer_descriptografado_w);
				end if;
			end loop;
			sys.utl_http.end_response(res_w);
		exception
			when sys.utl_http.end_of_body then
				sys.utl_http.end_response(res_w);
			when others then
				sys.utl_http.end_response(res_w);
				wheb_mensagem_pck.exibir_mensagem_abort(349244, 'ERROR=' || sqlerrm(sqlcode));
		end;
    
		return lista_w;
	end;

	/*INICIO metodos integração Comunika*/
	procedure comunika_conectar (NM_USUARIO in varchar2, DS_SENHA_USUARIO in varchar2, IE_MODO_TESTE in number) as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSVola.conectar(java.lang.String,java.lang.String,java.lang.Integer)';
	function comunika_enviar_sms(DS_REMETENTE in varchar2,DS_DESTINATARIO in varchar2,DS_MENSAGEM in varchar2,ID_SMS in varchar2) return number as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSVola.enviarSMS(java.lang.String,java.lang.String,java.lang.String,java.lang.String) return java.lang.Integer';
	function comunika_get_creditos return number as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSVola.getCreditos() return java.lang.Integer';
	function comunika_get_ds_resultado(CD_RESULTADO in number) return varchar2 as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSVola.getDsResultado(java.lang.Integer) return java.lang.String';
	function comunika_get_ds_status_sms(ID_SMS in varchar2) return varchar2 as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSVola.getDsStatusSMS(java.lang.String) return java.lang.String';
	procedure comunika_retorno_sms as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSVola.processaRetornoSMS()';
	/*Fim métodos integração Comunika*/

	/*Inicio métodos integração TWW 1.0*/
	function tww_get_creditos (NM_USUARIO in varchar2, DS_SENHA_USUARIO in varchar2,NM_USUARIO_PROXY_P in varchar2, DS_SENHA_PROXY_P in varchar2,DS_IP_PROXY_P in varchar2) return number as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSTww.getCreditos(java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String) return java.lang.Integer';
	function tww_enviar_sms(NM_USUARIO in varchar2, DS_SENHA_USUARIO in varchar2,DS_REMETENTE in varchar2,DS_DESTINATARIO in varchar2,DS_MENSAGEM in varchar2,NM_USUARIO_PROXY_P in varchar2, DS_SENHA_PROXY_P in varchar2,DS_IP_PROXY_P in varchar2) return number as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSTww.enviarSMS(java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String) return java.lang.Integer';
	function tww_verifica_erro(CD_ERRO in number) return varchar2 as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSTww.getDescricaoErro(java.lang.Integer) return java.lang.String';
	function tww_get_status_sms (NM_USUARIO in varchar2, DS_SENHA_USUARIO in varchar2,NM_USUARIO_PROXY_P in varchar2, DS_SENHA_PROXY_P in varchar2,DS_IP_PROXY_P in varchar2,DS_REMETENTE_P in varchar2,DT_ENVIO_P in varchar2) return varchar2 as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSTww.getStatusSMS(java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String) return java.lang.String';
	procedure tww_retorno_sms (NM_USUARIO in varchar2, DS_SENHA_USUARIO in varchar2,NM_USUARIO_PROXY_P in varchar2, DS_SENHA_PROXY_P in varchar2,DS_IP_PROXY_P in varchar2) as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSTww.processaRetornoSMS(java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String)';
	/*Fim métodos TWW*/

	/*Inicio métodos integração TWW 2_02*/
	function tww_2_02_get_creditos (NM_USUARIO in varchar2, DS_SENHA_USUARIO in varchar2,NM_USUARIO_PROXY_P in varchar2, DS_SENHA_PROXY_P in varchar2,DS_IP_PROXY_P in varchar2) return number as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSTww_2_02.getCreditos(java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String) return java.lang.Integer';

	function tww_2_02_enviar_sms(NM_USUARIO in varchar2, DS_SENHA_USUARIO in varchar2,DS_REMETENTE in varchar2,DS_DESTINATARIO in varchar2,DS_MENSAGEM in varchar2,NM_USUARIO_PROXY_P in varchar2, DS_SENHA_PROXY_P in varchar2,DS_IP_PROXY_P in varchar2) return number as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSTww_2_02.enviarSMS(java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String) return java.lang.Integer';

	function tww_2_02_verifica_erro(CD_ERRO in number) return varchar2 as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSTww_2_02.getDescricaoErro(java.lang.Integer) return java.lang.String';

	function tww_2_02_get_status_sms (NM_USUARIO in varchar2, DS_SENHA_USUARIO in varchar2,NM_USUARIO_PROXY_P in varchar2, DS_SENHA_PROXY_P in varchar2,DS_IP_PROXY_P in varchar2,DS_REMETENTE_P in varchar2,DT_ENVIO_P in varchar2) return varchar2 as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSTww_2_02.getStatusSMS(java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String) return java.lang.String';

	procedure tww_2_02_retorno_sms (NM_USUARIO in varchar2, DS_SENHA_USUARIO in varchar2,NM_USUARIO_PROXY_P in varchar2, DS_SENHA_PROXY_P in varchar2,DS_IP_PROXY_P in varchar2) as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSTww_2_02.processaRetornoSMS(java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String)';
	/*Fim métodos TWW*/

	/*Inicio métodos integração Human*/
	function human_enviar_sms(NM_USUARIO in varchar2, DS_SENHA_USUARIO in varchar2,DS_REMETENTE in varchar2,DS_ID in varchar2, DS_DESTINATARIO in varchar2,DS_MENSAGEM in varchar2,NM_USUARIO_PROXY_P in varchar2, DS_SENHA_PROXY_P in varchar2,DS_IP_PROXY_P in varchar2) return number as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSHuman.enviarSMS(java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String) return java.lang.Integer';
	function human_verifica_erro(CD_ERRO in number) return varchar2 as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSHuman.getDescricaoErro(java.lang.Integer) return java.lang.String';
	function human_get_status_sms(ID_SMS_P in number, NM_USUARIO in varchar2, DS_SENHA in varchar2, NM_USUARIO_PROXY_P in varchar2, DS_SENHA_PROXY_P in varchar2, DS_IP_PROXY_P in varchar2) return varchar2 as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSHuman.getStatusSMS(java.lang.Integer, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';
	procedure human_retorno_sms (NM_USUARIO in varchar2, DS_SENHA_USUARIO in varchar2, NM_USUARIO_PROXY_P in varchar2, DS_SENHA_PROXY_P in varchar2, DS_IP_PROXY_P in varchar2) as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSHuman.processaRetornoSMS(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String)';
	/*Fim métodos Human*/

	/*Inicio métodos Spring Wireless*/

	function spring_enviar_sms(NM_USUARIO in varchar2, DS_SENHA_USUARIO in varchar2, DS_ID in varchar2, DS_DESTINATARIO in varchar2,DS_MENSAGEM in varchar2,NM_USUARIO_PROXY_P in varchar2, DS_SENHA_PROXY_P in varchar2,DS_IP_PROXY_P in varchar2, DS_RMI_ADDRESS in varchar2, DS_RMI_PORT in varchar2, CD_EMPRESA in varchar2) return number as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSSpringWireless.enviarSMS(java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.Integer';
		function spring_verifica_erro(CD_ERRO in number) return varchar2 as

		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSSpringWireless.getDescricaoErro(java.lang.Integer) return java.lang.String';
	function spring_get_status_sms(ID_SMS_P in number, NM_USUARIO in varchar2, DS_SENHA in varchar2, NM_USUARIO_PROXY_P in varchar2, DS_SENHA_PROXY_P in varchar2, DS_IP_PROXY_P in varchar2) return varchar2 as

		language JAVA name 'br.com.wheb.sms.cliente.WhebSMSSpringWireless.getStatusSMS(java.lang.Integer, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';
		/*Fim métodos Spring Wireless*/


	/*INICIO metodos integração SmsDigital*/
	function digital_enviar_sms(
				NM_USUARIO 			in varchar2,
				DS_SENHA_USUARIO 	in varchar2,
				DS_REMETENTE		in varchar2,
				DS_DESTINATARIO		in varchar2,
				DS_MENSAGEM			in varchar2,
				NM_USUARIO_PROXY_P	in varchar2,
				DS_SENHA_PROXY_P	in varchar2,
				DS_IP_PROXY_P		in varchar2)
				return number as

		language JAVA name 'br.com.wheb.sms.cliente.WhebSmsDigital.enviarSMS(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.Integer';

	function digital_get_status_sms(
				ID_SMS_P			in number,
				NM_USUARIO_P		in varchar2,
				DS_SENHA_P			in varchar2,
				NM_USUARIO_PROXY_P	in varchar2,
				DS_SENHA_PROXY_P	in varchar2,
				DS_IP_PROXY_P		in varchar2)
				return varchar2 as
		language JAVA name 'br.com.wheb.sms.cliente.WhebSmsDigital.getStatusSMS(java.lang.Integer, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';

	procedure digital_retorno_sms (
				ID_SMS_P			in number,
				NM_USUARIO_P		in varchar2,
				DS_SENHA_USUARIO_P	in varchar2,
				NM_USUARIO_PROXY_P	in varchar2,
				DS_SENHA_PROXY_P	in varchar2,
				DS_IP_PROXY_P		in varchar2) as

		language JAVA name 'br.com.wheb.sms.cliente.WhebSmsDigital.getRespostaSMS(java.lang.Integer, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String)';

	function digital_get_creditos (
				NM_USUARIO_P		in varchar2,
				DS_SENHA_USUARIO_P	in varchar2,
				NM_USUARIO_PROXY_P	in varchar2,
				DS_SENHA_PROXY_P	in varchar2,
				DS_IP_PROXY_P		in varchar2)
				return number as

		language JAVA name 'br.com.wheb.sms.cliente.WhebSmsDigital.getCreditos(java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String) return java.lang.Integer';






	/*INICIO metodos GOIP*/
    function goip_enviar_sms(
				DS_DOMINIO_SERVIDOR	in varchar2,
				NM_USUARIO 			in varchar2,
				DS_SENHA_USUARIO 	in varchar2,
				DS_REMETENTE		in varchar2,
				DS_DESTINATARIO		in varchar2,
				DS_MENSAGEM		in varchar2,
				NM_USUARIO_PROXY_P	in varchar2,
				DS_SENHA_PROXY_P	in varchar2,
				DS_IP_PROXY_P		in varchar2)
				return number as

	language JAVA name 'br.com.wheb.sms.cliente.WhebSmsGoip.enviarSMS(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.Integer';

	function goip_enviar_sms(
				DS_DOMINIO_SERVIDOR	in varchar2,
				NM_USUARIO 			in varchar2,
				DS_SENHA_USUARIO 	in varchar2,
				DS_REMETENTE		in varchar2,
				DS_DESTINATARIO		in varchar2,
				DS_MENSAGEM		in varchar2,
				NM_USUARIO_PROXY_P	in varchar2,
				DS_SENHA_PROXY_P	in varchar2,
				DS_IP_PROXY_P		in varchar2,
				IE_PROVIDER_P		in varchar2)
				return number as

	language JAVA name 'br.com.wheb.sms.cliente.WhebSmsGoip.enviarSMS(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.Integer';

	procedure	armazena_configuracoes_sms(NM_USUARIO_P in varchar2) as

		ds_parametro_w			varchar2(255);
		cd_estabelecimento_w	number(4);
	begin

		cd_estabelecimento_w := nvl(wheb_usuario_pck.get_cd_estabelecimento,1);

		nm_usuario_sms_w 		:= OBTER_VALOR_PARAM_USUARIO(0,54,nvl(wheb_usuario_pck.get_cd_perfil,0),nm_usuario_p,cd_estabelecimento_w);
		if	(nm_usuario_sms_w is null) then
			select	ds_parametro
			into	ds_parametro_w
			from	funcao_parametro
			where	cd_funcao	= 0
			and		nr_sequencia	= 54;
			Wheb_mensagem_pck.exibir_mensagem_abort(213820,'DS_PARAMETRO_W=' || ds_parametro_w);
		end if;

		ds_senha_usuario_sms_w	:= OBTER_VALOR_PARAM_USUARIO(0,55,nvl(wheb_usuario_pck.get_cd_perfil,0),nm_usuario_p,cd_estabelecimento_w);
		if	(ds_senha_usuario_sms_w is null) then
			select	ds_parametro
			into	ds_parametro_w
			from	funcao_parametro
			where	cd_funcao		= 0
			and		nr_sequencia	= 55;
			Wheb_mensagem_pck.exibir_mensagem_abort(213820,'DS_PARAMETRO_W=' || ds_parametro_w);
		end if;

		cd_empresa_w			:= OBTER_VALOR_PARAM_USUARIO(0,89,0,nm_usuario_p,1);
		ip_servidor_proxy_w		:= OBTER_VALOR_PARAM_USUARIO(0,80,0,nm_usuario_p,1);
		nm_usuario_proxy_w 		:= OBTER_VALOR_PARAM_USUARIO(0,81,0,nm_usuario_p,1);
		ds_senha_proxy_w		:= OBTER_VALOR_PARAM_USUARIO(0,82,0,nm_usuario_p,1);

	end;

	procedure	grava_retorno_sms(nr_celular_p in varchar2, ds_resposta_p in varchar2,	dt_resposta_p in varchar2) as
	begin
		insert into log_retorno_sms(
			nr_sequencia,
			nr_celular,
			ds_resposta,
			dt_resposta,
			ie_processado
		)values(
			log_retorno_sms_seq.nextVal,
			nr_celular_p,
			ds_resposta_p,
			to_date(dt_resposta_p,'dd/mm/yyyy hh24:mi:ss'),
			'N'
		);
		commit;
	end;

	procedure 	verifica_resposta_sms(
			NM_USUARIO_P in varchar2,
			ID_SMS_P	 in number default null)
			as
	parametros_sms_w		LT_PARAMETROS_SMS;
	ie_forma_w				varchar2(1);
	ds_retorno_sms_w		clob;
	xml_w			        xmltype;
	dt_teste_w				date;
	lista_retorno_xml 		t_list_of_xml;


	item					lt_mensagem_sms;
	lista					lt_mensagens_sms;


	begin
		armazena_configuracoes_sms(NM_USUARIO_P);
		parametros_sms_w := LT_PARAMETROS_SMS(	null, null, null, null,null,
												null,null,null,null,
												null,null,null,null,
												null,null,null,null);


		parametros_sms_w.DS_OPERACAO			:= 'RETORNO';
		parametros_sms_w.ID_SMS					:= ID_SMS_P;
		parametros_sms_w.NM_USUARIO				:= nm_usuario_sms_w;
		parametros_sms_w.DS_SENHA				:= ds_senha_usuario_sms_w;
		parametros_sms_w.IP_SERVIDOR_PROXY		:= ip_servidor_proxy_w;
		parametros_sms_w.CD_EMPRESA				:= cd_empresa_w;
		parametros_sms_w.NM_USUARIO_PROXY		:= nm_usuario_proxy_w;
		parametros_sms_w.DS_SENHA_PROXY			:= ds_senha_proxy_w;

		ie_forma_w	 		:= obter_valor_param_usuario(0,202,nvl(wheb_usuario_pck.get_cd_perfil,0),NM_USUARIO_P, nvl(wheb_usuario_pck.get_cd_estabelecimento,1));

		if	(nvl(ie_forma_w, 'B') = 'B') then
			begin
			if (cd_empresa_w = 1 ) then
				comunika_conectar(nm_usuario_sms_w,ds_senha_usuario_sms_w,0);
				comunika_retorno_sms;
			elsif ( cd_empresa_w = 2) then
				tww_retorno_sms(nm_usuario_sms_w,ds_senha_usuario_sms_w,nm_usuario_proxy_w,ds_senha_proxy_w,ip_servidor_proxy_w);
			elsif ( cd_empresa_w = 3) then
				tww_2_02_retorno_sms(nm_usuario_sms_w,ds_senha_usuario_sms_w,nm_usuario_proxy_w,ds_senha_proxy_w,ip_servidor_proxy_w);
			elsif ( cd_empresa_w = 4) then
				human_retorno_sms(nm_usuario_sms_w,ds_senha_usuario_sms_w,nm_usuario_proxy_w,ds_senha_proxy_w,ip_servidor_proxy_w);
			elsif ( cd_empresa_w = 5) then
				Wheb_mensagem_pck.exibir_mensagem_abort(248883); --Operação não implementada para a Spring Wireless
			elsif ( cd_empresa_w = 8) then
				if	(ID_SMS_P is null) then
					Wheb_mensagem_pck.exibir_mensagem_abort(297286); -- Para utilização deste recurso é necessário informar o ID do sms
				end if;

				digital_retorno_sms(
						id_sms_p,
						nm_usuario_sms_w,
						ds_senha_usuario_sms_w,
						nm_usuario_proxy_w,
						ds_senha_proxy_w,
						ip_servidor_proxy_w);
			end if;
			end;
		else
			begin
				lista_retorno_xml := obter_retorno_operacao_sms(nm_usuario_p, parametros_sms_w);
        				
				for i in 1 .. lista_retorno_xml.count loop
					lista := OBTER_LISTA_MSGS_RETORNO_SMS(lista_retorno_xml(i));  
          
					for j in 1 .. lista.mensagens.count loop
						item := lista.mensagens(j);
						grava_retorno_sms(item.nr_celular, item.ds_mensagem, item.dt_resposta);
					end loop;                    
				end loop;        
			end;
		end if;
	end;

	procedure enviar_sms(DS_REMETENTE_P in varchar2,DS_DESTINATARIO_P in varchar2,DS_MENSAGEM_p in varchar2,NM_USUARIO_P in varchar2,ID_SMS_P out number) as
	/*
	DS_DESTINARATIO_P -> Para enviar para mais de um destinatario , separar o telefone por ( ; )  ponto e virgula
	*/
	ds_destinatario_w		varchar2(50);
	ds_destinatarios_w		varchar2(512);
	ds_mensagem_w			varchar2(512);
	ds_sep_cel_w			varchar2(10);
	nr_pos_separador_w		NUMBER(10);
	qt_controle_w			number(10);
	qt_tam_sep_w			number(10);
	ds_servidor_w			varchar2(2000);
	ie_provider_w			varchar2(10);
	ie_forma_w				varchar2(1);
	parametros_sms_w		LT_PARAMETROS_SMS;
	ds_retorno_sms_w		varchar2(255);
	retorno_w			lt_retorno;
	lista_retorno_xml		t_list_of_xml;


	type lista is RECORD (
		nr_celular VARCHAR2(50));

	type myArray is table of lista index by binary_integer;

	/*Contem os parametros do SQL*/
	ar_destinatario_w myArray;

	begin

	ie_forma_w	 		:= obter_valor_param_usuario(0,202,nvl(wheb_usuario_pck.get_cd_perfil,0),NM_USUARIO_P, nvl(wheb_usuario_pck.get_cd_estabelecimento,1));
	armazena_configuracoes_sms(NM_USUARIO_P);
	ds_mensagem_w 		:= elimina_acentuacao(ds_mensagem_p);
	ds_sep_cel_w		:= ';';
	ds_destinatarios_w	:= ds_destinatario_p;

	/*INICIO - TRATAMENTO PARA ENVIAR PARA VARIOS DESTINÁRIOS*/
	if	(substr(ds_destinatarios_w,length(ds_destinatarios_w),1) <> ds_sep_cel_w) then
		ds_destinatarios_w := ds_destinatarios_w || ds_sep_cel_w;
	end if;

	nr_pos_separador_w := instr(ds_destinatarios_w,ds_sep_cel_w);
	qt_controle_w	   := 0;
	qt_tam_sep_w 	   := length(ds_sep_cel_w);
	while	(nr_pos_separador_w > 0 ) loop
		begin
		qt_controle_w 		:= qt_controle_w + 1;
		ds_destinatario_w  	:= substr(ds_destinatarios_w,1,nr_pos_separador_w-1);
		ds_destinatarios_w   	:= substr(ds_destinatarios_w,nr_pos_separador_w+qt_tam_sep_w,length(ds_destinatarios_w));
		ar_destinatario_w(qt_controle_w).nr_celular := ds_destinatario_w;
		nr_pos_separador_w := instr(ds_destinatarios_w,ds_sep_cel_w);
		if	(qt_controle_w > 20) then
			nr_pos_separador_w := 0;
		end if;
		end;
	end loop;
	/*FIM - TRATAMENTO PARA ENVIAR PARA VARIOS DESTINÁRIOS*/

	if (ar_destinatario_w.count = 0) then
		ar_destinatario_w(1).nr_celular := ds_destinatarios_w;
	end if;

	for contador_w IN 1..ar_destinatario_w.count loop
		ds_destinatario_w := ar_destinatario_w(contador_w).nr_celular;

		if ((substr(ds_destinatario_w,1,2) = '55') and ( Length(ds_destinatario_w) > 11))  then
			ds_destinatario_w := substr(ds_destinatario_w,3,length(ds_destinatario_w));
		end if;


		ie_forma_w	 		:= obter_valor_param_usuario(0,202,nvl(wheb_usuario_pck.get_cd_perfil,0),NM_USUARIO_P, nvl(wheb_usuario_pck.get_cd_estabelecimento,1));
		ie_provider_w 		:= obter_valor_param_usuario(0,210,nvl(wheb_usuario_pck.get_cd_perfil,0),NM_USUARIO_P, nvl(wheb_usuario_pck.get_cd_estabelecimento,1));
		ds_servidor_w 		:= obter_valor_param_usuario(0,206,nvl(wheb_usuario_pck.get_cd_perfil,0),NM_USUARIO_P, nvl(wheb_usuario_pck.get_cd_estabelecimento,1));

		select 	wheb_sms_seq.nextval
		into	id_sms_p
		from	dual;



		parametros_sms_w := LT_PARAMETROS_SMS(	null, null, null, null,null,
												null,null,null,null,
												null,null,null,null,
												null,null,null,null);

		parametros_sms_w.DS_OPERACAO			:= 'ENVIAR';
		parametros_sms_w.NM_USUARIO				:= nm_usuario_sms_w;
		parametros_sms_w.DS_SENHA				:= ds_senha_usuario_sms_w;
		parametros_sms_w.DS_REMETENTE			:= ds_remetente_p;
		parametros_sms_w.DS_DESTINATARIO		:= ds_destinatario_w;
		parametros_sms_w.DS_MENSAGEM			:= ds_mensagem_w;
		parametros_sms_w.ID_SMS					:= id_sms_p;
		parametros_sms_w.CD_SMS_PROVIDER		:= ie_provider_w;
		parametros_sms_w.IP_SERVIDOR_PROXY		:= ip_servidor_proxy_w;
		parametros_sms_w.CD_EMPRESA				:= cd_empresa_w;
		parametros_sms_w.DS_DOMINIO_SERVIDOR	:= ds_servidor_w; --GOIP
		parametros_sms_w.NM_USUARIO_PROXY		:= nm_usuario_proxy_w;
		parametros_sms_w.DS_SENHA_PROXY			:= ds_senha_proxy_w;


		if	(nvl(ie_forma_w, 'B') = 'B') then
			begin
			if (cd_empresa_w = 1 ) then
				comunika_conectar(nm_usuario_sms_w, ds_senha_usuario_sms_w, 0);
				ds_retorno_sms_w := comunika_enviar_sms(ds_remetente_p, ds_destinatario_w, ds_mensagem_w, '');
				if	(ds_retorno_sms_w not in (0,5)) then
					wheb_mensagem_pck.exibir_mensagem_abort(213824, 'DS_RETORNO_SMS_W='||comunika_get_ds_resultado(ds_retorno_sms_w)||';DS_REMETENTE_P='||ds_remetente_p||';DS_DESTINATARIO_W='||ds_destinatario_w);
				end if;
			elsif ( cd_empresa_w = 2) then
				ds_retorno_sms_w := tww_enviar_sms(nm_usuario_sms_w,ds_senha_usuario_sms_w,id_sms_p,ds_destinatario_w,ds_mensagem_w,nm_usuario_proxy_w,ds_senha_proxy_w,ip_servidor_proxy_w);
				if(ds_retorno_sms_w not in(0)) then
					wheb_mensagem_pck.exibir_mensagem_abort(213824, 'DS_RETORNO_SMS_W='||tww_verifica_erro(ds_retorno_sms_w)||';DS_REMETENTE_P='||ds_remetente_p||';DS_DESTINATARIO_W='||ds_destinatario_w);
				end if;
			elsif ( cd_empresa_w = 3) then
				ds_retorno_sms_w := tww_2_02_enviar_sms(nm_usuario_sms_w,ds_senha_usuario_sms_w,id_sms_p,ds_destinatario_w,ds_mensagem_w,nm_usuario_proxy_w,ds_senha_proxy_w,ip_servidor_proxy_w);
				if(ds_retorno_sms_w not in(0)) then
					wheb_mensagem_pck.exibir_mensagem_abort(213824, 'DS_RETORNO_SMS_W='||tww_verifica_erro(ds_retorno_sms_w)||';DS_REMETENTE_P='||ds_remetente_p||';DS_DESTINATARIO_W='||ds_destinatario_w);
				end if;
			elsif ( cd_empresa_w = 4) then
				ds_retorno_sms_w := human_enviar_sms(nm_usuario_sms_w,ds_senha_usuario_sms_w,ds_remetente_p,id_sms_p,ds_destinatario_w,ds_mensagem_w,nm_usuario_proxy_w,ds_senha_proxy_w,ip_servidor_proxy_w);
				if (ds_retorno_sms_w not in (0)) then
					wheb_mensagem_pck.exibir_mensagem_abort(213824, 'DS_RETORNO_SMS_W='||human_verifica_erro(ds_retorno_sms_w)||';DS_REMETENTE_P='||ds_remetente_p||';DS_DESTINATARIO_W='||ds_destinatario_w);
				end if;

			elsif ( cd_empresa_w = 7) then



				if (nvl(ie_provider_w, '1') <> '1') then
					begin
					ds_retorno_sms_w := goip_enviar_sms(
							ds_servidor_w,
							nm_usuario_sms_w,
							ds_senha_usuario_sms_w,
							ds_remetente_p,
							ds_destinatario_w,
							ds_mensagem_w,
							nm_usuario_proxy_w,
							ds_senha_proxy_w,
							ip_servidor_proxy_w,
							ie_provider_w);
					end;
				else
					begin
					ds_retorno_sms_w := goip_enviar_sms(
							ds_servidor_w,
							nm_usuario_sms_w,
							ds_senha_usuario_sms_w,
							ds_remetente_p,
							ds_destinatario_w,
							ds_mensagem_w,
							nm_usuario_proxy_w,
							ds_senha_proxy_w,
							ip_servidor_proxy_w);
					end;
				end if;

				if (ds_retorno_sms_w in (0)) then
					--Erro ao enviar SMS! Verifique a comunicação com o servidor GOIP ou se as credenciais estão corretas! ...
					wheb_mensagem_pck.exibir_mensagem_abort(370160, 'DS_REMETENTE_P='||ds_remetente_p||';DS_DESTINATARIO_W='||ds_destinatario_w);
				end if;

			elsif ( cd_empresa_w = 8) then

				if	(trim(ds_remetente_p) is not null) then
					ds_mensagem_w	:= ds_remetente_p || ': ' || ds_mensagem_w;
				end if;

				ds_retorno_sms_w := digital_enviar_sms(
							nm_usuario_sms_w,
							ds_senha_usuario_sms_w,
							ds_remetente_p,
							ds_destinatario_w,
							ds_mensagem_w,
							nm_usuario_proxy_w,
							ds_senha_proxy_w,
							ip_servidor_proxy_w);

				if (ds_retorno_sms_w in (1)) then
					wheb_mensagem_pck.exibir_mensagem_abort(213824, 'DS_RETORNO_SMS_W='||ds_retorno_sms_w||';DS_REMETENTE_P='||ds_remetente_p||';DS_DESTINATARIO_W='||ds_destinatario_w);
				end if;
			else

				ds_retorno_sms_w := spring_enviar_sms(nm_usuario_sms_w,ds_senha_usuario_sms_w, id_sms_p,ds_destinatario_w,ds_mensagem_w,nm_usuario_proxy_w,ds_senha_proxy_w,ip_servidor_proxy_w,
				OBTER_VALOR_PARAM_USUARIO(9041,5,nvl(wheb_usuario_pck.get_cd_perfil,0),nm_usuario_p,nvl(wheb_usuario_pck.get_cd_estabelecimento,1)),
				OBTER_VALOR_PARAM_USUARIO(9041,6,nvl(wheb_usuario_pck.get_cd_perfil,0),nm_usuario_p,nvl(wheb_usuario_pck.get_cd_estabelecimento,1)), cd_empresa_w);

				if (ds_retorno_sms_w not in (0)) then

					wheb_mensagem_pck.exibir_mensagem_abort(213824, 'DS_RETORNO_SMS_W='||spring_verifica_erro(ds_retorno_sms_w)||';DS_REMETENTE_P='||ds_remetente_p||';DS_DESTINATARIO_W='||ds_destinatario_w);					end if;
			end if;
			end;
		else
			begin
				lista_retorno_xml := obter_retorno_operacao_sms(nm_usuario_p, parametros_sms_w);
        				
				retorno_w := obter_retorno(lista_retorno_xml(1));          

				if (somente_numero(retorno_w.valor) in (1)) then
					wheb_mensagem_pck.exibir_mensagem_abort(213824, 'DS_RETORNO_SMS_W='||retorno_w.valor||';DS_REMETENTE_P='||ds_remetente_p||';DS_DESTINATARIO_W='||ds_destinatario_w);
				else
					begin
						id_sms_p	:= nvl(retorno_w.valor, 0);
					exception
						when others then
							wheb_mensagem_pck.exibir_mensagem_abort(213824, 'DS_RETORNO_SMS_W='||retorno_w.valor||';DS_REMETENTE_P='||ds_remetente_p||';DS_DESTINATARIO_W='||ds_destinatario_w);
					end;
				end if;
			end;
		end if;

	end loop;
	end;

	function	get_creditos(NM_USUARIO_P in varchar2) return number as
	parametros_sms_w	LT_PARAMETROS_SMS;
	lista_retorno_xml	t_list_of_xml;
	ie_forma_w				varchar2(1);
	retorno_w				  LT_RETORNO;
	begin
		armazena_configuracoes_sms(NM_USUARIO_P);

		parametros_sms_w := LT_PARAMETROS_SMS(	null, null, null, null,null,
												null,null,null,null,
												null,null,null,null,
												null,null,null,null);

		parametros_sms_w.DS_OPERACAO			:= 'CREDITOS';
		parametros_sms_w.NM_USUARIO				:= nm_usuario_sms_w;
		parametros_sms_w.DS_SENHA				:= ds_senha_usuario_sms_w;
		parametros_sms_w.IP_SERVIDOR_PROXY		:= ip_servidor_proxy_w;
		parametros_sms_w.CD_EMPRESA				:= cd_empresa_w;
		parametros_sms_w.NM_USUARIO_PROXY		:= nm_usuario_proxy_w;
		parametros_sms_w.DS_SENHA_PROXY			:= ds_senha_proxy_w;

		ie_forma_w	 		:= obter_valor_param_usuario(0,202,nvl(wheb_usuario_pck.get_cd_perfil,0),NM_USUARIO_P, nvl(wheb_usuario_pck.get_cd_estabelecimento,1));

		if	(nvl(ie_forma_w, 'B') = 'B') then
			begin
			if (cd_empresa_w = 1 ) then
				comunika_conectar(nm_usuario_sms_w,ds_senha_usuario_sms_w,0);
				return comunika_get_creditos;
			elsif ( cd_empresa_w = 2) then
				return tww_get_creditos(nm_usuario_sms_w,ds_senha_usuario_sms_w,nm_usuario_proxy_w,ds_senha_proxy_w,ip_servidor_proxy_w);
			elsif ( cd_empresa_w = 3) then
				return tww_2_02_get_creditos(nm_usuario_sms_w,ds_senha_usuario_sms_w,nm_usuario_proxy_w,ds_senha_proxy_w,ip_servidor_proxy_w);
			elsif ( cd_empresa_w = 4) then
				wheb_mensagem_pck.exibir_mensagem_abort(213832);
			elsif ( cd_empresa_w = 5) then

				wheb_mensagem_pck.exibir_mensagem_abort(248883); --Operação não implementada para a Spring Wireless
			elsif ( cd_empresa_w = 8) then
				return digital_get_creditos(
					nm_usuario_sms_w,
					ds_senha_usuario_sms_w,
					nm_usuario_proxy_w,
					ds_senha_proxy_w,
					ip_servidor_proxy_w);
			end if;
			end;
		else
			begin
				lista_retorno_xml := obter_retorno_operacao_sms(nm_usuario_p, parametros_sms_w);
        				
				retorno_w := obter_retorno(lista_retorno_xml(1));  
          
				return nvl(retorno_w.valor, 0);     
			end;
		end if;
	end;

	function	obter_status_sms(ID_SMS_P in number,DT_ENVIO_P in VARCHAR2,NM_USUARIO_P in varchar2) return varchar2 as
	cd_status_sms 		varchar2(10);
	ie_forma_w				varchar2(1);
	parametros_sms_w	LT_PARAMETROS_SMS;
	lista_retorno_xml	t_list_of_xml;
	retorno_w				  lt_retorno;
	begin
		if (cd_empresa_w is null ) then
			armazena_configuracoes_sms(NM_USUARIO_P);
		end if;

		ie_forma_w	 		:= obter_valor_param_usuario(0,202,nvl(wheb_usuario_pck.get_cd_perfil,0),NM_USUARIO_P, nvl(wheb_usuario_pck.get_cd_estabelecimento,1));


		parametros_sms_w := LT_PARAMETROS_SMS(	null, null, null, null,null,
												null,null,null,null,
												null,null,null,null,
												null,null,null,null);

		parametros_sms_w.DS_OPERACAO			:= 'STATUS';
		parametros_sms_w.NM_USUARIO				:= nm_usuario_sms_w;
		parametros_sms_w.DS_SENHA				:= ds_senha_usuario_sms_w;
		parametros_sms_w.ID_SMS					:= ID_SMS_P;
		parametros_sms_w.IP_SERVIDOR_PROXY		:= ip_servidor_proxy_w;
		parametros_sms_w.CD_EMPRESA				:= cd_empresa_w;
		parametros_sms_w.NM_USUARIO_PROXY		:= nm_usuario_proxy_w;
		parametros_sms_w.DS_SENHA_PROXY			:= ds_senha_proxy_w;


		if	(nvl(ie_forma_w, 'B') = 'B') then
			begin
			if (cd_empresa_w = 1 ) then
				return 'Não implementado (Vola)';
			elsif ( cd_empresa_w = 2) then
				return tww_get_status_sms(nm_usuario_sms_w,ds_senha_usuario_sms_w,nm_usuario_proxy_w,ds_senha_proxy_w,ip_servidor_proxy_w,id_sms_p,dt_envio_p);
			elsif ( cd_empresa_w = 3) then
				return tww_2_02_get_status_sms(nm_usuario_sms_w,ds_senha_usuario_sms_w,nm_usuario_proxy_w,ds_senha_proxy_w,ip_servidor_proxy_w,id_sms_p,dt_envio_p);
			elsif ( cd_empresa_w = 4) then
				return human_get_status_sms(ID_SMS_P, nm_usuario_sms_w, ds_senha_usuario_sms_w, nm_usuario_proxy_w,ds_senha_proxy_w,ip_servidor_proxy_w);
			elsif ( cd_empresa_w = 5) then

				wheb_mensagem_pck.exibir_mensagem_abort(248883); --Operação não implementada para a Spring Wireless
			elsif ( cd_empresa_w = 8) then
				return digital_get_status_sms(
						id_sms_p,
						nm_usuario_sms_w,
						ds_senha_usuario_sms_w,
						nm_usuario_proxy_w,
						ds_senha_proxy_w,
						ip_servidor_proxy_w);
			end if;
			end;
		else
			begin
				lista_retorno_xml := obter_retorno_operacao_sms(nm_usuario_p, parametros_sms_w);
        				
				retorno_w := obter_retorno(lista_retorno_xml(1));  
        
				return retorno_w.valor;
			end;

		end if;
	end;

	function 	obter_ds_status_sms(CD_STATUS_P in varchar2,NM_USUARIO_P in varchar2) return varchar2 as
	begin
		if (cd_empresa_w is null ) then
			armazena_configuracoes_sms(NM_USUARIO_P);
		end if;
		if (cd_empresa_w = 1 ) then
			return 'Não implementado (Vola)';
		elsif ( cd_empresa_w in (2,3)) then
			return obter_valor_dominio(2353,CD_STATUS_P);
		elsif ( cd_empresa_w = 5) then
			wheb_mensagem_pck.exibir_mensagem_abort(248883); --Operação não implementada para a Spring Wireless
		end if;
	end;

end wheb_sms;
/