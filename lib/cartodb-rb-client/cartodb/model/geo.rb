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

          case geometry_column[:geometry_type].upcase
          when 'POINT'
            self.send :define_method, :the_geom do
              self.attributes[geometry_name]
            end

            self.send :define_method, :the_geom= do |the_geom|
              self.attributes[geometry_name] = the_geom
            end

            setup_point_geometry
          when 'MULTIPOLYGON'
            self.send :define_method, :the_geom do
              self.attributes[geometry_name]
            end

            self.send :define_method, :the_geom= do |the_geom|
              self.attributes[geometry_name] = convert_to_polygon(the_geom)
            end
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

        case self.class.geometry_type
        when 'point'
          longitude = attributes.delete(:longitude)
          latitude = attributes.delete(:latitude)

          attributes[:the_geom] = convert_to_point(latitude, longitude) if latitude && longitude
        when /polygon/
          attributes[:the_geom] = convert_to_polygon(attributes[:the_geom])
        end

        attributes
      end
      private :prepare_geo_attributes

      def convert_to_point(latitude, longitude)
        RGEO_FACTORY.point(longitude, latitude)
      end

      def convert_to_polygon(the_geom)
        case the_geom
        when String
          RGeo::GeoJSON.decode(the_geom, :json_parser => :json, :geo_factory => RGeo::Geographic.spherical_factory(:srid => 4326))
        when Hash
          RGeo::GeoJSON.decode(::JSON.generate(the_geom), :json_parser => :json, :geo_factory => RGeo::Geographic.spherical_factory(:srid => 4326))
        end
      end
      private :convert_to_polygon

    end
  end
end
