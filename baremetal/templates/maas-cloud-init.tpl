#cloud-config
package_update: true
package_upgrade: true
packages:
- net-tools
write_files:
- content: |
    export MAAS_DBUSER='maas'
    export MAAS_DBPASS='hh^00lBPmjT'
    export MAAS_DBNAME='maas'
    export HOSTNAME=${node_hostname}

  path: /opt/canonical/field/values.source
  owner: root:root
  permissions: '744'
- content: |
    sudo snap install --channel=3.2 maas
    sudo apt update -y
    sudo apt install -y postgresql
    source /opt/canonical/field/values.source
    sudo -i -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
    sudo -i -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
    echo "host    $MAAS_DBNAME    $MAAS_DBUSER    0/0     md5" | tee -a /etc/postgresql/14/main/pg_hba.conf
    sudo maas init region+rack --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@$HOSTNAME/$MAAS_DBNAME"
  path: /opt/canonical/field/setup-maas.sh
  owner: root:root
  permissions: '744'
runcmd:
- dhclient
- /opt/canonical/field/setup-maas.sh
# TODO:
# - ['iptables', '-t', 'nat', '-A', 'POSTROUTING', '-o', 'eth0', '-j', 'SNAT', '--to', 'TODO']