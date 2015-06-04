require 'jsonapi_cli/property'

module JsonapiCli
  module Properties
    class ObjectProperty < Property
      attr_reader :properties

      def initialize(options = {})
        @properties = options.fetch(:properties, {})
      end

      def set_property(name, property)
        if properties.has_key?(name)
          raise "property already defined: #{name.inspect}"
        end
        properties[name] = property
        self
      end

      def generate_default_value(*generator_args)
        {}
      end

      def generate_value(resource)
        return generator.call(resource) if generator

        object = generate_default_value
        properties.each_pair do |name, property|
          object[name] = property.generate_value(resource)
        end
        object 
      end
    end
  end
end
