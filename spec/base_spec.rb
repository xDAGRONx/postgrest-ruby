require 'spec_helper'

RSpec.describe PostgREST::Base do
  let(:base) { described_class.new(info) }
  let(:info) { Hash.new }

  describe '#to_h (aliased as #info)' do
    let(:info) do
      { 'one' => 2, 'three' => :four, :five => 'six' }
    end

    it 'should return the original hash, with symbols as keys' do
      result = { one: 2, three: :four, five: 'six' }
      expect(base.to_h).to eq(result)
      expect(base.info).to eq(result)
    end

    context 'no args given' do
      let(:info) { nil }

      it 'should return an empty hash' do
        expect(base.to_h).to eq({})
        expect(base.info).to eq({})
      end
    end
  end
end
