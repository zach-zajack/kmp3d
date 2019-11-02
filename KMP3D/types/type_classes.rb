module KMP3D
  class KTPT < Vector
    def initialize
      @name = "Start Positions"
      @settings = [
        Settings.new(:int, "Player Index", "-1"),
        Settings.new(:int, "Padding", "0")
      ]
      super
    end
  end

  class ENPT < Point
    def initialize
      @name = "Enemy Routes"
      @external_settings = [Settings.new(:ints, "Next Group(s)", "0")]
      @settings = [
        Settings.new(:float, "Size", "25.0"),
        Settings.new(:int, "Setting 1", "0"),
        Settings.new(:int, "Setting 2", "0")
      ]
      super
    end
  end

  class ITPT < Point
    def initialize
      @name = "Item Routes"
      @external_settings = [Settings.new(:ints, "Next Group(s)", "0")]
      @settings = [
        Settings.new(:float, "Size", "25.0"),
        Settings.new(:int, "Setting 1", "0"),
        Settings.new(:int, "Setting 2", "0")
      ]
      super
    end
  end

  class CKPT < Checkpoint
    def initialize
      @name = "Checkpoints"
      @external_settings = [Settings.new(:ints, "Next Group(s)", "0")]
      @settings = [
        Settings.new(:int, "Respawn ID", "0"),
        Settings.new(:int, "Checkpoint Type", "-1")
      ]
      @groups = []
      super
    end
  end

  class GOBJ < Object
    def initialize
      @name = "Objects"
      @external_settings = [Settings.new(:int, "Object ID", "101")]
      @settings = [
        Settings.new(:int, "Route", "-1"),
        Settings.new(:int, "S1", "0"),
        Settings.new(:int, "S2", "0"),
        Settings.new(:int, "S3", "0"),
        Settings.new(:int, "S4", "0"),
        Settings.new(:int, "S5", "0"),
        Settings.new(:int, "S6", "0"),
        Settings.new(:int, "S7", "0"),
        Settings.new(:int, "S8", "0"),
        Settings.new(:int, "Flag", "0x3F")
      ]
      super
    end

    def settings_name
      "Objects"
    end
  end

  class POTI < Point
    def initialize
      @name = "Routes"
      @external_settings = [
        Settings.new(:bool, "Toggle Smooth Motion", "0"),
        Settings.new(:bool, "Toggle Cyclic Motion", "0")
      ]
      @settings = [
        Settings.new(:int, "Setting 1", "60"),
        Settings.new(:int, "Setting 2", "0")
      ]
      super
    end

    def settings_name
      "Route"
    end
  end

  class JGPT < Vector
    def initialize
      @name = "Respawns"
      @settings = [
        Settings.new(:int, "Index", "0"),
        Settings.new(:int, "Range", "0")
      ]
      super
    end
  end

  class CNPT < Vector
    def initialize
      @name = "Cannons"
      @settings = [Settings.new(:int, "Shoot Effect", "0")]
      super
    end
  end

  class MSPT < Vector
    def initialize
      @name = "End Positions"
      @settings = [Settings.new(:float, "Size", "25.0")]
      super
    end
  end

  class STGI < StageInfo
    def initialize
      @name = "Stage Info"
      @external_settings = [
        Settings.new(:int, "Lap count", "3"),
        Settings.new(:int, "Pole position", "0"),
        Settings.new(:int, "Driver distance", "0"),
        Settings.new(:float, "Speed", "0")
      ]
      super
    end
  end
end
