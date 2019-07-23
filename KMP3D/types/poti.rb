module KMP3D
  class POTI < Type
    def initialize
      @name = "Routes"
      @external_settings = [
        Settings.new(:bool, "Toggle Smooth Motion", "0"),
        Settings.new(:bool, "Toggle Cyclic Motion", "0")
      ]
      @settings = [
        Settings.new(:int, "Setting 1", "60"),
        Settings.new(:int, "Setting 2", "0")
      ]
      super
    end
  end
end
