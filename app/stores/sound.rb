# frozen_string_literal: true

module Stores
  class Sound < OBSControl::Store
    def initialize(config)
      @notes = []
      @sounds = config.sounds.each { |sound| @notes << sound.note }
      @colorScheme = config.colorSchemes.sound
    end

    def receive(event, payload)
      case event
      when :Launchpad__Open
        init_stage
      when :Launchpad__NoteChanged
        play_sound(payload)
      end
    end

    def play_sound(payload)
      note = payload[:note]
      return unless @notes.include?(note) && payload[:state] == :PRESSED

      sound = @sounds.find { |sound| sound.note == note }
      Concurrent::Promise.execute do
        put(:Launchpad__NoteOn, note_payload(sound, 1))
        result = system(sound.command)
      end
        .then { |result| sleep(sound.millis / 1000) }
        .then { |result| put(:Launchpad__NoteOn, note_payload(sound, 0)) }
    end

    def init_stage
      @sounds.each do |sound|
        put(:Launchpad__NoteOn, note_payload(sound))
      end
    end

    def note_payload(sound, state = 0)
      velocity, channel = sound.color? ? sound.color[state] : @colorScheme[state]
        
      {
        note: sound.note,
        velocity: velocity,
        channel: channel 
      }
    end
  end
end
