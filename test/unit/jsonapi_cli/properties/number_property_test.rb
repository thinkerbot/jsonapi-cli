#!/usr/bin/env ruby
require File.expand_path('../../../helper', __FILE__)
require 'jsonapi_cli/properties/number_property'

class JsonapiCli::Properties::NumberPropertyTest < Test::Unit::TestCase
  NumberProperty = JsonapiCli::Properties::NumberProperty

  def setup
    Random.srand(0)
  end

  def resource
    Object.new
  end

  #
  # type
  #

  def test_type_is_number
    property = NumberProperty.new
    assert_equal(:number, property.type)
  end

  #
  # generate_value
  #

  def test_generate_value_returns_a_number
    property = NumberProperty.new
    assert_equal(97.62700488457676, property.generate_value(resource))
  end
end
