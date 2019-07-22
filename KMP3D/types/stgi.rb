module KMP3D
  class STGI < Type
    def initialize
      @name = "Stage Info"
      @settings = [Settings.new(:float, "Size", "25.0")]
      super
    end

    def add_to_model(_)
    end

    def add_to_component(_)
    end

    def save_settings

    end
  end
end
