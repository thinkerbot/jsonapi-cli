require 'jsonapi_cli/resource'
require File.expand_path("../persons.rb", __FILE__)

class Groups < JsonapiCli::Resource
  register "http://localhost:3000/groups"

  attribute :name
  relationship :members, :type => :persons, :size => 0..3
  
  def generate_name
    Faker::Name.name
  end
end
