require 'faker'
require 'jsonapi_cli/attribute'

module JsonapiCli
  class Resource
    class << self
      REGISTRY = []

      attr_reader :url
      attr_reader :name

      def register(url, name = nil)
        @url = url
        @name = name || self.to_s.split('::').last.downcase
        REGISTRY << self
      end

      def each(&block)
        REGISTRY.each(&block)
      end

      def attributes
        @attributes ||= {}
      end

      protected

      def attribute(name, options = {})
        attributes[name] = Attribute.new(options)
      end
    end

    def attributes
      @attributes ||= _generate_attributes
    end

    def _generate_attributes
      attributes = {}
      self.class.attributes.each_pair do |name, attribute|
        generator_method = "generate_#{attribute.type}"
        attributes[name] = send(generator_method)
      end
      attributes
    end

    def generate_field
      Faker::Lorem.word
    end
  end
end
