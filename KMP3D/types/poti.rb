module KMP3D
  class POTI < Type
    def initialize
      @name = "Routes"
      @settings = [Settings.new(:float, "Size", "25.0")]
      super
    end
  end
end
