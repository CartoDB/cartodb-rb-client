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

    end
  end
end
