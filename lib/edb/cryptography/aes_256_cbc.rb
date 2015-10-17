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
require 'hkdf'
require 'fast_secure_compare/fast_secure_compare'

module EDB
  module Cryptography
    module AES_256_CBC
      class << self
        def encrypt(data)
          raise "Cannot encrypt #{filename}: It's empty" if data.empty?

          cipher = OpenSSL::Cipher.new('AES-256-CBC')
          cipher.encrypt

          hkdf = HKDF.new(::EDB.opts[:CRYPTOGRAPHY][:AES_256_CBC][:secret])
          cipher.key         = hkdf.next_bytes(32)
          authentication_key = hkdf.next_bytes(64)
          cipher.iv     = iv = cipher.random_iv

          ciphered_data = cipher.update(data) + cipher.final
          ciphered_data << iv

          authentication = OpenSSL::HMAC.digest(OpenSSL::Digest.new('SHA256'), authentication_key, ciphered_data)
          ciphered_data << authentication
        end

        def decrypt(ciphered_data)
          raise "Cannot decrypt #{filename}: It's empty" if ciphered_data.length < 64

          decipher = OpenSSL::Cipher.new('AES-256-CBC')
          decipher.decrypt

          authentication = slice_str!(ciphered_data, 32)

          hkdf = HKDF.new(::EDB.opts[:CRYPTOGRAPHY][:AES_256_CBC][:secret])
          decipher.key       = hkdf.next_bytes(32)
          authentication_key = hkdf.next_bytes(64)

          new_authentication = OpenSSL::HMAC.digest(OpenSSL::Digest.new('SHA256'), authentication_key, ciphered_data)
          raise 'Authentication failed.' unless FastSecureCompare.compare(authentication, new_authentication)

          decipher.iv = slice_str!(ciphered_data, 16)

          deciphered_data = decipher.update(ciphered_data) + decipher.final
        end

        private
        def slice_str!(str, n)
          len = str.length
          str.slice!(len - n, len)
        end
      end
    end
  end
end
