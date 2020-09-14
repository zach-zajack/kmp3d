module KMP3D
  class CAME < Type
    CamType = Struct.new(:name, :model, :route, :opening)
    CAMTYPES = [
      CamType.new("Goal",           :rails, false, false),
      CamType.new("FixSearch",      :point, false, false),
      CamType.new("PathSearch",     :point,  true, false),
      CamType.new("KartFollow",     :point, false, false),
      CamType.new("KartPathFollow",  :both, false,  true),
      CamType.new("OP_FixMoveAt",   :rails,  true,  true),
      CamType.new("OP_PathMoveAt",  :point,  true, false)
    ]

    def initialize
      @name = "Cameras"
      @settings = [
        Settings.new(:text, :byte, "Next", "0xFF"),
        Settings.new(:text, :byte, "Route", "0xFF"),
        Settings.new(:text, :uint16, "Zoom vel.", "60"),
        Settings.new(:text, :uint16, "View vel.", "60"),
        Settings.new(:text, :float, "Zoom start", "0.0"),
        Settings.new(:text, :float, "Zoom end", "0.0"),
        Settings.new(:text, :float, "Time", "60.0")
      ]
      super
    end

    def camtype
      CAMTYPES.map { |type| type.name }
    end

    def camera?
      true
    end

    def hide_point?
      CAMTYPES[@group].model != :point && @step < 2
    end

    def draw_connected_points(view, comp, pos)
      return unless hide_point?
      view.line_stipple = "-"
      view.draw_polyline([@prev, pos]) if @step == 1
    end

    def transform(comp, pos)
      comp.transform!(Geom::Transformation.translation(pos))
    end

    def advance_steps(pos)
      case CAMTYPES[@group].model
      when :rails
        # needed for add_comp
        add_rails(pos) if @step == 1
        @step += 1
        @step %= 2
      when :both
        add_rails(pos) if @step == 1
        add_point(pos) if @step == 2
        @step += 1
        @step %= 3
      end
      @prev = pos
      return @step
    end

    def helper_text
      case CAMTYPES[@group].model
      when :point
        "Click to place the position of the camera."
      when :rails
        case @step
        when 0 then "(Step 1/2) Click to place the camera view start."
        when 1 then "(Step 2/2) Click to place the camera view end."
        end
      when :both
        case @step
        when 0 then "(Step 1/3) Click to place the camera view start."
        when 1 then "(Step 2/3) Click to place the camera view end."
        when 2 then "(Step 3/3) Click to place the position of the camera."
        end
      end
    end

    def import(pos, rail_start, rails_end, group, settings)
      @group = group
      camtypemdl = CAMTYPES[@group].model
      settings = camtype_settings(settings)
      skp_grp = Data.entities.add_group
      skp_grp.entities.add_cline(rail_start, rails_end) if camtypemdl != :point
      skp_grp.entities.add_instance(model, pos) if camtypemdl != :rails
      comp = skp_grp.to_component
      comp.name = "KMP3D #{type_name}(#{group},#{settings * ','})"
      comp.layer = name
    end

    def inputs
      # settings added due to next point using previous settings
      inputs = [[-1, false] + camtype_settings(@settings.map { |s| s.default })]
      Data.entities_in_group(type_name, @group).each do |ent|
        id = ent.kmp3d_id(type_name)
        selected = Data.selection.include?(ent)
        inputs << [id, selected] + ent.kmp3d_settings[1..-1]
      end
      return inputs
    end

    def to_html
      tag(:table) do
        if on_external_settings?
          table_rows(@table, @external_settings) * ""
        else table_rows(inputs, camtype_settings(@settings)) * ""
        end
      end
    end

    def on_external_settings?
      false
    end

    def add_comp(comp)
      if CAMTYPES[@group].model == :point
        super(comp)
      else
        comp.erase!
        super(@comp_group.to_component)
      end
    end

    def camtype_settings(settings)
      if CAMTYPES[@group].route && CAMTYPES[@group].opening
        settings
      elsif CAMTYPES[@group].route && !CAMTYPES[@group].opening
        settings[1..2] + settings[4..5]
      else
        [settings[2]] + settings[4..5]
      end
    end

    private

    def add_rails(pos)
      @comp_group = Data.entities.add_group
      @comp_group.layer = name
      @comp_group.entities.add_cline(@prev, pos)
    end

    def add_point(pos)
      @comp_group.entities.add_instance(model, pos)
    end

    def transform_rail_start(comp, pos)
      comp.transform!(Geom::Transformation.translation(pos - [0, 1500.m, 0]))
    end
  end
end
