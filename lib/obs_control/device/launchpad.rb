# frozen_string_literal: true

module OBSControl
  module Device
    class Launchpad < OBSControl::Device::Base

      def initialize
        @midi_input = UniMIDI::Input.use(1)
        @midi_output = UniMIDI::Output.use(1)
      end

      def start
        MIDIEye::Listener.new(@midi_input).tap do |listener|
          listener.listen_for do |event|
            message = event[:message]
            if message.is_a?(MIDIMessage::ControlChange)
              notify(
                :Launchpad__ControlChange,
                { note: message.index, state: press_or_release(message.value) }
              )
            else
              notify(
                :Launchpad__NoteChanged,
                { note: message.note, state: press_or_release(message.velocity) }
              )
            end
          end
          notify(:Launchpad__Open)
        end.run(background: true)
      end

      def handles?(event)
        %i[Launchpad__NoteOn Launchpad__NoteOff].include?(event)
      end

      def send(event, payload)
        note = payload[:note]
        velocity = payload[:velocity]
        channel = payload.fetch(:channel, 1)

        @midi_output.puts(MIDIMessage::NoteOn.new(
          channel,
          note,
          velocity
        ))
      end

      private

      def press_or_release(value)
        value == 127 ? :PRESSED : :RELEASED
      end
    end
  end
end
