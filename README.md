# Backup, encrypt and manage your database

*EDB* aims to be a framework to make and manage backups of your database.
It is composed by three macro areas that reflect themself inside the `edb.yml` and are *DBMS*, *CRYPTOGRAPHY* and *STORAGE*.
The first one is deals with the actual backup process of your favorite DBMS. The second one will eventually encrypt the backup compies made previously and the last one will be asked to storage the final output somewhere in the world.

At the moment, we have just one module for each area: *PostgreSQL*, *AWS S3* and *AES-256-CBC*, but adding more modules require nothing but a new file inside the proper folder.

## Install
`$ gem install edb`

## Run
Setup `example/edb.yml` (remember also to change the `SECRET`) and then:

`$ edb example/edb.yml`  

Consider also to add *EDB* to your cronjobs.
