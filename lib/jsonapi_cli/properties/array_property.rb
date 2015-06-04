require 'jsonapi_cli/property'

module JsonapiCli
  module Properties
    class ArrayProperty < Property
      DEFAULT_SIZE = 1..3

      attr_reader :size
      attr_reader :properties

      def initialize(options = {})
        @size = options.fetch(:size, DEFAULT_SIZE)
        @properties = options.fetch(:properties, [])
      end

      def sizes_enum
        @sizes_enum ||= Enumerator.new do |output|
          loop do
            output << \
            case size
            when Range   then rand(size)
            when Integer then size
            else raise "invalid size: #{size.inspect}"
            end
          end
        end
      end

      def next_size(resource)
        case resource.list_mode
        when :min then size.kind_of?(Integer) ? size : size.min
        when :max then size.kind_of?(Integer) ? size : size.max
        when :rand then sizes_enum.next
        end
      end

      def properties_enum
        @properties_enum ||= properties.cycle
      end

      def generate_default_value(*generator_args)
        []
      end

      def generate_value(resource)
        return generator.call(resource) if generator

        array = generate_default_value
        unless properties.empty?
          next_size(resource).times do
            array << properties_enum.next.generate_value(resource)
          end
        end
        array
      end
    end
  end
end
