module KMP3D
  class STGI < GroupType
    def initialize
      @name = "Stage Info"
      @external_settings = [
        Settings.new(:text, :byte, "Lap Count", "3"),
        Settings.new(:dropdown, :byte, "Pole Position", "0", %w[Left Right]),
        Settings.new(
          :dropdown, :byte, "Driver Distance", "0", %w[Normal Closer]
        ),
        Settings.new(
          :dropdown, :byte, "Lens Flare", "0", %w[Enabled Disabled]
        ),
        Settings.new(:text, :uint32, "Flare Color (ARGB)", "0xE6E6E6"),
        Settings.new(:hidden, :byte, "Unknown", "75"),
        Settings.new(:text, :float, "Speed Modifier", "1.0")
      ]
      super
    end

    def group_options
      ""
    end

    def on_external_settings?
      true
    end
  end
end
