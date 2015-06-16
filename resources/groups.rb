require 'jsonapi_cli/resource'
require File.expand_path("../persons.rb", __FILE__)

class Groups < JsonapiCli::Resource
  register "http://localhost:3000/groups"

  attribute :name
  relationship :members, :type => :persons, :size => 1..3, :related_name => :group
  
  def generate_name(property)
    Faker::Name.name
  end
end
