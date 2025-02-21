#!/bin/bash

# Caminhos dos arquivos
BACKUP_FILE="/backup-ldap/incremental/backup-incremental.ldif"
RESTORE_FILE="/backup-ldap/incremental/restore-users.ldif"

# Verifica se o arquivo de backup incremental existe
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Erro: Arquivo de backup incremental não encontrado!"
    exit 1
fi

# Criar um novo arquivo de restauração LDIF
echo "# Arquivo LDIF gerado a partir do accesslog para restaurar usuários deletados" > "$RESTORE_FILE"

inside_entry=0
USER_DN=""

# Processa o arquivo linha por linha
while IFS= read -r line; do
    # Inicia a captura quando encontra um bloco de deleção
    if [[ "$line" =~ ^dn:\ reqStart=.* ]]; then
        inside_entry=0  # Reseta captura de dados
    fi

    # Detecta que é uma entrada de deletação
    if [[ "$line" == "objectClass: auditDelete" ]]; then
        inside_entry=1
    fi

    # Captura o DN do usuário deletado
    if [[ "$inside_entry" -eq 1 && "$line" =~ ^reqDN:\ (.*) ]]; then
        USER_DN="dn: ${BASH_REMATCH[1]}"
        echo "" >> "$RESTORE_FILE"
        echo "$USER_DN" >> "$RESTORE_FILE"
    fi

    # Captura os atributos antigos, ignorando os proibidos
    if [[ "$inside_entry" -eq 1 && "$line" =~ ^reqOld:\ (.*) ]]; then
        ATTR="${BASH_REMATCH[1]}"

        # Lista de atributos proibidos
        case "$ATTR" in
            structuralObjectClass:*|entryUUID:*|entryCSN:*|createTimestamp:*|modifyTimestamp:*|creatorsName:*|modifiersName:*)
                continue
                ;;
            *)
                echo "$ATTR" >> "$RESTORE_FILE"
                ;;
        esac
    fi

    # Quando encontrar uma linha vazia, finaliza a entrada atual
    if [[ -z "$line" ]]; then
        inside_entry=0
    fi

done < "$BACKUP_FILE"

echo "Arquivo de restauração gerado com sucesso: $RESTORE_FILE"
