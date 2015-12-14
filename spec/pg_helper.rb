require 'support/temporary_server'

RSpec.configure do |config|
  config.before(:suite) do
    @temp_server = PostgREST::TemporaryServer
      .new('postgrest-ruby_test_db', 'postgrest-ruby_user')
    @temp_server.setup
  end

  config.after(:suite) do
    @temp_server.teardown
  end
end
