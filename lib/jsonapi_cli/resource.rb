require 'faker'
require 'jsonapi_cli/attribute'

module JsonapiCli
  class Resource
    class << self
      REGISTRY = []

      attr_reader :url
      attr_reader :type

      def register(url, type = nil)
        @url = url
        @type = type || self.to_s.split('::').last.downcase
        REGISTRY << self
      end

      def each(&block)
        REGISTRY.each(&block)
      end

      def attributes
        @attributes ||= {}
      end

      def inherited(subclass)
        subclass.attributes.merge!(attributes)
      end

      def autotype_on
        @autotype = true
      end

      def autotype_off
        @autotype = false
      end

      def autotype?
        @autotype
      end

      def create(options = {})
        list_mode = options.fetch(:list_mode, LIST_MODES.first)

        unless LIST_MODES.include?(list_mode)
          raise "invalid list mode: #{list_mode.inspect}"
        end

        new(list_mode)
      end

      def generate_from(generator, *method_names)
        method_names.each do |method_name|
          define_method("generate_#{method_name}") do
            generator.send(method_name)
          end
        end
      end

      protected

      def attribute(name, options = {}, &block)
        if block_given?
          options[:type] ||= :object
          options[:attributes] = with_attributes({}, &block)
        elsif autotype?
          options[:type] ||= name
        end

        attribute_class = \
        case options[:type]
        when :object then ObjectAttribute
        when :list   then ListAttribute
        else Attribute
        end

        attributes[name] = attribute_class.new(options)  
      end

      def with_attributes(new_attributes)
        current = @attributes
        begin
          @attributes = new_attributes
          yield
        ensure
          @attributes = current
        end
        new_attributes
      end
    end

    LIST_MODES = [:rand, :min, :max]

    attr_reader :list_mode

    def initialize(list_mode)
      @list_mode = list_mode
    end

    def url(id = nil)
      id ? File.join(self.class.url, id.to_s) : self.class.url
    end

    def headers(action)
      { 
        'Content-Type' => 'application/vnd.api+json',
        'Accept'       => 'application/vnd.api+json'
      }
    end

    def payload(id = nil)
      {"data" => data(id)}
    end

    def type
      self.class.type
    end

    def attributes
      @attributes ||= generate_object(self.class.attributes)
    end

    def data(id = nil)
      data = {}
      data["type"] = type
      data["id"]   = id if id
      data["attributes"] = attributes
      data
    end

    def generate_field
      Faker::Lorem.word
    end

    def generate_object(attributes)
      object = {}
      attributes.each_pair do |key, attribute|
        object[key] = attribute.value_for(self) 
      end
      object 
    end

    def generate_list(attributes, range)
      num = \
      case list_mode
      when :rand then rand(range)
      when :min  then range.min
      when :max  then range.max + 1
      else 0
      end

      num.times.map do
        generate_object(attributes)
      end
    end

    def method_missing(m, *args, &block)
      super unless m =~ /^generate_(.*)/
      type = $1
      key  = self.class.to_s.split("::").map(&:downcase)
      key << type
      if translation = Faker::Base.translate(key.join('.'))
        translation.respond_to?(:sample) ? translation.sample : translation
      else
        super
      end
    end
  end
end
