#!/usr/bin/env ruby
require File.expand_path('../../../helper', __FILE__)
require 'jsonapi_cli/properties/boolean_property'

class JsonapiCli::Properties::BooleanPropertyTest < Test::Unit::TestCase
  BooleanProperty = JsonapiCli::Properties::BooleanProperty

  def setup
    Random.srand(0)
  end

  def resource
    Object.new
  end

  #
  # type
  #

  def test_type_is_boolean
    property = BooleanProperty.new
    assert_equal(:boolean, property.type)
  end

  #
  # generate_value
  #

  def test_generate_value_returns_a_boolean
    property = BooleanProperty.new
    assert_equal(true, property.generate_value(resource))
  end
end
