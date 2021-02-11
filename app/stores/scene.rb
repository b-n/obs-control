# frozen_string_literal: true

module Stores
  class Scene < OBSControl::Store
    def initialize(config)
      @colorSchemes = config.colorSchemes.scene
      @current_scene = ''
      @notes = []
      @scenes = config.scenes.each do |scene|
        @current_scene = scene.name if scene.default
        @notes << scene.note
      end
    end

    def receive(event, payload)
      case event
      when :OBS__Open
        get_current_scene
      when :OBS__SwitchScenes
        scene_changed(payload)
      when :Launchpad__NoteChanged
        set_scene(payload)
      end
    end

    def get_current_scene
      put(:OBS__GetCurrentScene)
        .then do |result|
          @current_scene = result['name']
          draw_scenes
        end
    end

    def set_scene(payload)
      note = payload[:note]
      return unless @notes.include?(note) && payload[:state] == :PRESSED

      scene_name = @scenes.find { |scene| scene.note == note }.name
      @current_scene = scene_name
      put(:OBS__SetCurrentScene, { 'scene-name': scene_name })
      draw_scenes
    end

    def scene_changed(payload)
      @current_scene = payload['scene-name']
      draw_scenes
    end

    def draw_scenes
      @scenes.each do |scene|
        velocity, channel = color_scheme(scene)
        put(
          :Launchpad__NoteOn, 
          {
            note: scene.note,
            channel: channel,
            velocity: velocity
          }
        )
      end
    end

    def color_scheme(scene)
      @colorSchemes[scene.name == @current_scene ? 1 : 0]
    end
  end
end
