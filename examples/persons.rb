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
    attribute :street
    attribute :city
    attribute :state
  end

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

  PHONE_TYPES = %w{cell home work}
  def generate_phone_type
    PHONE_TYPES.sample
  end

  def generate_phone_number
    Faker::PhoneNumber.phone_number
  end

  def generate_street
    Faker::Address.street_address
  end

  def generate_city
    Faker::Address.city
  end

  def generate_state
    Faker::Address.state
  end
end
