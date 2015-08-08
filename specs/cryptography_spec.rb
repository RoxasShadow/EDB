require_relative 'spec_helper'

describe EDB::Cryptography do
  describe '#supports?' do
    context 'given algorithm is supported' do
      it 'returns true' do
        expect(EDB::Cryptography.supports?('AES_256_CBC')).to be_truthy
      end
    end

    context 'given algorithm is not supported' do
      it 'returns false' do
        expect(EDB::Cryptography.supports?('LOL_WUT_128')).to be_falsy
      end
    end
  end
end
