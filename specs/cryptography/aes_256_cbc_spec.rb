require_relative '../spec_helper'

describe EDB::Cryptography::AES_256_CBC do
  describe '#encrypt' do
    context 'given string is empty' do
      it 'raises an exception' do
        expect { EDB::Cryptography::AES_256_CBC.encrypt('') }.to raise_error
      end
    end

    context 'non-empty string is given' do
      let(:data)          { 'kanbaru is mai waifu' }
      let(:ciphered_data) { EDB::Cryptography::AES_256_CBC.encrypt(data) }

      it 'returns a valid AES-256-CBC ciphered string' do
        expect(ciphered_data.length).to be 80
      end
    end
  end

  describe '#decrypt' do
    context 'given data is less than 64 chars long' do
      it 'raises an exception' do
        expect { EDB::Cryptography::AES_256_CBC.decrypt('H' * 63) }.to raise_error
      end
    end

    context 'valid data is given' do
      let(:real_data)     { 'kanbaru is mai waifu' }
      let(:ciphered_data) { EDB::Cryptography::AES_256_CBC.encrypt(real_data) }
      let(:data)          { EDB::Cryptography::AES_256_CBC.decrypt(ciphered_data) }

      it 'returns a string matching the original given one' do
        expect(data).to eq real_data
      end
    end
  end

  describe '#slice_str!' do
    let(:str)    { 'senjougahara' }
    let(:sliced) { EDB::Cryptography::AES_256_CBC.instance_exec(str) { |str| slice_str!(str, 6) } }

    it 'returns and remove the last n characters from given string' do
      expect(sliced).to eq 'gahara'
      expect(str).to    eq 'senjou'
    end
  end

  describe '#hash_keychain' do
    let(:keychain) { EDB::Cryptography::AES_256_CBC.instance_eval { hash_keychain('hitagi') } }

    it 'returns an array with two 64 bytes long keys' do
      expect(keychain[0].length).to be 64
      expect(keychain[1].length).to be 64
    end
  end
end
