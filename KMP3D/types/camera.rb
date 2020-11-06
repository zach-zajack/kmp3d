module KMP3D
  class CAME < Type
    attr_accessor :op_cam_index

    CamType = Struct.new(:name, :model, :route, :opening, :rel_pos)
    CAMTYPES = [
      CamType.new("0 Goal",           :point, false, false,  true),
      CamType.new("1 FixSearch",      :point, false, false, false),
      CamType.new("2 PathSearch",     :point,  true, false, false),
      CamType.new("3 KartFollow",     :point, false, false,  true),
      CamType.new("4 KartPathFollow", :both,  false,  true, false),
      CamType.new("5 OP_FixMoveAt",   :rails,  true,  true, false),
      CamType.new("6 OP_PathMoveAt",  :rails,  true,  true, false)
    ]

    def initialize
      @name = "Cameras"
      @op_cam_index = Data.model.get_attribute("KMP3D", "CAME", 0)
      @settings = [
        Settings.new(:text,   :byte,   "Next", "0xFF"),
        Settings.new(:hidden, :byte,   "Camshake", "0"),
        Settings.new(:text,   :byte,   "Route", "0xFF"),
        Settings.new(:hidden, :uint16, "Point vel.", "0"),
        Settings.new(:text,   :uint16, "Zoom vel.", "5"),
        Settings.new(:text,   :uint16, "View vel.", "0"),
        Settings.new(:hidden, :byte,   "Start flag", "0"),
        Settings.new(:hidden, :byte,   "Movie flag", "0"),
        Settings.new(:hidden, :vec3,   "Position", "0, 0, 0"),
        Settings.new(:hidden, :vec3,   "Rotation", "0, 0, 0"),
        Settings.new(:text,   :float,  "Zoom start", "45.0"),
        Settings.new(:text,   :float,  "Zoom end", "45.0"),
        Settings.new(:text,   :vec3,   "Relative Pos.", "0, 0, 0"), # view start
        Settings.new(:hidden, :vec3,   "View End", "0, 0, 0"),
        Settings.new(:text,   :float,  "Time", "60.0")
      ]
      super
    end

    def camtype
      CAMTYPES.map { |type| type.name } << "Camera Settings"
    end

    def camera?
      true
    end

    def hide_point?
      CAMTYPES[@group].model != :point && @step < 2
    end

    def draw_connected_points(view, pos, selection=false)
      return unless (on_external_settings? || hide_point?) && pos && @step == 1
      view.line_stipple = "-"
      view.draw_polyline([@prev, pos])
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

    def table_helper_text
      # Based off http://wiki.tockdom.com/wiki/KMP_Editing/Cameras
      case @group
      when 0
        "Activates immediately after passing the goal; with the player as the origin, the camera's View Start position both follows and looks at the player. It can be reactivated as a Replay Camera if linked to an AREA, but does not display in spectator (online/waiting) mode."
      when 1
        "Camera stays static in View Start location, and always looks towards the player."
      when 2
        "Route controlled, always looks at the player."
      when 3
        "With the player as the origin, the camera's View Start position both follows and looks at the player."
      when 4
        "From its position, it looks at View Start and shifts view to View End."
      when 5
        "Opening camera, follows route; from its position, it looks at View Start and shifts view to View End."
      when 6
        "Opening camera onboard with same effects as normal drive Camera (unsure)."
      else
        "Unused"
      end
    end

    def import(pos, rail_start, rails_end, group, settings)
      @group = group
      camtype_model = CAMTYPES[group].model
      if camtype_model == :point
        comp = Data.entities.add_instance(model, pos)
      else
        skp_grp = Data.entities.add_group
        skp_grp.entities.add_cline(rail_start, rails_end)
        skp_grp.entities.add_instance(model, pos) if camtype_model == :both
        comp = skp_grp.to_component
      end
      comp.name = "KMP3D #{type_name}(#{group}|#{settings * '|'})"
      comp.layer = name
    end

    def select_point(ent)
      route = ent.kmp3d_settings[3]
      return if ["0xFF", "-1", "255"].include?(route)
      ents = Data.entities_in_group("POTI", route)
      Data.selection.contains?(ent) ?
        ents.each { |e| Data.selection.add(e) } : \
        ents.each { |e| Data.selection.remove(e) }
    end

    def to_html
      if on_external_settings?
        tag(:div, :class => "cameras") { camera_settings_html }
      else
        tag(:table) \
          { table_rows(inputs, @settings) * "" } + \
        tag(:div, :class => "helper-text") { table_helper_text }
      end
    end

    def table_columns(id, row, settings)
      super(id, camtype_settings(row.clone), camtype_settings(settings.clone))
    end

    def prompt_columns(settings)
      super(camtype_settings(settings.clone))
    end

    def on_external_settings?
      @group == 7
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
      settings[0]  = nil unless CAMTYPES[@group].opening # next camera
      settings[2]  = nil unless CAMTYPES[@group].route # route
      settings[5]  = nil unless CAMTYPES[@group].model != :point # viewspeed
      settings[12] = nil unless CAMTYPES[@group].rel_pos # relative position
      settings[14] = nil unless CAMTYPES[@group].opening # time
      settings.compact!
    end

    def save_settings
      Data.model.set_attribute("KMP3D", "CAME", @op_cam_index)
    end

    private

    def camera_settings_html
      "Initial opening camera index: " + \
      tag(:input, :id => "opCameIdx", :type => "text", :size => "2", \
        :value => @op_cam_index, :onchange => callback("setOpCamIdx")) + br + \
      tag(:button, :onclick => callback("playOpening")) \
        { "Play Opening Cameras" } + br + \
      tag(:button, :onclick => callback("playReplay")) \
        { "Play Replay Cameras" } + br + \
      tag(:button, :onclick => callback("stopReplay")) \
        { "Stop Camera Playback" }
    end

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
