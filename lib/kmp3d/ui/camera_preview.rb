module KMP3D
  module CameraPreview
    Route = Struct.new(:pos, :speed)
    MKW_FRAMERATE = 59.94

    def rel_pos
      x, y, z = @settings[12].split(",")
      return [x.to_f.m, -z.to_f.m, y.to_f.m]
    end

    def time
      (Time.now - @start_time) * MKW_FRAMERATE
    end

    def delta
      Time.now - @prev_time
    end

    def lerp(p1, p2, t)
      Geom::Transformation.interpolate(p1, p2, t).origin
    end

    # def next_pos
    #  return @points[0].pos if @points.length == 1
    #  @point_prog += delta * @points[0].speed * MKW_FRAMERATE
    #  dist = @points[0].pos.distance(@points[1].pos).to_m
    #  ratio = @point_prog/dist
    #  return lerp(@points[0].pos, @points[1].pos, ratio) if ratio <= 1
    #  @points.shift
    #  return next_pos
    # end

    def target
      @rail_prog += delta * @view_vel * 100 / MKW_FRAMERATE
      ratio = @rail_prog / @rail_dist
      ratio = 1 if ratio > 1
      lerp(@rail_start, @rail_end, ratio)
    end

    def zoom
      @zoom_prog += delta * @zoom_vel * 100 / MKW_FRAMERATE
      @zoom_prog = @zoom_end if @zoom_prog >= @zoom_end
      return @zoom_prog
    end

    def route_path(ent)
      return [Route.new(ent.transformation.origin, 0)] unless @camtype.route
      return Data.entities_in_group("POTI", @settings[2]).map do |ent|
        Route.new(ent.transformation.origin, ent.kmp3d_settings[1].to_f)
      end
    end

    def came_rails(ent)
      return Array.new(2, ent.transformation.origin) if @camtype.model == :point

      ents = ent.definition.entities
      line = ents.select { |e| e.typename == "ConstructionLine" }.first
      return [line.start, line.end]
    end

    def points
      @points.map { |p| p.pos }
    end
  end

  class CameraOpening
    include CameraPreview

    def initialize(ent)
      get_ent_settings(ent)
    end

    def get_ent_settings(ent)
      @group      = ent.kmp3d_group.to_i
      @camtype    = CAME::CAMTYPES[@group]
      @settings   = ent.kmp3d_settings[1..-1]
      @points     = route_path(ent)
      @point_prog = 0
      @rail_start, @rail_end = came_rails(ent)
      @rail_dist  = @rail_start.distance(@rail_end).to_m
      @rail_prog  = 0
      @next_came  = @settings[0]
      @zoom_vel   = @settings[4].to_f
      @view_vel   = @settings[5].to_f
      @zoom_prog  = @settings[10].to_f
      @zoom_end   = @settings[11].to_f
      @total_time = @settings[14].to_f
      @start_time = Time.now
      @prev_time  = Time.now
    end

    def nextFrame(view)
      # TODO: replace n-order bezier with piecewise lines/cubic parametrics
      pos = KMP3D::KMPMath.bezier_at(points, time / @total_time)
      view.camera = Sketchup::Camera.new(pos, target, Z_AXIS, true, zoom)
      view.show_frame
      @prev_time = Time.now
      return true if time < @total_time # continue animation if true
      return false if ["0xFF", "-1", "255"].include?(@next_came)

      get_ent_settings(Data.get_entity("CAME", @next_came))
      return true
    end
  end

  class CameraReplay
    include CameraPreview

    def initialize(ent)
      @start_time = Time.now
      @prev_time  = Time.now
      get_ent_settings(ent)
      @enpt = enpt_route
      @area = Data.kmp3d_entities("AREA")
    end

    def get_ent_settings(ent)
      @group      = ent.kmp3d_group.to_i
      @camtype    = CAME::CAMTYPES[@group]
      @settings   = ent.kmp3d_settings[1..-1]
      @points     = route_path(ent)
      @point_prog = 0
      @rail_start, @rail_end = came_rails(ent)
      @rail_dist  = @rail_start.distance(@rail_end).to_m
      @rail_prog  = 0
      @zoom_vel   = @settings[4].to_f
      @view_vel   = @settings[5].to_f
      @zoom_prog  = @settings[10].to_f
      @zoom_end   = @settings[11].to_f
    end

    def enpt_route
      enpts = []
      grp = 0
      type = Data.type_by_typename("ENPT")
      loop do
        enpts += Data.entities_in_group("ENPT", grp).map do |e|
          e.transformation.origin
        end
        # always pick the first group in a split path
        grp = type.table[grp+1][0].split(",").first.to_i
        break if grp == 0
      end
      return enpts
    end

    def nextFrame(view)
      ratio = time / (30 * MKW_FRAMERATE)
      enpt = KMP3D::KMPMath.bezier_at(@enpt, ratio)
      # TODO: area priority
      area = @area.select { |a| KMP3D::KMPMath.intersect_area?(a, enpt) }.first
      get_ent_settings(Data.get_entity("CAME", area.kmp3d_settings[3])) if area
      pos = KMP3D::KMPMath.bezier_at(points, ratio)
      pos, tgt = camera_data(enpt, pos)
      view.camera = Sketchup::Camera.new(pos, tgt, Z_AXIS, true, zoom)
      view.show_frame
      return ratio < 1
    end

    def camera_data(player_pos, pos)
      case @group
      when 0, 3
        pos = player_pos + rel_pos
        tgt = player_pos
      when 1, 2
        tgt = player_pos
      else
        tgt = target
      end
      return pos, tgt
    end
  end
end
