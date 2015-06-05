require 'jsonapi_cli/properties/array_property'
require 'jsonapi_cli/properties/boolean_property'
require 'jsonapi_cli/properties/integer_property'
require 'jsonapi_cli/properties/null_property'
require 'jsonapi_cli/properties/number_property'
require 'jsonapi_cli/properties/object_property'
require 'jsonapi_cli/properties/string_property'
require 'jsonapi_cli/properties/relationship_property'

module JsonapiCli
  module Properties
    module_function

    def lookup(type)
      case type
      when :object  then ObjectProperty
      when :integer then IntegerProperty
      when :boolean then BooleanProperty
      when :string, nil  then StringProperty
      when :null    then NullProperty
      when :number  then NumberProperty
      else raise "invalid type: #{type.inspect}"
      end
    end

    def create(options = {})
      type = options.delete(:type)
      property_class = lookup(type)
      property_class.new(options)
    end
  end
end
