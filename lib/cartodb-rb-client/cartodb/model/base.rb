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
        self.class.table_name    = nil
        @attributes              = attributes
        update_cartodb_schema
      end

    end
  end
end