module KMP3D
  class CAME < Type
    attr_reader :camtype

    def initialize
      @name = "Cameras"
      @camtype = ["Goal", "FixSearch", "PathSearch", "KartFollow", \
        "KartPathFollow", "OP_FixMoveAt", "OP_PathMoveAt"]
      @camtype_model = [:rails, :point, :point, :point, :both, :rails, :point]
      @settings = [
        Settings.new(:text, :byte, "Next", "0xFF"),
        Settings.new(:text, :byte, "Shake", "0"),
        Settings.new(:text, :byte, "Route", "0xFF"),
        Settings.new(:text, :uint16, "Cam vel.", "60"),
        Settings.new(:text, :uint16, "Zoom vel.", "60"),
        Settings.new(:text, :uint16, "View vel.", "60"),
        Settings.new(:text, :float, "Zoom start", "0.0"),
        Settings.new(:text, :float, "Zoom end", "0.0"),
        Settings.new(:text, :float, "Time", "60.0")
      ]
      super
    end

    def camera?
      true
    end

    def hide_point?
      @camtype_model[@group] != :point && @step < 2
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
      case @camtype_model[@group]
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
      case @camtype_model[@group]
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

    def inputs
      # settings added due to next point using previous settings
      inputs = [[-1, false] + @settings.map { |s| s.default }]
      Data.entities_in_group(type_name, @group).each do |ent|
        id = ent.kmp3d_id(type_name)
        selected = Data.selection.include?(ent)
        inputs << [id, selected] + ent.kmp3d_settings[1..-1]
      end
      return inputs
    end

    def on_external_settings?
      false
    end

    def add_comp(comp)
      @camtype_model[@group] == :point ? \
        super(comp) : super(@comp_group.to_component)
    end

    def add_point(pos)
      @comp_group.entities.add_instance(model, pos)
    end

    private

    def add_rails(pos)
      @comp_group = Data.entities.add_group
      @comp_group.layer = @name
      @comp_group.entities.add_cline(@prev, pos)
    end

    def transform_rail_start(comp, pos)
      comp.transform!(Geom::Transformation.translation(pos - [0, 1500.m, 0]))
    end

    def camtype_settings(settings)

    end
  end
end
