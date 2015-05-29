require 'faker'
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

      def autotype_on
        @autotype = true
      end

      def autotype_off
        @autotype = false
      end

      def autotype?
        @autotype
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
          define_method("generate_#{method_name}") do
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
        elsif autotype?
          options[:type] ||= name
        end

        attribute_class = \
        case options[:type]
        when :object then ObjectAttribute
        when :list   then ListAttribute
        else Attribute
        end

        property = attribute_class.new(options)
        assign_property(name, property)
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
        if autotype?
          options[:type] ||= name
        end

        property = Relationship.new(options)
        assign_property(name, property)
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
      @attributes ||= generate_object(self.class.attributes)
    end

    def relationships
      @relationships ||= generate_relationships(self.class.relationships)
    end

    def data
      data = {}
      data["type"] = type
      data["id"]   = id if id
      data["attributes"] = attributes
      data["relationships"] = relationships unless relationships.empty?
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

    def generate_relationships(relationships)
      rels = {}
      relationships.each_pair do |key, relationship|
        rels[key] = {
          "data" => relationship.value_for(self)
        }
      end
      rels
    end

    def generate_related(type, range)
      num = \
      case list_mode
      when :rand then rand(range)
      when :min  then range.min
      when :max  then range.max + 1
      else 0
      end

      resources = cache.resources_by_id(type).values
      related = resources.sample(num)
      
      while related.length < num
        resource_class = Resource::REGISTRY[type.to_s]
        related << resource_class.create({}, cache).save
      end

      related
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
