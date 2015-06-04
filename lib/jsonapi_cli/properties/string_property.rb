require 'jsonapi_cli/property'
require 'faker'

module JsonapiCli
  module Properties
    class StringProperty < Property
      def generate_default_value(*generator_args)
        Faker::Lorem.word
      end
    end
  end
end
