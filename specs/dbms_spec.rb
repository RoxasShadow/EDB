require_relative 'spec_helper'

describe EDB::DBMS do
  describe '#supports?' do
    context 'given DBMS device is supported' do
      it 'returns true' do
        expect(EDB::DBMS.supports?('MySQL')).to be_truthy
      end
    end

    context 'given DBMS device is not supported' do
      it 'returns false' do
        expect(EDB::DBMS.supports?('CongoDB')).to be_falsy
      end
    end
  end
end
