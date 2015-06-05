#!/usr/bin/env ruby
require File.expand_path('../../../helper', __FILE__)
require 'jsonapi_cli/properties/object_property'

class JsonapiCli::Properties::ObjectPropertyTest < Test::Unit::TestCase
  ObjectProperty = JsonapiCli::Properties::ObjectProperty

  def resource
    Object.new
  end

  class ExampleProperty < JsonapiCli::Property
    def initialize(options = {})
      @value = options.fetch(:value)
    end
    
    def generate_default_value(resource)
      @value
    end
  end

  #
  # type
  #

  def test_type_is_object
    property = ObjectProperty.new
    assert_equal(:object, property.type)
  end

  #
  # generate_value
  #

  def test_generate_value_returns_empty_hash
    property = ObjectProperty.new
    assert_equal({}, property.generate_value(resource))
  end

  def test_generate_value_populates_hash_with_property_values
    properties = {
      "a" => ExampleProperty.new(:value => "A"),
      "b" => ExampleProperty.new(:value => "B"),
    }
    property = ObjectProperty.new(:properties => properties)

    assert_equal({
      "a" => "A",
      "b" => "B",
    }, property.generate_value(resource))
  end
end
