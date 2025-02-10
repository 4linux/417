#!/bin/bash

# Caminho para o arquivo de configuração do HAProxy
HAPROXY_CFG="/etc/haproxy/haproxy.cfg"

# Endereços IP dos servidores LDAP
LDAP_MASTER1="172.16.0.201"
LDAP_MASTER2="172.16.0.202"

# Caminho para o arquivo de log
LOG_FILE="/var/log/ldap_failover.log"

# Caminho para o arquivo PID (para evitar múltiplas execuções)
PID_FILE="/var/run/ldap_failover.pid"

# Verifica se já existe um processo rodando
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "Já existe uma instância rodando. Encerrando..."
    exit 1
fi

# Registra o PID do processo atual
echo $$ > "$PID_FILE"

# Função para registrar mensagens no log
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Teste de conectividade com o ldap-master1
if nc -z "$LDAP_MASTER1" 389; then
    # Restaura o ldap-master1 se necessário
    if grep -q "server ldap-master1 $LDAP_MASTER2:389 check" "$HAPROXY_CFG"; then
        sudo sed -i "s/server ldap-master1.*/server ldap-master1 $LDAP_MASTER1:389 check/" "$HAPROXY_CFG"
        sudo systemctl reload haproxy
        log_message "ldap-master1 está ativo novamente. Restaurando para configuração original..."
    fi
else
    # Faz failover para ldap-master2 se necessário
    if grep -q "server ldap-master1 $LDAP_MASTER1:389 check" "$HAPROXY_CFG"; then
        sudo sed -i "s/server ldap-master1.*/server ldap-master1 $LDAP_MASTER2:389 check/" "$HAPROXY_CFG"
        sudo systemctl reload haproxy
        log_message "ldap-master1 está inativo. Executando failover para ldap-master2..."
    fi
fi

# Remove o arquivo PID ao sair
rm -f "$PID_FILE"
exit 0
