module CartoDB
  module Client
    module Utils
      def self.parse_json(response)
        json = nil
        setup_parser
        unless response.nil? || response.body.nil? || response.body == ''
          begin
            json = JSON.parse(response.body, :object_class => CartoDB::Types::Metadata, :symbolize_names => true)
          rescue JSON::ParserError => e
            json = CartoDB::Types::Metadata.new
          end
        end
        json
      end

      def self.setup_parser
        # We need to ensure that the JSON parser is JSON::Pure::Parser, until pull request https://github.com/flori/json/pull/69 is accepted
        JSON.parser = JSON::Pure::Parser unless JSON::Parser == JSON::Pure::Parser
      end
    end
  end
end