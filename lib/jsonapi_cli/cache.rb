module JsonapiCli
  class Cache
    attr_reader :resources

    def initialize
      @resources = {}
      @sequences = {}
    end

    def sequence(type)
      @sequences[type] ||= Enumerator.new do |output|
        curr = 0
        loop do
          output << curr
          curr += 1
        end
      end
    end

    def next_id(type)
      sequence(type).next
    end

    def resources_by_id(type)
      resources[type.to_s] ||= {}
    end

    def fetch(type, id)
      resources_by_id(type)[id]
    end

    def store(resource)
      resources_by_id(resource.type)[resource.id] = resource
    end

    def remove(resource)
      resources_by_id(resource.type).delete(resource.id)
    end

    def each
      return enum_for(:each) unless block_given?

      resources.each_value do |type_cache|
        type_cache.each_value do |resource|
          yield resource
        end
      end
    end
  end
end
