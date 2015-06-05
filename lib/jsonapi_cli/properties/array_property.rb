require 'jsonapi_cli/property'

module JsonapiCli
  module Properties
    class ArrayProperty < Property
      DEFAULT_SIZE = 0

      attr_reader :size
      attr_reader :property

      def initialize(options = {})
        @size = options.fetch(:size, DEFAULT_SIZE)
        @property = options.fetch(:property)
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

      def generate_default_value(resource)
        next_size(resource).times.map do 
          property.generate_value(resource)
        end
      end

      def transform_value(resource, value)
        value.map do |val|
          property.transform_value(resource, val)
        end
      end
    end
  end
end
