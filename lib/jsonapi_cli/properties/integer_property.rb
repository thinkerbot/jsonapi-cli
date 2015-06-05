require 'jsonapi_cli/property'

module JsonapiCli
  module Properties
    class IntegerProperty < Property
      DEFAULT_RANGE = -1000..1000

      def generate_default_value(resource)
        rand(DEFAULT_RANGE)
      end
    end
  end
end
