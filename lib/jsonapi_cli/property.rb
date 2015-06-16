require 'faker'

module JsonapiCli
  class Property
    class << self
      def type
        @type ||= to_s.split("::").last.chomp("Property").downcase.to_sym
      end
    end

    attr_reader :generator
    attr_reader :transformer

    def initialize(options = {})
      @generator = options.fetch(:generator, nil)
      @transformer = options.fetch(:transformer, nil)
    end

    def type
      self.class.type
    end

    def generate_default_value(resource)
      raise NotImplementedError
    end

    def generate_value(resource)
      generator && resource.respond_to?(generator) ? resource.send(generator, self) : generate_default_value(resource)
    end

    def transform_default_value(resource, value)
      value
    end

    def transform_value(resource, value)
      transformer && resource.respond_to?(transformer) ? resource.send(transformer, self, value) : transform_default_value(resource, value)
    end
  end
end
