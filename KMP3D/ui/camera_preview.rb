module KMP3D
  class CameraPreview
    def initialize(ent)
      @settings   = ent.kmp3d_settings[1..-1]
      @points     = route_path(ent)
      @smooth     = settings[:smooth]
      @zoom_start = settings[:zoom_start]
      @rail_start = settings[:rail_start]
      @zoom_end   = settings[:zoom_end]
      @rail_end   = settings[:rail_end]
      @total_time = settings[:total_time]
      @start_time = Time.now
    end

    def time
      (Time.now - @start_time)/(@total_time*60.0)
    end

    def nextFrame(view)
      pos  = KMP3D::KMPMath.bezier_at(@points, time)
      rail = KMP3D::KMPMath.lerp(@rail_start, @rail_end, time)
      zoom = KMP3D::KMPMath.lerp(@zoom_start, @zoom_end, time)
      view.camera = Sketchup::Camera.new(pos, zoom, Z_AXIS, true, zoom)
      view.show_frame
      return time < 1 # return false when the animation is over
    end

    private

    def route_path(ent)
      return [ent.transformation.origin] if !CAME::CAMTYPES[@index].route
      return Data.entities_in_group("POTI", @settings[]).map do |ent|

      end
    end
  end
end
