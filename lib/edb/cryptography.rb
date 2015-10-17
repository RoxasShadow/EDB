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
Dir[File.dirname(__FILE__) + '/cryptography/*.rb'].each { |file| require file }

module EDB
  module Cryptography
    class << self
      include ::EDB::IsModuleSupported

      def encrypt(method, filename)
        ::EDB::Logger.log(:info, "Encrypting #{filename}...")

        ciphered_data = File.open(filename, 'rb') do |file|
          data = file.read

          this_module   = to_module(method)
          ciphered_data = this_module.encrypt(data)
        end

        File.open(filename, 'wb') do |file|
          file.write(ciphered_data)
        end
      end

      def decrypt(method, filename)
        ::EDB::Logger.log(:info, "Decrypting #{filename}...")

        data = File.open(filename, 'rb') do |file|
          ciphered_data = file.read

          this_module = to_module(method)
          data        = this_module.decrypt(ciphered_data)
        end

        File.open("#{filename}.dec", 'wb') do |file|
          file.write(data)
        end
      end

      private
      def to_module(method)
        Object.const_get("::EDB::Cryptography::#{method}")
      end
    end
  end
end
