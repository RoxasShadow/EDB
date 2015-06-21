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

Dir.mkdir(date) unless Dir.exists?(date)

puts   "Dumping #{db[:name]}..."
system "PGPASSWORD='#{db[:pass]}' pg_dump -h #{db[:host]} -p #{db[:port]} -U #{db[:username]} -F c -b -f '#{file[:dump]}' #{db[:name]}"

puts 'Dumping cluster...'
system "PGPASSWORD='#{db[:pass]}' pg_dumpall -h #{db[:host]} -p #{db[:port]} -U #{db[:username]} -f '#{file[:cluster]}'"

# Encryption
[file[:dump], file[:cluster]].each do |source|
  cipher = OpenSSL::Cipher.new('AES-256-CBC')
  cipher.encrypt
  cipher.key = OPTS[:SECRET]

  contents = File.read(source)
  File.open(source, 'wb') do |file|
    ciphered_content = cipher.update(contents) + cipher.final
    file.write(ciphered_content)
  end
end

puts 'Uploading backups...'
AWS.config(OPTS[:AWS])
bucket = AWS::S3.new.buckets[OPTS[:AWS][:bucket][:main]]
bucket.objects.create("#{OPTS[:AWS][:bucket][:folder]}/#{file[:dump]}", Pathname.new("./#{file[:dump]}"))
bucket.objects.create("#{OPTS[:AWS][:bucket][:folder]}/#{file[:cluster]}", Pathname.new("./#{file[:cluster]}"))

puts 'Cleaning...'
#FileUtils.rm_rf(date)

puts 'Done.'

