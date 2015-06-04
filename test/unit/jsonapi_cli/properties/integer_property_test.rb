#!/usr/bin/env ruby
require File.expand_path('../../../helper', __FILE__)
require 'jsonapi_cli/properties/integer_property'

class JsonapiCli::Properties::IntegerPropertyTest < Test::Unit::TestCase
  IntegerProperty = JsonapiCli::Properties::IntegerProperty

  def setup
    Random.srand(0)
  end

  def resource
    Object.new
  end

  #
  # type
  #

  def test_type_is_integer
    property = IntegerProperty.new
    assert_equal(:integer, property.type)
  end

  #
  # generate_value
  #

  def test_generate_value_returns_a_integer
    property = IntegerProperty.new
    assert_equal(-316, property.generate_value(resource))
  end
end
