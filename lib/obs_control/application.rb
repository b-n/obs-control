# frozen_string_literal: true

module OBSControl
  class Application
    def start!(stores)
      @devices = [
        OBSControl::Device::Launchpad.new,
        OBSControl::Device::OBS.new
      ]

      stores.each do |store|
        store.devices = @devices
      end

      run
    end

    def run
      trap("TERM") { stop }
      trap("INT") { stop }

      EM.epoll
      EM.run do
        @devices.each { |device| device.start }
      end
    end

    def stop
      puts "Terminating"
      EventMachine.stop
    end
  end
end
