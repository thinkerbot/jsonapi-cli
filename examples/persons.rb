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

  GENDERS = %w{male female}
  def generate_gender
    GENDERS.sample
  end

  PHONE_TYPES = %w{cell home work}
  def generate_phone_type
    PHONE_TYPES.sample
  end
end
