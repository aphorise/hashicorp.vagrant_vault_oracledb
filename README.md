# HashiCorp `vagrant` demo of **`vault`** with Oracle-DB Secrets Engine.
Twenty (20) configs on one Vault Oracle DB mount.

## Makeup & Concept

```
  Severs: Oracle & Vault        .……………………………………….50
                                ┊   Oracle-DB   ┊
                                ┊    Database   ┊
                                └………………………………………┘
                                       ⤊
 .┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄.        ⤊
 |db_oracle/config/oracle1     ╲   ____⤊______.51
 |db_oracle/roles/my-role1     ┊   |  vault1   |
 |........./config/oracle2     ┊   |  oracle   |
 |........./roles/my-role2     ┊╌╌╌|  plugins: |
 |........./config/oracle3     ┊   |___________|
 |........./roles/my-role3     ┊
 ╰┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄╯ ... other vault configs / roles ...
```


## Usage & Workflow

```bash
# // in root of this repo:
wget https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-18c-1.0-1.x86_64.rpm

vagrant up ;
# // ... output of provisioning steps.
vagrant global-status ; # should show running nodes
  # id       name    provider   state   directory
  # -------------------------------------------------------------------------------
  # 2a42e67  db         virtualbox running /home/auser/hashicorp.vagrant_vault_oracledb
  # 03a90a4  vault1     virtualbox running /home/auser/hashicorp.vagrant_vault_oracledb

# // SSH to vault1
vagrant ssh vault1 ;
# // ...
#vagrant@vault1:~$ \ # perform setup:
./4.vault_configure_dynamic.sh

# perform read tests on all my-role
./vault_oracledb_test.sh
  # ROOT ROTATED: 1 Oracle-DB mount with 20 root configs in 2 seconds.
  # CRED ROTATED: 20 1 roles on Oracle-DB mounts in 12 seconds.
  # END
#// connecting to database:
sqlplus system/password@//db.test:1521/XEPDB1

# // ---------------------------------------------------------------------------
# when completely done:
vagrant destroy -f ; # ... destroy al
vagrant box remove -f oraclelinux/7 --provider virtualbox ; # ... delete box images
```


## Notes
This repo is intended as a mere practise / training exercise.

See also more information at:
 - [HTTP API Docs: Oracle Database Plugin](https://www.vaultproject.io/api-docs/secret/databases/oracle)
 - [Learn: rotation](https://learn.hashicorp.com/vault/secrets-management/db-root-rotation)
 - [Learn: Database Static Roles and Credential Rotation](https://learn.hashicorp.com/vault/secrets-management/db-creds-rotation)
 - [Learn: Dynamic Secrets: Database Secrets Engine](https://learn.hashicorp.com/tutorials/vault/database-secrets)

Reference material used:
 - [kikitux/vault-dev-orcl](https://github.com/kikitux/vault-dev-orcl)
------
