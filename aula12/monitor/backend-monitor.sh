#!/bin/bash

echo "=== Monitoramento do OpenLDAP ==="

echo -e "\nTempo de Atividade (Uptime):"
ldapsearch -LLL -x -D cn=Manager,dc=4labs,dc=example -w Admin123! -b cn=Uptime,cn=Time,cn=Monitor -s base '(objectClass=*)' '*' '+' | grep monitoredInfo

echo -e "\nBytes Transferidos:"
ldapsearch -LLL -x -D cn=Manager,dc=4labs,dc=example -w Admin123! -b cn=Bytes,cn=Statistics,cn=Monitor -s base '(objectClass=*)' '*' '+' | grep ^monitorCounter

echo -e "\nOperações Realizadas:"
ldapsearch -LLL -x -D cn=Manager,dc=4labs,dc=example -w Admin123! -b cn=Entries,cn=Statistics,cn=Monitor -s base '(objectClass=*)' '*' '+' | grep ^monitorCounter
