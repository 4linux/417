#!/bin/bash

# Configurações
LDAP_HOST="ldap://ldap-master1.4labs.example"
LDAP_FILE="/tmp/ldap_modifications.ldif"
DOMAIN_SID=$(sudo net getdomainsid | grep "SID for domain" | awk '{print $NF}')

# Limpa arquivo LDIF anterior
rm -f "$LDAP_FILE"

# Obter DNs dos usuários diretamente do LDAP
ldapsearch -H "$LDAP_HOST" -LLL -x -b "dc=4labs,dc=example" "(objectClass=posixAccount)" dn | grep "^dn: " | while read -r LINE; do
    # Extrair o DN e UID do usuário
    DN=$(echo "$LINE" | sed 's/^dn: //')
    USERNAME=$(echo "$DN" | grep -oP '(?<=uid=)[^,]+')  # Substitui UID por USERNAME

    # Calcular RID e SID do usuário
    RID=$((RANDOM + 1000))  # Exemplo de geração; pode ser baseado em UID LDAP se necessário
    USER_SID="$DOMAIN_SID-$RID"

    # Hash NTLM padrão (substitua pelo cálculo dinâmico, se necessário)
    NTLM_HASH="C5B3084BBBE9ED9A5AB924CC1E6C802E"

    # Gerar entrada LDIF para o usuário
    cat <<EOF >> "$LDAP_FILE"
dn: $DN
changetype: modify
add: objectClass
objectClass: sambaSamAccount
-
add: sambaSID
sambaSID: $USER_SID
-
add: sambaNTPassword
sambaNTPassword: $NTLM_HASH

EOF

    echo "LDIF gerado para $USERNAME ($DN)"
done

echo "Arquivo LDIF criado em $LDAP_FILE"

