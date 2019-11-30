module KMP3D
  class STGI < Type
    def initialize
      @name = "Stage Info"
      @external_settings = [
        Settings.new(:text, :byte, "Lap Count", "3"),
        Settings.new(:dropdown, :byte, "Pole Position", "0", ["Left", "Right"]),
        Settings.new(
          :dropdown, :byte, "Driver Distance", "0", ["Normal", "Closer"]
        ),
        Settings.new(:text, :float, "Speed Modifier", "1.0")
      ]
      super
    end

    def on_external_settings?
      true
    end
  end
end
