module KMP3D
  class Vector < Type
    def initialize
      @step = 0
      super("vector")
    end

    def transform(comp, pos)
      case @step
      when 0 then comp.transform!(Geom::Transformation.translation(pos))
      when 1
        comp.transform!(Geom::Transformation.rotation(@prev, [0, 0, 1], \
          angle(pos)))
      end
    end

    def advance_steps(pos)
      @prev = pos
      @step += 1
      @step %= 2
      return @step
    end

    def helper_text
      case @step
      when 0 then "(Step 1/2) Click to place the point's position."
      when 1 then "(Step 2/2) Click to place the point's direction."
      end
    end

    private

    def angle(pos)
      Math::PI - Math.atan2(pos.x - @prev.x, pos.y - @prev.y)
    end
  end
end
