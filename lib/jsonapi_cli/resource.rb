require 'jsonapi_cli/properties'
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

      def attributes
        @attributes ||= Properties::ObjectProperty.new("attributes")
      end

      def relationships
        @relationships ||= Properties::ObjectProperty.new("relationships")
      end

      def create(options = {}, cache = Cache.new)
        list_mode = options.fetch(:list_mode, LIST_MODES.first)

        unless LIST_MODES.include?(list_mode)
          raise "invalid list mode: #{list_mode.inspect}"
        end

        new(list_mode, cache)
      end

      protected

      def capture_to(target)
        current = @attributes
        begin
          @attributes = target
          yield
        ensure
          @attributes = current
        end
        target
      end

      def attribute(name, options = {}, &block)
        options[:generator] ||= "generate_#{name}".to_sym
        options[:transformer] ||= "transform_#{name}".to_sym

        if block_given?
          size = options.delete(:size)

          options[:type] = :object
          property = Properties.create(name, options)
          capture_to(property, &block)

          if size
            property = Properties::ArrayProperty.new("#{name}[]", :size => size, :property => property)
          end
        else
          property = Properties.create(name, options)
        end

        attributes.properties[name] = property
      end

      def relationship(name, options = {})
        options[:type] ||= name
        options[:picker] ||= "pick_#{name}".to_sym
        relationships.properties[name] = Properties::RelationshipProperty.new(name, options)
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

    def identifier
      {"type" => type, "id" => id}
    end

    def object(include_relationships = true)
      data = {}
      data["type"] = type
      data["id"] = id
      data["attributes"] = attributes

      if include_relationships && !relationships.values.flatten.empty?
        data["relationships"] = self.class.relationships.generate_value(self) 
      end

      {"data" => data}
    end

    def request(include_relationships = true)
      data = {}
      data["type"] = type
      data["attributes"] = attributes

      if include_relationships && !relationships.values.flatten.empty?
        data["relationships"] = self.class.relationships.generate_value(self) 
      end

      {"data" => data}
    end

    def response(include_relationships = true)
      data = {}
      data["type"] = type
      data["id"]   = id
      data["attributes"] = self.class.attributes.transform_value(self, attributes)

      if include_relationships && !relationships.values.flatten.empty?
        data["relationships"] = self.class.relationships.generate_value(self) 
      end

      {"data" => data}
    end

    def save
      @id = cache.next_id(type)
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
      @attributes ||= self.class.attributes.generate_value(self)
    end

    def relationships
      @relationships ||= Hash.new {|hash, key| hash[key] = []}
    end

    def inspect
      "<#{type}:#{id}>"
    end
  end
end
