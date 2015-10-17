require_relative '../spec_helper'

describe EDB::DBMS::MySQL do
  describe '#backup' do
    let(:dump) { '/Applications/MAMP/Library/bin/mysqldump --user=username --password=password --single-transaction sample_database > ./sample_database.sql' }

    it 'calls mysqldump correctly' do
      allow(Kernel).to receive(:system).and_wrap_original do |m, *args|
        expect(args[0]).to eq dump
      end

      EDB::DBMS::MySQL.backup('.')
    end

    it 'returns the the files that have been created' do
      allow(Kernel).to receive(:system).and_wrap_original {}

      results = EDB::DBMS::MySQL.backup('.')
      expect(results).to eq ['./sample_database.sql']
    end
  end
end
