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
end
