module KMP3D
  class JGPT < Type
    def initialize
      @name = "Respawns"
      @settings = [Settings.new(:float, "Size", "25.0")]
      super
    end
  end
end
