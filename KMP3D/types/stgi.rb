module KMP3D
  class STGI < Type
    def initialize
      @name = "Stage Info"
      @external_settings = [
        Settings.new(:int16, "Lap count", "3"),
        Settings.new(:int16, "Pole position", "0"),
        Settings.new(:int16, "Driver distance", "0"),
        Settings.new(:float, "Speed", "0")
      ]
      super
    end

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
  end
end
