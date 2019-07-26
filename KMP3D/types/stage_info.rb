module KMP3D
  class StageInfo < Type
    def add_to_model(_)
    end

    def add_to_component(_)
    end

    def external_settings
      nil
    end

    def on_external_settings?
      true
    end

    def helper_text
      "Update settings for how the track behaves, e.g. lap count."
    end
  end
end
