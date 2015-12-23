require 'pg'

require 'support/temporary_server'

module PGHelper
  module_function

  def temporary_server
    @temp_server ||=
      PostgREST::TemporaryServer.new(db_name, postgres_user, postgres_port)
  end

  def db_name
    'postgrest-ruby_test_db'
  end

  def postgres_user
    'postgrest_ruby_user'
  end

  def postgres_port
    55561
  end

  def postgrest_url
    PGHelper.temporary_server.url
  end

  def restart_postgrest
    PGHelper.temporary_server.restart_postgrest
  end

  def postgres_connection
    @pg_conn ||=
      PG.connect(dbname: db_name, port: postgres_port, user: postgres_user)
  end

  def execute_sql(*args)
    PGHelper.postgres_connection.exec(*args)
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    PGHelper.temporary_server.setup
  end

  config.after(:suite) do
    PGHelper.temporary_server.teardown
  end
end
