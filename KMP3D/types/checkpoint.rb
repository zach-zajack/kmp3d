module KMP3D
  class Checkpoint < Type
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

    def enable_combine?
      false
    end

    private

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
