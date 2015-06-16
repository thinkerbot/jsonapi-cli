#!/usr/bin/env ruby
require File.expand_path('../../../helper', __FILE__)
require 'jsonapi_cli/properties/null_property'

class JsonapiCli::Properties::NullPropertyTest < Test::Unit::TestCase
  NullProperty = JsonapiCli::Properties::NullProperty

  def resource
    Object.new
  end

  #
  # type
  #

  def test_type_is_null
    property = NullProperty.new "name"
    assert_equal(:null, property.type)
  end

  #
  # generate_value
  #

  def test_generate_value_returns_a_null
    property = NullProperty.new "name"
    assert_equal(nil, property.generate_value(resource))
  end
end
