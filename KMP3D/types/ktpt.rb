module KMP3D
  class KTPT < Type
    def initialize
      @name = "Start Positions"
      @settings = [
        Settings.new(:int, "Player Index", "-1"),
        Settings.new(:int, "Padding", "0")
      ]
      super("vector")
    end
  end
end
