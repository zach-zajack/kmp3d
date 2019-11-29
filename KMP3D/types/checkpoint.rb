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

    def model
      Data.load_def("checkpoint")
    end

    def transform(comp, pos)
      case @step
      when 0 then comp.transform!(Geom::Transformation.translation(pos - \
        [0, 1500.m, 0]))
      when 1
        comp.transform!(Geom::Transformation.scaling(@prev, \
          1.0, scale(pos), 1.0))
        comp.transform!(Geom::Transformation.rotation(@prev, [0,0,1], \
          angle(pos)))
      when 2
        return comp unless change_direction?(pos)
        comp.transform!(Geom::Transformation.rotation(@avg, [0,0,1], Math::PI))
      end
    end

    def advance_steps(pos)
      if @step == 1
        @slope = (@prev.y - pos.y)/(@prev.x - pos.x)
        @prev_angle = angle(pos)
        @avg = [(pos.x + @prev.x)/2, (pos.y + @prev.y)/2, (pos.z + @prev.z)/2]
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
      avg = [(pos2.x + pos1.x)/2, (pos2.y + pos1.y)/2]
      avg.z = closest_kmp3d_entity_height(avg)
      comp = Data.entities.add_instance(model, avg)
      comp.transform!(Geom::Transformation.scaling(avg, 1.0, scale(pos2), 1.0))
      comp.transform!(Geom::Transformation.rotation(avg, [0,0,1], angle(pos2)))
      comp.name = "KMP3D #{type_name}(#{group},#{settings * ','})"
      comp.layer = name
    end

    def set_kmp3d_points
      @kmp3d_points = Data.entities.select { |ent| ent.kmp3d_object? }
      @kmp3d_points.map! { |ent| ent.transformation.origin }
    end

    private

    def closest_kmp3d_entity_height(pos)
      sorted = @kmp3d_points.sort do |ent1, ent2|
        pos.distance([ent1.x, ent1.y]) <=> pos.distance([ent2.x, ent2.y])
      end
      sorted.first.z
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
