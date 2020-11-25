module KMP3D
  class Point < GroupType
    def transform(comp, pos)
      comp.transform!(Geom::Transformation.translation(pos))
    end

    def advance_steps(_pos)
      0
    end

    def helper_text
      "Click to add a new point."
    end

    def import(pos, group, settings)
      comp = Data.entities.add_instance(model, pos)
      comp.name = "KMP3D #{type_name}(#{group}|#{settings * '|'})"
      comp.layer = name
      return comp
    end

    def draw_connected_points(view, _pos, selection=false)
      view.line_width = 5
      groups.times do |group|
        view.drawing_color = (@group == group && selection ? "Blue" : "DarkRed")
        array = Data.entities_in_group(type_name, group).map do |ent|
          ent.transformation.origin
        end
        view.draw_polyline(array) if array.length >= 2
      end
    end
  end

  class ENPT < Point
    def initialize
      @name = "Enemy Routes"
      @external_settings = [Settings.new(:text, :bytes, "Next Group(s)", "0")]
      @settings = [
        Settings.new(:text, :float, "Size", "25.0"),
        Settings.new(
          :dropdown, :uint16, "Setting 1", "0",
          ["None", "Item Route Marker", "Use Item", "Wheelie", "End Wheelie"]
        ),
        Settings.new(
          :dropdown, :byte, "Setting 2", "0",
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

  class POTI < Point
    def initialize
      @name = "Routes"
      @external_settings = [
        Settings.new(:dropdown, :byte, "Setting 1", 0, %w[Verbatim Smooth]),
        Settings.new(
          :dropdown, :byte, "Setting 2", 0, ["Cyclic motion", "Back and forth"]
        )
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
end
