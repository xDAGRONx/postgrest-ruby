require 'spec_helper'

RSpec.describe PostgREST do
  it 'has a version number' do
    expect(PostgREST::VERSION).not_to be_nil
  end
end
