require 'jsonapi_cli/resource'

class Persons < JsonapiCli::Resource 
  register "http://localhost:3000/persons"

  attribute :first_name
  attribute :last_name
  attribute :gender

  attribute :phones, :array => true do
    attribute :label, :subtype => :phone_type
    attribute :phone_number
  end

  attribute :address do
    attribute :street, :subtype => :street_address
    attribute :city
    attribute :state
  end

  generate_from Faker::Name, :first_name, :last_name
  generate_from Faker::PhoneNumber, :phone_number
  generate_from Faker::Address, :street_address, :city, :state

  def generate_phone_type(attribute)
    Faker::Base.translate("persons.phone_type").sample
  end

  def generate_gender(attribute)
    Faker::Base.translate("persons.gender").sample
  end
end
