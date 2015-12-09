require 'tmpdir'
require 'net/http'

module PGHelper
  def with_server(db_name, pg_user, pg_port = 55561, port = 55560)
    if block_given?
      with_database(db_name, pg_user, pg_port) do
        begin
          pid = Process.spawn("postgrest " \
            "postgres://#{pg_user}@localhost:#{pg_port}/#{db_name} " \
            "-a #{pg_user} -p #{port} -s public", out: '/dev/null')

          url = "http://localhost:#{port}"
          wait_for_server(url)

          yield(url)
        ensure
          Process.kill('TERM', pid) if pid
        end
      end
    end
  end

  def with_database(db_name, pg_user, pg_port = 55561)
    if block_given?
      Dir.mktmpdir do |dir|
        location = "#{dir}/#{db_name}"

        `initdb -D #{location} --auth=trust --username=#{pg_user}`

        `pg_ctl -D #{location} -l #{dir}/#{db_name}.log -w -o "-p #{pg_port}" start`

        begin
          `createdb -w -p #{pg_port} -U #{pg_user} #{db_name}`

          yield
        ensure
          `pg_ctl -D #{location} stop -s -m fast`
        end
      end
    end
  end

  private

  def wait_for_server(url)
    start_time = Time.now
    timeout = 10
    wait_time = 0.01

    until server_available?(url)
      fail 'Unable to start PostgREST server' if Time.now > start_time + timeout

      sleep(wait_time *= 2)
    end
  end

  def server_available?(url)
    Net::HTTP.get(URI(url)) && true
  rescue Errno::ECONNREFUSED
    false
  end
end
