require 'jsonapi_cli/property'
require 'faker'

module JsonapiCli
  module Properties
    class StringProperty < Property
      def generate_default_value(resource)
        Faker::Lorem.word
      end
    end
  end
end
