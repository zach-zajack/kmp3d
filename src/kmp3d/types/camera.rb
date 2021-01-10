module KMP3D
  class CAME < Type
    attr_accessor :op_cam_index, :vid_cam_index

    CamType = Struct.new(:name, :model, :route, :opening, :rel_pos)
    CAM_TYPES = [
      CamType.new("0 Goal",        :point, false, false, true),
      CamType.new("1 Fixed",       :point, false, false, false),
      CamType.new("2 Path",        :point, true, false, false),
      CamType.new("3 Follow",      :point, false, false, true),
      CamType.new("4 FixedMoveAt", :both,  false,  true, false),
      CamType.new("5 PathMoveAt",  :rails,  true,  true, false),
      CamType.new("6 FollowPath",  :point,  true,  false, false)
    ].freeze

    def initialize
      @name = "Cameras"
      @op_cam_index  = Data.model.get_attribute("KMP3D", "OPCAME", 0)
      @vid_cam_index = Data.model.get_attribute("KMP3D", "VIDCAME", 0)
      @settings = [
        Settings.new(:text,   :byte,   "Next", "-1"),
        Settings.new(:hidden, :byte,   "Camshake", "0"),
        Settings.new(:text,   :byte,   "Route", "-1"),
        Settings.new(:hidden, :uint16, "Point vel.", "0"),
        Settings.new(:text,   :uint16, "Zoom vel.", "5"),
        Settings.new(:text,   :uint16, "View vel.", "0"),
        Settings.new(:hidden, :byte,   "Start flag", "0"),
        Settings.new(:hidden, :byte,   "Movie flag", "0"),
        Settings.new(:hidden, :vec3,   "Position", "0, 0, 0"),
        Settings.new(:hidden, :vec3,   "Rotation", "0, 0, 0"),
        Settings.new(:text,   :float,  "Zoom start", "45.0"),
        Settings.new(:text,   :float,  "Zoom end", "45.0"),
        Settings.new(:text,   :vec3,   "Relative Position", "0, 0, 0"),
        Settings.new(:hidden, :vec3,   "View End", "0, 0, 0"),
        Settings.new(:text,   :float,  "Time", "60.0")
      ]
      super
    end

    def hide_point?
      CAM_TYPES[@group].model != :point && @step < 2
    end

    def draw_connected_points(view, pos, _selection=false)
      return unless (on_external_settings? || hide_point?) && pos && @step == 1

      view.line_stipple = "-"
      view.draw_polyline([@prev, pos])
    end

    def transform(comp, pos)
      comp.move!(Geom::Transformation.translation(pos))
    end

    def advance_steps(pos)
      case CAM_TYPES[@group].model
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
      case CAM_TYPES[@group].model
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
      case @group
      when 0
        "Activates for a few seconds after the race is completed. Follows the player based on the relative position. Normal position is irrelevant."
      when 1
        "Stays at its position and looks at the player."
      when 2
        "Follows a route and looks at the player. Normal position is irrelevant."
      when 3
        "Follows the player based on the relative position. Normal position is irrelevant."
      when 4
        "Stays at its position and looks at view start -> view end. Can be used as an opening camera."
      when 5
        "Follows a route and looks at view start -> view end. Can be used as an opening camera."
      when 6
        "Follows the player based on a relative position, where the relative position is instead determined by a route. Normal position is irrelevant."
      else
        "Unused"
      end
    end

    def import(pos, rail_start, rails_end, group, settings)
      @group = group
      camtype_model = CAM_TYPES[group].model
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
      return comp
    end

    def group_options
      settings = CAM_TYPES.map { |type| type.name } << "Preview Cameras"
      sidenav(@group, "switchGroup", settings)
    end

    def select_point(ent)
      route = ent.kmp3d_settings[3]
      return if ["0xFF", "-1", "255"].include?(route)

      ents = Data.entities_in_group("POTI", route)
      if Data.selection.contains?(ent)
        ents.each { |e| Data.selection.add(e) }
      else
        ents.each { |e| Data.selection.remove(e) }
      end
    end

    def linked_types
      ["Routes", "Objects", "Enemy Routes"]
    end

    def to_html
      if on_external_settings?
        tag(:div, :class => "cameras") { camera_settings_html } + \
          tag(:div, :class => "helper-text") do
            "You can preview camera setups here. Note these are not entirely accurate, so make sure to test them in the game as well."
          end
      else
        tag(:table) \
          { table_rows(inputs, @settings) * "" } + \
          tag(:div, :class => "helper-text") { table_helper_text }
      end
    end

    def table_columns(id, row, settings)
      super(id, sieve_settings(row.clone), sieve_settings(settings.clone))
    end

    def prompt_columns(settings)
      super(sieve_settings(settings.clone))
    end

    def on_external_settings?
      @group == 7
    end

    def add_comp(comp)
      if CAM_TYPES[@group].model == :point
        super(comp)
      else
        comp.erase!
        super(@comp_group.to_component)
      end
    end

    def sieve_settings(settings)
      settings[0]  = nil unless CAM_TYPES[@group].opening # next camera
      settings[2]  = nil unless CAM_TYPES[@group].route # route
      settings[5]  = nil unless CAM_TYPES[@group].model != :point # viewspeed
      settings[12] = nil unless CAM_TYPES[@group].rel_pos # relative position
      settings[14] = nil unless CAM_TYPES[@group].opening # time
      return settings
    end

    def save_settings
      Data.model.set_attribute("KMP3D", "OPCAME", @op_cam_index)
      Data.model.set_attribute("KMP3D", "VIDCAME", @vid_cam_index)
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
