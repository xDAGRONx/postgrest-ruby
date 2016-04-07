require 'spec_helper'
require 'pg_helper'

RSpec.describe PostgREST::Dataset do
  include PGHelper

  before(:all) do
    execute_sql('CREATE TABLE foo (num integer)')
    restart_postgrest
  end

  after(:all) do
    execute_sql('DROP TABLE foo')
    restart_postgrest
  end

  after(:each) { execute_sql('DELETE FROM foo') }

  let(:connection) { PostgREST::Connection.new(postgrest_url) }
  let(:dataset) { described_class.new(connection, table_name, query, headers) }
  let(:table_name) { 'foo' }
  let(:query) { PostgREST::Query.new(num: 'gte.2') }
  let(:headers) { {} }

  describe '#to_a' do
    subject { dataset.to_a }

    it 'should query the connection with the given parameters' do
      execute_sql('INSERT INTO foo values (1), (5), (2)')
      is_expected.to eq([{ 'num' => 5 }, { 'num' => 2 }])
    end
  end

  describe '#first' do
    subject { dataset.first }

    it 'should return the first matching record' do
      execute_sql('INSERT INTO foo values (1), (5), (2)')
      is_expected.to eq({ 'num' => 5 })
    end
  end

  describe '#order' do
    before(:each) do
      execute_sql('INSERT INTO foo values (1), (5), (2), (NULL), (6)')
    end

    let(:query) { PostgREST::Query.new }

    it 'should return a new dataset with the given order clause' do
      result = dataset.order(:num)
      expect(result).to be_a(described_class)
      expect(result).not_to be(dataset)
      expect(result.query.encode).to eq('order=num')
    end

    it 'should order by the given attribute(s) ascending by default' do
      result = dataset.order(:num)
      expect(result_nums(result)).to eq([1, 2, 5, 6, nil])
    end

    it 'should allow setting the order to descending' do
      result = dataset.order(num: :desc)
      expect(result_nums(result)).to eq([nil, 6, 5, 2, 1])
    end

    it 'should allow specifying "nullsfirst"' do
      result = dataset.order(num: ['NULLSFIRST', :asc])
      expect(result_nums(result)).to eq([nil, 1, 2, 5, 6])
    end

    it 'should allow specifying "nullslast"' do
      result = dataset.order(num: [:DESC, :nullslast])
      expect(result_nums(result)).to eq([6, 5, 2, 1, nil])
    end

    context 'using multiple columns' do
      before(:all) do
        execute_sql('CREATE TABLE foo1 (num1 integer, num2 integer)')
        restart_postgrest
        execute_sql('INSERT INTO foo1 values (1,1), (1, 2), (3, 2), (0, 0)')
      end

      after(:all) do
        execute_sql('DROP TABLE foo1')
        restart_postgrest
      end

      let(:table_name) { 'foo1' }

      it 'should append chained order clauses' do
        result = dataset.order(:num2).order(num1: :desc)
        expect(result_nums(result)).to eq([[0, 0], [1, 1], [3, 2], [1, 2]])
      end
    end
  end
end

def result_nums(result)
  result.map { |r| r.length == 1 ? r.first.last : r.values }
end