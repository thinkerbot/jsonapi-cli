#!/usr/bin/env ruby
require File.expand_path('../../../helper', __FILE__)
require 'jsonapi_cli/properties/array_property'

class JsonapiCli::Properties::ArrayPropertyTest < Test::Unit::TestCase
  ArrayProperty = JsonapiCli::Properties::ArrayProperty

  def setup
    Random.srand(0)
  end

  def resource
    resource = Object.new
    def resource.list_mode
      :rand
    end
    resource
  end

  class ExampleProperty < JsonapiCli::Property
    def initialize(options = {})
      @value = options.fetch(:value)
    end

    def generate_default_value
      @value
    end
  end

  #
  # type
  #

  def test_type_is_array
    property = ArrayProperty.new
    assert_equal(:array, property.type)
  end

  #
  # generate_value
  #

  def test_generate_value_returns_empty_array
    property = ArrayProperty.new
    assert_equal([], property.generate_value(resource))
  end

  def test_generate_value_populates_hash_with_size_property_values
    properties = [
      ExampleProperty.new(:value => "A"),
      ExampleProperty.new(:value => "B"),
    ]
    property = ArrayProperty.new(:size => 3, :properties => properties)

    assert_equal(["A", "B", "A"], property.generate_value(resource))
  end

  def test_generate_value_picks_randomly_within_range_sizes
    properties = [
      ExampleProperty.new(:value => "A"),
      ExampleProperty.new(:value => "B"),
    ]
    property = ArrayProperty.new(:size => 0..10, :properties => properties)

    assert_equal(["A", "B", "A", "B", "A"], property.generate_value(resource))
    assert_equal([], property.generate_value(resource))
    assert_equal(["B", "A", "B"], property.generate_value(resource))
  end
end
