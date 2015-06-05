require 'jsonapi_cli/property'

module JsonapiCli
  module Properties
    class NumberProperty < Property
      DEFAULT_RANGE = -1000.0..1000.0

      def generate_default_value(resource)
        rand(DEFAULT_RANGE)
      end
    end
  end
end
