module PostgREST
  class Query
    attr_reader :params

    def initialize(params = {})
      @params = params
    end

    def encode
      URI.encode_www_form(encoded_params)
    end

    def append_order(*args)
      branch(order: OrderClause.new(args)) { |_, x, y| x.join(y) }
    end

    def filter(args)
      branch(WhereClause.new(args).query) { |_, x, y| [*x] | [*y] }
    end

    def exclude(args)
      branch(WhereClause.new(args, true).query) { |_, x, y| [*x] | [*y] }
    end

    def select(columns)
      branch(select: columns.join(','))
    end

    def append_select(columns)
      branch(select: columns.join(',')) { |_, x, y| [x, y].join(',') }
    end

    private

    def branch(new_query, &block)
      self.class.new(params.merge(new_query, &block))
    end

    def encoded_params
      Hash[params.map { |k, v| [k, v.respond_to?(:encode) ? v.encode : v] }]
    end
  end
end
