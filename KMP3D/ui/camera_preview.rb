module KMP3D
  class CameraPreview
    def initialize(ent)
      get_ent_settings(ent)
    end

    def time
      (Time.now - @start_time)/(@total_time/60.0)
    end

    def nextFrame(view)
      pos  = KMP3D::KMPMath.bezier_at(@points, time)
      rail = KMP3D::KMPMath.lerp(@rail_start, @rail_end, time)
      zoom = KMP3D::KMPMath.lerp(@zoom_start, @zoom_end, time)
      view.camera = Sketchup::Camera.new(pos, rail, Z_AXIS, true)
      view.show_frame
      return true if time < 1 # continue animation
      case @next_came
      when "0xFF", "-1", "255" then return false # stop animation
      else
        get_ent_settings(Data.get_entity("CAME", @next_came))
        return true
      end
    end

    private

    def get_ent_settings(ent)
      @group = ent.kmp3d_group.to_i
      @type = CAME::CAMTYPES[@group]
      @settings = ent.kmp3d_settings[1..-1]
      @points = route_path(ent)
      @rail_start, @rail_end = came_rails(ent)
      # add smooth setting
      @next_came  = @settings[0]
      @zoom_vel   = @settings[2].to_f
      @view_vel   = @settings[3].to_f
      @zoom_start = @settings[4].to_f
      @zoom_end   = @settings[5].to_f
      @total_time = @settings[6].to_f
      @start_time = Time.now
    end

    def route_path(ent)
      return [ent.transformation.origin] if !CAME::CAMTYPES[@group].route
      return Data.entities_in_group("POTI", @settings[1]).map do |ent|
        ent.transformation.origin
      end
    end

    def came_rails(ent)
      return Array.new(2, ent.transformation.origin) if @type.model == :point
      ents = ent.definition.entities
      line = ents.select { |e| e.typename == "ConstructionLine" }.first
      return [line.start, line.end]
    end
  end
end
