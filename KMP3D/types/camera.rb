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

    def transform(comp, pos)
      case @camtype_model[@group]
      when :point
        comp.transform!(Geom::Transformation.translation(pos))
      when :rails
      end
    end

    def advance_steps(pos)
      case @camtype_model[@group]
      when :rails
        @step += 1
        @step %= 2
      when :both
        @step += 1
        @step %= 3
      end
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

    private

    def transform_rail_start(comp, pos)
      comp.transform!(Geom::Transformation.translation(pos - [0, 1500.m, 0]))
    end

    def camtype_settings(settings)

    end
  end
end
