module KMP3D
  class GOBJ < GroupType
    def initialize
      @name = "Objects"
      @external_settings = [
        Settings.new(:text, :obj, "Object ID", "itembox"),
        Settings.new(:path, :path, "Object Path", Data.load_obj("itembox"))
      ]
      @settings = [
        Settings.new(:text, :uint16, "Ref ID", "0x0"),
        Settings.new(:text, :uint16, "Route ID", "-1"),
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
      @obj_list = Objects::LIST.keys.join("|")
      super
    end

    def sequential_id?
      false
    end

    def settings_name
      ""
    end

    def add_group(init=false)
      return super if init

      object = UI.inputbox(["Enter Object Name"], ["itembox"], [@obj_list], "Add Object").first
      @table << [object, Data.load_obj(object)]
    end

    def model
      @table[@group + 1][1]
    end

    def transform(comp, pos)
      comp.transform!(Geom::Transformation.translation(pos))
    end

    def advance_steps(_pos)
      0
    end

    def helper_text
      "Click to add a new object."
    end

    def import(pos, rot, scale, group, settings)
      comp = Data.entities.add_instance(Data.load_obj(group), pos)
      comp.transform!(Geom::Transformation.scaling(pos, *scale))
      comp.transform!(Geom::Transformation.rotation(pos, [1, 0, 0],  rot[0]))
      comp.transform!(Geom::Transformation.rotation(pos, [0, 0, 1],  rot[1]))
      comp.transform!(Geom::Transformation.rotation(pos, [0, 1, 0], -rot[2]))
      comp.name = "KMP3D #{type_name}(#{group}|#{settings * '|'})"
      comp.layer = name
      return comp
    end

    def inputs
      # settings added due to next point using previous settings
      inputs = [[-1, false] + @settings.map { |s| s.default }]
      Data.entities.each do |ent|
        next unless ent.type?("GOBJ") && ent.kmp3d_group == group_id(@group)

        id = ent.kmp3d_id(type_name)
        selected = Data.selection.include?(ent)
        inputs << [id, selected] + ent.kmp3d_settings[1..-1]
      end
      return inputs
    end

    def group_id(i)
      @table[i.to_i + 1][0]
    end

    def update_group(value, row, col)
      Data.model.start_operation("Update object group")
      Data.entities.each do |ent|
        next unless ent.type?("GOBJ") && ent.kmp3d_group == group_id(row)

        case col.to_i
        # change the definition to the default if the object name is changed
        when 0
          definition = Data.load_obj(value)
          @table[row.to_i + 1][1] = definition
          ent.edit_setting(0, value)
          ent.definition = definition
        # change the definition to the path if the object path is changed
        when 1 then ent.definition = value
        end
      end
      super
      Data.model.commit_operation
    end
  end
end
