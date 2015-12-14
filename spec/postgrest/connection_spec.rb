require 'spec_helper'
require 'pg_helper'

RSpec.describe PostgREST::Connection do
  describe '#tables' do
    context 'no tables defined' do
      it 'should return an empty array' do
        connection = described_class.new('http://localhost:55560')
        expect(connection.tables).to eq([])
      end
    end
  end
end
