module KMP3D
  class POTI < Type
    def initialize
      @name = "Routes"
      @external_settings = [
        Settings.new(:int16, "Toggle Smooth Motion", "0"),
        Settings.new(:int16, "Toggle Cyclic Motion", "0"),
      ]
      @settings = [
        Settings.new(:int16, "Setting 1", "60"),
        Settings.new(:int16, "Setting 2", "0")
      ]
      super
    end
  end
end
