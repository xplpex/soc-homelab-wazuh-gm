#!/bin/bash 
# Comandos de Incident Response utilizados para expandir o disco (LVM) 
# após o banco de dados do Indexer esgotar o storage de 25GB. 
 
# 1. Cresce a partição base 
growpart /dev/sda 3 
 
# 2. Atualiza o Volume Físico (PV) 
pvresize /dev/sda3 
 
# 3. Expande o Volume Lógico (LV) para 100% do espaço livre 
lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv 
 
# 4. Aplica o resize no sistema de arquivos ext4 
resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv 
 
# 5. Validação 
df -h / 
