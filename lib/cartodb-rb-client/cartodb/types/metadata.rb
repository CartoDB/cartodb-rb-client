module CartoDB
  module Types
    class Metadata < Hash

      class << self
        def from_hash(hash = {})
          metadata = self.new

          hash.each do |key, value|
            metadata[key.to_sym] = value
          end
          metadata
        end
      end

      def []=(key, value)

        value = cast_value(value)
        self.class.send :define_method, "#{key}" do
          self[key.to_sym]
        end

        self.class.send :define_method, "#{key}=" do |value|
          self[key.to_sym] = value
        end

        value = _date?(value) unless key.to_s.eql?('the_geom')

        value = _geometry_features(value) if key.to_s.eql?('the_geom')

        super(key, value)
      end

      def method_missing(name, *args, &block)
        if name.to_s.end_with?('=') && args.size == 1
          key = name.to_s[0...-1]
          self[key.to_sym] = args[0]
        else
          super
        end
      end

      def _geometry_features(the_geom)

        begin
          the_geom = RGeo::WKRep::WKBParser.new(RGeo::Geographic.spherical_factory(:srid => 4326), :support_ewkb => true).parse(the_geom)
        rescue
          begin
            the_geom = RGeo::GeoJSON.decode(the_geom, :json_parser => :json, :geo_factory => RGeo::Geographic.spherical_factory(:srid => 4326))
          rescue
          end
        end

        case the_geom
        when RGeo::Feature::Point || RGeo::Geographic::SphericalPointImpl
          self.class.send :define_method, :latitude do
            self.the_geom ? self.the_geom.y : nil
          end

          self.class.send :define_method, :longitude do
            self.the_geom ? self.the_geom.x : nil
          end
        end

        the_geom
      end
      private :_geometry_features

      def _date?(value)
        begin
          value = DateTime.strptime(value)
        rescue
          value
        end
      end
      private :_date?

      def cast_value(value)
        return nil   if value.nil?
        return true  if value.eql?('t')
        return false if value.eql?('f')

        value.match('.') ? Float(value) : Integer(value) rescue
        return DateTime.strptime(value, '%Y-%m-%d') rescue
        return DateTime.strptime(value, '%d-%m-%Y') rescue

        value
      end
      private :cast_value

    end
  end
end
