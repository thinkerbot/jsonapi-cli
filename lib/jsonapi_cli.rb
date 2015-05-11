require "jsonapi_cli/version"

module JsonapiCli
  module_function

  def version
    "jsonapi_cli version %s (%s)" % [VERSION, RELDATE]
  end
end
