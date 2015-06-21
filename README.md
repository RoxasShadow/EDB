# Backup, encrypt and send to S3 your PostgreSQL database

Currently this is nothing but code that Just Works™.
I expect to add more DBMS and configurable stuff. In the meanwhile I hope this can be useful to you.

## Setup
Setup `secrets.yml` (remember also to change the `SECRET`), put `dumper.rb` in your cronjobs and then:

`$ gem install aws-sdk --version 1.59.1`  
`$ ruby dumper.rb`  
`$ ruby decrypt.rb`  

