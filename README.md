# Backup, encrypt and manage your database

*EDB* is a framework to make and manage backups of your database.
It is composed by three macro areas that reflect themself inside `edb.yml` and are *DBMS*, *CRYPTOGRAPHY* and *STORAGE*.
The first one deals with the actual backup process of your DBMS. The second one will eventually encrypt the backup copies made previously and the last one will be asked to store the final output somewhere in the world.

At the moment, we have just one module for each area: *PostgreSQL*, *AWS S3* and *AES-256-CBC*, but adding more modules requires nothing but a new file inside the proper folder.

## Install
`$ gem install edb`

## Run
Setup `example/edb.yml` (remember also to change the `SECRET`) and then:

`$ edb example/edb.yml`  

Consider also to add *EDB* to your cronjobs.
