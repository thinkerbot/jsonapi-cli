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
    property = Properties.create(:type => :string)
    assert_equal StringProperty, property.class

    property = Properties.create(:type => :integer)
    assert_equal IntegerProperty, property.class
  end

  def test_create_returns_array_property_wrapping_property_if_array_is_true
    property = Properties.create(:array => true, :type => :string)
    assert_equal ArrayProperty, property.class
    assert_equal [StringProperty], property.properties.map(&:class)
  end
end