require 'jsonapi_cli/property'

module JsonapiCli
  module Properties
    class ObjectProperty < Property
      attr_reader :properties

      def initialize(name, options = {})
        super
        @properties = options.fetch(:properties, {})
      end

      def set_property(name, property)
        if properties.has_key?(name)
          raise "property already defined: #{name.inspect}"
        end
        properties[name] = property
        self
      end

      def generate_default_value(resource)
        object = {}
        properties.each_pair do |name, property|
          object[name] = property.generate_value(resource)
        end
        object
      end

      def transform_default_value(resource, value)
        object = {}
        value.each_pair do |name, val|
          object[name] = properties[name].transform_value(resource, val)
        end
        object
      end
    end
  end
end
