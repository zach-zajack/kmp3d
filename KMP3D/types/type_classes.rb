module KMP3D
  class KTPT < Vector
    def initialize
      @name = "Start Positions"
      @settings = [
        Settings.new(:text, :int16, "Player Index", "0xFFFF"),
        Settings.new(:text, :uint16, "Padding", "0")
      ]
      super
    end
  end

  class ENPT < Point
    def initialize
      @name = "Enemy Routes"
      @external_settings = [Settings.new(:text, :bytes, "Next Group(s)", "0")]
      @settings = [
        Settings.new(:text, :float, "Size", "25.0"),
        Settings.new(:dropdown,
          ["Default", "Item Start", "Item", "Wheelie", "End Wheelie"],
          "Setting 1", 0),
        Settings.new(:dropdown,
          ["Default", "End Drift", "No Drift", "Force Drift"], "Setting 2", 0),
      ]
      super
    end
  end

  class ITPT < Point
    def initialize
      @name = "Item Routes"
      @external_settings = [Settings.new(:text, :bytes, "Next Group(s)", "0")]
      @settings = [
        Settings.new(:text, :float, "Size", "25.0"),
        Settings.new(:dropdown, ["Abyss", "Ground", "Verbatim", "Mushroom"],
          "Setting 1", 0),
        Settings.new(:dropdown, ["Default", "No stop", "Shortcut", "Both"],
          "Setting 2", 0),
      ]
      super
    end
  end

  class CKPT < Checkpoint
    def initialize
      @name = "Checkpoints"
      @external_settings = [Settings.new(:text, :bytes, "Next Group(s)", "0")]
      @settings = [
        Settings.new(:text, :byte, "Respawn ID", "0"),
        Settings.new(:text, :byte, "Type", "0xFF")
      ]
      @groups = []
      super
    end
  end

  class GOBJ < Object
    def initialize
      @name = "Objects"
      @external_settings = [Settings.new(:text, :uint16, "Object ID", "101")]
      @settings = [
        Settings.new(:text, :uint16, "Route", "0xFFFF"),
        Settings.new(:text, :uint16, "S1", "0"),
        Settings.new(:text, :uint16, "S2", "0"),
        Settings.new(:text, :uint16, "S3", "0"),
        Settings.new(:text, :uint16, "S4", "0"),
        Settings.new(:text, :uint16, "S5", "0"),
        Settings.new(:text, :uint16, "S6", "0"),
        Settings.new(:text, :uint16, "S7", "0"),
        Settings.new(:text, :uint16, "S8", "0"),
        Settings.new(:text, :uint16, "Flag", "0x3F")
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
        Settings.new(:checkbox, :bool, "Smooth?", false),
        Settings.new(:checkbox, :bool, "Cyclic?", false)
      ]
      @settings = [
        Settings.new(:text, :uint16, "Time (1/60s)", "60"),
        Settings.new(:text, :uint16, "Unknown", "0")
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
      @settings = [Settings.new(:text, :int16, "Range", "0")]
      super
    end
  end

  class CNPT < Vector
    def initialize
      @name = "Cannons"
      @settings = [Settings.new(:dropdown,
        ["Straight", "Curved", "Slow & Curved"], "Shoot Effect", 0)]
      super
    end
  end

  class MSPT < Vector
    def initialize
      @name = "End Positions"
      @settings = [Settings.new(:text, :uint16, "Unknown", "0")]
      super
    end
  end

  class STGI < StageInfo
    def initialize
      @name = "Stage Info"
      @external_settings = [
        Settings.new(:text, :byte, "Lap count", "3"),
        Settings.new(:text, :byte, "Pole position", "0"),
        Settings.new(:text, :byte, "Driver distance", "0"),
        Settings.new(:text, :float, "Speed Modifier", "1.0")
      ]
      super
    end
  end
end
