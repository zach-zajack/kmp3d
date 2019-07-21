module KMP3D
  class ITPT < Type
    def initialize
      @name = "Item Routes"
      @group_settings = [
        Settings.new(:float, "Next 1", "0")
      ]
      @settings = [Settings.new(:float, "Size", "25.0")]
      @groups = []
      super
    end
  end
end
