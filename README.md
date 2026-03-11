# 🛡️ SOC Home Lab & Detection Engineering

**Um laboratório prático demonstrando o ciclo de vida completo de uma operação de cibersegurança: Provisionamento de Infraestrutura (Docker/LVM), Defesa de Borda (ModSecurity WAF), Simulação de Ataques (Kali Linux) e Engenharia de Detecção (Wazuh SIEM).**

[![Wazuh](https://img.shields.io/badge/SIEM-Wazuh-blue?style=flat&logo=wazuh)](https://wazuh.com/)
[![ModSecurity](https://img.shields.io/badge/WAF-ModSecurity-red?style=flat)](#)
[![Docker](https://img.shields.io/badge/Infra-Docker-2496ED?style=flat&logo=docker)](https://www.docker.com/)
[![Ubuntu](https://img.shields.io/badge/OS-Ubuntu-E95420?style=flat&logo=ubuntu)](https://ubuntu.com/)

## 🎯 Objetivo do Projeto
Demonstrar na prática o fluxo completo de um ciberataque e sua respectiva mitigação e detecção, passando pelas disciplinas de Infraestrutura, Red Team e Blue Team.

## 🛠️ Stack Tecnológica
- **Sistema Operacional**: Ubuntu Server 24.04 LTS
- **Virtualização & Orquestração**: VirtualBox, Docker e Docker Compose
- **Alvo (Aplicação Vulnerável)**: Damn Vulnerable Web App (DVWA)
- **Defesa de Borda (WAF)**: Nginx + ModSecurity (OWASP Core Rule Set)
- **SIEM / XDR**: Wazuh (Manager, Indexer, Dashboard e Agent)
- **Atacante**: Kali Linux (Ferramentas: Nikto, cURL)

---

## 🚀 Etapa 1: Infraestrutura e Provisionamento

A base do laboratório foi construída sobre um servidor Ubuntu, rodando os serviços em containers Docker para garantir isolamento e fácil gerenciamento.

**Implementação do servidor base:**
![Servidor Base](images/1InicioUbuntu.PNG)

Durante o provisionamento da stack pesada do SIEM, enfrentei um cenário clássico de Incident Response de Infraestrutura: esgotamento de disco. Para resolver a indisponibilidade, foi necessário atuar diretamente no sistema de arquivos do Linux, expandindo fisicamente o disco e realizando o resize da partição LVM (lvextend e resize2fs) sem perda de dados.

**Subindo a stack do SOC via Docker Compose:**
![Docker Compose Up](images/2Updocker.PNG)

---

## 🛡️ Etapa 2: A Defesa (WAF & SIEM)

Com a infraestrutura de pé, a aplicação DVWA foi colocada atrás de um Proxy Reverso Nginx equipado com o ModSecurity configurado em modo Enforcement. Todo o tráfego malicioso seria bloqueado e auditado.

O Wazuh Agent foi instalado no servidor web para coletar esses logs de auditoria e enviá-los em tempo real para o Manager.

**Wazuh Agent ativo e coletando telemetria:**
![Wazuh Agent](images/4AgentWazuhrodando.PNG)

**Painel Geral do SIEM:**
![Painel Wazuh](images/3wazuhrodando.PNG)

---

## ⚔️ Etapa 3: Simulação de Ataque (Red Team)

Utilizando uma máquina virtual com Kali Linux, iniciei a simulação de ataques externos para validar a resiliência do WAF e a visibilidade do SIEM.

Foram executados:
- **Ataques manuais de SQL Injection**: Utilizando curl para injetar payloads maliciosos na URL.
- **Scanner de Vulnerabilidades**: Utilização do Nikto para gerar volume massivo de requisições agressivas e forçar o motor de detecção.

O WAF atuou conforme o esperado, bloqueando as requisições e retornando o status HTTP 403 Forbidden.

**Visão do atacante sendo bloqueado:**
![Ataque Bloqueado](images/5ataque.PNG)

---

## 🕵️‍♂️ Etapa 4: Engenharia de Detecção & Tuning (Blue Team)

Aqui o laboratório provou o seu maior valor prático. Ao analisar o painel do SOC, observei o recebimento de mais de 13.000 logs no momento do ataque do scanner.

Porém, detectei uma falha na classificação de risco (Falso Negativo de Severidade). O Wazuh estava recebendo os bloqueios de Injeção de SQL do ModSecurity, mas classificando o evento apenas como Nível 7 (Medium Risk) em uma regra genérica de servidor web.

**SOC recebendo o ataque massivo, mas classificando com severidade média:**
![Ataque no SOC](images/6Socvendoatack.PNG)

Em um ambiente real, um ataque direcionado bloqueado na borda requer visibilidade crítica. Para corrigir isso, atuei na criação de uma Regra Customizada (Rule Override) no motor do Wazuh.

A nova regra foi desenhada para:
1. Interceptar o ID original do log do ModSecurity.
2. Elevar a severidade para Nível 12 (Critical).
3. Adicionar uma descrição precisa do incidente.
4. Mapear a detecção para a tática T1190 (Exploit Public-Facing Application) do framework MITRE ATT&CK.

**Tuning e criação da nova regra no SIEM:**
![Regra Customizada](images/7MelhoradeRegrea.PNG)

---

## 🎯 Resultado Final

Após o tuning e reinicialização do Manager, um novo ataque cirúrgico foi disparado. A arquitetura validou o fluxo perfeito: o WAF bloqueou a injeção, o Agente roteou o log, e o SIEM, agora treinado, disparou um alerta crítico em vermelho, garantindo que o time de SOC não perderia esse evento no meio do ruído diário.

**Sucesso na detecção com Alerta Crítico (Level 12) em tempo real:**
![Alerta Crítico](images/8AlertaPosRegra.PNG)

---

## 💡 Conclusão e Lições Aprendidas

Este laboratório demonstrou que implantar ferramentas de segurança (como WAFs e SIEMs) é apenas o passo inicial de uma estratégia de defesa. O trabalho vital de um time de Blue Team está em entender o comportamento dos logs, realizar troubleshooting constante da infraestrutura (como o roteamento de logs via Docker e LVM Storage) e, principalmente, afinar as regras de detecção para transformar dados brutos em inteligência acionável.
