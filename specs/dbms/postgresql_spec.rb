require_relative '../spec_helper'

describe EDB::DBMS::PostgreSQL do
  describe '#backup' do
    let(:dump)    { "PGPASSWORD='password' /Applications/Postgres.app/Contents/Versions/9.3/bin/pg_dump -h localhost -p 5432 -U username -F c -b -f './sample_database.sql' -t table_name_only_included_in_backup -T table_name_excluded_in_backup sample_database" }
    let(:cluster) { "PGPASSWORD='password' /Applications/Postgres.app/Contents/Versions/9.3/bin/pg_dumpall -h localhost -p 5432 -U username -f './cluster.sql'" }
    let(:after_sql) { "PGPASSWORD='password' /Applications/Postgres.app/Contents/Versions/9.3/bin/psql -h localhost -p 5432 -U username -d sample_database -f ~/Documents/clear_some_tables_after_backup.sql" }

    it 'calls pg_dump correctly' do
      allow(Kernel).to receive(:system).and_wrap_original do |m, *args|
        expect(args[0]).to satisfy { |c| [dump, cluster, after_sql].include?(c) }
      end

      EDB::DBMS::PostgreSQL.backup('.')
    end

    it 'returns the the files that have been created' do
      allow(Kernel).to receive(:system).and_wrap_original {}

      results = EDB::DBMS::PostgreSQL.backup('.')
      expect(results).to eq ['./sample_database.sql', './cluster.sql']
    end
  end
end
