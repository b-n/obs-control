module OBSControl
  class Store
    def devices=(devices)
      @devices = devices
      @devices.each do |device|
        device.register -> (event, payload) { receive(event, payload) }
      end
    end

    # Called when an event is fired either by a device
    #
    # @param event [Symbol] The event being fired
    # @param payload [Hash] Information from the events
    #
    # @return nil
    def receive(event, payload)
      raise 'Implement a receive method in your store'
    end

    # Send a particular event. Will return with the value from the first device that
    # responds to this event
    # 
    # @param event [Symbol] the event to fire
    # @param payload [Hash] additional parameters that may be required
    #
    # @returns Dependent on implementation
    def put(event, payload = {})
      result = @devices.lazy.map do |device|
        device.handles?(event) && device.send(event, payload)
      end.find(&:itself)
      raise "Event: #{event} not implemented" if result.nil?

      result
    end
  end
end
