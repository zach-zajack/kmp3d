module KMP3D
  class ENPT < Type
    def initialize
      @name = "Enemy Routes"
      @external_settings = [Settings.new(:ints, "Next Group(s)", "0")]
      @settings = [
        Settings.new(:float, "Size", "25.0"),
        Settings.new(:int, "Setting 1", "0"),
        Settings.new(:int, "Setting 2", "0")
      ]
      super
    end
  end
end
