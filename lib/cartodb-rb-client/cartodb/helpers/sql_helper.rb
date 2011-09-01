module CartoDB
  module Helpers
    module SqlHelper

      def prepare_data(hash)
        hash.each do |key, value|
          hash[key] = format_value(value)
        end
        hash
      end

      def format_value(value)
        case value
        when ::String
          "'#{value}'"
        when ::Date, ::DateTime, ::Time
          "'#{value}'"
        when RGeo::Feature::Geometry
          "'#{RGeo::WKRep::WKBGenerator.new(:type_format => :ewkb, :emit_ewkb_srid => true, :hex_format => true).generate(value)}'"
        when NilClass
          'NULL'
        else
          value
        end
      end
      private :format_value

    end
  end
end
