module KMP3D
  class STGI < Type
    def initialize
      @name = "Stage Info"
      @external_settings = [
        Settings.new(:text, :byte, "Lap Count", "3"),
        Settings.new(:text, :byte, "Pole Position", "0"),
        Settings.new(:text, :byte, "Driver Distance", "0"),
        Settings.new(:text, :float, "Speed Modifier", "1.0")
      ]
      super
    end

    def on_external_settings?
      true
    end
  end
end
