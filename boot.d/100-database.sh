#!/bin/bash
. /opt/netrig/lib/config.sh
get_val ".users.www_db_user"
WWW_DB_USER=$CF_VAL
get_val ".users.www_db_group"
WWW_DB_GROUP=$CF_VAL
get_val ".users.fcgi_perl_group"
FCGI_GROUP=$CF_VAL
get_val ".users.asterisk_user"
AST_USER=$CF_VAL

echo "* Creating users/groups, if needed"
getent group ${WWW_DB_GROUP} 2>&1 >/dev/null
if [ $? -ne 0 ]; then
   echo " - Group: ${WWW_DB_GROUP}"
   addgroup --system ${WWW_DB_GROUP}
fi

getent passwd ${WWW_DB_USER} 2>&1 >/dev/null
if [ $? -ne 0 ]; then
   echo " - User: ${WWW_DB_USER}"
   mkdir -p /opt/netrig/.empty
   touch /opt/netrig/.empty/.keepme
   adduser --system \
   	   --comment "www-databases for netrig" \
   	   --home /opt/netrig/.empty --no-create-home \
   	   --ingroup ${WWW_DB_GROUP} \
   	   --shell /bin/false ${WWW_DB_USER}
fi

echo "* Fixing permissions..."
chown root:root /opt/netrig/run /opt/netrig/logs
chmod 1777 /opt/netrig/run /opt/netrig/logs
chown ${AST_USER}:fcgi-perl data/
chmod 1775 data/
chmod 0660 data/*.db
