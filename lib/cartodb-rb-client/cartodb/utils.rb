module CartoDB
  module Utils
    def self.parse_json(response)
      json = nil
      unless response.nil? || response.body.nil? || response.body == ''
        begin
          json = JSON.parse(response.body)
        rescue JSON::ParserError => e
        end
      end
      json.to_openstruct
    end
  end
end