module PostgREST
  class Dataset
    include Enumerable

    attr_reader :connection, :table, :query, :headers

    def initialize(connection, table, query = Query.new, headers = {})
      @connection = connection
      @table = table
      @query = query
      @headers = headers
    end

    def each(&block)
      fetch_rows.each(&block)
    end

    alias all to_a

    def first
      fetch_rows(headers: headers.merge('Prefer' => 'plurality=singular'))
    end

    def [](args)
      where(args).first
    end

    def order(*args)
      branch(query: query.order(*args))
    end

    def order_append(*args)
      branch(query: query.append_order(*args))
    end

    def order_prepend(*args)
      branch(query: query.prepend_order(*args))
    end

    def filter(args = {})
      branch(query: query.filter(args))
    end

    alias where filter

    def exclude(args = {})
      branch(query: query.exclude(args))
    end

    def select(*columns)
      branch(query: query.select(columns.flatten))
    end

    def select_append(*columns)
      branch(query: query.append_select(columns.flatten))
    end

    private

    def fetch_rows(args = {})
      q = args.fetch(:query) { query }
      h = args.fetch(:headers) { headers }
      connection.table(table, q.encode, h)
    end

    def branch(args)
      self.class.new(connection, table, args.fetch(:query) { query },
        args.fetch(:headers) { headers })
    end
  end
end
