require 'jsonapi_cli/resource'

class Persons < JsonapiCli::Resource
  register "http://localhost:3000"

  attribute :first_name, :type => :first_name
  attribute :last_name, :type => :last_name
  attribute :gender, :type => :gender

  def generate_first_name
    Faker::Name.first_name
  end

  def generate_last_name
    Faker::Name.last_name
  end

  GENDERS = %w{male female}
  def generate_gender
    GENDERS.sample
  end
end
