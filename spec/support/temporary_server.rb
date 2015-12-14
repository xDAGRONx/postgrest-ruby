require 'tmpdir'
require 'net/http'

module PostgREST
  class TemporaryServer
    PostgRESTServerStartError = Class.new(StandardError)

    attr_reader :db_name, :pg_user, :pg_port, :port, :pg_dir, :pid

    def initialize(db_name, pg_user, pg_port = 55561, port = 55560)
      @db_name = db_name
      @pg_user = pg_user
      @pg_port = pg_port.to_s
      @port    = port.to_s
      @pg_dir  = Dir.mktmpdir
    end

    def url
      "http://localhost:#{port}"
    end

    def setup
      unless setup_database && setup_postgrest && wait_for_server
        fail PostgRESTServerStartError, 'Unable to initiate PostgREST server'
      end
    end

    def teardown
      Process.kill('TERM', pid) if pid
    ensure
      begin
        `pg_ctl -D #{pg_location} stop -s -m fast`
      ensure
        FileUtils.remove_entry(pg_dir)
      end
    end

    private

    def setup_database
      initdb && pg_start && createdb
    end

    def initdb
      system_with_error('initdb', '-D', pg_location,
        '--auth=trust', "--username=#{pg_user}")
    end

    def pg_start
      system_with_error('pg_ctl', '-D', pg_location, '-l',
        "#{pg_location}.log", '-w', '-o', %("-p #{pg_port}"), 'start')
    end

    def createdb
      system_with_error('createdb', '-w', '-p', pg_port,
        '-U', pg_user, db_name)
    end

    def system_with_error(*args)
      system(*args, out: '/dev/null') || fail(PostgRESTServerStartError, $?)
    end

    def setup_postgrest
      @pid = Process.spawn("postgrest " \
        "postgres://#{pg_user}@localhost:#{pg_port}/#{db_name} " \
        "-a #{pg_user} -p #{port} -s public", out: '/dev/null')
    end

    def pg_location
      "#{pg_dir}/#{db_name}"
    end

    def wait_for_server
      start_time = Time.now
      timeout = 10
      wait_time = 0.01

      until server_available?
        return false if Time.now > start_time + timeout

        sleep(wait_time *= 2)
      end

      true
    end

    def server_available?
      Net::HTTP.get(URI(url)) && true
    rescue Errno::ECONNREFUSED
      false
    end
  end
end
