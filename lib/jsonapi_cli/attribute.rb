require 'faker'

module JsonapiCli
  class Property
    attr_reader :options
    attr_reader :generator_method

    def initialize(options = {})
      @options = options
      @generator_method = options.fetch(:generator_method, nil)
    end

    def type
      raise NotImplementedError
    end

    def generate_value(resource)
      raise NotImplementedError
    end

    def value_for(resource)
      generator_method && resource.respond_to?(generator_method) ?
      resource.send(generator_method, self) :
      generate_value(resource)
    end
  end

  class Attribute < Property
    def type
      @type ||= self.class.to_s.split("::").last.chomp("Attribute").downcase
    end
  end

  class StringAttribute < Attribute
    def generate_value(resource)
      Faker::Lorem.word
    end
  end

  class BooleanAttribute < Attribute
    OPTIONS = [true, false]
    def generate_value(resource)
      OPTIONS.sample
    end
  end

  class IntegerAttribute < Attribute
    DEFAULT_RANGE = -1000..1000
    def generate_value(resource)
      rand(DEFAULT_RANGE)
    end
  end

  class NumberAttribute < Attribute
    DEFAULT_RANGE = -1000.0..1000.0
    def generate_value(resource)
      rand(DEFAULT_RANGE)
    end
  end

  class NullAttribute < Attribute
    def generate_value(resource)
      nil
    end
  end

  class ObjectAttribute < Attribute
    class << self
      def generate_object(resource, attributes)
        object = {}
        attributes.each_pair do |key, attribute|
          object[key] = attribute.value_for(resource) 
        end
        object 
      end
    end

    def generate_value(resource)
      ObjectAttribute.generate_object(resource, attributes)
    end

    def attributes
      @attributes ||= options.fetch(:attributes, {})
    end

    def generator_args
      super + [attributes]
    end
  end

  class ArrayAttribute < Attribute
    def attribute
      @attribute ||= options.fetch(:attribute)
    end

    DEFAULT_RANGE = 1...3

    def generate_value(resource)
      num = \
      case resource.list_mode
      when :rand then rand(range)
      when :min  then range.min
      when :max  then range.max + 1
      else 0
      end

      num.times.map do
        attribute.value_for(resource)
      end
    end

    def range
      @range ||= options.fetch(:range, DEFAULT_RANGE)
    end
  end

  class Relationship < Property
    class << self
      def generate_relationships(resource, relationships)
        rels = {}
        relationships.each_pair do |key, relationship|
          rels[key] = {
            "data" => relationship.value_for(resource)
          }
        end
        rels
      end
    end
    DEFAULT_RANGE = 0...3

    def type
      options[:type]
    end

    def generate_value(resource)
      num = \
      case resource.list_mode
      when :rand then rand(range)
      when :min  then range.min
      when :max  then range.max + 1
      else 0
      end

      cache = resource.cache
      resources = cache.resources_by_id(type).values
      related = resources.sample(num)
      
      while related.length < num
        resource_class = cache.resource_class(type)
        related << resource_class.create({}, cache).save
      end

      related
    end

    def range
      @range ||= options.fetch(:range, DEFAULT_RANGE)
    end

    def value_for(resource)
      related_resources = super(resource)

      linkage = related_resources.map do |related_resource|
        {"type" => related_resource.type, "id" => related_resource.id}
      end

      {
        "linkage" => linkage
      }
    end

  end
end
