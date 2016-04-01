require 'spec_helper'
require 'pg_helper'

RSpec.describe PostgREST::Connection do
  include PGHelper

  let(:connection) { described_class.new(postgrest_url) }

  describe '#tables' do
    subject { connection.tables }

    context 'no tables defined' do
      it 'should return an empty array' do
        is_expected.to eq([])
      end
    end

    context 'at least one table defined' do
      before(:all) do
        execute_sql('CREATE TABLE foobar ()')
        restart_postgrest
      end

      after(:all) do
        execute_sql('DROP TABLE foobar')
        restart_postgrest
      end

      it 'should return the list of table descriptions' do
        is_expected.to contain_exactly('schema' => 'public',
          'name' => 'foobar', 'insertable' => true)
      end
    end
  end

  describe '#table' do
    let(:table_name) { 'foobar1' }
    subject { connection.table(table_name) }

    context 'table exists' do
      before(:all) do
        execute_sql("CREATE TABLE foobar1 (num integer)")
        restart_postgrest
      end

      after(:all) do
        execute_sql("DROP TABLE foobar1")
        restart_postgrest
      end

      context 'table is empty' do
        it 'should return an empty array' do
          is_expected.to eq([])
        end
      end

      context 'table contains records' do
        before(:each) { execute_sql("INSERT INTO foobar1 values (1), (5), (1)") }
        after(:each) { execute_sql("DELETE FROM foobar1") }

        it 'should return an array of records' do
          is_expected.to contain_exactly({ 'num' => 1 },
            { 'num' => 5 }, { 'num' => 1 })
        end

        it 'should allow filtering of records' do
          expect(connection.table(table_name, { num: 'eq.1' }))
            .to contain_exactly({ 'num' => 1 }, { 'num' => 1 })
        end

        it 'should allow specifying orders' do
          expect(connection.table(table_name, { order: 'num.desc'}))
            .to eq([{ 'num' => 5 }, { 'num' => 1 }, { 'num' => 1 }])
        end

        it 'should allow specifying request headers' do
          expect(connection.table(table_name, { num: 'eq.5' },
            { 'Prefer' => 'plurality=singular' }))
            .to eq({ 'num' => 5 })
          expect(connection.table(table_name, {}, { 'Range' => '1-2' }))
            .to eq([{ 'num' => 5 }, { 'num' => 1}])
        end
      end
    end

    context 'table does not exist' do
      it 'should return the parsed PostgREST error hash' do
        is_expected.to be_a(Hash)
        expect(subject['message'])
          .to eq(%(relation "public.#{table_name}" does not exist))
      end
    end
  end

  describe '#describe' do
    let(:table_name) { 'foobar1' }
    subject { connection.describe(table_name) }

    context 'table exists' do
      before(:all) do
        execute_sql("CREATE TABLE foobar1 (num integer)")
        restart_postgrest
      end

      after(:all) do
        execute_sql("DROP TABLE foobar1")
        restart_postgrest
      end

      it 'should return a hash describing the table' do
        is_expected.to eq({ "pkey" => [], "columns" => [
          { "references" => nil, "default" => nil, "precision" => 32,
            "updatable" => true, "schema" => "public", "name" => "num",
            "type" => "integer", "maxLen" => nil, "enum" => [],
            "nullable" => true, "position" => 1 }
          ] })
      end
    end

    context 'table does not exist' do
      it { is_expected.to be_nil }
    end
  end
end
