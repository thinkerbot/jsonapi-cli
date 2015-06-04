require 'faker'

module JsonapiCli
  class Property
    class << self
      def type
        @type ||= to_s.split("::").last.chomp("Property").downcase.to_sym
      end
    end

    attr_reader :generator

    def initialize(options = {})
      @generator = options.fetch(:generator, nil)
    end

    def type
      self.class.type
    end

    def generate_default_value(*generator_args)
      raise NotImplementedError
    end

    def generator_args(resource)
      []
    end

    def generate_value(resource)
      args = generator_args(resource)
      generator && resource.respond_to?(generator) ? resource.send(generator, *args) : generate_default_value(*args)
    end
  end
end
