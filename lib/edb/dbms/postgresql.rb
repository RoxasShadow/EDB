#--
# Copyright(C) 2015 Giovanni Capuano <webmaster@giovannicapuano.net>
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright notice, this list of
#       conditions and the following disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY Giovanni Capuano ''AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Giovanni Capuano OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are those of the
# authors and should not be interpreted as representing official policies, either expressed
# or implied, of Giovanni Capuano.
#++

module EDB
  module DBMS
    module PostgreSQL
      class << self
        def backup(dir_name)
          db    = ::EDB.opts[:DBMS][:PostgreSQL]
          files = {
            dump:    File.join(dir_name, "#{db[:database]}.sql")
          }
          if db[:include_cluster]
            files[:cluster] = File.join(dir_name, 'cluster.sql')
          end

          if db[:only_tables]
            only_tables = db[:only_tables].map{|t| "-t #{t}" }.join(" ")
          end

          if db[:exclude_tables]
            exclude_tables = db[:exclude_tables].map{|t| "-T #{t}" }.join(" ")
          end


          ::EDB::Logger.log(:info, "Dumping #{db[:database]}...")
          pg_dump = db[:binpath] && !db[:binpath].empty? ? File.join(db[:binpath], 'pg_dump') : 'pg_dump'
          Kernel.system "PGPASSWORD='#{db[:password]}' #{pg_dump} -h #{db[:host]} -p #{db[:port]} -U #{db[:username]} -F c -b -f '#{files[:dump]}' #{only_tables} #{exclude_tables} #{db[:database]}"

          if db[:include_cluster]
            ::EDB::Logger.log(:info, 'Dumping the cluster...')
            pg_dumpall = db[:binpath] && !db[:binpath].empty? ? File.join(db[:binpath], 'pg_dumpall') : 'pg_dumpall'
            Kernel.system "PGPASSWORD='#{db[:password]}' #{pg_dumpall} -h #{db[:host]} -p #{db[:port]} -U #{db[:username]} -f '#{files[:cluster]}'"
          end

          if db[:run_sql_after_backup]
            ::EDB::Logger.log(:info, 'Run sql after backup...')
            psql = db[:binpath] && !db[:binpath].empty? ? File.join(db[:binpath], 'psql') : 'psql'
            Kernel.system "PGPASSWORD='#{db[:password]}' #{psql} -h #{db[:host]} -p #{db[:port]} -U #{db[:username]} -d #{db[:database]} -f #{db[:run_sql_after_backup]}"
          end

          files.values
        end
      end
    end
  end
end
