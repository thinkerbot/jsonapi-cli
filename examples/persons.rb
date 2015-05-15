require 'jsonapi_cli/resource'

class Persons < JsonapiCli::Resource
  register "http://localhost:3000/persons"
  autotype_on

  attribute :first_name
  attribute :last_name
  attribute :gender

  attribute :phones, :type => :list do
    attribute :label, :type => :phone_type
    attribute :phone_number
  end

  attribute :address do
    attribute :street, :type => :street_address
    attribute :city
    attribute :state
  end

  generate_from Faker::Name, :first_name, :last_name
  generate_from Faker::PhoneNumber, :phone_number
  generate_from Faker::Address, :street_address, :city, :state
end
