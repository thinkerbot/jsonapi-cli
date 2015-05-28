require 'jsonapi_cli/resource'

module JsonapiCli
  class Config
    class << self
      def options(overrides = {})
        {
          :seed        => ENV['JSONAPI_SEED'] || Random.srand,
          :load_path   => ENV['JSONAPI_LOAD_PATH'] || 'resources',
          :locale_path => ENV['JSONAPI_LOCALE_PATH'] || 'locales',
        }.merge(overrides)
      end

      def create(options = {})
        options = self.options(options)
        config  = {}

        load_path = options[:load_path]
        config[:resource_dirs] = load_path.split(":")

        locale_path = options[:locale_path]
        config[:locale_dirs] = locale_path.split(":")

        config[:seed] = options[:seed].to_i

        new(config)
      end
    end

    attr_reader :resource_dirs
    attr_reader :locale_dirs
    attr_reader :seed
    attr_reader :cache

    def initialize(config = {})
      @resource_dirs  = config.fetch(:resource_dirs) { [] }
      @locale_dirs    = config.fetch(:locale_dirs) { [] }
      @seed           = config.fetch(:seed, 0)
      @cache          = Cache.new
    end

    def resource_files
      files = []
      resource_dirs.each do |dir|
        Dir[File.join(dir, "**", "*.rb")].each do |file|
          files << File.expand_path(file)
        end
      end
      files
    end

    def locale_files
      files = []
      locale_dirs.each do |dir|
        Dir[File.join(dir, "**", "*.yml")].each do |file|
          files << File.expand_path(file)
        end
      end
      files
    end

    def setup
      locale_files.each do |file|
        I18n.load_path << file
      end

      resource_files.each do |file|
        require file
      end

      Random.srand(seed)

      self
    end
  end
end
