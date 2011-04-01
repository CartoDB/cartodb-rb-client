module CartoDB
  module Model
    module Query

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def all
          scope = Scope.new(self)
          scope.all
        end

        def where(attributes = nil, *rest)
          scope = Scope.new(self)
          scope.where(attributes, rest)
        end

        def find(id)
          where(id)
        end

        def count
          begin
            results = connection.query "SELECT COUNT(CARTODB_ID) FROM #{table_name}"
            results.rows.first[:count]
          rescue Exception => e
            0
          end
        end

      end

      def count
        self.class.count
      end

      def count=(ammount)
        self.class.count= ammount
      end

    end
  end
end
