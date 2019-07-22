module KMP3D
  class ENPT < Type
    def initialize
      @name = "Enemy Routes"
      @external_settings = [Settings.new(:byte_6, "Next Group(s)", "0")]
      @settings = [
        Settings.new(:float, "Size", "25.0"),
        Settings.new(:int16, "Setting 1", "0000"),
        Settings.new(:int16, "Setting 2", "0000")
      ]
      super
    end
  end
end
