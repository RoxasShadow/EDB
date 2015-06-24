gem 'aws-sdk', '=1.59.1'
require 'aws-sdk'

require 'yaml'
require 'openssl'

module EDB
  VERSION = '0.1'

  class << self
    def opts
      @@opts
    end

    def opts=(options)
      @@opts = options
    end
  end

  module DBMS
    class << self
      def supports?(dbms)
        this_module = to_module(dbms)
        all_modules.include?(this_module)
      end

      def backup(dbms, *args)
        this_module = to_module(dbms)
        this_module.backup(*args)
      end

      private
      def to_module(dbms)
        Object.const_get("::EDB::DBMS::#{dbms}")
      end

      def all_modules
        constants.select { |c| const_get(c).is_a?(Module) }.map { |c| const_get(c) }
      end
    end

    module PostgreSQL
      def self.backup(dir_name)
        db    = ::EDB.opts[:DB][:PostgreSQL]
        files = {
          dump:    File.join(dir_name, "#{db[:name]}.sql"),
          cluster: File.join(dir_name, 'cluster.sql')
        }

        puts "Dumping #{db[:name]}..."
        # system "PGPASSWORD='#{db[:pass]}' pg_dump -h #{db[:host]} -p #{db[:port]} -U #{db[:username]} -F c -b -f '#{files[:dump]}' #{db[:name]}"

        puts 'Dumping the cluster...'
        # system "PGPASSWORD='#{db[:pass]}' pg_dumpall -h #{db[:host]} -p #{db[:port]} -U #{db[:username]} -f '#{files[:cluster]}'"

        files.values
      end
    end
  end

  module Cryptography
    class << self
      def encrypt(method, file)
        this_module = to_module(method)
        this_module.encrypt(file)
      end

      private
      def to_module(method)
        Object.const_get("::EDB::Cryptography::#{method}")
      end
    end

    module AES_256_CBC
      class << self
        def encrypt(source)
          p "encrypting #{source}"; return

          cipher = OpenSSL::Cipher.new('AES-256-CBC')
          cipher.encrypt
          cipher.key = ::EDB.opts[:CRYPTOGRAPHY][:AES_256_CBC][:secret]

          contents = File.read(source)
          File.open(source, 'wb') do |file|
            ciphered_content = cipher.update(contents) + cipher.final
            file.write(ciphered_content)
          end
        end
      end
    end
  end

  module Storage
    class << self
      def upload(service, source)
        this_module = to_module(service)
        this_module.upload(source)
      end

      private
      def to_module(service)
        Object.const_get("::EDB::Storage::#{service}")
      end
    end

    module S3
      class << self
        def upload(source)
          p "uploading #{source}"; return

          aws = ::EDB.opts[:STORAGE][:S3]
          AWS.config(aws)

          target = File.join(aws[:bucket][:folder], source)
          source = File.join('./', source)

          bucket = AWS::S3.new.buckets[aws[:bucket][:main]]
          bucket.objects.create(target, Pathname.new(source))
        end
      end
    end
  end

  class Dumper
    PATTERN = ->(time) { "#{time.day}_#{time.month}_#{time.year}" }

    def initialize(opts)
      ::EDB.opts = opts
    end

    def run
      create_dir

      ::EDB.opts[:DB].each do |dbms|
        dbms_name = dbms[0]

        if EDB::DBMS.supports?(dbms_name)
          files = EDB::DBMS.backup(dbms_name, @dir_name)

          if ::EDB.opts[:CRYPTOGRAPHY]
            ::EDB.opts[:CRYPTOGRAPHY].each do |method|
              files.each { |file| ::EDB::Cryptography.encrypt(method[0], file) }
            end
          end

          if ::EDB.opts[:STORAGE]
            ::EDB.opts[:STORAGE].each do |service|
              files.each { |file| ::EDB::Storage.upload(service[0], file) }
            end
          end
        else
          puts "No support for #{dbms_name}."
        end
      end
    end

    private
    def create_dir
      @dir_name = PATTERN.call(Time.now)
      # Dir.mkdir(@dir_name) unless Dir.exists?(@dir_name)
    end
  end
end

opts = YAML.load_file('secrets.yml')
EDB::Dumper.new(opts).run
