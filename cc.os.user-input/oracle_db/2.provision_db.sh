#!/usr/bin/env bash
printf """
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

${IPDB} db.test db
${IPV} vault.test vault1
""" > /etc/hosts
printf 'db.test' > /etc/hostname && hostname db.test ;

# install oracle-database-preinstall-18c if not installed
rpm -q oracle-database-preinstall-18c || {
  yum install -q -y oracle-database-preinstall-18c
}

# check DB is installed
rpm -q oracle-database-xe-18c || {
  [ -f /vagrant/oracle-database-xe-18c-1.0-1.x86_64.rpm ] || {
    cd /vagrant/
    wget https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-18c-1.0-1.x86_64.rpm --quiet
  }
  [ -d /opt/oracle/product/18c/dbhomeXE ] && rm -fr /opt/oracle/product/18c/dbhomeXE
  yum localinstall -q -y /vagrant/oracle-database-xe-18c-1.0-1.x86_64.rpm
}
