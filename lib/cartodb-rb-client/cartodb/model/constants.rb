module CartoDB
  module Model
    module Constants

      CARTODB_TYPES = {
        String     => 'string',
        Integer    => 'number',
        Numeric    => 'number',
        Date       => 'date',
        DateTime   => 'date',
        TrueClass  => 'boolean',
        FalseClass => 'boolean'
      }.freeze

      INVALID_COLUMNS = [
        :cartodb_id,
        :id
      ].freeze

      GEOMETRY_COLUMN = 'the_geom'.freeze

      RGEO_FACTORY = ::RGeo::Geographic.simple_mercator_factory().freeze

      DEFAULT_ROWS_PER_PAGE = 10.freeze

    end
  end
end
