module KMP3D
  class CKPT < Type
    def initialize
      @name = "Checkpoints"
      @external_settings = [Settings.new(:text, :bytes, "Next Group(s)", "0")]
      @settings = [
        Settings.new(:text, :byte, "Respawn ID", "0"),
        Settings.new(:text, :byte, "Type", "0xFF")
      ]
      @groups = []
      super
    end

    def checkpoint?
      true
    end

    def sequential_id?
      true
    end

    def draw_connected_points(view, pos, selection=false)
      view.line_width = 5
      c = 0
      oob_areas = Data.kmp3d_entities("AREA").select \
        { |area| area.kmp3d_settings[2].to_i == 10 }
      groups.times do |group|
        color = (@group == group && selection ? "Blue" : "Aqua")
        Data.entities_in_group(type_name, group).each do |ent|
          pos = ent.transformation.origin
          rot = KMPMath.matrix_to_euler(ent.transformation.to_a)
          scale = ent.transformation.to_a[4...7].distance([0, 0, 0]).m
          points = KMPMath.checkpoint_transform(pos.x, pos.y, -rot.y, scale)
          p1 = points[0..1] + [pos.z]
          p2 = points[2..3] + [pos.z]
          view.drawing_color = (coob_active?(oob_areas, c) ? "DarkRed" : color)
          view.draw_lines(p1, @prev1) if @prev1
          view.draw_lines(p2, @prev2) if @prev2
          @prev1 = p1
          @prev2 = p2
          c += 1
        end
      end
    end

    def model
      Data.load_def("checkpoint")
    end

    def transform(comp, pos)
      case @step
      when 0 then comp.transform!(Geom::Transformation.translation(pos - \
        [0, 1500.m, 0]))
      when 1
        comp.transform!(
          Geom::Transformation.scaling(@prev, 1.0, scale(pos), 1.0)
        )
        comp.transform!(
          Geom::Transformation.rotation(@prev, [0, 0, 1], angle(pos))
        )
      when 2
        return comp unless change_direction?(pos)
        comp.transform!(
          Geom::Transformation.rotation(@avg, [0, 0, 1], Math::PI)
        )
      end
    end

    def advance_steps(pos)
      if @step == 1
        @slope = (@prev.y - pos.y) / (@prev.x - pos.x)
        @prev_angle = angle(pos)
        @avg = \
          [(pos.x + @prev.x) / 2, (pos.y + @prev.y) / 2, (pos.z + @prev.z) / 2]
      end
      @prev = pos
      @step += 1
      @step %= 3
      return @step
    end

    def helper_text
      case @step
      when 0 then "(Step 1/3) Click to place one end of the checkpoint."
      when 1 then "(Step 2/3) Click to place the other end of the checkpoint."
      when 2 then "(Step 3/3) Click in direction of the checkpoint."
      end
    end

    def import(pos1, pos2, group, settings)
      @prev = pos1
      avg = [(pos2.x + pos1.x) / 2, (pos2.y + pos1.y) / 2]
      avg.z = closest_enpt_height(avg)
      comp = Data.entities.add_instance(model, avg)
      comp.transform!(Geom::Transformation.scaling(avg, 1.0, scale(pos2), 1.0))
      comp.transform!(
        Geom::Transformation.rotation(avg, [0, 0, 1], angle(pos2))
      )
      comp.name = "KMP3D #{type_name}(#{group}|#{settings * '|'})"
      comp.layer = name
      return comp
    end

    def select_point(ent)
      respawn = Data.get_entity("JGPT", ent.kmp3d_settings[1])
      if Data.selection.contains?(ent)
        Data.selection.add(respawn)
      else
        Data.selection.remove(respawn)
      end
    end

    def set_enpt
      @enpt = Data.kmp3d_entities("ENPT")
      @enpt.map! { |ent| ent.transformation.origin }
    end

    private

    def coob_active?(areas, c)
      areas.any? do |area|
        p1, p2 = area.kmp3d_settings[5..6].map { |p| p.to_i }
        (([p1, p2].min...[p1, p2].max).include?(c)) ^ (p1 > p2)
      end
    end

    def closest_enpt_height(pos)
      @enpt.sort! { |ent| pos.distance([ent.x, ent.y]) }
      @enpt.first.z
    end

    def angle(pos)
      -Math.atan2(@prev.x - pos.x, @prev.y - pos.y)
    end

    def scale(pos)
      pos.distance(@prev).to_m / 3000 # 3000m is the length of the model
    end

    def change_direction?(pos)
      (@slope * (pos.x - @prev.x) + @prev.y > pos.y) ^ (@prev_angle <= 0)
    end
  end
end
