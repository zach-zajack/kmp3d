module KMP3D
  class Vector < Type
    def model
      Data.load_def("vector")
    end

    def vector?
      true
    end

    def transform(comp, pos)
      case @step
      when 0 then comp.transform!(Geom::Transformation.translation(pos))
      when 1
        comp.transform!(
          Geom::Transformation.rotation(@prev, [0, 0, 1], angle(pos))
        )
      end
    end

    def advance_steps(pos)
      @prev = pos
      @step += 1
      @step %= 2
      return @step
    end

    def helper_text
      case @step
      when 0 then "(Step 1/2) Click to place the point's position."
      when 1 then "(Step 2/2) Click to place the point's direction."
      end
    end

    def import(pos, rot, group, settings)
      comp = Data.entities.add_instance(model, pos)
      comp.transform!(Geom::Transformation.rotation(pos, [1, 0, 0],  rot[0]))
      comp.transform!(Geom::Transformation.rotation(pos, [0, 0, 1],  rot[1]))
      comp.transform!(Geom::Transformation.rotation(pos, [0, 1, 0], -rot[2]))
      comp.name = "KMP3D #{type_name}(#{group}|#{settings * '|'})"
      comp.layer = name
      return comp
    end

    private

    def angle(pos)
      Math::PI - Math.atan2(pos.x - @prev.x, pos.y - @prev.y)
    end
  end

  class KTPT < Vector
    def initialize
      @name = "Start Positions"
      @settings = [
        Settings.new(:text, :int16, "Player Index", "0xFFFF"),
        Settings.new(:hidden, :uint16, "Padding", "0")
      ]
      super
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
          :dropdown, :int16, "Shoot Effect", "0",
          ["Straight", "Curved", "Slow & Curved"]
        )
      ]
      super
    end

    def transform(comp, pos)
      case @step
      when 0 then comp.transform!(Geom::Transformation.translation(pos))
      when 1
        comp.transform!(
          Geom::Transformation.rotation(@prev, [0, 0, 1], angle(pos))
        )
        comp.transform!(Geom::Transformation.translation(pos - @prev))
      end
    end

    def helper_text
      case @step
      when 0 then "(Step 1/2) Click to place the cannon's start position."
      when 1 then "(Step 2/2) Click to place the cannon's end position."
      end
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
end
