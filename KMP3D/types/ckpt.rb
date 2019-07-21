module KMP3D
  class CKPT < Type
    def initialize
      @name = "Checkpoints"
      @group_settings = [
        Settings.new(:float, "Next 1", "0")
      ]
      @settings = [Settings.new(:float, "Size", "25.0")]
      @groups = []
      super("checkpoint")
    end
  end
end
