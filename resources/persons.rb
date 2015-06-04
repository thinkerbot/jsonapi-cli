require 'jsonapi_cli/resource'

class Persons < JsonapiCli::Resource 
  register "http://localhost:3000/persons"

  attribute :first_name
  attribute :last_name
  attribute :gender

  attribute :phones, :array => true do
    attribute :label
    attribute :phone_number
  end

  attribute :address do
    attribute :street, :generator => :generate_street_address
    attribute :city
    attribute :state
  end

  def generate_first_name
    Faker::Name.first_name
  end

  def generate_last_name
    Faker::Name.last_name
  end

  def generate_gender
    I18n.translate("persons.gender").sample
  end

  def generate_label
    I18n.translate("persons.phone_type").sample
  end

  def generate_phone_number
    Faker::PhoneNumber.phone_number
  end

  def generate_street_address
    Faker::Address.street_address
  end

  def generate_city
    Faker::Address.city
  end

  def generate_state
    Faker::Address.state
  end
end
