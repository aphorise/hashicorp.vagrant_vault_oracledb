#!/bin/bash
sVAULT_TOKEN=${VAULT_TOKEN}  # // '<insert your token here>'
sVAULT_ADDR=${VAULT_ADDR}  # // 'https://...:8200'
SECONDS=0
VDB_LIST=($(vault secrets list | grep database | cut -d/ -f1 | sort -V)) ;

for sX in ${VDB_LIST[*]} ; do
 for (( iX=1 ; iX <= 20; iX++ )) ; do
	if ! vault write -force ${sX}/rotate-root/oracle${iX} 2>&1>/dev/null &
		then printf "ERROR: Unable to root-rotate ${sX}/rotate-root/oracle${iX}\n" ;
	fi ;
 done ;
done ;
wait  # wait for any bg pending / bg tasks.
printf "ROOT ROTATED: ${#VDB_LIST[*]} Oracle-DB mount with 20 root configs in ${SECONDS} seconds.\n" ;

SECONDS=0
#iX=1;
for sX in ${VDB_LIST[*]} ; do
 for (( iX=1 ; iX <= 20; iX++ )) ; do
 #	if ! vault read ${sX}/roles/my-role${iX} 2>&1>/dev/null  # // WAS READING CONFIG BEFORE (not correct)
	if ! vault read ${sX}/creds/my-role${iX} 2>&1>/dev/null
		then printf "ERROR: Unable to rotate ${sX}/creds/my-role${iX}\n" ;
	fi ;
 done ;
#	((++iX)) ;
done ;
wait  # wait for any bg pending / bg tasks.
printf "CRED ROTATED: 20 ${#VDB_LIST[*]} roles on Oracle-DB mounts in ${SECONDS} seconds.\n" ;

printf "END\n" ; 
