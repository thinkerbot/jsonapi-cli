require 'jsonapi_cli/resource'
require File.expand_path("../persons.rb", __FILE__)

class Groups < JsonapiCli::Resource
  register "http://localhost:3000/groups"

  attribute :name
  relationship :members, :type => :persons, :range => 0..3

  generate_from Faker::Name, :name
end
