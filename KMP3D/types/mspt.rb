module KMP3D
  class MSPT < Type
    def initialize
      @name = "End Positions"
      @settings = [Settings.new(:float, "Size", "25.0")]
      super("vector")
    end
  end
end
