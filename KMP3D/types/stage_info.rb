module KMP3D
  class StageInfo < Type
    def transform(comp, _)
      comp.visible = false
      comp
    end

    def on_external_settings?
      true
    end

    def use_points?
      false
    end

    def helper_text
      "Update settings for how the track behaves, e.g. lap count."
    end
  end
end
