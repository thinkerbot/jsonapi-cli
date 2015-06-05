require 'jsonapi_cli/property'

module JsonapiCli
  module Properties
    class BooleanProperty < Property
      OPTIONS = [true, false]
  
      def generate_default_value(resource)
        OPTIONS.sample
      end
    end
  end
end
