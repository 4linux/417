#!/bin/bash

# Caminho para o arquivo de configuração do HAProxy
HAPROXY_CFG="/etc/haproxy/haproxy.cfg"

# Endereços IP dos servidores LDAP
LDAP_MASTER1="172.16.0.201"
LDAP_MASTER2="172.16.0.202"

# Caminho para o arquivo de log
LOG_FILE="/var/log/ldap_failover.log"

# Variável para armazenar o estado anterior do ldap-master1
previous_state="active"

# Função para registrar mensagens no log
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Função para atualizar o HAProxy para usar apenas o ldap-master2
failover_to_backup() {
    sudo sed -i "s/server ldap-master1.*/server ldap-master1 $LDAP_MASTER2:389 check/" "$HAPROXY_CFG"
    sudo systemctl reload haproxy
    log_message "ldap-master1 está inativo. Executando failover para ldap-master2..."
}

# Função para restaurar o HAProxy para o ldap-master1
restore_primary() {
    sudo sed -i "s/server ldap-master1.*/server ldap-master1 $LDAP_MASTER1:389 check/" "$HAPROXY_CFG"
    sudo systemctl reload haproxy
    log_message "ldap-master1 está ativo novamente. Restaurando para configuração original..."
}

# Verificação contínua do estado do ldap-master1
while true; do
    # Teste de conectividade com o ldap-master1
    if nc -z $LDAP_MASTER1 389; then
        if [ "$previous_state" != "active" ]; then
            restore_primary
            previous_state="active"
        fi
    else
        if [ "$previous_state" != "inactive" ]; then
            failover_to_backup
            previous_state="inactive"
        fi
    fi
    
    # Pausa de 10 segundos antes da próxima verificação
    sleep 10
done

