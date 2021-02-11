# frozen_string_literal: true

require 'json'

module OBSControl
  module Device
    class OBS < OBSControl::Device::Base
      def initialize
        @message_counter = 0
        @messages = {}
      end

      def start
        @ws ||= WebSocket::EventMachine::Client.connect(uri: 'ws://localhost:4444')

        @ws.onopen do
          puts 'Connected'
          notify(:OBS__Open)
        end

        @ws.onmessage do |msg, _|
          message = JSON.parse(msg)
          message_id = message['message-id']

          next @messages[message_id] = message unless message_id.nil?

          message_type = message['update-type']
          event_name = "OBS__#{message_type}".to_sym
          notify(event_name, message)
        end

        @ws.onclose do
          notify(:OBS__Close)
          puts "Disconnected"
        end

        @ws.onerror do |e|
          notify(:OBS__Error, e)
          puts "Errored: #{e}"
        end
      end

      def handles?(event)
        %i[
          OBS__GetSceneList
          OBS__SetCurrentScene
          OBS__GetCurrentScene
          OBS__SetTextFreetype2Properties
        ].include?(event)
      end

      def send(event, data = {})
        _, type = event.to_s.split('__', 2)

        @message_counter += 1
        data['request-type'] = type
        data['message-id'] = "#{@message_counter}"
        Concurrent::Promise.execute do
          @ws.send(data.to_json)
          loop do
            break if @messages["#{@message_counter}"]
            sleep 0.01
          end
          result = @messages["#{@message_counter}"]
        end.rescue { |e| 'Sending websocket failed!' }
      end
    end
  end
end
