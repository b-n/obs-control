# frozen_string_literal: true

module OBSControl
  module Device
    autoload(:Launchpad,    'obs_control/device/launchpad.rb')
    autoload(:OBS,          'obs_control/device/obs.rb')
    autoload(:Base,         'obs_control/device/base.rb')
  end
end
