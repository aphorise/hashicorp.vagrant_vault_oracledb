#!/usr/bin/env bash

rpm -q oracle-instantclient19.9-basic oracle-instantclient19.9-sqlplus || {
  cd /etc/yum.repos.d ;
  rm -f *.repo ;
  wget https://yum.oracle.com/public-yum-ol7.repo --quiet ;
  # yum install -q -y yum-utils ;
  if ! yum-config-manager --enable ol7_oracle_instantclient 2>&1 > /dev/null ; then printf 'ERROR: oracle_instantclient\n' ; fi ;
  yum install -q -y oracle-instantclient19.9-basic oracle-instantclient19.9-sqlplus ;
}
