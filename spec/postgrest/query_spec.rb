require 'spec_helper'

RSpec.describe PostgREST::Query do
  describe '#encode' do
    it 'should encode the params for an HTTP query' do
      query = described_class.new(a: 2, b: [1, 2, 3])
      expect(query.encode).to eq('a=2&b=1&b=2&b=3')
    end
  end

  describe '#order' do
    let(:query) { described_class.new(a: 2) }
    subject { query.order(:b) }

    it 'should return a new query object' do
      is_expected.to be_a(described_class)
      is_expected.not_to be(query)
    end

    it 'should set the "order" param with the given order args' do
      expect(subject.encode).to eq('a=2&order=b')
    end

    it 'should allow chaining to re-order' do
      result = subject.order(c: :desc)
      expect(result.encode).to eq('a=2&order=c.desc')
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

  describe '#filter' do
    let(:query) { described_class.new(a: 2) }
    subject { query.filter(b: [1,2,3], a: (1..4)) }

    it 'should return a new query object' do
      is_expected.to be_a(described_class)
      is_expected.not_to be(query)
    end

    it 'should add the given filters to the query' do
      expect(subject.encode).to eq('a=2&a=gte.1&a=lte.4&b=in.1%2C2%2C3')
    end

    it 'should allow chaining to narrow filter' do
      result = subject.filter(c: nil)
      expect(result.encode)
        .to eq('a=2&a=gte.1&a=lte.4&b=in.1%2C2%2C3&c=is.null')
    end
  end

  describe '#exclude' do
    let(:query) { described_class.new(a: 2) }
    subject { query.exclude(b: [1,2,3], a: (1..4)) }

    it 'should return a new query object' do
      is_expected.to be_a(described_class)
      is_expected.not_to be(query)
    end

    it 'should add the given excludes to the query' do
      expect(subject.encode)
        .to eq('a=2&a=not.gte.1&a=not.lte.4&b=not.in.1%2C2%2C3')
    end

    it 'should allow chaining to narrow exclude' do
      result = subject.exclude(c: nil)
      expect(result.encode)
        .to eq('a=2&a=not.gte.1&a=not.lte.4&b=not.in.1%2C2%2C3&c=not.is.null')
    end
  end

  describe '#select' do
    let(:query) { described_class.new(a: 'eq.2') }
    subject { query.select([:a, :c]) }

    it 'should return a new query object' do
      is_expected.to be_a(described_class)
      is_expected.not_to be(query)
    end

    it 'should add the given select clause to the query' do
      expect(subject.encode).to eq('a=eq.2&select=a%2Cc')
    end

    it 'should override previous selections when chained' do
      result = subject.select([:c, :d])
      expect(result.encode).to eq('a=eq.2&select=c%2Cd')
    end
  end

  describe '#append_select' do
    let(:query) { described_class.new(a: 'eq.2') }
    subject { query.append_select([:a, :c]) }

    it 'should return a new query object' do
      is_expected.to be_a(described_class)
      is_expected.not_to be(query)
    end

    it 'should add the given select clause to the query' do
      expect(subject.encode).to eq('a=eq.2&select=a%2Cc')
    end

    it 'should append to previous selections when chained' do
      result = subject.append_select([:c, :d])
      expect(result.encode).to eq('a=eq.2&select=a%2Cc%2Cc%2Cd')
    end
  end
end
