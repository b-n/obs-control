module OBSControl
  module Device
    class Base
      def register(callback)
        listeners << callback
      end

      def notify(event, payload = {})
        listeners.each do |listener|
          listener.call(event, payload)
        end
      end

      def handles?(event)
        raise 'Device needs to implement a handles? method'
      end

      def listeners
        @listeners ||= []
      end
    end
  end
end
