-- if com condição para não rodar triggers (precisa ser colocado na base de produção para não causar danos)
--pls_util_cta_pck.ie_grava_log_w != 'N'
-- triggers que foram desabilitadas na Rio Preto
alter trigger OPERADORDB.TR_BIU_SERV_GENERICO_PROC disable;
alter trigger CUSTOM_TASY.TR_BIU_SERV_GENERICO disable;
alter trigger CUSTOM_TASY.TR_BIU_SERV_GENERICO_PROC disable;
alter trigger CUSTOM_TASY.TR_CST_ASSIM_QUE_FAZ1 disable;
alter trigger MIGRACAOGP.TR_CST_COMPLEMENTO_REABR disable;
alter trigger CUSTOM_TASY.TR_CST_EVITA_ERROS_VALORES_FAT disable;
alter trigger CUSTOM_TASY.TR_CST_EVITA_GUIAS_DUPLICADAS disable;
alter trigger CUSTOM_TASY.TR_CST_EVITA_STATUS_ERRADO disable;
alter trigger custom_tasy.TR_CST_PLS_CONTA_COPART disable;
alter trigger CUSTOM_TASY.TR_CST_TIRA_BO_TASY disable;
alter trigger CUSTOM_TASY.TR_CST_VER_GUIA_TASY_TOTVS disable;
alter trigger CUSTOM_TASY.TR_CST_VER_GUIA_TASY_TOTVS_AN disable;

exec pls_atualiza_datas_conta_item;