require_relative 'spec_helper'

describe EDB::Storage do
  describe '#supports?' do
    context 'given storage device is supported' do
      it 'returns true' do
        expect(EDB::Storage.supports?('S3')).to be_truthy
      end
    end

    context 'given storage device is not supported' do
      it 'returns false' do
        expect(EDB::Storage.supports?('CappellaAmbrosiana')).to be_falsy
      end
    end
  end
end
