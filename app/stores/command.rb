# frozen_string_literal: true

module Stores
  class Command < OBSControl::Store
    def initialize(config)
      @colorScheme = config.colorSchemes.command
      @notes = []
      @commands = config.commands.each do |command|
        @notes << command.note
      end
    end

    def receive(event, payload)
      case event
      when :Launchpad__Open
        init_stage
      when :Launchpad__NoteChanged
        call_command(payload)
      end
    end

    def call_command(payload)
      note = payload[:note]
      return unless @notes.include?(note)

      command = @commands.find { |command| command.note == note }
      set_color(command, payload[:state])

      return if payload[:state] == :RELEASED

      put(command.name.to_sym, command.payload.to_h)
    end

    def init_stage
      @commands.each do |command|
        set_color(command, :RELEASED)
      end
    end
 
    def set_color(command, state = :PRESSED)
      put(:Launchpad__NoteOn, note_payload(command, state == :PRESSED ? 1 : 0))
    end

    def note_payload(command, state = 0)
      velocity, channel = command.color? ? command.color[state] : @colorScheme[state]
      {
        note: command.note,
        velocity: velocity,
        channel: channel 
      }
    end
  end
end
