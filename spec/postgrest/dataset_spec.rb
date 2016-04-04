require 'spec_helper'
require 'pg_helper'

RSpec.describe PostgREST::Dataset do
  include PGHelper

  before(:all) do
    execute_sql('CREATE TABLE foo (num integer)')
    execute_sql('INSERT INTO foo values (1), (5), (2)')
    restart_postgrest
  end

  after(:all) do
    execute_sql('DROP TABLE foo')
    restart_postgrest
  end

  let(:connection) { PostgREST::Connection.new(postgrest_url) }
  let(:dataset) { described_class.new(connection, table_name, query, headers) }
  let(:table_name) { 'foo' }
  let(:query) { { num: 'gte.2' } }
  let(:headers) { {} }

  describe '#to_a' do
    subject { dataset.to_a }

    it 'should query the connection with the given parameters' do
      is_expected.to eq([{ 'num' => 5 }, { 'num' => 2 }])
    end
  end

  describe '#first' do
    subject { dataset.first }

    it 'should return the first matching record' do
      is_expected.to eq({ 'num' => 5 })
    end
  end
end
