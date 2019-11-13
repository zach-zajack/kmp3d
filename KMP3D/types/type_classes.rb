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
        Settings.new(
          :dropdown, :uint16, "Setting 1", 0,
          ["None", "Item Route Marker", "Use Item", "Wheelie", "End Wheelie"]
        ),
        Settings.new(
          :dropdown, :byte, "Setting 2", 0,
          ["None", "End Drift", "No Drift", "Force Drift"]
        ),
        Settings.new(:hidden, :byte, "Setting 3", "0")
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
        Settings.new(
          :dropdown, :uint16, "Setting 1", 0,
          ["None", "Bill Uses Gravity", "Bill ignores gravity"]
        ),
        Settings.new(
          :dropdown, :uint16, "Setting 2", 0,
          ["None", "Bill doesn't stop", "Low-priority", "Both"]
        )
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
        Settings.new(:checkbox, :byte, "Smooth?", false),
        Settings.new(:checkbox, :byte, "Cyclic?", false)
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
      @settings = [
        Settings.new(:hidden, :uint16, "ID", "0"),
        Settings.new(:text, :int16, "Range", "0")
      ]
      super
    end
  end

  class CNPT < Vector
    def initialize
      @name = "Cannons"
      @settings = [
        Settings.new(:hidden, :uint16, "ID", "0"),
        Settings.new(
          :dropdown, :int16, "Shoot Effect", 0,
          ["Straight", "Curved", "Slow & Curved"]
        )
      ]
      super
    end
  end

  class MSPT < Vector
    def initialize
      @name = "End Positions"
      @settings = [
        Settings.new(:hidden, :uint16, "ID", "0"),
        Settings.new(:text, :uint16, "Unknown", "0")
      ]
      super
    end
  end

  class STGI < Type
    def initialize
      @name = "Stage Info"
      @external_settings = [
        Settings.new(:text, :byte, "Lap Count", "3"),
        Settings.new(:text, :byte, "Pole Position", "0"),
        Settings.new(:text, :byte, "Driver Distance", "0"),
        Settings.new(:text, :float, "Speed Modifier", "1.0")
      ]
      super
    end

    def on_external_settings?
      true
    end
  end
end
