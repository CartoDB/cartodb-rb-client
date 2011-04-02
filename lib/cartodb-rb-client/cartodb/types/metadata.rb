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

        super(key, value)
      end

    end
  end
end