require "jsonapi_cli/config"
require "jsonapi_cli/version"

module JsonapiCli
  module_function

  def options(overrides = {})
    Config.options(overrides)
  end

  def setup(options = {})
    Config.create(options).setup
  end

  def version
    "jsonapi_cli version %s (%s)" % [VERSION, RELDATE]
  end
end
