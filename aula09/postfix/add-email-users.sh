#!/bin/bash

ldapsearch -x -LLL -b 'dc=4labs,dc=example' '(&(objectClass=posixAccount)(!(objectClass=qmailUser)))' dn | egrep -v 'root|nobody' | awk '
/^dn: / {
  print $0
  print "changetype: modify"
  print "add: objectClass"
  print "objectClass: qmailUser"
  print "-"
  print "add: mailQuota"
  print "mailQuota: 10000000"
  print ""
}' > modifica-usuarios.ldif
