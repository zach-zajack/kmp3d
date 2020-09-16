module KMP3D
  class AREA < Type
    def initialize
      @name = "Area"
      @settings = [
        Settings.new(:dropdown, :byte, "Shape", "0", ["Cube", "Cylinder"]),
        Settings.new(
          :dropdown, :byte, "Area Type", "0",
          [
            "Camera", "Env Effect", "BFG Entry Swap", "Moving Road",
            "Force Recalc.", "Minimap Control", "Music Change", "Boos",
            "Draw Distance", "Unknown (0x09)", "Fall Boundary"
          ]
        ),
        Settings.new(:text, :byte, "Camera", "0xFF"),
        Settings.new(:text, :byte, "Priority", "0"),
        Settings.new(:text, :uint16, "Set. 1", "0"),
        Settings.new(:text, :uint16, "Set. 2", "0"),
        Settings.new(:text, :byte, "Route", "0xFF"),
        Settings.new(:text, :byte, "ENPT", "0xFF"),
        Settings.new(:hidden, :uint16, "Padding", "0")
      ]
      super
    end

    def model
      model_for(inputs[-1][2])
    end

    def transform(comp, pos)
      comp.transform!(Geom::Transformation.translation(pos))
    end

    def advance_steps(pos)
      0
    end

    def helper_text
      "Click to add a new area."
    end

    def import(pos, rot, scale, group, settings)
      comp = Data.entities.add_instance(model_for(settings[0]), pos)
      comp.transform!(Geom::Transformation.scaling(pos, *scale))
      comp.transform!(Geom::Transformation.rotation(pos, [1, 0, 0],  rot[0]))
      comp.transform!(Geom::Transformation.rotation(pos, [0, 0, 1],  rot[1]))
      comp.transform!(Geom::Transformation.rotation(pos, [0, 1, 0], -rot[2]))
      comp.name = "KMP3D #{type_name}(#{group},#{settings * ','})"
      comp.layer = name
    end

    def update_setting(ent, value, col)
      Data.model.start_operation("Update area point")
      super
      ent.definition = model_for(value) if col.to_i == 0
      Data.model.commit_operation
    end

    private

    def model_for(value)
      value.to_s == "0" ? Data.load_def("cube") : Data.load_def("cylinder")
    end
  end
end
