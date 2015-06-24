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
  class Dumper
    PATTERN = ->(time) { "#{time.day}_#{time.month}_#{time.year}" }

    def initialize(opts)
      ::EDB.opts = opts
    end

    def run
      create_dir

      ::EDB.opts[:DBMS].each do |dbms|
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
          ::EDB::Logger.log(:error, "No support for #{dbms_name}.")
        end
      end
    end

    private
    def create_dir
      @dir_name = PATTERN.call(Time.now)
      Dir.mkdir(@dir_name) unless Dir.exists?(@dir_name)
    end
  end
end
