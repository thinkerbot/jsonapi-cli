require 'jsonapi_cli/property'

module JsonapiCli
  module Properties
    class RelationshipProperty < Property
      DEFAULT_SIZE = 0..3

      attr_reader :type
      attr_reader :size
      attr_reader :picker
      attr_reader :related_name

      def initialize(options = {})
        super
        @type = options.fetch(:type)
        @related_name = options.fetch(:related_name, nil)
        @size = options.fetch(:size, DEFAULT_SIZE)
        @picker = options.fetch(:picker, nil)
      end

      def sizes_enum
        @sizes_enum ||= Enumerator.new do |output|
          loop do
            output << rand(size)
          end
        end
      end

      def related_relationship(resource)
        related_name ? Resource::REGISTRY[type.to_s].relationships.properties[related_name] : nil
      end

      def generate_picks(resource)
        sizes_enum.next.times.map do |index|
          [resource, self, index]
        end
      end

      def pick_still_needed?(resource, index)
        resource.relationships[self][index].nil?
      end

      def pickable?(resource)
        resource.relationships[self].compact.length < size.max
      end

      def pick_default_resources(pickable_resources)
        if pickable_resources.empty?
          raise "not enough resources of type: #{type.inspect}"
        end

        pickable_resources.sample
      end

      def assign_pick(resource, related_resource, index = nil)
        relationships = resource.relationships[self]

        index ||= (relationships.index(:nil?) || relationships.length)
        relationships[index] = related_resource
      end

      def already_picked?(resource, related_resource)
        resource.relationships[self].include?(related_resource)
      end

      def pick_resource(resource)
        pickable_resources = resource.cache.resources_of_type(type).select do |related_resource|
          !already_picked?(resource, related_resource)
        end

        if related_relationship = self.related_relationship(resource)
          pickable_resources = pickable_resources.select do |related_resource|
            related_relationship.pickable?(related_resource)
          end
        end

        if pickable_resources.empty? && resource.relationships[self].compact.length >= size.min
          nil
        else
          picker && resource.respond_to?(picker) ? resource.send(picker, pickable_resources) : pick_default_resources(pickable_resources)
        end
      end

      def process_pick(resource, index)
        if pick_still_needed?(resource, index)
          if related_resource = pick_resource(resource)
            assign_pick(resource, related_resource, index)
 
            if related_relationship = self.related_relationship(resource)
              related_relationship.assign_pick(related_resource, resource)
            end
          end
        end
      end

      def arrayify?
        size == 1 ? false : true
      end

      def generate_default_value(related_resources)
        data = []

        related_resources.each do |related_resource|
          data << {"type" => related_resource.type, "id" => related_resource.id}
        end

        if ! arrayify?
          data = data.first
        end

        {
          "data" => data
        }
      end

      def generator_args(resource)
        [resource.relationships[self]]
      end
    end
  end
end
