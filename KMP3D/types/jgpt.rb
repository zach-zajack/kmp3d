module KMP3D
  class JGPT < Type
    def initialize
      @name = "Respawns"
      @settings = [
        Settings.new(:int, "Index", "0"),
        Settings.new(:int, "Range", "0")
      ]
      super("vector")
    end
  end
end
