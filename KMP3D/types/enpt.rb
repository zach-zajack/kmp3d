module KMP3D
  class ENPT < Type
    def initialize
      @name = "Enemy Routes"
      @group_settings = [Settings.new(:byte_6, "Next Group(s)", "0")]
      @settings = [
        Settings.new(:float, "Size", "25.0"),
        Settings.new(:uint16, "Setting 1", "0000"),
        Settings.new(:uint16, "Setting 2", "0000")
      ]
      super
    end
  end
end
