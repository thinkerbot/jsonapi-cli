module JsonapiCli
  class Attribute
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def type
      @type ||= options.fetch(:type, :field)
    end
  end
end
