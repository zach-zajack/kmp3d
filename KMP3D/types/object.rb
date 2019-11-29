module KMP3D
  class GOBJ < Type
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

    def model
      model_for(@table[@group + 1][0])
    end

    def object?
      true
    end

    def transform(comp, pos)
      comp.transform!(Geom::Transformation.translation(pos))
    end

    def advance_steps(pos)
      0
    end

    def helper_text
      "Click to add a new object."
    end

    def import(pos, rot, scale, group, settings)
      comp = Data.entities.add_instance(model_for(group), pos)
      comp.transform!(Geom::Transformation.rotation(pos, [1, 0, 0],  rot[0]))
      comp.transform!(Geom::Transformation.rotation(pos, [0, 0, 1],  rot[1]))
      comp.transform!(Geom::Transformation.rotation(pos, [0, 1, 0], -rot[2]))
      comp.name = "KMP3D #{type_name}(#{group},#{settings * ','})"
      comp.layer = name
    end

    def group_id(i)
      @table[i.to_i + 1][0].to_i
    end

    def update_group(value, row, col)
      Data.model.start_operation("Update object group")
      Data.entities_in_group(type_name, group_id(row)).each do |ent|
        ent.edit_setting(0, value)
        ent.definition = model_for(value)
      end
      Data.model.commit_operation
      super
    end

    private

    def model_for(i)
      case i.to_s
      when "101" then Data.load_def("itembox")
      else Data.load_def("point")
      end
    end
  end
end
