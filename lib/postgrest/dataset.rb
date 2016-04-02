module PostgREST
  class Dataset
    include Enumerable

    attr_reader :connection, :table, :query, :headers

    def initialize(connection, table, query = {}, headers = {})
      @connection = connection
      @table = table
      @query = query
      @headers = headers
    end

    def each(&block)
      fetch_rows.each(&block)
    end

    private

    def fetch_rows
      connection.table(table, query, headers)
    end
  end
end
