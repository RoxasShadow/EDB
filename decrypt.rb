#! /usr/bin/env ruby
require 'fileutils'
require 'aws-sdk'
require 'base64'
require 'yaml'

# gem install aws-sdk --version 1.59.1

OPTS = YAML.load_file('secrets.yml')

time = Time.now
date = "#{time.day}_#{time.month}_#{time.year}"

db   = OPTS[:DB]
file = { dump: "#{date}/#{db[:name]}.sql", cluster: "#{date}/cluster.sql" }

# Decryption
[file[:dump], file[:cluster]].each do |source|
  decipher = OpenSSL::Cipher.new('AES-256-CBC')
  decipher.decrypt
  decipher.key = OPTS[:SECRET]

  contents = File.read(source)
  File.open("#{source}.dec", 'wb') do |file|
    deciphered_content = decipher.update(contents) + decipher.final
    file.write(deciphered_content)
  end
end

puts 'Done.'

