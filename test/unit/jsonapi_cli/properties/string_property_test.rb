#!/usr/bin/env ruby
require File.expand_path('../../../helper', __FILE__)
require 'jsonapi_cli/properties/string_property'

class JsonapiCli::Properties::StringPropertyTest < Test::Unit::TestCase
  StringProperty = JsonapiCli::Properties::StringProperty

  def setup
    Random.srand(0)
  end

  def resource
    Object.new
  end

  #
  # type
  #

  def test_type_is_string
    property = StringProperty.new
    assert_equal(:string, property.type)
  end

  #
  # generate_value
  #

  def test_generate_value_returns_a_string
    property = StringProperty.new
    assert_equal("eligendi", property.generate_value(resource))
  end
end
