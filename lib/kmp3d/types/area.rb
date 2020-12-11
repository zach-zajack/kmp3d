module KMP3D
  class AREA < Type
    AreaType = Struct.new(:name, :use_params)
    AREA_TYPES = [
      AreaType.new("0 Camera",        false),
      AreaType.new("1 Effect",        false),
      AreaType.new("2 Fog",           true),
      AreaType.new("3 Pull",          true),
      AreaType.new("4 Enemy Recalc.", false),
      AreaType.new("5 Minimap",       false),
      AreaType.new("6 Sound",         true),
      AreaType.new("7 Teresa/Boos",   false),
      AreaType.new("8 Object Group",  true),
      AreaType.new("9 Object Loader", true),
      AreaType.new("10 Boundary",     true)
    ].freeze

    def initialize
      @name = "Area"
      @settings = [
        Settings.new(:dropdown, :byte, "Shape", "0", %w[Box Cylinder]),
        Settings.new(:text, :byte, "Camera ID", "0xFF"),
        Settings.new(:text, :byte, "Priority", "0"),
        Settings.new(:text, :uint16, "Setting 1", "0"),
        Settings.new(:text, :uint16, "Setting 2", "0"),
        Settings.new(:text, :byte, "Route ID", "0xFF"),
        Settings.new(:text, :byte, "Enemy route ID", "0xFF"),
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

    def advance_steps(_pos)
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
      comp.name = "KMP3D #{type_name}(#{group}|#{settings * '|'})"
      comp.layer = name
      return comp
    end

    def group_options
      sidenav(@group, "switchGroup", AREA_TYPES.map { |type| type.name })
    end

    def select_point(ent)
      camera = ent.kmp3d_settings[3]
      return if ["0xFF", "-1", "255"].include?(camera)

      cam_ent = Data.get_entity("CAME", camera)
      if Data.selection.contains?(ent)
        Data.selection.add(cam_ent)
      else
        Data.selection.remove(cam_ent)
      end
    end

    def update_setting(ent, value, col)
      Data.model.start_operation("Update AREA")
      super
      ent.definition = model_for(value) if col.to_i == 0
      Data.model.commit_operation
    end

    def table_helper_text
      case @group
      when 0
        "Enables camera when inside the area for replays."
      when 1
        "Disables EnvFire, EnvSnow, and enables EnvKareha when inside the area. EnvKarehaUp is used instead if Setting 1 is 1. Enables the Mushroom Gorge cave and Dry Dry Ruins interior effects as well."
      when 2
        "Enables BFG fog when inside the area. Setting 1 refers to the posteffect index for the fog."
      when 3
        "Activates moving road (KCL type 0x0B). Links moving road to route if the right KCL variant is used. Settings 1 and 2 refer to acceleration and speed respectively, if used for the right variant."
      when 4
        "Links CPU recalculation (KCL type 0x12) to ENPT route."
      when 5
        "Crops minimap to the bounds of the area. Useful for tournaments and missions."
      when 6
        "Enables audio distortion effects such as reverb and IIR filters."
      when 7
        "Enables Boos (b_teresa) to display when inside the area."
      when 8
        "Groups objects within the given area to a given ID. Setting 1 refers to the ID that these objects are given. Paired with Area 9 (Object Loader) to dynamically unload objects."
      when 9
        "Unloads objects by group when inside the area. Setting 1 refers to the group ID, as defined in Area 8 (Object Group)."
      when 10
        "Adds fall boundaries to the game when inside the area. Useful for touraments and missions, or lazy KCL editing. #{br}
        #{br} If using Riidefi's Conditional Out of Bounds code:
        #{br} Setting 1 refers to the checkpoint that enables it when crossed. #{br} Setting 2 refers to the checkpoint that disables it when crossed. #{br} If the second checkpoint comes before the first, it is disabled the following lap."
      end
    end

    def linked_types
      ["Cameras", "Checkpoints", "Enemy Routes"]
    end

    def visible_layers
      ["Cameras"]
    end

    private

    def model_for(value)
      value.to_s == "0" ? Data.load_def("cube") : Data.load_def("cylinder")
    end
  end
end
