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
require 'openssl'

module EDB
  module Cryptography
    module AES_256_CBC
      class << self
        def encrypt(source)
          ::EDB::Logger.log(:info, "Encrypting #{source}...")

          cipher = OpenSSL::Cipher.new('AES-256-CBC')
          cipher.encrypt
          cipher.key = ::EDB.opts[:CRYPTOGRAPHY][:AES_256_CBC][:secret]

          contents = File.read(source)
          raise "Cannot encrypt #{source}: It's empty" if contents.empty?

          File.open(source, 'wb') do |file|
            ciphered_content = cipher.update(contents) + cipher.final
            file.write(ciphered_content)
          end
        end

        def decrypt(source, new_file = true)
          ::EDB::Logger.log(:info, "Decrypting #{source}...")

          decipher = OpenSSL::Cipher.new('AES-256-CBC')
          decipher.decrypt
          decipher.key = ::EDB.opts[:CRYPTOGRAPHY][:AES_256_CBC][:secret]

          contents = File.read(source)
          raise "Cannot decrypt #{source}: It's empty" if contents.empty?

          new_source = new_file ? "#{source}.dec" : source
          File.open(new_source, 'wb') do |file|
            deciphered_content = decipher.update(contents) + decipher.final
            file.write(deciphered_content)
          end
        end
      end
    end
  end
end
