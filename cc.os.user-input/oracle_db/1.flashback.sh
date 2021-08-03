#!/usr/bin/env bash

export ORACLE_SID=XE
export ORAENV_ASK=NO
export PATH=/usr/local/bin:$PATH

source oraenv

sudo -u oracle -H -E /opt/oracle/product/18c/dbhomeXE/bin/sqlplus / as sysdba <<EOF
shutdown immediate;
startup mount;
FLASHBACK DATABASE TO RESTORE POINT good;
alter database open;
exit;
EOF
