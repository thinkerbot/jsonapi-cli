require 'jsonapi_cli/property'

module JsonapiCli
  module Properties
    class NullProperty < Property
      def generate_default_value(resource)
        nil
      end
    end
  end
end
