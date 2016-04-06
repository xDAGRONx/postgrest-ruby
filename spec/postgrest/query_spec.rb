require 'spec_helper'

RSpec.describe PostgREST::Query do
  describe '#encode' do
    it 'should encode the params for an HTTP query' do
      query = described_class.new(a: 2, b: [1, 2, 3])
      expect(query.encode).to eq('a=2&b=1&b=2&b=3')
    end
  end

  describe '#append_order' do
    let(:query) { described_class.new(a: 2) }
    subject { query.append_order(:b) }

    it 'should return a new query object' do
      is_expected.to be_a(described_class)
      is_expected.not_to be(query)
    end

    it 'should append the given order args to the "order" param' do
      expect(subject.encode).to eq('a=2&order=b')
    end

    it 'should allow chaining to append orders' do
      result = subject.append_order(c: :desc)
      expect(result.encode).to eq('a=2&order=b%2Cc.desc')
    end
  end
end
