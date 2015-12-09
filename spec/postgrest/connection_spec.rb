require 'spec_helper'
require 'pg_helper'

RSpec.describe PostgREST::Connection do
  include PGHelper

  describe '#tables' do
    context 'no tables defined' do
      it 'should return an empty array' do
        with_server('postgrest_test_db', 'postgrest_user') do |url|
          connection = described_class.new(url)
          expect(connection.tables).to eq([])
        end
      end
    end
  end
end
