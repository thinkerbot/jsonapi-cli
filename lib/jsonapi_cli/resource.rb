require 'jsonapi_cli/attribute'
require 'jsonapi_cli/cache'

module JsonapiCli
  class Resource
    REGISTRY = {}

    class << self
      attr_reader :url
      attr_reader :type

      def register(url, type = nil)
        @url = url
        @type = type || self.to_s.split('::').last.downcase
        Resource::REGISTRY[@type] = self
      end

      def each(&block)
        Resource::REGISTRY.each_value(&block)
      end

      def properties
        @properties ||= {}
      end

      def attributes
        properties.select {|name, property| property.kind_of?(Attribute) }
      end

      def relationships
        properties.select {|name, property| property.kind_of?(Relationship) }
      end

      def inherited(subclass)
        subclass.attributes.merge!(attributes)
      end

      def create(options = {}, cache = Cache.new)
        list_mode = options.fetch(:list_mode, LIST_MODES.first)

        unless LIST_MODES.include?(list_mode)
          raise "invalid list mode: #{list_mode.inspect}"
        end

        new(list_mode, cache)
      end

      def generate_from(generator, *method_names)
        method_names.each do |method_name|
          define_method("generate_#{method_name}") do |attribute|
            generator.send(method_name)
          end
        end
      end

      protected

      def assign_property(name, property)
        name = name.to_s
        if properties.has_key?(name)
          raise "property already defined: #{name.inspect}"
        end
        properties[name] = property
      end

      def attribute(name, options = {}, &block)
        if block_given?
          options[:type] ||= :object
          options[:attributes] = capture_properties({}, &block)
        end

        is_array = options[:array]

        type = options[:type]
        attribute_class = \
        case type
        when :object  then ObjectAttribute
        when :integer then IntegerAttribute
        when :boolean then BooleanAttribute
        when :string, nil  then StringAttribute
        when :null    then NullAttribute
        when :number  then NumberAttribute
        else raise "invalid type: #{type.inspect}"
        end

        subtype = options[:subtype]
        options[:generator_method] = "generate_#{subtype || name}"

        attribute = attribute_class.new(options)
        attribute = ArrayAttribute.new(:attribute => attribute) if is_array
        assign_property(name, attribute)
      end

      def capture_properties(target)
        current = @properties
        begin
          @properties = target
          yield
        ensure
          @properties = current
        end
        target
      end

      def relationship(name, options = {})
        type = options[:type] ||= name
        options[:generator_method] = "pick_#{type || name}"

        relationship = Relationship.new(options)
        assign_property(name, relationship)
      end
    end

    LIST_MODES = [:rand, :min, :max]

    attr_reader :id
    attr_reader :list_mode
    attr_reader :cache

    def initialize(list_mode, cache)
      @id = nil
      @list_mode = list_mode
      @cache = cache
    end

    def url
      id ? File.join(self.class.url, id.to_s) : self.class.url
    end

    def headers(action)
      { 
        'Content-Type' => 'application/vnd.api+json',
        'Accept'       => 'application/vnd.api+json'
      }
    end

    def payload
      {"data" => data}
    end

    def save
      @id = cache.next_id(type)
      relationships
      cache.store(self)
      self
    end

    def delete
      cache.remove(self)
      @id = nil
      self
    end

    def type
      self.class.type
    end

    def attributes
      @attributes ||= ObjectAttribute.generate_object(self, self.class.attributes) 
    end

    def relationships
      @relationships ||= Relationship.generate_relationships(self, self.class.relationships)
    end

    def data
      data = {}
      data["type"] = type
      data["id"]   = id if id
      data["attributes"] = attributes
      data["relationships"] = relationships unless relationships.empty?
      data
    end
  end
end
