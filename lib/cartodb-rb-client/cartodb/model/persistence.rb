module CartoDB
  module Model
    module Persistence
      include CartoDB::Model::Constants

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def create(attributes = {})
          model = self.new attributes
          model.save
          model
        end

      end

      def save
        if new_record?
          create_row
        else
          update_row
        end
      end

      def destroy
        unless new_record?
          delete_row
        end
      end

      def new_record?
        cartodb_id.nil? || cartodb_id <= 0
      end

      def create_row
        # only the columns defined in the model are valid to create
        row = attributes.symbolize_keys.reject{|key,value| INVALID_COLUMNS.include?(key)}.select{|key,value| column_names.include?(key.to_s) }
        record_count = count
        inserted_record = connection.insert_row table_name, row
        @count = record_count + 1
        self.cartodb_id = inserted_record.id
      end
      private :create_row

      def update_row
        row = attributes.select{|key,value| column_names.include?(key.to_s) }
        connection.update_row table_name, cartodb_id, row
      end
      private :update_row

      def delete_row
        connection.delete_row table_name, cartodb_id
      end
      private :delete_row

    end
  end
end
