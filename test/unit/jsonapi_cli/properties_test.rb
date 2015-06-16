#!/usr/bin/env ruby
require File.expand_path('../../helper', __FILE__)
require 'jsonapi_cli/properties'

class JsonapiCli::PropertiesTest < Test::Unit::TestCase
  Properties = JsonapiCli::Properties
  include Properties

  def setup
    Random.srand(0)
  end

  #
  # create
  #

  def test_create_returns_property_for_simple_types
    property = Properties.create("name", :type => :string)
    assert_equal StringProperty, property.class

    property = Properties.create("name", :type => :integer)
    assert_equal IntegerProperty, property.class
  end
end
