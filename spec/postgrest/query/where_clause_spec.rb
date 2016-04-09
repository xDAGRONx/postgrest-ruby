require 'spec_helper'

RSpec.describe PostgREST::Query::WhereClause do
  describe '#encode' do
    let(:clause) { described_class.new(query) }
    let(:query) do
      { a: 1, b: nil, c: true, d: { like: 'hi*' },
        e: (6...12), f: [6, 7, 8] }
    end

    subject { clause.encode }

    context 'query includes an array' do
      let(:query) { { a: [1, 2, 3] } }

      it 'should encode the param using "in"' do
        is_expected.to eq(a: ['in.1,2,3'])
      end
    end

    context 'query includes a range' do
      let(:query) { { a: (1..5) } }

      it 'should encode the param using "gte" and "lte"' do
        is_expected.to eq(a: ['gte.1', 'lte.5'])
      end
    end

    context 'query includes a hash' do
      let(:query) { { a: { lt: 2, gte: -10 } } }

      it 'should use the keys and values to encode the param' do
        is_expected.to eq(a: ['lt.2', 'gte.-10'])
      end
    end

    context 'query includes true or false' do
      let(:query) { { a: true, b: false } }

      it 'should encode the param using "is"' do
        is_expected.to eq(a: ['is.true'], b: ['is.false'])
      end
    end

    context 'query includes nil' do
      let(:query) { { a: nil } }

      it 'should encode the param using "is.null"' do
        is_expected.to eq(a: ['is.null'])
      end
    end

    context 'query param is not a special case' do
      let(:query) { { a: 1, b: 'foo' } }

      it 'should encode the param using "eq"' do
        is_expected.to eq(a: ['eq.1'], b: ['eq.foo'])
      end
    end

    context 'query is a mixture of param types' do
      it 'should encode each param properly' do
        is_expected.to eq(a: ['eq.1'], b: ['is.null'], c: ['is.true'],
          d: ['like.hi*'], e: ['gte.6', 'lte.12'], f: ['in.6,7,8'])
      end
    end

    context 'query is for exclusions' do
      let(:clause) { described_class.new(query, true) }

      it 'should encode each param with a "not"' do
        is_expected.to eq(a: ['not.eq.1'], b: ['not.is.null'], c: ['not.is.true'],
          d: ['not.like.hi*'], e: ['not.gte.6', 'not.lte.12'], f: ['not.in.6,7,8'])
      end
    end
  end
end
