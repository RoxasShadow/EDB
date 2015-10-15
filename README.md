# Backup, encrypt and manage your database

*EDB* is a framework to make and manage backups of your database.
It is composed by three macro areas that reflect themself inside `edb.yml` and are *DBMS*, *CRYPTOGRAPHY* and *STORAGE*.
The first one deals with the actual backup process of your database. The second one will eventually encrypt the backup copies you made and the last one will copy them somewhere (S3 bucket, your local filesystem, etc.).


**tl;dr** Make (optionally) ciphered backups of your database(s) and then upload them via FTP and Amazon S3 (or just keep them in your server).

## Install
`$ gem install edb`

## Run
Setup and customize `example/edb.yml` (remember also to change the `secret`) and then:

`$ edb example/edb.yml`

Consider also to add *EDB* to your cronjobs.

## Available modules
- *Cryptography*: `AES_256_CBC`
- *DBMS*:         `PostgreSQL`, `MySQL`
- *Storage*:      `S3`, `Filesystem`, `FTP`

## FAQ
**Q:** What if I want to dump two or three MySQL databases?   
*A:* Just add a `:MySQL:` block for every database you need to dump.


**Q:** What if I want to save a database to S3 and another one into my local filesystem?   
*A:* Well, you can't. By design, every macro-block (like, `:DBMS:`) is unaware of the other ones. So, for instance, I couldn't ask `:Filesystem:` to work only for the first `:MySQL:` block since it actually does not know what a `:MySQL:` block is. You need just to create two configuration files.
