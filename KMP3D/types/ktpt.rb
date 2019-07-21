module KMP3D
  class KTPT < Type
    def initialize
      @name = "Start Positions"
      @settings = [Settings.new(:int16, "Player Index", "-1")]
      super("vector")
    end
  end
end
