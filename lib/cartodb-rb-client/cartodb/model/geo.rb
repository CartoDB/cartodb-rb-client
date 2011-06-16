module CartoDB
  module Model
    module Geo
      include CartoDB::Model::Constants

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        include CartoDB::Model::Constants

        def setup_geometry_column(geometry_column)
          return if geometry_column[:geometry_type].nil?

          geometry_name = geometry_column[:name].to_sym

          self.send :define_method, :the_geom do
            self.attributes[geometry_name]
          end

          self.send :define_method, :the_geom= do |the_geom|
            self.attributes[geometry_name] = the_geom
          end

          case geometry_column[:geometry_type].upcase
          when 'POINT'
            setup_point_geometry
          end
        end
        private :setup_geometry_column

        def setup_point_geometry
          self.send :define_method, :latitude do
            self.the_geom ? self.the_geom.y : nil
          end
          self.send :define_method, :longitude do
            self.the_geom ? self.the_geom.x : nil
          end

          self.send :define_method, :latitude= do |latitude|
            @latitude = latitude
            if @latitude && @longitude
              self.the_geom = RGEO_FACTORY.point(@longitude, @latitude)
            end
          end
          self.send :define_method, :longitude= do |longitude|
            @longitude = longitude
            if @latitude && @longitude
              self.the_geom = RGEO_FACTORY.point(@longitude, @latitude)
            end
          end

        end
        private :setup_point_geometry

      end

      def prepare_geo_attributes(attributes)
        return if attributes.nil?
        longitude = attributes.delete(:longitude)
        latitude = attributes.delete(:latitude)
        if latitude && longitude
          attributes[:the_geom] = RGEO_FACTORY.point(longitude, latitude)
        end

        attributes
      end
      private :prepare_geo_attributes

      def from_geo_json
        RGeo::GeoJSON.decode(the_geom, :json_parser => :json, :geo_factory => RGEO_FACTORY)
      end
      private :from_geo_json

      def to_geo_json
        RGeo::GeoJSON.encode(the_geom)
      end
      private :to_geo_json
    end
  end
end
