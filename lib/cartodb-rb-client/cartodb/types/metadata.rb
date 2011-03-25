module CartoDB
  module Types
    class Metadata < Hash

      def method_missing(name, *args, &block)
        if args.empty? && block.nil? && self.has_key?(name)
          self[name]
        elsif args.count == 1 && block.nil? && name.to_s.ends_with?('=') && self.has_key?(name[0..-2].to_sym)
          self[name[0..-2].to_sym] = args.first
        else
          super
        end
      end

    end
  end
end