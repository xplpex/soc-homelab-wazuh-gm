#!/bin/bash 
# Script para rotear logs do stdout do Docker (ModSecurity) para um arquivo físico 
# Necessário para a ingestão correta pelo Wazuh Agent. 
 
LOG_FILE="/home/ubuntu/lab-soc/web-layer/waf-logs/modsec_audit.log" 
 
echo "[*] Criando arquivo de log em $LOG_FILE" 
touch $LOG_FILE 
 
echo "[*] Iniciando ponte de logs em background..." 
nohup docker logs -f modsecurity-waf >> $LOG_FILE 2>&1 & 
 
echo "[+] Concluído! Logs sendo roteados. PID do processo em background:" 
jobs -l 
