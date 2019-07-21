module KMP3D
  class CNPT < Type
    def initialize
      @name = "Cannons"
      @settings = [Settings.new(:float, "Size", "25.0")]
      super("vector")
    end
  end
end
