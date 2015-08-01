# Backup, encrypt and manage your database

*EDB* is a framework to make and manage backups of your database.
It is composed by three macro areas that reflect themself inside `edb.yml` and are *DBMS*, *CRYPTOGRAPHY* and *STORAGE*.
The first one deals with the actual backup process of your database. The second one will eventually encrypt the backup copies you made and the last one will copy them somewhere (S3 bucket, your local filesystem, etc.).

At the moment, we have just one module for each area: *PostgreSQL*, *AWS S3* and *AES-256-CBC*, but adding more modules requires nothing but a new file inside the proper folder.

## Install
`$ gem install edb`

## Run
Setup and customize `example/edb.yml` (remember also to change the `secret`) and then:

`$ edb example/edb.yml`

Consider also to add *EDB* to your cronjobs.

## Available modules
- *Cryptography*: `AES_256_CBC`
- *DBMS*:         `PostgreSQL`
- *Storage*:      `S3`, `Filesystem`
