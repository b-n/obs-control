# frozen_string_literal: true

require 'recursive-open-struct'
require 'stores/scene'
require 'stores/sound'
require 'stores/command'

class Application < OBSControl::Application
  def initialize
    start! [
      Stores::Scene.new(config),
      Stores::Sound.new(config),
      Stores::Command.new(config)
    ]
  end

  def config
    RecursiveOpenStruct.new(YAML.load_file('config/config.yml'), recurse_over_arrays: true)
  end
end
