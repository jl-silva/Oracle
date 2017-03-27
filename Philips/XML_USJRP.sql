  <?xml version="1.0" encoding="UTF-8" ?> 
- <!--  Published by JAX-WS RI at http://jax-ws.dev.java.net. RI's version is JAX-WS RI 2.1.4-b01-. 
  --> 
- <definitions xmlns:tns="http://www.ans.gov.br/tiss/ws/tipos/tisssolicitacaostatusautorizacao/v30201" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns="http://schemas.xmlsoap.org/wsdl/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" name="tissSolicitacaoStatusAutorizacao" targetNamespace="http://www.ans.gov.br/tiss/ws/tipos/tisssolicitacaostatusautorizacao/v30201">
- <types>
- <schema xmlns:soap11-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns="http://www.w3.org/2001/XMLSchema">
  <import namespace="http://www.ans.gov.br/padroes/tiss/schemas" schemaLocation="https://autoweb.unimedriopreto.com.br:82/TISS30201OPS/tissSolicitacaoStatusAutorizacao?xsd=6" /> 
  </schema>
  </types>
- <message name="tissSolicitacaoStatusAutorizacao_Request">
  <part name="solicitacaoStatusAutorizacao" element="ans:solicitacaoStatusAutorizacaoWS" /> 
  </message>
- <message name="tissSolicitacaoStatusAutorizacao_Response">
  <part name="situacaoAutorizacao" element="ans:situacaoAutorizacaoWS" /> 
  </message>
- <message name="tissFault">
  <part name="tissFault" element="ans:tissFaultWS" /> 
  </message>
- <portType name="tissSolicitacaoStatusAutorizacao_PortType">
- <operation name="tissSolicitacaoStatusAutorizacao_Operation">
  <input message="tns:tissSolicitacaoStatusAutorizacao_Request" /> 
  <output message="tns:tissSolicitacaoStatusAutorizacao_Response" /> 
  <fault name="TissFault" message="tns:tissFault" /> 
  </operation>
  </portType>
- <binding name="tissSolicitacaoStatusAutorizacao_Binding" type="tns:tissSolicitacaoStatusAutorizacao_PortType">
  <soap:binding style="document" transport="http://schemas.xmlsoap.org/soap/http" /> 
- <operation name="tissSolicitacaoStatusAutorizacao_Operation">
  <soap:operation soapAction="" /> 
- <input>
  <soap:body use="literal" /> 
  </input>
- <output>
  <soap:body use="literal" /> 
  </output>
- <fault name="TissFault">
  <soap:fault name="TissFault" use="literal" /> 
  </fault>
  </operation>
  </binding>
- <service name="tissSolicitacaoStatusAutorizacao">
- <port name="tissSolicitacaoStatusAutorizacao_Port" binding="tns:tissSolicitacaoStatusAutorizacao_Binding">
  <soap:address location="https://autoweb.unimedriopreto.com.br:82/TISS30201OPS/tissSolicitacaoStatusAutorizacao" /> 
  </port>
  </service>
  </definitions>