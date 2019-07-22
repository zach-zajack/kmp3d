module KMP3D
  class JGPT < Type
    def initialize
      @name = "Respawns"
      @settings = [Settings.new(:float, "Size", "25.0")]
      super("vector")
    end
  end
end
