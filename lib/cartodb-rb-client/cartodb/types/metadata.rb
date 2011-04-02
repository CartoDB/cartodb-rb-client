module CartoDB
  module Types
    class Metadata < Hash

      def []=(key, value)
        self.class.send :define_method, "#{key}" do
          self[key.to_sym]
        end

        self.class.send :define_method, "#{key}=" do
          self[key.to_sym] = value
        end

        value = _date?(value) unless key.to_s.eql?('the_geom')

        value = _geometry_features(value) if key.to_s.eql?('the_geom')

        super(key, value)
      end

      def _geometry_features(geo_json)
        begin
          the_geom = RGeo::GeoJSON.decode(geo_json, :json_parser => :json, :geo_factory => ::RGeo::Geographic.simple_mercator_factory())
          case the_geom
          when RGeo::Feature::Point
            self.class.send :define_method, :latitude do
              self.the_geom ? self.the_geom.y : nil
            end

            self.class.send :define_method, :longitude do
              self.the_geom ? self.the_geom.x : nil
            end

          end
        rescue Exception => e
          puts e
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

    end
  end
end
