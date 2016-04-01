module PostgREST
  class Connection
    attr_reader :url

    def initialize(url)
      @url = url
    end

    def tables
      HTTParty.get(url).parsed_response
    end

    def table(table_name, query = {}, headers = {})
      HTTParty.get("#{url}/#{table_name}", query: query, headers: headers)
        .parsed_response
    end

    def describe(table_name)
      HTTParty.options("#{url}/#{table_name}").parsed_response
    end
  end
end
