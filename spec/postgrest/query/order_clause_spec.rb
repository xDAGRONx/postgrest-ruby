require 'spec_helper'

RSpec.describe PostgREST::Query::OrderClause do
  describe '#encode' do
    it 'should format the given columns for HTTP query' do
      clause = described_class.new(:column1, column2: :DESC,
        column3: [:nullsfirst, 'asc'])
      expect(clause.encode)
        .to eq('column1,column2.desc,column3.asc.nullsfirst')
    end
  end

  describe '#join' do
    it 'should return a new order clause, with all of the columns from both original clauses' do
      clause1 = described_class.new(:column2, column1: :asc)
      clause2 = described_class.new(column3: [:desc, :nullslast])
      result = clause1.join(clause2)

      expect(result).to be_a(described_class)
      expect(result).not_to be(clause1)
      expect(result).not_to be(clause2)

      expect(result.encode).to eq('column2,column1.asc,column3.desc.nullslast')
    end
  end
end
