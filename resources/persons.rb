require 'jsonapi_cli/resource'

class Persons < JsonapiCli::Resource 
  register "http://localhost:3000/persons", "persons"

  attribute :first_name
  attribute :last_name
  attribute :gender

  attribute :phones, :size => 1..3 do
    attribute :label
    attribute :phone_number
  end

  attribute :address do
    attribute :street, :generator => :generate_street_address
    attribute :city
    attribute :state
  end

  relationship :group, :type => :groups, :size => 0..1, :related_name => :members
  
  def generate_first_name(property)
    Faker::Name.first_name
  end

  def generate_last_name(property)
    Faker::Name.last_name
  end

  def generate_gender(property)
    I18n.translate("persons.gender").sample
  end

  def generate_label(property)
    I18n.translate("persons.phone_type").sample
  end

  def generate_phone_number(property)
    Faker::PhoneNumber.phone_number
  end

  def transform_phone_number(property, value)
    value.gsub(/\w/, "x")
  end

  def generate_street_address(property)
    Faker::Address.street_address
  end

  def generate_city(property)
    Faker::Address.city
  end

  def generate_state(property)
    Faker::Address.state
  end

  def pick_group(property, resources)
    resources.sample
  end
end
