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

      protected

      def attribute(name, options = {}, &block)
        if block_given?
          options[:type] ||= :object
          options[:attributes] = with_attributes({}, &block)
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

    def crud(action, id = nil)
      if id
        case action
        when :create then ["PUT",    url(id), headers(action), payload(id)]
        when :read   then ["GET",    url(id), headers(action), nil]
        when :update then ["PATCH",  url(id), headers(action), payload(id)]
        when :delete then ["DELETE", url(id), headers(action), nil]
        else raise "invalid CRUD action for item: #{action.inspect}"
        end
      else
        case action
        when :create then ["POST", url, headers(action), payload]
        when :read   then ["GET",  url, headers(action), nil]
        else raise "invalid CRUD action for collection: #{action.inspect}"
        end
      end
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
      rand(range).times.map do
        generate_object(attributes)
      end
    end
  end
end
