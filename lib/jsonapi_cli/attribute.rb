module JsonapiCli
  class Attribute
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def type
      @type ||= options.fetch(:type, :field)
    end

    def generator_method
      @generator_method ||= "generate_#{type}".to_sym
    end

    def generator_args
      []
    end

    def value_for(resource)
      resource.send(generator_method, *generator_args)
    end

    def inspect
      "<#{type}>"
    end
  end

  class ObjectAttribute < Attribute
    def attributes
      @attributes ||= options.fetch(:attributes, {})
    end

    def generator_args
      super + [attributes]
    end

    def inspect
      "<#{type} - #{attributes.inspect}>"
    end
  end

  class ListAttribute < ObjectAttribute
    DEFAULT_RANGE = 1...3

    def range
      @range ||= options.fetch(:range, DEFAULT_RANGE)
    end

    def generator_args
      super + [range]
    end

    def inspect
      "<#{type} - #{attributes.inspect}>"
    end
  end
end
