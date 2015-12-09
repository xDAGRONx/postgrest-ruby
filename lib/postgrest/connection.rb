module PostgREST
  class Connection
    attr_reader :url

    def initialize(url)
      @url = url
    end

    def tables
      HTTParty.get(url).parsed_response
    end
  end
end
