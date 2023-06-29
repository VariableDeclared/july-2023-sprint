#cloud-config
package_update: true
package_upgrade: true
packages:
- net-tools
- git
- zsh
write_files:
- content: |
    # Files are not rendered at the same time?
    export MAAS_DBUSER='maas'
    export MAAS_DBPASS='hh^00lBPmjT'
    export MAAS_DBNAME='maas'
    export HOSTNAME=${node_hostname}
    sudo snap install --channel=3.2 maas
    sudo apt update -y
    sudo apt install -y postgresql
    source /opt/canonical/field/values.source
    sudo -i -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
    sudo -i -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
    echo "host    $MAAS_DBNAME    $MAAS_DBUSER    0/0     md5" | tee -a /etc/postgresql/14/main/pg_hba.conf
    sudo maas init region+rack --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@localhost/$MAAS_DBNAME" --maas-url default
    sudo maas createadmin --username root --password root --email root@localhost
    
  path: /opt/canonical/field/setup-maas.sh
  owner: root:root
  permissions: '744'
- content: |
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

    gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
    sudo apt update
    sudo apt-get install terraform
    mkdir ~/maas-terraform
  path: /opt/canonical/field/setup-terraform.sh
  owner: root:root
  permissions: '744'
- content: |
    export MAAS_DBUSER='maas'
    export MAAS_DBPASS='hh^00lBPmjT'
    export MAAS_DBNAME='maas'
    export HOSTNAME=${node_hostname}

  path: /opt/canonical/field/values.source
  owner: root:root
  permissions: '744'
runcmd:
- dhclient
- /opt/canonical/field/setup-maas.sh
- /opt/canonical/field/setup-terraform.sh
# TODO:
# - ['iptables', '-t', 'nat', '-A', 'POSTROUTING', '-o', 'eth0', '-j', 'SNAT', '--to', 'TODO']