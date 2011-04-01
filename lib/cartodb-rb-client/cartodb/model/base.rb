module CartoDB
  module Model
    class Base
      include CartoDB::Model::AttributeMethods::Getters
      include CartoDB::Model::AttributeMethods::Setters
      include CartoDB::Model::Schema
      include CartoDB::Model::Persistence
      include CartoDB::Model::Query

      def initialize(attributes = {})
        self.class.cartodb_table = nil
        @attributes              = attributes
        self.class.send(:update_cartodb_schema) unless schema_synchronized?
      end

    end
  end
end