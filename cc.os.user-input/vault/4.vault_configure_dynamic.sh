#!/usr/bin/env bash
source ~/.bashrc
export PATH=/usr/local/bin:${PATH}
export CLIENT_HOME=/usr/lib/oracle/19.9/client64
export LD_LIBRARY_PATH=${CLIENT_HOME}/lib
export PATH=${PATH}:${CLIENT_HOME}/bin

if [[ ! ${VPLUGIN_INSTANCES+x} ]]; then VPLUGIN_INSTANCES=20 ; fi ; # // number of Oracle plugin mount to try to assimulate.

for (( iX = 1; iX <= ${VPLUGIN_INSTANCES}; iX++ )) ; do
	DBDYNAMIC="dynamic${iX}" ;
	DBSTATIC="static${iX}" ;
	DBUSER="myuser${iX}" ;
	if ! sqlplus -S system/password@//db.test:1521/XEPDB1 <<< """
declare
userexist integer;

begin
	select count(*) into userexist from dba_users where username='${DBDYNAMIC^^}';
	if (userexist = 0) then
		execute immediate 'create user ${DBDYNAMIC}';
		execute immediate 'grant connect to ${DBDYNAMIC}';
		execute immediate 'grant all privileges to ${DBDYNAMIC}';
	end if;
end;
/

declare
userexist integer;

begin
	select count(*) into userexist from dba_users where username='${DBSTATIC^^}';
	if (userexist = 0) then
		execute immediate 'create user ${DBSTATIC}';
		execute immediate 'grant connect to ${DBSTATIC}';
		execute immediate 'grant all privileges to ${DBSTATIC}';
	end if;
end;
/

declare
userexist integer;

begin
	select count(*) into userexist from dba_users where username='${DBUSER^^}';
	if (userexist = 0) then
		execute immediate 'create user ${DBUSER}';
		execute immediate 'grant connect to ${DBUSER}';
		execute immediate 'grant all privileges to ${DBUSER}';
	end if;
end;
/

alter user ${DBDYNAMIC} identified by "password";
exit;
""" 2>&1 > /dev/null ; then printf "ERROR: Unable to create ${DBDYNAMIC^^}\n" ; fi ;
done ;

# vault secrets enable -version=1 kv 2>&1 > /dev/null ; 
# vault secrets enable transit 2>&1 > /dev/null ; 

SQL_DROP="revoke connect from {{username}}; revoke create session from {{username}}; revoke GTPSAPLUSERGROUP from {{username}}; drop user {{username}} cascade;"
SQL_DROP="REVOKE CONNECT FROM {{username}}; REVOKE CREATE SESSION FROM {{username}}; DROP USER {{username}};"
#SQL_CREATE='CREATE USER {{username}} IDENTIFIED BY "{{password}}"; GRANT ALL PRIVILEGES TO {{username}}; GRANT CONNECT TO {{username}}; GRANT DBA TO {{username}}; GRANT RESOURCE TO {{username}}; GRANT CREATE VIEW TO {{username}}; GRANT CREATE SESSION TO {{username}};'  # CREATE OR REPLACE TRIGGER vault_schema_logon AFTER logon ON DATABASE WHEN (USER like '\''%V_ROOT%'\'') BEGIN execute immediate "ALTER SESSION SET CURRENT_SCHEMA = AMIPUR" END;' ;
SQL_CREATE='CREATE USER {{username}} IDENTIFIED BY "{{password}}"; GRANT ALL PRIVILEGES TO {{username}}; GRANT CONNECT TO {{username}}; GRANT DBA TO {{username}}; GRANT RESOURCE TO {{username}}; GRANT CREATE VIEW TO {{username}}; GRANT CREATE SESSION TO {{username}}; CREATE OR REPLACE TRIGGER vault_schema_logon AFTER logon ON DATABASE WHEN (USER like '\''%V_ROOT%'\'') BEGIN execute immediate GRANT CREATE SESSION TO {{username}} END;' ;

VDBPATH="db_oracle" ;

vault secrets enable -path=${VDBPATH} database 2>&1 > /dev/null ;

for (( iX = 1; iX <= ${VPLUGIN_INSTANCES}; iX++ )) ; do
	# vault secrets enable -path=database${iX} database 2>&1 > /dev/null ;
	if ! vault write ${VDBPATH}/config/oracle${iX} plugin_name=oracle-database-plugin \
			max_open_connections=1 max_connection_lifetime=2 \
			allowed_roles="*" \
			connection_url='{{username}}/{{password}}@db.test:1521/XEPDB1' \
			username="dynamic${iX}" password='password' 2>&1>/dev/null ; then 
		printf "ERROR: ${VDBPATH}\n" ;
	fi ;
	# vault read database${iX}/config/oracle

	if ! vault write ${VDBPATH}/roles/my-role${iX} db_name=oracle${iX} \
			creation_statements="${SQL_CREATE}" revocation_statements="${SQL_DROP}" default_ttl="1h" max_ttl="24h" 2>&1>/dev/null ; then 
		printf "ERROR: ${VDBPATH}/roles/my-role${iX}\n" ;
	fi ;
	# vault read database${iX}/roles/my-role${iX}
done ;
