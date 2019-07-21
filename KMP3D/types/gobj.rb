module KMP3D
  class GOBJ < Type
    def initialize
      @name = "Objects"
      @settings = [Settings.new(:float, "Size", "25.0")]
      super
    end
  end
end
