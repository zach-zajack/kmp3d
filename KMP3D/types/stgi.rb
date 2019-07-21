module KMP3D
  class STGI < Type
    def initialize
      @name = "Stage Info"
      @settings = [Settings.new(:float, "Size", "25.0")]
      super
    end
  end
end
